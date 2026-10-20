# Critic — adversarial PR review

[`critic.yml`](../workflows/critic.yml) asks Claude Opus 5.5 to review pull requests adversarially
and posts the result as a PR comment.

## When it runs

| Condition | Result |
| :-- | :-- |
| `critic` label added to the PR | Runs |
| PR has the `critic` label | Runs on every push |
| PR is a draft | Skipped (runs when marked ready) |
| additions + deletions ≥ `CRITIC_LINE_THRESHOLD` (300) | Runs |
| Anything else | Runs with probability `CRITIC_PROBABILITY` (0.25) |

Reviews use **Claude Opus 5.5** (`claude-opus-5-5`).

Optional: set `CRITIC_MODELS=argon,opus` to pick at random between Opus and **Gemini 4 Argon** (`gemini-4-argon`),
with the other model as fallback if one fails. Argon needs a `GEMINI_API_KEY` on a **paid** AI Studio project:
the free tier has a quota of 0 for Argon (tested 2026-10-20), and Claude is not available through the Gemini API.

## Setup

1. Add the repository secret `ANTHROPIC_API_KEY`: `gh secret set ANTHROPIC_API_KEY`.
2. Optional: override defaults with repository variables (`gh variable set NAME --body VALUE`):

| Variable | Default | Meaning |
| :-- | :-- | :-- |
| `CRITIC_LINE_THRESHOLD` | `300` | Lines changed that always trigger a review |
| `CRITIC_PROBABILITY` | `0.25` | Chance of a spot-check below the threshold (0–1) |
| `CRITIC_MODELS` | `opus` | Models to choose from (`opus`, `argon`, or `argon,opus`) |
| `CRITIC_LABEL` | `critic` | Label that forces a review |
| `CRITIC_IGNORE` | `*.lock,package-lock.json,pnpm-lock.yaml` | Comma-separated globs left out of the diff |
| `CRITIC_MAX_DIFF_CHARS` | `200000` | Diff size sent to the model |
| `CRITIC_ARGON_MODEL` / `CRITIC_OPUS_MODEL` | `gemini-4-argon` / `claude-opus-5-5` | Model IDs |

## Security notes

- The workflow uses the `pull_request` event, so **PRs from forks get no secrets** and the critic skips them.
- The script and prompt are checked out from the **base** commit, so a PR cannot change its own reviewer.
  Changes to the critic take effect after they are merged.
- PR code is never checked out or executed; the diff comes from the GitHub API and is passed to the model
  as untrusted data.

## Files

- [`prompt.md`](prompt.md) — the reviewer's system prompt; edit it to tune the critic.
- [`critic.py`](critic.py) — trigger logic, model calls and commenting (Python standard library only).
- [`test_critic.py`](test_critic.py) — `python3 -m unittest discover -s .github/critic`
