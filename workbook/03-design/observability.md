# A38 · Observability & SLOs

Owner: System Architect. Stage 3, written 2026-10-21. Catalog entry: A38 (`03-design/observability.md`, tailored as **Reduced** in `A04 §5`: SLOs from every performance and availability `REQ-N`, structured logging standard with strict redaction, spend and usage metrics, in-app/CLI alert rules linked to `A63` runbook entries, and error-budget policy for `A71`; no external distributed-tracing or third-party paging service, per `R3` proportionality).

---

## 1. Service Level Objectives (`SLO-01`–`SLO-09`, `A38.1`, `A71.2`)

Every performance, scalability, and availability requirement in `A10` (`REQ-N-001`–`REQ-N-009`) maps to a Service Level Objective (`SLO-01`–`SLO-09`) with a concrete Service Level Indicator (SLI), target, measurement window, error-budget policy (`A71`), and alert rule (`ALT-01`–`ALT-06`).

| SLO ID | `REQ-N` Trace | Indicator (SLI) & Data Source | Target | Measurement Window | Error-Budget Policy (`A71`) | Linked Alert & `A63` Runbook |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| `SLO-01` | `REQ-N-001` | **Card flip & rating latency:** `p95` duration of `POST /api/review/{cardId}/rate` (`submitCardRating`) + client state transition, recorded in structured request log (`duration_ms`). | `p95 <= 100 ms` (`>= 95%` of requests `<= 100 ms`) | Rolling 30 days (and per-release `TC-S-001` [alias `TC-S-N01`] benchmark) | If `< 95%` of ratings complete within `100 ms` over 200 reviews, freeze feature additions on `M03` and run SQLite `EXPLAIN QUERY PLAN` / index remediation (`RB-01`). | `ALT-01` $\rightarrow$ `RB-01` (`A63`) |
| `SLO-02` | `REQ-N-002` | **Next card / quiz question fetch latency:** `p95` duration of `GET /api/review/next` and `GET /api/quiz/next`, recorded in structured request log (`duration_ms`). | `p95 <= 300 ms` (`>= 95%` of requests `<= 300 ms`) | Rolling 30 days (and `TC-S-002` [alias `TC-S-N02`] benchmark) | If `p95 > 300 ms`, inspect `IDX-01`–`IDX-09` usage and query plans before merging further slice changes (`RB-01`). | `ALT-01` $\rightarrow$ `RB-01` (`A63`) |
| `SLO-03` | `REQ-N-003` | **Today checklist load & generation latency:** `p95` duration of `GET /api/today` (`getTodayPlan`) + initial render, recorded in request log (`duration_ms`). | `p95 <= 1,000 ms` (`>= 95%` of loads `<= 1,000 ms`) | Rolling 30 days (and `TC-S-003` [alias `TC-S-N03`] benchmark) | If `p95 > 1,000 ms`, profile `M06` (`PlannerService`) and SQLite views `v_daily_plan_summary` (`RB-01`). | `ALT-01` $\rightarrow$ `RB-01` (`A63`) |
| `SLO-04` | `REQ-N-004` | **Claude written-answer marking latency:** `p90` end-to-end latency of `POST /api/quiz/{questionId}/attempt` when `grader = 'claude'`, recorded in `grading_call_log.duration_ms` (`R32`). | `p90 <= 10,000 ms` (`>= 90%` of calls `<= 10.0 s`) | Rolling 30 days (or trailing 50 calls; `TC-S-004` [alias `TC-S-N04`]) | Calls exceeding `10,000 ms` automatically time out to self-marking (`UC-12 ext 3a`). If `> 10%` of calls time out or fail over 20 attempts, switch default `Settings.grading_model` to Haiku or default quiz mode to self-marking (`RB-02`). | `ALT-02` $\rightarrow$ `RB-02` (`A63`) |
| `SLO-05` | `REQ-N-005` | **Claude tutor time-to-first-token (TTFT):** `p90` elapsed time from `POST /api/tutor/threads/{threadId}/messages` dispatch to first SSE `delta` event, logged in `tutor_message` (`R25`) / server log (`ttft_ms`). | `p90 <= 3,000 ms` (`>= 90%` of messages `<= 3.0 s`) | Rolling 30 days (or trailing 50 messages; `TC-S-005` [alias `TC-S-N05`]) | Verify ephemeral prompt-cache hit rate (`cached_tokens / (input_tokens + cached_tokens) >= 70%`). If TTFT breaches `3.0 s` on `> 10%` of calls, trim slide context window or switch tutor model (`RB-02`). | `ALT-02` $\rightarrow$ `RB-02` (`A63`) |
| `SLO-06` | `REQ-N-006` | **Pipeline per-lecture processing duration:** Wall-clock duration (`completed_at - started_at` in `run-summary.json`, `RPT-04`) for a single `<= 60`-slide lecture across ingestion, Stage A, and Stage B when not rate-limited. | `<= 900 s` (`15.0 min`) per lecture (`100%` of non-rate-limited runs) | Per pipeline run (`RPT-04`, `TC-S-006` [alias `TC-S-N06`]) | If a lecture exceeds `15 min` without a `429` rate limit, lower `parallel_lectures` or DPI (`150` $\rightarrow$ `120`) and inspect Reviewer revision counts (`RB-03`). | `ALT-03` $\rightarrow$ `RB-03` (`A63`) |
| `SLO-07` | `REQ-N-007` | **Multi-semester volume scalability:** `SLO-01` (`<= 100 ms`), `SLO-02` (`<= 300 ms`), and `SLO-03` (`<= 1,000 ms`) sustained at `24` modules, `12,000` cards, `16,000` questions, and `500,000` review/attempt log rows. | `100%` pass on `SLO-01`–`SLO-03` at 4-year degree volume | Verified at each release gate (`TC-S-007` [alias `TC-S-N07`] in `A53`) | Any regression on the 500k-row volume benchmark blocks the release until query/index regressions are fixed (`RB-01`). | `ALT-01` $\rightarrow$ `RB-01` (`A63`) |
| `SLO-08` | `REQ-N-008` | **Local zero-external-dependency availability (`R1`):** Successful HTTP `2xx` completion rate of `R1` study workflows (`GET /api/health`, `Today`, `Review`, `Quiz` MCQ/self-mark, `Deadlines`, `Readings`, `Import/Export`) on `localhost` without internet connectivity. | `100.0%` success rate (`0` failed requests due to external network) | Continuous in `R1`–`R3` (and `TC-S-008` [alias `TC-S-N08`]) | Zero error budget (`0%`): any accidental external network dependency in an `R1` path is a blocker defect (`DEF`) fixed immediately (`RB-04`). | `ALT-04` $\rightarrow$ `RB-04` (`A63`) |
| `SLO-09` | `REQ-N-009` | **PWA offline operation & queue sync (`R3`):** Offline completion success for cached `Today`/`Review`/`Quiz` workflows and post-reconnect flush latency of queued `pending_claude` written answers (`POST /api/quiz/offline-sync`). | `100%` offline completion; `100%` queue flush within `<= 30 s` of reconnect | Rolling 30 days in `R3` (and `TC-S-009` [alias `TC-S-N09`]) | If offline sync fails or exceeds `30 s`, retain queued answers in `IndexedDB`, display manual `[Retry sync]` banner on `SCR-01`, and fall back to self-marking if desired (`RB-05`). | `ALT-05` $\rightarrow$ `RB-05` (`A63`) |

---

## 2. Structured Logging & Redaction Standard (`A38`, `REQ-N-012`, `REQ-N-013`, `REQ-N-016`)

Both the Study App server (`packages/server/src/infra/logger.ts`) and `pipeline-cli` (`packages/pipeline/src/cli/logger.ts`) write newline-delimited JSON (`NDJSON`) logs to `stdout`/`stderr` and to `~/.local/share/study-app/logs/app.log` (rotated at `10 MB`, max `3` files retained).

### 2.1 Log Entry Schema

```json
{
  "ts": "2026-10-28T06:15:12.402Z",
  "level": "info",
  "component": "server.http",
  "event": "http.request.completed",
  "reqId": "req-9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "operationId": "submitCardRating",
  "method": "POST",
  "path": "/api/review/COMP4901B-W04-C012/rate",
  "status": 200,
  "duration_ms": 14.2
}
```

### 2.2 Mandatory Redaction & Non-Logging Rules (`DEC-008`, `REQ-N-013`, `REQ-N-016`)

The logger middleware enforces an allowlist/denylist serializer before any line is emitted:
1. **Never log secrets or credentials (`REQ-N-013`):** `ANTHROPIC_API_KEY`, `CANVAS_API_TOKEN`, `STUDY_APP_PASSWORD_HASH`, `SESSION_SECRET`, `Authorization` headers, `Cookie` / `Set-Cookie` headers (`__Host-study_session`), and `password` request fields are replaced with `"[REDACTED]"`.
2. **Never log copyrighted course text (`DEC-008`, `REQ-N-016`):** Slide text, `front`, `back`, `extra`, `stem`, `options`, `model_answer`, `marking_points`, `citation`, and extracted Canvas HTML/markdown are never written to application logs. Only opaque curriculum IDs (e.g. `cardId: "COMP4901B-W04-C012"`, `lectureId: "COMP4901B-W04"`) and byte/character counts are logged.
3. **Never log personal study content (`PD` flag, `A37`):** `QuestionAttempt.user_answer` (student's written answers), `TutorMessage.content` (student and assistant chat messages), `FeedbackItem.comment`, and third-party names/emails are never written to application logs.

---

## 3. Spend, Usage, and Health Metrics (`A38`, `SM-1`–`SM-6`)

Because this is a single-user application (`ASM-021`), operational and AI spend metrics are stored directly in SQLite (`grading_call_log` `R32`, `tutor_message` `R25`, `import_batch` `R30`, `card_review_log` `R09`, `daily_plan` `R22`) and surfaced on **`SCR-08` (`Stats, Retention, Forecast & API Spend`, `RPT-02`)** and **`SCR-06` / `SCR-10` (`Import` / `Settings, Backups & File Exports`)**:

| Metric ID | Metric Name | Source Table / File | Formula / Aggregation | Surface (`A35` / `A41`) |
| :-- | :-- | :-- | :-- | :-- |
| `MET-01` | **Monthly Claude API Spend (`SM-6`)** | `grading_call_log` (`R32`) + `tutor_message` (`R25`) | $\sum \text{cost\_micro\_usd} / 10^6$ for current calendar month in `Settings.timezone` (default `Asia/Hong_Kong` per `ASM-022`, `ASM-067`), grouped by `feature` (`marking` vs `tutor`) and `model`. | `SCR-08` (`RPT-02`), `SCR-10` (`Settings`) |
| `MET-02` | **Prompt Cache Efficiency** | `grading_call_log` (`R32`) + `tutor_message` (`R25`) | $\sum \text{cached\_tokens} / \sum (\text{input\_tokens} + \text{cached\_tokens})$. | `SCR-08` (`RPT-02`) |
| `MET-03` | **HTTP Endpoint Latency (`p50`, `p95`)** | In-memory ring buffer (`last 1,000 requests` per `operationId`) + `app.log` | Exact `p50` and `p95` of `duration_ms` for `submitCardRating`, `getNextReviewCards`, `getNextQuizQuestions`, `getTodayPlan`. | `GET /api/health` diagnostics & `SCR-08` |
| `MET-04` | **Pipeline Run Duration & Acceptance Rate** | `run-summary.json` (`RPT-04`) | Wall-clock `completed_at - started_at` per lecture; `cards_accepted / (cards_accepted + cards_flagged + cards_rejected)`. | `RPT-04` CLI output & `SCR-06` |
| `MET-05` | **SQLite Database Integrity & Backup Freshness** | `study.db` (`PRAGMA quick_check`) + `STUDY_APP_BACKUP_DIR` | Timestamp and byte size of most recent verified `VACUUM INTO` snapshot. | `GET /api/health` & `SCR-10` |

---

## 4. Alert Rules and `A63` Runbook Mapping (`A38.2`, `A63.1`)

Without an external paging service (`A04 §5`), alerts are delivered as **persistent in-app warning banners** on `SCR-01` (`Today`), `SCR-06` (`Import`), `SCR-08` (`Stats`), and `SCR-10` (`Settings`), and as **CLI stderr alerts** during pipeline runs. Every alert (`ALT-01`–`ALT-06`) maps 1-to-1 to a runbook procedure (`RB-01`–`RB-06`) in `A63` (`05-release/docs/runbook.md`):

| Alert ID | Trigger Condition | Linked SLO / BR | Where Surfaced | Runbook Entry in `A63` (`A38.2`, `A63.1`) |
| :-- | :-- | :-- | :-- | :-- |
| `ALT-01` | **Local Query Latency Breach:** `p95` of `submitCardRating > 100 ms` (`SLO-01`), `getNextReviewCards`/`getNextQuizQuestions > 300 ms` (`SLO-02`), or `getTodayPlan > 1,000 ms` (`SLO-03`) over `>= 20` requests. | `SLO-01`, `SLO-02`, `SLO-03`, `SLO-07` | `app.log` `"level":"warn","event":"slo.latency.breach"` + diagnostic badge on `SCR-08` (`RPT-02`). | `RB-01`: *Diagnosing and fixing SQLite latency regressions (`PRAGMA optimize`, index check, WAL checkpoint)*. |
| `ALT-02` | **Claude API Timeout, Error Spike, or Spend Cap Hit:** Marking call exceeds `10.0 s` (`SLO-04`), Tutor TTFT exceeds `3.0 s` (`SLO-05`), Anthropic returns `429`/`5xx`, or monthly spend in `Settings.timezone` reaches `80%` (warning) / `100%` (`monthly_spend_cap_mode = 'block'` [default] or `'warn'` per `ASM-067`) of `Settings.monthly_spend_cap_micro_usd` (`BR-041`). | `SLO-04`, `SLO-05`, `BR-041` | In-app banner on `SCR-03` (`Quiz` self-mark fallback prompt), `SCR-07` (`Tutor`), and `SCR-08` (`Stats`). | `RB-02`: *Handling Claude API timeouts, rate limits, and monthly spend-cap alerts*. |
| `ALT-03` | **Pipeline Lecture Duration Breach, Subscription Limit, or High Spot-Check Rejection:** Single lecture run exceeds `15 min` (`SLO-06`), Claude Code hits a 5-hour/weekly subscription limit (`RSK-004`), or human spot-check rejects `> 20%` of sampled items (`AT-035`). | `SLO-06`, `BR-014`, `RSK-004` | `pipeline-cli` stderr warning + `SCR-06` human-review banner. | `RB-03`: *Resuming interrupted pipeline runs (`--resume`), tuning batch size, and re-running lectures failing spot-check*. |
| `ALT-04` | **Database Integrity, Disk-Full (`ENOSPC`), or Pre-Import Backup Failure:** `PRAGMA quick_check` fails on startup, `VACUUM INTO` fails (`HTTP 503`), or `application_id != 0x53544459`. | `SLO-08`, `REQ-N-011`, `BR-024` | Startup abort / blocking error banner on `SCR-06` & `SCR-10` (`Import / Backups`). | `RB-04`: *Recovering `study.db` from a verified `VACUUM INTO` backup after a crash or failed import*. |
| `ALT-05` | **PWA Offline Queue Sync Failure (`R3`):** `POST /api/quiz/offline-sync` fails or remains unsynced `> 30 s` after network restoration (`SLO-09`). | `SLO-09`, `REQ-N-009` | Persistent top banner on `SCR-01` (`Today`): `"[Offline Queue: N answers pending sync — Retry Now]"`. | `RB-05`: *Resolving stuck offline quiz queues and switching queued items to self-marking*. |
| `ALT-06` | **Hosted Authentication Brute-Force Rate Limit (`R3`):** `>= 5` failed password attempts on `POST /api/auth/login` within `60 s` (`REQ-N-015`, `RSK-008`). | `REQ-N-015`, `BR-045` | `app.log` `"level":"warn","event":"auth.rate_limit.triggered"` + `429` response. | `RB-06`: *Responding to hosted login brute-force alerts, rotating `STUDY_APP_PASSWORD_HASH`, `SESSION_SECRET`, and `ANTHROPIC_API_KEY`, or taking the host offline*. |
