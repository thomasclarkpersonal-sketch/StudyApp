# Critic — adversarial PR review

[`workflows/critic.yml`](workflows/critic.yml) runs Claude Code (Claude Opus 5.5) on pull requests to perform the
review defined in [`.claude/commands/critic.md`](../.claude/commands/critic.md), and posts the result as one PR
comment that is updated on every push. The same file works locally as the `/critic` command in Claude Code.

## When it runs

A same-repository, non-draft PR is reviewed when **any** of these is true:

| Trigger | Default | Override (repository variable) |
| :-- | :-- | :-- |
| Lines changed (additions + deletions) | ≥ 300 | `CRITIC_MIN_LINES` |
| Files changed | ≥ 20 | `CRITIC_MIN_FILES` |
| It changes a contract file (protocol, catalog, `critic.md`, `critic.yml`, `CRITIC.md`, `AGENTS.md`, `CLAUDE.md`), or any `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, `.mcp.json` or `.claude/` path at any depth, including renames away | always | — |
| Random sample, drawn once per PR number | 1 in 4 | `CRITIC_SAMPLE_ONE_IN` |
| The PR has the `critic` label | always | — |

Example: `gh variable set CRITIC_SAMPLE_ONE_IN --body 10`.

## Findings

| Tier | Effect |
| :-- | :-- |
| 🚨 CRITICAL | Fails the **Critic** check. |
| ⚠️ DEBT | Warning, re-reported on every push until fixed or waived by a maintainer comment `critic-waive: <finding title>, <reason>`. |
| 💡 SUGGESTION | Optional. |

The critic judges a PR against the base branch's copies of the contract files, so a PR cannot change the rules it is
judged by. Before the review, every `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, `.mcp.json` and `.claude/` directory (at any depth) is reset to
the base branch's copies (symlinks included), so Claude Code in CI does not load a PR's instructions, settings or
hooks. Weakening an existing rule is CRITICAL unless a maintainer adds the `contract-change` label.
If the critic errors or writes no report, the check fails (fail-closed); re-run the job.

## Setup (one time)

1. **Claude subscription token.** In Claude Code, inside this repo, run `/install-github-app`.
   It installs the Claude GitHub App on the repo (not strictly needed: the critic uses the job's own token) and stores the `CLAUDE_CODE_OAUTH_TOKEN` secret; usage counts
   against the installing user's Claude subscription. If it pushes an `add-claude-github-actions-…` branch with
   its own workflows, delete that branch: this repo only uses `critic.yml`.
   - Manual alternative: run `claude setup-token`, then `gh secret set CLAUDE_CODE_OAUTH_TOKEN`.
   - Fallback: if `CLAUDE_CODE_OAUTH_TOKEN` is not set, the critic uses the `ANTHROPIC_API_KEY` secret
     (billed per token; set a spend limit in the Anthropic console).
2. **Labels** (already created): `critic`, `contract-change`.
3. **Block merges on CRITICAL findings** (done): the `Protect main` ruleset (Settings → Rules → Rulesets) requires a pull
   request and the **Critic** status check for `main`. A repository admin can bypass it when merging a PR. Keep it in
   place: `AGENTS.md` relies on it.

## Security notes

- **Trust boundary:** the workflow uses the `pull_request` event, so `critic.yml` itself runs from the PR. A PR that edits
  it always triggers the critic, but it could also change how it is reviewed, so its green check is not proof of a
  base-branch review: review changes to `critic.yml` by hand before merging.

- Fork PRs and drafts are skipped: forks receive no secrets.
- The critic's job token is read-only for code (`contents: read`); Claude may only read files, run read-only `git`
  commands and write its report.
- The only PR conversation the critic sees is `critic-waive` lines from people with write access, so comments
  cannot steer the review.
