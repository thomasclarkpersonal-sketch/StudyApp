#!/usr/bin/env python3
"""Adversarial PR critic.

Decides whether to review a pull request, picks a random model (Gemini 4 Argon or
Claude Opus 5.5), asks it for an adversarial review of the PR diff, and posts the
result as a PR comment.

Trigger rules (first match wins):
  1. The PR carries the critic label (default ``critic``)        -> always run
  2. The PR is a draft                                            -> skip
  3. additions + deletions >= CRITIC_LINE_THRESHOLD (default 300) -> run
  4. otherwise run with probability CRITIC_PROBABILITY (default 0.25)

Standard library only, so it runs on a bare GitHub runner without installing anything.

Local dry run (no API calls, nothing posted):
    python3 .github/critic/critic.py --event path/to/event.json --dry-run
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import random
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROMPT_FILE = HERE / "prompt.md"
COMMENT_LIMIT = 65_000  # GitHub hard limit is 65,536 characters


@dataclass(frozen=True)
class Model:
    key: str
    label: str
    provider: str  # "gemini" | "anthropic"
    model_id: str
    secret: str


MODELS: dict[str, Model] = {
    "argon": Model(
        key="argon",
        label="Gemini 4 Argon",
        provider="gemini",
        model_id=os.environ.get("CRITIC_ARGON_MODEL") or "gemini-4-argon",
        secret="GEMINI_API_KEY",
    ),
    "opus": Model(
        key="opus",
        label="Claude Opus 5.5",
        provider="anthropic",
        model_id=os.environ.get("CRITIC_OPUS_MODEL") or "claude-opus-5-5",
        secret="ANTHROPIC_API_KEY",
    ),
}


@dataclass(frozen=True)
class Config:
    threshold: int
    probability: float
    label: str
    models: list[str]
    max_diff_chars: int
    ignore: list[str]

    @classmethod
    def from_env(cls) -> "Config":
        def env(name: str, default: str) -> str:
            # Unset repo variables arrive as empty strings in Actions, so treat "" as unset.
            return os.environ.get(name) or default

        models = [m.strip().lower() for m in env("CRITIC_MODELS", "argon,opus").split(",") if m.strip()]
        unknown = [m for m in models if m not in MODELS]
        if unknown:
            raise SystemExit(f"CRITIC_MODELS contains unknown model(s): {unknown}; known: {list(MODELS)}")
        return cls(
            threshold=int(env("CRITIC_LINE_THRESHOLD", "300")),
            probability=min(1.0, max(0.0, float(env("CRITIC_PROBABILITY", "0.25")))),
            label=env("CRITIC_LABEL", "critic"),
            models=models,
            max_diff_chars=int(env("CRITIC_MAX_DIFF_CHARS", "200000")),
            ignore=[p.strip() for p in env("CRITIC_IGNORE", "*.lock,package-lock.json,pnpm-lock.yaml").split(",") if p.strip()],
        )


# --------------------------------------------------------------------------- decision


def decide(event: dict, cfg: Config, rng: random.Random) -> tuple[bool, str]:
    """Return (should_run, human-readable reason). Pure function: easy to unit test."""
    pr = event.get("pull_request")
    if not pr:
        return False, "event has no pull_request payload"

    action = event.get("action", "")
    labels = {lbl.get("name", "") for lbl in pr.get("labels", [])}

    if action == "labeled":
        if event.get("label", {}).get("name") == cfg.label:
            return True, f"`{cfg.label}` label added"
        return False, "unrelated label added"

    if cfg.label in labels:
        return True, f"PR has `{cfg.label}` label"

    if pr.get("draft"):
        return False, "PR is a draft"

    changed = int(pr.get("additions", 0)) + int(pr.get("deletions", 0))
    if changed >= cfg.threshold:
        return True, f"{changed} lines changed (threshold {cfg.threshold})"

    roll = rng.random()
    if roll < cfg.probability:
        return True, f"random spot-check ({changed} lines changed; rolled {roll:.2f} < {cfg.probability:.2f})"
    return False, f"{changed} lines changed (< {cfg.threshold}) and random roll {roll:.2f} >= {cfg.probability:.2f}"


def pick_models(cfg: Config, rng: random.Random) -> list[Model]:
    """Randomly order the configured models that have an API key; first is primary, rest are fallbacks."""
    available = [MODELS[k] for k in cfg.models if os.environ.get(MODELS[k].secret)]
    rng.shuffle(available)
    return available


# --------------------------------------------------------------------------- HTTP helpers


def http(method: str, url: str, headers: dict, body: dict | None = None, timeout: int = 600, raw: bool = False):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers={"content-type": "application/json", **headers})
    attempts = 3
    for attempt in range(1, attempts + 1):
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                payload = resp.read().decode()
                return payload if raw else json.loads(payload or "null")
        except urllib.error.HTTPError as e:
            detail = e.read().decode(errors="replace")[:2000]
            if e.code in (429, 500, 502, 503, 504, 529) and attempt < attempts:
                time.sleep(10 * attempt)
                continue
            raise RuntimeError(f"{method} {url.split('?')[0]} -> HTTP {e.code}: {detail}") from None
        except (urllib.error.URLError, TimeoutError) as e:
            if attempt < attempts:
                time.sleep(10 * attempt)
                continue
            raise RuntimeError(f"{method} {url.split('?')[0]} failed: {e}") from None


class GitHub:
    def __init__(self, repo: str, token: str):
        self.base = (os.environ.get("GITHUB_API_URL") or "https://api.github.com").rstrip("/")
        self.repo = repo
        self.headers = {
            "authorization": f"Bearer {token}",
            "accept": "application/vnd.github+json",
            "x-github-api-version": "2022-11-28",
        }

    def pr_files(self, number: int) -> list[dict]:
        files, page = [], 1
        while True:
            batch = http("GET", f"{self.base}/repos/{self.repo}/pulls/{number}/files?per_page=100&page={page}", self.headers)
            files.extend(batch)
            if len(batch) < 100 or page >= 30:  # API caps at 3000 files
                return files
            page += 1

    def comment(self, number: int, body: str) -> str:
        res = http("POST", f"{self.base}/repos/{self.repo}/issues/{number}/comments", self.headers, {"body": body})
        return res.get("html_url", "")


def build_diff(files: list[dict], cfg: Config) -> tuple[str, list[str]]:
    """Assemble a unified-ish diff from the PR files API, honouring ignore globs and the size budget."""
    parts, skipped, used = [], [], 0
    for f in files:
        name = f.get("filename", "?")
        if any(fnmatch.fnmatch(name, pat) or fnmatch.fnmatch(Path(name).name, pat) for pat in cfg.ignore):
            skipped.append(f"{name} (ignored)")
            continue
        header = f"--- {f.get('previous_filename', name)}\n+++ {name}  [{f.get('status')}, +{f.get('additions')}/-{f.get('deletions')}]\n"
        patch = f.get("patch")
        chunk = header + (patch if patch else "(patch not available: binary or too large)") + "\n"
        if used + len(chunk) > cfg.max_diff_chars:
            skipped.append(f"{name} (over size budget)")
            continue
        parts.append(chunk)
        used += len(chunk)
    return "".join(parts), skipped


# --------------------------------------------------------------------------- model calls


def call_gemini(model: Model, system: str, user: str) -> str:
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model.model_id}:generateContent"
    headers = {"x-goog-api-key": os.environ[model.secret]}
    body = {
        "systemInstruction": {"parts": [{"text": system}]},
        "contents": [{"role": "user", "parts": [{"text": user}]}],
        "generationConfig": {"maxOutputTokens": 32768, "thinkingConfig": {"thinkingLevel": "high"}},
    }
    try:
        res = http("POST", url, headers, body)
    except RuntimeError as e:
        if "HTTP 400" not in str(e):
            raise
        body["generationConfig"].pop("thinkingConfig")  # model may not accept thinking config; retry plain
        res = http("POST", url, headers, body)
    parts = (res.get("candidates") or [{}])[0].get("content", {}).get("parts", [])
    text = "".join(p.get("text", "") for p in parts if not p.get("thought"))
    if not text.strip():
        raise RuntimeError(f"Gemini returned no text: {json.dumps(res)[:1000]}")
    return text


def call_anthropic(model: Model, system: str, user: str) -> str:
    headers = {"x-api-key": os.environ[model.secret], "anthropic-version": "2023-06-01"}
    body = {
        "model": model.model_id,
        "max_tokens": 16000,
        "system": system,
        "messages": [{"role": "user", "content": user}],
    }
    res = http("POST", "https://api.anthropic.com/v1/messages", headers, body)
    text = "".join(b.get("text", "") for b in res.get("content", []) if b.get("type") == "text")
    if not text.strip():
        raise RuntimeError(f"Anthropic returned no text: {json.dumps(res)[:1000]}")
    return text


def review(model: Model, system: str, user: str) -> str:
    return (call_gemini if model.provider == "gemini" else call_anthropic)(model, system, user)


# --------------------------------------------------------------------------- main


def summary(line: str) -> None:
    print(line)
    path = os.environ.get("GITHUB_STEP_SUMMARY")
    if path:
        with open(path, "a", encoding="utf-8") as fh:
            fh.write(line + "\n\n")


def build_user_prompt(pr: dict, diff: str, skipped: list[str]) -> str:
    skipped_note = ("\nFiles not shown: " + ", ".join(skipped)) if skipped else ""
    return (
        f"Pull request #{pr.get('number')}: {pr.get('title', '')}\n"
        f"Base: {pr.get('base', {}).get('ref')}  Head: {pr.get('head', {}).get('ref')}\n"
        f"Size: +{pr.get('additions')}/-{pr.get('deletions')} across {pr.get('changed_files')} files{skipped_note}\n\n"
        "<untrusted_pr_description>\n"
        f"{(pr.get('body') or '(no description)')[:10000]}\n"
        "</untrusted_pr_description>\n\n"
        "<untrusted_diff>\n"
        f"{diff or '(empty diff)'}\n"
        "</untrusted_diff>\n"
    )


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--event", default=os.environ.get("GITHUB_EVENT_PATH"), help="path to the GitHub event JSON")
    ap.add_argument("--dry-run", action="store_true", help="decide and pick a model, but call no APIs")
    args = ap.parse_args()
    if not args.event:
        ap.error("--event is required outside GitHub Actions")

    event = json.loads(Path(args.event).read_text(encoding="utf-8"))
    cfg = Config.from_env()
    seed = os.environ.get("CRITIC_SEED")
    rng = random.Random(seed) if seed else random.SystemRandom()

    run, reason = decide(event, cfg, rng)
    if not run:
        summary(f"⏭️ Critic skipped: {reason}.")
        return 0

    models = pick_models(cfg, rng)
    if args.dry_run:
        order = " → ".join(m.label for m in models) or "(no API keys set)"
        summary(f"🧪 Dry run: critic would run ({reason}); model order: {order}.")
        return 0
    if not models:
        # Normal for PRs from forks: secrets are not exposed to them.
        summary(f"⚠️ Critic wanted to run ({reason}) but no API keys are available "
                f"({', '.join(MODELS[k].secret for k in cfg.models)}). Skipping.")
        return 0

    pr = event["pull_request"]
    gh = GitHub(os.environ["GITHUB_REPOSITORY"], os.environ["GITHUB_TOKEN"])
    diff, skipped = build_diff(gh.pr_files(pr["number"]), cfg)
    system = PROMPT_FILE.read_text(encoding="utf-8")
    user = build_user_prompt(pr, diff, skipped)

    errors: list[str] = []
    for model in models:
        try:
            print(f"Requesting review from {model.label} ({model.model_id})…")
            text = review(model, system, user)
            break
        except Exception as e:  # noqa: BLE001 - fall back to the next model on any failure
            errors.append(f"{model.label}: {e}")
            print(f"::warning::{model.label} failed: {e}")
    else:
        summary("❌ Critic failed on every model:\n\n" + "\n".join(f"- {e}" for e in errors))
        return 1

    sha = pr.get("head", {}).get("sha", "")[:7]
    fallback = f" (fallback after: {'; '.join(e.split(':')[0] for e in errors)})" if errors else ""
    header = (
        "## 🧐 Critic review\n"
        f"<sub>Model: **{model.label}** (`{model.model_id}`){fallback} · Trigger: {reason} · Commit: `{sha}`</sub>\n\n"
    )
    footer = (
        "\n\n---\n<sub>Automated adversarial review: findings may be wrong, verify before acting. "
        f"Add the `{cfg.label}` label to request a review on every push.</sub>"
    )
    body = header + text.strip()
    if len(body) + len(footer) > COMMENT_LIMIT:
        body = body[: COMMENT_LIMIT - len(footer) - 40] + "\n\n…(truncated)"
    url = gh.comment(pr["number"], body + footer)
    summary(f"✅ Critic review by {model.label} posted ({reason}): {url}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
