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
| It changes the contract (protocol, catalog or `critic.md`) | always | — |
| Random sample, drawn once per PR number | 1 in 4 | `CRITIC_SAMPLE_ONE_IN` |
| The PR has the `critic` label | always | — |

Example: `gh variable set CRITIC_SAMPLE_ONE_IN --body 10`.

## Findings

| Tier | Effect |
| :-- | :-- |
| 🚨 CRITICAL | Fails the **Critic** check. |
| ⚠️ DEBT | Warning, re-reported on every push until fixed or waived by a maintainer comment `critic-waive: <finding title>, <reason>`. |
| 💡 SUGGESTION | Optional. |

The critic judges a PR against `main`'s copies of the protocol, the catalog and `critic.md`, so a PR cannot change the
rules it is judged by. Weakening an existing rule is CRITICAL unless a maintainer adds the `contract-change` label.
If the critic errors or writes no report, the check fails (fail-closed); re-run the job.

## Setup (one time)

1. **Claude subscription token and GitHub App.** In Claude Code, inside this repo, run `/install-github-app`.
   It installs the Claude GitHub App on the repo and stores the `CLAUDE_CODE_OAUTH_TOKEN` secret; usage counts
   against the installing user's Claude subscription. If it pushes an `add-claude-github-actions-…` branch with
   its own workflows, delete that branch: this repo only uses `critic.yml`.
   - Manual alternative: install https://github.com/apps/claude on this repository only, run `claude setup-token`,
     then `gh secret set CLAUDE_CODE_OAUTH_TOKEN`.
   - To bill an API key instead, see the comment above `claude_code_oauth_token` in `critic.yml`.
2. **Labels** (already created): `critic`, `contract-change`.
3. **Optional, to block merges on CRITICAL findings:** once the critic has run at least once, add a branch ruleset
   for `main` (Settings → Rules → Rulesets) that requires the **Critic** status check.

## Security notes

- Fork PRs and drafts are skipped: forks receive no secrets.
- The critic's job token is read-only for code (`contents: read`); Claude may only read files, run read-only `git`
  commands and write its report.
- The only PR conversation the critic sees is `critic-waive` lines from people with write access, so comments
  cannot steer the review.
