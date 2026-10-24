# ADR-002 · Data Store and Dual Persistence Strategy

- **Artifact ID:** `A30` (`ADR-002`)
- **Stage:** Stage 3 — Architecture & Design
- **Date:** `2026-10-21`
- **Status:** Accepted
- **Deciders:** System Architect
- **Drivers:** `[SEED §4, §5, §8, §10]`, `DEC-002`, `DEC-011`, `REQ-F-018`–`022`, `REQ-N-001`–`003`, `REQ-N-007`, `REQ-N-008`, `REQ-N-011`, `REQ-N-016`, `REQ-N-017`, `REQ-N-020`, `RSK-011`, `RSK-012`

---

## 1. Context and Forces

The system has two subsystems (`DEC-002`, `A04 §3`):
1. **The Generation Pipeline (`DATA`):** Runs interactively in Claude Code per module and lecture (`[USER Q-05]`), producing intermediate drafts, review records, flagged items, and 6 final module export files (`concepts.json`, `deck.json`, `question-bank.json`, `deadlines.json`, `readings.json`, `glossary.json`), plus consuming `feedback.json`.
2. **The Study App (`BIS`):** Runs locally in `R1`–`R2` and on a small host in `R3`, storing modules, cards, questions, FSRS states (`CardState`, `ConceptState`), append-only review logs (`CardReviewLog`, `QuestionAttempt`), deadlines, milestones, tasks, readings, daily plans, tutor threads/messages, proposals, feedback items, and API spend logs.

Key constraints:
- Review history (`CardState`, `CardReviewLog`, `ConceptState`, `QuestionAttempt`) must **never** be lost or overwritten across re-imports (`[SEED §10]`, `UDP-04`, `REQ-F-022`, `REQ-N-011`, `RSK-011`).
- Local queries must complete in `<= 100 ms` (`REQ-N-001`) up to 4 years of degree history (`12,000` cards, `16,000` questions, `500,000` review log rows, `REQ-N-007`).
- Pipeline intermediate and export files contain copyrighted course-derived material and must live outside git-tracked repository paths (`DEC-008`, `REQ-N-016`, `REQ-N-017`).

---

## 2. Decision

We adopt a **Dual Persistence Strategy** with a strict, schema-validated boundary (`REQ-N-020`):

1. **Study App Data Store — Single Embedded SQLite Database (`study.db` via `better-sqlite3`):**
   - Configured at connection open with:
     - `PRAGMA application_id = 0x53544459;` (`"STDY"` magic header so the server verifies it is opening a genuine Study App database before any write, `A33`);
     - `PRAGMA foreign_keys = ON;`
     - `PRAGMA journal_mode = WAL;`
     - `PRAGMA synchronous = FULL;` (guaranteeing zero committed transaction loss across `SIGKILL` or power loss, `REQ-N-011`);
     - `PRAGMA busy_timeout = 5000;`
   - **Data representation rules (`A33`):**
     - **Identifiers:** Imported curriculum entities (`Module`, `Lecture`, `Concept`, `Card`, `Question`, `GlossaryEntry`, `Deadline`, `Reading`) use the deterministic natural string keys from `flashcard-pipeline.md` (`<MODULE>-<WEEK>-K<nn>`, `-C<nnn>`, `-Q<nnn>`, `-G<nnn>`, `-D<nnn>`, `-R<nnn>`, `BR-020`) so re-imports match existing rows losslessly (`DT-02`). App-generated transactional rows (`CardReviewLog`, `QuestionAttempt`, `Task`, `Milestone`, `DailyPlanItem`, `TutorThread`, `TutorMessage`, `Proposal`, `FeedbackItem`, `ImportBatch`, `GradingCallLog`) use UUID v4 (`TEXT PRIMARY KEY`).
     - **Money:** Stored exclusively as exact 64-bit integers in **micro-USD** (`1 USD = 1,000,000 micro_usd`, e.g. `cost_micro_usd INTEGER NOT NULL CHECK (cost_micro_usd >= 0)`), never IEEE-754 floating point (`A33`, `B10`).
     - **Timestamps:** Stored as ISO-8601 UTC strings (`YYYY-MM-DDTHH:mm:ss.sssZ`, `TEXT`), with user-facing dates formatted in the module/settings IANA time zone (default `Asia/Hong_Kong`, `ASM-022`, `BR-033`).
   - **Crash-safe backup before import, migration & restore (`REQ-N-011`, `UDP-04`):** Before every module import (`UC-06`), schema migration, or backup restore, the server creates an online hot backup in `STUDY_APP_BACKUP_DIR` using SQLite's `VACUUM INTO` API (`study-pre-import-<moduleId>-<timestamp>-<id>.db` before import, `study-backup-<timestamp>-<id>.db` on manual `POST /api/backup/create`, and `study-safety-<timestamp>-<id>.db` before `POST /api/backup/restore`), computes its SHA-256 checksum, and verifies `PRAGMA application_id = 0x53544459` and `PRAGMA integrity_check` before starting any write or restore transaction.

2. **Pipeline Workspace Store — External File-System Directory (`STUDY_DATA_DIR/pipeline/<module>/`):**
   - Pipeline intermediate files (`E22`–`E27`: `pipeline.config.json`, `cards.round*.json`, `review.round*.json`, `flagged.json`, `module-audit.json`, `run-summary.json`) and final export packages (`export/{concepts,deck,question-bank,deadlines,readings,glossary}.json`) are stored as UTF-8 JSON files on disk outside git-tracked directories (`DEC-008`, `REQ-N-016`, `REQ-N-017`).
   - Every file write is performed atomically via write-to-temp-file + `fs.renameSync` after passing `Ajv` JSON Schema validation (`A34`).

---

## 3. Alternatives Considered

### Alternative A: Client-Side PostgreSQL / Dockerised RDBMS (PostgreSQL 16)
- **Pros:** Rich native types (`TIMESTAMPTZ`, `NUMERIC`, `UUID`).
- **Why rejected:** Requires running a separate database daemon or Docker container on the student's laptop (`REQ-N-008`) and exceeds the `$0–$10/month` `R3` hosting budget (`ASM-060`) when a managed Postgres instance is added. SQLite in WAL mode is designed to meet the `REQ-N-001`–`REQ-N-003` latency targets (`<= 100 ms` / `<= 300 ms` / `<= 1,000 ms` p95) up to the `500,000`-row 4-year degree volume (`REQ-N-007`) in a single file (empirically measured in `SL-01`, `SL-07`, `SL-08`, and `SL-10`).

### Alternative B: Storing Pipeline Intermediate Rounds inside SQLite
- **Pros:** Single storage engine for both subsystems.
- **Why rejected:** Violates `[SEED §5]` and `flashcard-pipeline.md §11`, where the pipeline is decoupled from the web app via the 6 JSON export files and `feedback.json`, and complicates Claude Code subagents reading/writing staged files directly during interactive CLI runs (`ADR-004`).

### Alternative C: Browser-Only Storage (`IndexedDB` / `localStorage` without SQLite)
- **Pros:** Zero backend persistence layer needed in `R1`.
- **Why rejected:** Browser storage can be evicted or cleared accidentally by the browser (`RSK-011`), cannot safely hold server-side secrets (`REQ-N-013`), and cannot synchronize between laptop and phone in `R3` (`REQ-F-059`).

---

## 4. Consequences

- **Positive:**
  - Single-file transactional durability (`study.db`) with instant atomic online backups (`VACUUM INTO`) before every import.
  - Clean contract boundary (`A34` JSON Schemas) between the Claude Code pipeline and the Study App.
  - Zero external database server required in `R1`–`R2` (`REQ-N-008`) and single-volume deployment in `R3` (`ADR-006`).
- **Negative / Trade-offs:**
  - SQLite enforces single-writer concurrency; since this is a single-user application (`ASM-021`), write contention is near zero and handled by `busy_timeout = 5000`.
