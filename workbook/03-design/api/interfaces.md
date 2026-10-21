# A34 · Interface Contracts

- **Artifact ID:** `A34`
- **Stage:** Stage 3 — Architecture & Design
- **Owner:** System Architect
- **Date:** `2026-10-21`
- **Catalog entry:** `A34` (`systems_analysis_and_design_project_framework.md`, `INT` risk flag)
- **Machine-readable specifications:**
  - OpenAPI 3.1.0 REST & SSE Contract: [`workbook/03-design/api/openapi.yaml`](openapi.yaml)
  - JSON Schema Draft 2020-12 Pipeline & Feedback Contracts: [`workbook/03-design/api/schemas/pipeline-contracts.schema.json`](schemas/pipeline-contracts.schema.json)

---

## 1. Study App HTTP & SSE Operations (`openapi.yaml`, `G3.4`)

All 38 HTTP operations defined in [`openapi.yaml`](openapi.yaml) use a single RFC 9457 Problem Details error model (`application/problem+json`, `#/components/schemas/ProblemDetails`), trace to requirements and use cases (`G3.4`), and appear in the `A36` Authorization Matrix (`A36 §4`):

| # | `operationId` | Method & Path | `REQ` / `UC` Trace | Required Role (`A36`) | Idempotency / Pagination | Success | Error Statuses (`application/problem+json`) |
| :-- | :-- | :-- | :-- | :-- | :-- | :-: | :-- |
| 1 | `getHealth` | `GET /api/health` | `REQ-N-008`, `REQ-N-015` | Public (`R1`–`R3`) | Safe `GET` | `200` | `503` (DB unavailable) |
| 2 | `loginOwner` | `POST /api/auth/login` | `UC-18`, `REQ-F-059`, `REQ-N-015`, `BR-045` | Public $\rightarrow$ `Student` | Rate-limited (`<= 5`/min/IP) | `200` | `400`, `401` (bad password), `429` (rate limit) |
| 3 | `logoutOwner` | `POST /api/auth/logout` | `UC-18`, `REQ-F-059`, `BR-045` | `Student` | Idempotent session revoke | `204` | `401` |
| 4 | `listModules` | `GET /api/modules` | `UC-06`–`10`, `REQ-F-021`, `REQ-F-038`, `BR-005` | `Student` | Safe `GET` | `200` | `401` |
| 5 | `getModuleSummary` | `GET /api/modules/{moduleId}` | `UC-08`, `UC-15`, `UC-17`, `REQ-F-005`, `REQ-F-053`, `REQ-F-058` | `Student` | Safe `GET` | `200` | `401`, `404` |
| 6 | `previewModuleImport` | `POST /api/import/preview` | `UC-06`, `REQ-F-021`, `REQ-N-020`, `DT-02` | `Student` | Read-only dry run | `200` | `400`, `401`, `422` (schema / `BR-017` / `BR-020` error) |
| 7 | `applyModuleImport` | `POST /api/import/apply` | `UC-06`, `REQ-F-021`, `REQ-F-022`, `REQ-N-011`, `REQ-N-020`, `DT-02`, `BR-021`–`024` | `Student` | `Idempotency-Key` header | `200` | `400`, `401`, `409`, `422` |
| 8 | `getNextReviewCards` | `GET /api/review/next` | `UC-07`, `REQ-F-023`–`027`, `REQ-N-002`, `BR-025` | `Student` | Query `limit` (`1..200`) | `200` | `400`, `401` |
| 9 | `submitCardRating` | `POST /api/review/{cardId}/rate` | `UC-07`, `REQ-F-023`, `REQ-N-001`, `REQ-N-010`, `BR-026`, `BR-027` | `Student` | `Idempotency-Key` header | `200` | `400`, `401`, `404` |
| 10 | `updateCardStateOrContent` | `PATCH /api/cards/{cardId}` | `UC-07`, `REQ-F-025` | `Student` | Idempotent `PATCH` | `200` | `400`, `401`, `404` |
| 11 | `getNextQuizQuestions` | `GET /api/quiz/next` | `UC-08`, `UC-15`, `REQ-F-028`–`031`, `REQ-F-053`, `REQ-N-002`, `DT-03` | `Student` | Query `limit` (`1..50`) | `200` | `400`, `401` |
| 12 | `submitQuizAttempt` | `POST /api/quiz/{questionId}/attempt` | `UC-08`, `UC-12`, `UC-18`, `REQ-F-032`–`034`, `REQ-F-043`, `REQ-F-047`, `REQ-F-048`, `REQ-F-061`, `REQ-N-004`, `DT-04` | `Student` | `Idempotency-Key` header | `200` | `400`, `401`, `404`, `422`, `502` (Claude timeout $\rightarrow$ self-mark fallback) |
| 13 | `overrideQuizAttemptRating` | `PATCH /api/quiz/attempts/{attemptId}` | `UC-08`, `UC-12`, `REQ-F-044`, `BR-031` | `Student` | Idempotent `PATCH` | `200` | `400`, `401`, `404` |
| 14 | `flushOfflineQuizQueue` | `POST /api/quiz/offline-sync` | `UC-18`, `REQ-F-060`, `REQ-F-061`, `REQ-N-009` | `Student` | `Idempotency-Key` + `eventId` dedup | `200` | `400`, `401` |
| 15 | `startMockExam` | `POST /api/exams/mock` | `UC-15`, `REQ-F-054`, `BR-018`, `BR-043` | `Student` | Creates exam session | `201` | `400`, `401`, `404` |
| 16 | `submitMockExam` | `POST /api/exams/mock/{examId}/submit` | `UC-15`, `REQ-F-054` | `Student` | Idempotent per `examId` | `200` | `400`, `401`, `404` |
| 17 | `listDeadlines` | `GET /api/deadlines` | `UC-09`, `REQ-F-035`, `REQ-F-037`, `REQ-N-018`, `DT-05` | `Student` | Safe `GET` | `200` | `401` |
| 18 | `upsertDeadline` | `PUT /api/deadlines/{deadlineId}` | `UC-09`, `REQ-F-036`, `REQ-F-037`, `BR-004`, `BR-023` | `Student` | Idempotent `PUT` | `200` | `400`, `401`, `422` (`weighting` out of `0..100`) |
| 19 | `upsertMilestone` | `PUT /api/deadlines/{deadlineId}/milestones/{milestoneId}` | `UC-16`, `REQ-F-056` | `Student` | Idempotent `PUT` | `200` | `400`, `401`, `404` |
| 20 | `listReadings` | `GET /api/readings` | `UC-03`, `UC-10`, `REQ-F-005`, `REQ-F-041` | `Student` | Safe `GET` | `200` | `401` |
| 21 | `updateReadingStatus` | `PATCH /api/readings/{readingId}` | `UC-10`, `REQ-F-041` | `Student` | Idempotent `PATCH` | `200` | `400`, `401`, `404` |
| 22 | `upsertTask` | `PUT /api/tasks/{taskId}` | `UC-10`, `REQ-F-038` | `Student` | Idempotent `PUT` | `200` | `400`, `401` |
| 23 | `getTodayPlan` | `GET /api/today` | `UC-10`, `UC-16`, `REQ-F-038`–`041`, `REQ-F-053`, `REQ-F-055`, `REQ-F-056`, `REQ-N-003`, `DT-06` | `Student` | Safe `GET` | `200` | `400`, `401` |
| 24 | `updateTodayPlanItem` | `PATCH /api/today/items/{itemId}` | `UC-10`, `UC-16`, `REQ-F-040`, `REQ-F-055` | `Student` | Idempotent `PATCH` | `200` | `400`, `401`, `404` |
| 25 | `reportStudyItem` | `POST /api/feedback/report` | `UC-11`, `REQ-F-042`, `BR-038` | `Student` | Idempotent per open `(itemType, itemId, reason)` | `201` | `400`, `401`, `404` |
| 26 | `exportFeedbackJson` | `GET /api/export/feedback` | `UC-11`, `UC-19`, `REQ-F-042`, `REQ-F-063`, `REQ-N-020` | `Student` | Query `limit` (`1..1000`) | `200` | `400`, `401` |
| 27 | `listTutorThreads` | `GET /api/tutor/threads` | `UC-13`, `REQ-F-045`, `REQ-F-052` | `Student` | Paginated (`limit`, `offset`) | `200` | `401` |
| 28 | `createTutorThread` | `POST /api/tutor/threads` | `UC-13`, `REQ-F-045` | `Student` | Creates thread | `201` | `400`, `401`, `404` |
| 29 | `sendTutorMessage` | `POST /api/tutor/threads/{threadId}/messages` | `UC-13`, `REQ-F-046`–`048`, `REQ-F-051`, `REQ-N-005`, `REQ-N-023`, `BR-039`–`041` | `Student` | `Idempotency-Key` header | `200` (`SSE`) | `400`, `401`, `404`, `422` (`BR-040` coursework refusal), `429` (`BR-041` spend cap), `502` |
| 30 | `deleteTutorThread` | `DELETE /api/tutor/threads/{threadId}` | `UC-13`, `REQ-F-052`, `ASM-023` | `Student` | Idempotent `DELETE` | `204` | `401`, `404` |
| 31 | `reviewTutorProposal` | `PATCH /api/proposals/{proposalId}` | `UC-14`, `REQ-F-049`, `BR-042` | `Student` | Idempotent `PATCH` | `200` | `400`, `401`, `404` |
| 32 | `getStatsAndSpend` | `GET /api/stats` | `UC-17`, `UC-20`, `REQ-F-048`, `REQ-F-058`, `REQ-F-065`, `BR-041`, `BR-044` | `Student` | Safe `GET` | `200` | `401` |
| 33 | `getSettings` | `GET /api/settings` | `UC-10`, `UC-16`, `UC-17`, `REQ-F-026`, `REQ-F-039`, `REQ-F-048`, `REQ-F-062` | `Student` | Safe `GET` | `200` | `401` |
| 34 | `updateSettings` | `PATCH /api/settings` | `UC-10`, `UC-16`, `UC-17`, `UC-18`, `REQ-F-026`, `REQ-F-039`, `REQ-F-048`, `REQ-F-055`, `REQ-F-062` | `Student` | Idempotent `PATCH` | `200` | `400`, `401`, `422` |
| 35 | `exportCalendarIcs` | `GET /api/calendar.ics` | `UC-16`, `REQ-F-057` | `Student` | Safe `GET` (`text/calendar`) | `200` | `400`, `401` |
| 36 | `exportAnkiTsv` | `GET /api/export/anki.tsv` | `UC-21`, `REQ-F-066` | `Student` | Safe `GET` (`text/tab-separated-values`) | `200` | `400`, `401` |
| 37 | `createDatabaseBackup` | `POST /api/backup/create` | `UC-06`, `REQ-N-011`, `BR-024` | `Student` | Creates verified snapshot | `201` | `401`, `503` (disk full) |
| 38 | `restoreDatabaseBackup` | `POST /api/backup/restore` | `UC-06`, `REQ-N-011`, `UDP-04` | `Student` | Requires `confirmOverwrite: true` | `200` | `400`, `401`, `404` |

---

## 2. Pipeline CLI Command Reference (`pipeline-cli`, `ADR-004`)

The generation pipeline's deterministic helper CLI (`packages/pipeline/src/cli/index.ts`) exposes **7 subcommands** invoked by the student and Claude Code slash commands (`.claude/commands/pipeline-*.md`). Every CLI command outputs structured JSON or human-readable summaries on `stdout`, writes RFC 9457-equivalent JSON diagnostics on `stderr` on error, and returns a deterministic POSIX exit code (`0` = success, `1` = validation/domain rule failure, `2` = CLI usage/argument error, `3` = external I/O or rate-limit interruption with resume command).

| # | Command (`operationId`) | Arguments & Options | `REQ` / `UC` / `BR` Trace | Required Role | Output & Error Handling |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `CLI-01` | `pipeline-cli sync-canvas` | `--module <id> [--config <path>] [--offline]` | `UC-03`, `REQ-F-002`, `REQ-N-013`, `REQ-N-014`, `REQ-N-016`, `BR-001`, `BR-002` | `Pipeline CLI Operator` (`Student`) | Syncs allowlisted read-only Canvas endpoints (`ADR-005`) into `<workspace>/source/canvas/`. On `401`/`403`/timeout or `--offline`, logs warning and exits `0` using local files (`UC-03 ext 2a`). Exits `1` if `0` local or Canvas files exist (`AT-031`). |
| `CLI-02` | `pipeline-cli extract-lecture` | `--module <id> --week <Wnn> --pdf <path> [--dpi 150]` | `UC-01`, `UC-03`, `REQ-F-001`, `REQ-F-003`–`005`, `REQ-F-007`, `REQ-N-014`, `BR-001`, `BR-007` | `Pipeline CLI Operator` (`Student`) | Renders slide PNGs (`pdftoppm`), extracts text (`pypdf`), recovers embedded `LaTeXiT` equations (`ASM-046`), classifies visual slides, and writes `<workspace>/lectures/<Wnn>/ingested-slides.json` wrapped in `<untrusted_course_material>`. Exits `1` on corrupt/unreadable PDF. |
| `CLI-03` | `pipeline-cli plan-run` | `[--workspace <dir>] [--resume]` | `UC-04`, `REQ-F-006`, `REQ-F-019`, `BR-003`, `BR-005`, `BR-015` | `Pipeline CLI Operator` (`Student`) | Orders modules (CS first, `BR-005`) and lectures (nearest assessment `covers_lectures` first) and prints the ordered execution plan and resume command if interrupted (`AT-033`). |
| `CLI-04` | `pipeline-cli build-reviewer-bundle` | `--module <id> --week <Wnn> --stage <card\|question> --round <1\|2\|3>` | `UC-01`, `UC-02`, `UC-14`, `REQ-F-009`, `REQ-F-013`, `REQ-F-050`, `REQ-N-012`, `BR-012`, `BR-042` | `Pipeline CLI Operator` (`Student`) | Builds `<workspace>/lectures/<Wnn>/reviewer-input.r<n>.json` containing **only** candidate items, `ingested-slides.json`, slide PNG paths, and `glossary.json` (`0` Creator notes or prior reviews). Exits `1` if `glossary.json` is missing (`BR-003`) or Stage A `concept-map.json` is incomplete before Stage B (`BR-015`). |
| `CLI-05` | `pipeline-cli apply-verdicts` | `--module <id> --week <Wnn> --stage <card\|question> --round <1\|2\|3>` | `UC-01`, `UC-02`, `UC-14`, `UC-19`, `REQ-F-008`–`016`, `REQ-F-050`, `REQ-F-064`, `DT-01`, `BR-011`–`014` | `Pipeline CLI Operator` (`Student`) | Validates `*-review.round<n>.json` against `ReviewRoundFile` schema (`Ajv`) and executes `DT-01`: freezes `accept` items into `*.final.json`, removes `reject` items in rounds `1`–`2` (`DT-01-R3`), emits `revise` delta for round `r + 1` (`DT-01-R2`), and moves round-3 failures to `flagged.json` (`DT-01-R4, R5`). |
| `CLI-06` | `pipeline-cli spot-check-and-export` | `--module <id> [--non-interactive-decisions <path>]` | `UC-05`, `REQ-F-017`–`020`, `REQ-N-006`, `REQ-N-020`, `REQ-N-022`, `BR-019`, `BR-020` | `Pipeline CLI Operator` (`Student`) | Presents `flagged.json`, `inferred` items, and a `10%` random sample of accepted items (`AT-035`: warns if `> 20%` rejected), validates all 6 output files against `pipeline-contracts.schema.json` (`Ajv`), and writes `<workspace>/export/{concepts,deck,question-bank,deadlines,readings,glossary}.json` + `run-summary.json` (`RPT-05`). Exits `1` on any schema violation (`AT-036`). |
| `CLI-07` | `pipeline-cli clean-rounds` | `--module <id>` | `UC-05`, `REQ-N-017`, `ASM-024` | `Pipeline CLI Operator` (`Student`) | Purges intermediate `*.round*.json` and `reviewer-input.r*.json` files for a completed module while preserving `export/*.json`, `flagged.json`, `module-audit.json`, and `run-summary.json` (`TC-I-N17`). |

---

## 3. Versioning, Idempotency, and Rate-Limiting Policy (`A34`)

1. **Contract Versioning:**
   - All HTTP routes live under `/api/` (`v1.0.0` in `openapi.yaml`).
   - All 6 pipeline JSON export files and `feedback.json` include a top-level `"version": "1.0"` field checked by `Ajv` (`pipeline-contracts.schema.json`). Any breaking change to a JSON export file increments `"version"` and requires a `CR-nnn` (`A70`).
2. **Idempotency for Unsafe Retryable Operations:**
   - `submitCardRating`, `submitQuizAttempt`, `applyModuleImport`, `sendTutorMessage`, and `flushOfflineQuizQueue` accept an optional `Idempotency-Key: <uuid>` header (and `eventId` in offline queues). An in-memory / SQLite deduplication cache (`24 h` TTL) returns the original response if the same key is retried, preventing duplicate `CardReviewLog` or `QuestionAttempt` rows on flaky mobile connections in `R3` (`REQ-N-009`).
3. **Rate Limits:**
   - `POST /api/auth/login` (`loginOwner`): `<= 5` failed attempts per `60 s` sliding window per client IP (`429 Too Many Requests`, `Retry-After: 60`, `REQ-N-015`).
   - Claude API endpoints (`submitQuizAttempt` with `grader="claude"`, `sendTutorMessage`): bounded by `Settings.monthly_spend_cap_micro_usd` (`429 Too Many Requests` when `spend_cap_mode = "hard_stop"`, `BR-041`).

---

## 4. External Integration Contracts (`INT` Flag — `A34.3`)

| Integration ID | External System (`A11`) | Protocol & Format | Timeout & Retry Policy | Failure & Fallback Handling (`G2.12`, `A34`) | Contract Test (`A39`) |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `INT-01` | **Pipeline $\leftrightarrow$ Study App File Exchange** (`D8`, `D9`) | UTF-8 JSON files validated against [`pipeline-contracts.schema.json`](schemas/pipeline-contracts.schema.json) (`ConceptsFile`, `DeckFile`, `QuestionBankFile`, `DeadlinesFile`, `ReadingsFile`, `GlossaryFile`, `FeedbackFile`). | Local disk / HTTP multipart upload (`<= 10 MB` payload limit, `10,000 ms` timeout). | If any file fails `Ajv` schema validation, `previewModuleImport` / `applyModuleImport` aborts before opening a DB write transaction and returns `422 Unprocessable Entity` with field-level `errors[]` (`AT-036`, `AT-037`). | `TC-I-166`, `TC-I-167` |
| `INT-02` | **Anthropic Claude API** (`E3`, `R2` Marking & Tutor) | HTTPS `POST https://api.anthropic.com/v1/messages` via `@anthropic-ai/sdk` with `anthropic-version: 2023-06-01` and ephemeral prompt caching (`cache_control: { type: "ephemeral" }`) on module glossary + slide text (`REQ-F-047`). | - Marking (`submitQuizAttempt`): `10,000 ms` timeout (`REQ-N-004`), `1` retry on `502`/`503`/`529` (`500 ms` backoff).<br>- Tutor (`sendTutorMessage`): `3,000 ms` first-token timeout (`REQ-N-005`), `30,000 ms` total stream timeout. | - On timeout, `429`, `5xx`, or `hard_stop` spend cap during quiz marking: returns `502`/`422` with `selfMarkFallbackAvailable: true` so the student can self-mark against `model_answer` and `marking_points` without losing their typed answer (`UC-12 ext 3a, 3b`).<br>- Offline in `R3`: queues attempt with `grader = "pending_claude"` (`REQ-F-061`). | `TC-I-168`, `TC-I-169` |
| `INT-03` | **HKUST Canvas LMS REST API** (`E4`, `DEC-009`, `ADR-005`) | HTTPS `GET https://canvas.ust.hk/api/v1/courses/:course_id/...` with `Authorization: Bearer <CANVAS_API_TOKEN>`. Strictly limited to the 6 allowlisted `GET` endpoints in `ADR-005 §2.2`. | `10,000 ms` per-request timeout; up to `2` retries with exponential backoff (`1,000 ms`, `3,000 ms`) on `429` or `502`/`503`/`504`, respecting `Retry-After`. | On `401`/`403`, network error, or disallowed endpoint, `pipeline-cli sync-canvas` logs a clear diagnostic warning and falls back automatically to reading local files in `<workspace>/source/` (`UC-03 ext 2a`, `RSK-014`). | `TC-I-170`, `TC-I-171` |
| `INT-04` | **External Calendar Apps** (`E5`, RFC 5545 `.ics` Feed) | `GET /api/calendar.ics` returning `text/calendar; charset=utf-8` (`VCALENDAR` `VERSION:2.0`, `PRODID:-//StudyApp//EN`, `VEVENT` per confirmed/inferred `Deadline` with `due_at != null` and per `Milestone`). | Synchronous local generation (`< 50 ms`, `ical-generator`). | Unannounced deadlines (`due_at == null`, `BR-004`) are excluded from `VEVENT` items so calendar parsers never fail on missing `DTSTART`. | `TC-I-172` |
| `INT-05` | **Anki Desktop / Mobile** (`E6`, `R3` TSV Export) | `GET /api/export/anki.tsv` returning `text/tab-separated-values; charset=utf-8` with header `#separator:tab\n#html:true` and rows `front<TAB>back_with_extra<TAB>space_separated_tags` (`REQ-F-066`). | Synchronous local generation (`< 100 ms`). | Embedded tabs and newlines in card fields are escaped (`\t` $\rightarrow$ space, `\n` $\rightarrow$ `<br>`) and LaTeX `$...$` / `$$...$$` is converted to Anki MathJax `\(...\)` / `\[...\]`. | `TC-I-173` |
