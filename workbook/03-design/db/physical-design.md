# A33 · Physical Data Design Notes

- **Artifact ID:** `A33`
- **Stage:** Stage 3 — Architecture & Design
- **Owner:** System Architect
- **Date:** `2026-10-21`
- **Catalog entry:** `A33` (`systems_analysis_and_design_project_framework.md`)
- **Executable DDL:** [`workbook/03-design/db/schema.sql`](schema.sql)
- **Related ADRs:** [`ADR-002`](../adr/ADR-002-data-store-and-dual-persistence.md), [`ADR-003`](../adr/ADR-003-architecture-style-and-layering.md), [`ADR-006`](../adr/ADR-006-hosting-deployment-and-auth.md), [`ADR-007`](../adr/ADR-007-normalization-and-json-audit-columns.md)

---

## 1. Engine Configuration & Physical Data Types (`A33`)

Every table in [`schema.sql`](schema.sql) is declared `STRICT` (SQLite 3.37+ strict typing mode) so SQLite enforces column type affinities rigorously (`TEXT`, `INTEGER`, `REAL`) and rejects mistyped inserts.

| Domain Type Class (`A18`) | Physical SQLite Type in `STRICT` Tables | Rationale & Validation Constraint (`A33`) |
| :-- | :-- | :-- |
| **Money (`cost_usd`, `monthly_spend_cap_usd`)** | `INTEGER` (`cost_micro_usd`, `monthly_spend_cap_micro_usd`) | **Exact integer micro-USD** (`1 USD = 1,000,000 micro_usd`, `ADR-002`, `DR-03`). Never uses IEEE-754 floating point (`REAL`), eliminating rounding drift when summing token charges across thousands of `GradingCallLog` and `TutorMessage` rows (`BR-041`, `SM-6`). |
| **Timestamps (`*_at`, `due`)** | `TEXT` (`ISO-8601 UTC` `YYYY-MM-DDTHH:mm:ss.sssZ`) | Enforced by `CHECK (<col> GLOB '????-??-??T??:??:??*Z')`. Lexicographical byte ordering in UTF-8 equals chronological ordering, enabling fast B-tree range scans (`idx_card_state_state_due`, `idx_card_review_log_reviewed_at`) while preserving unambiguous UTC storage (`ASM-022`). |
| **Local Calendar Dates (`due_on`, `plan_date`)** | `TEXT` (`YYYY-MM-DD`) | Enforced by `CHECK (<col> GLOB '????-??-??')`, interpreted in `Settings.timezone` (`Asia/Hong_Kong`, `ASM-022`). |
| **Curriculum Identifiers (`Lecture`, `Concept`, `Card`, `Question`, `GlossaryEntry`)** | `TEXT PRIMARY KEY` (Deterministic natural IDs) | Enforced by `CHECK (id GLOB '*-W[0-9][0-9]*-...')` (`BR-020`). Guarantees stable, repeatable keys across pipeline re-runs so `UC-06` re-imports update content in place without touching `CardState`/`ConceptState` (`BR-021`). |
| **Transactional Identifiers (`CardReviewLog`, `QuestionAttempt`, `Task`, `TutorThread`, etc.)** | `TEXT PRIMARY KEY` (UUID v4) | Generated via `crypto.randomUUID()` so offline PWA reviews (`R3`, `REQ-F-060`) and server writes never collide. |
| **Booleans (`suspended`, `flagged`, `done`, `completed`, `overridden`)** | `INTEGER NOT NULL DEFAULT 0` | Enforced by `CHECK (<col> IN (0, 1))`. |
| **Enumerations (`state`, `type`, `importance`, `kind`, `status`, `grader`, `mode`)** | `TEXT NOT NULL` | Enforced by explicit `CHECK (<col> IN (...))` matching the exact allowed values in `A18 §4` (`data-dictionary.csv`). |

---

## 2. Foreign Key Delete & Update Behaviour (`A33.2`)

Every `FOREIGN KEY` in [`schema.sql`](schema.sql) defines explicit `ON DELETE` and `ON UPDATE` rules (`A33` acceptance check), engineered to make accidental deletion of study history impossible (`[SEED §10]`, `UDP-04`, `BR-021`, `RSK-011`):

| Child Table (`FK Column`) | Parent Table | `ON DELETE` | `ON UPDATE` | Rationale (`BR-021`, `REQ-N-011`) |
| :-- | :-- | :-: | :-: | :-- |
| `lecture(module_id)`, `concept(module_id, lecture_id)`, `card(module_id, lecture_id, concept_id)`, `question(module_id, lecture_id, concept_id)`, `glossary_entry(module_id)`, `deadline(module_id)`, `reading(module_id)` | `module`, `lecture`, `concept` | `RESTRICT` | `CASCADE` | Curriculum items are never deleted during re-import (`BR-022` suspends removed items); `RESTRICT` blocks accidental parent deletion. |
| `card_state(card_id)`, `card_review_log(card_id)` | `card(id)` | `RESTRICT` | `CASCADE` | **Hard database backstop for `UDP-04` and `BR-021`:** SQLite physically refuses to delete any `card` that has a `card_state` or `card_review_log`. |
| `concept_state(concept_id)`, `question_attempt(question_id, concept_id)` | `concept(id)`, `question(id, concept_id)` | `RESTRICT` | `CASCADE` | **Hard database backstop for `UDP-04` and `BR-021`:** SQLite physically refuses to delete any `concept` or `question` that has scheduling state or attempts. |
| `concept_prerequisite`, `concept_card`, `card_tag`, `question_option`, `question_marking_point`, `deadline_lecture` | `concept`, `card`, `question`, `deadline` | `CASCADE` | `CASCADE` | Dependent `1NF`/`3NF` child rows are replaced atomically inside `ImportService` when a card/question/concept's metadata is updated during re-import. |
| `question_attempt_point(attempt_id)` | `question_attempt(id)` | `CASCADE` | `CASCADE` | Child rubric points belong exclusively to their parent `question_attempt`. |
| `milestone(deadline_id)`, `daily_plan_item(plan_id)` | `deadline(id)`, `daily_plan(id)` | `CASCADE` | `CASCADE` | Milestones belong to their parent deadline; plan items belong to their parent daily plan. |
| `tutor_message(thread_id)`, `tutor_message_citation(message_id)`, `proposal(thread_id)` | `tutor_thread(id)`, `tutor_message(id)` | `CASCADE` | `CASCADE` | Implements `REQ-F-052` (`ASM-023`): when the student deletes a `TutorThread`, all messages, citations, and unexported draft proposals in that thread are cleanly removed. |
| `glossary_entry(first_lecture_id)`, `reading(lecture_id)`, `task(module_id)`, `daily_plan_item(module_id)`, `grading_call_log(attempt_id)` | `lecture`, `module`, `question_attempt` | `SET NULL` | `CASCADE` | Optional/nullable attribution links degrade gracefully to `NULL` without losing the reading, task, or API cost log row. |

---

## 3. Index Justification Table (`A33.3`)

Every index (`IDX-01`–`IDX-15`) in [`schema.sql`](schema.sql) is justified by a named hot query and latency target (`REQ-N-001`–`REQ-N-003`, `REQ-N-007`). No table partitioning is used because the 4-year degree volume (`12,000` cards, `16,000` questions, `500,000` review log rows, `REQ-N-007`) occupies `< 150 MB` in SQLite, where B-tree composite indexes execute in `< 2 ms`.

| Index Name | Table & Columns | Named Query / Access Pattern | Target `REQ-N` |
| :-- | :-- | :-- | :-- |
| `idx_card_module_active` | `card(module_id, suspended, flagged, lecture_id)` | Filter active (`suspended = 0 AND flagged = 0`) flashcards for a module during daily queue build (`GET /api/review/next`). | `REQ-N-001`, `REQ-N-002` |
| `idx_card_state_state_due` | `card_state(state, due)` | Select due review cards (`due <= ?`) and new cards (`state = 'New'`) ordered by `due ASC`. | `REQ-N-002`, `REQ-N-003` |
| `idx_card_review_log_reviewed_at` | `card_review_log(reviewed_at, state_before, rating)` | Compute trailing 30-day true retention (`SM-2`, `BR-044`) and daily review counts on `GET /api/stats` across 500,000 rows via index-only covering scan. | `REQ-N-007`, `REQ-F-058` |
| `idx_card_review_log_card_id` | `card_review_log(card_id, reviewed_at)` | Per-card review history and `R3` FSRS parameter optimiser training sequence (`UC-20`). | `REQ-F-065`, `REQ-N-007` |
| `idx_concept_state_due_stability` | `concept_state(due, stability)` | Select due concepts (`due <= ?`) and order in assessment mode by lowest `stability ASC` (`BR-028`, `BR-043`). | `REQ-N-002`, `REQ-F-053` |
| `idx_concept_module_lecture` | `concept(module_id, lecture_id, importance)` | Module dashboard concept mastery breakdown and assessment-scope filtering (`GET /api/modules/:id`). | `REQ-N-003`, `REQ-F-058` |
| `idx_question_concept_active` | `question(concept_id, suspended, flagged, difficulty)` | Candidate variant lookup for a due concept (`DT-03`, `BR-029`). | `REQ-N-002` |
| `idx_question_attempt_concept_question` | `question_attempt(concept_id, question_id, attempted_at DESC)` | Determine unseen vs least-recently-seen variant (`DT-03`) and `>= 2` attempt count (`SM-5`, `BR-044`). | `REQ-N-002`, `REQ-F-058` |
| `idx_question_attempt_grader` | `question_attempt(grader, attempted_at) WHERE grader = 'pending_claude'` | Partial index to locate offline-queued written answers upon network reconnect (`R3`, `REQ-F-061`). | `REQ-N-009` |
| `idx_deadline_status_due_at` | `deadline(status, due_at, module_id)` | Upcoming deadline countdowns (`DT-05`) and active 21-day assessment mode lookup (`BR-043`). | `REQ-N-003` |
| `idx_daily_plan_item_plan_order` | `daily_plan_item(plan_id, deferred, order_index)` | Fetch today's ordered 9-step checklist (`GET /api/today`). | `REQ-N-003` |
| `idx_feedback_item_module_exported` | `feedback_item(module_id, exported, kind, reason)` | Fetch unexported feedback items (`GET /api/export/feedback`) and compute `SM-3` reported-wrong rate (`BR-038`). | `REQ-F-042`, `REQ-F-058` |
| `idx_tutor_thread_module_updated` | `tutor_thread(module_id, updated_at DESC)` | List module tutor threads in reverse chronological order (`GET /api/tutor/threads`). | `REQ-F-052` |
| `idx_tutor_message_created_cost` | `tutor_message(created_at, cost_micro_usd) WHERE role = 'assistant'` | Partial covering index to sum current calendar-month tutor API spend (`SM-6`, `BR-041`). | `REQ-F-048`, `REQ-F-058` |
| `idx_grading_call_log_called_cost` | `grading_call_log(called_at, cost_micro_usd)` | Covering index to sum current calendar-month marking API spend (`SM-6`, `BR-041`). | `REQ-F-048`, `REQ-F-058` |

---

## 4. Database Recognition, Versioned Migrations, and Crash-Safe Backup / Restore (`A33`, `REQ-N-011`)

### 4.1 Database Recognition (`PRAGMA application_id`)
When `packages/server/src/db/connection.ts` opens a database file path (`STUDY_DB_PATH`):
1. If the file is new (`0` bytes), it executes `001_initial_schema.sql` (`schema.sql`), setting `PRAGMA application_id = 0x53544459` (`"STDY"`).
2. If the file already exists and is non-empty, the connection manager reads `PRAGMA application_id` **before** running any migration or write. If `application_id != 0x53544459`, it immediately closes the handle and throws `InvalidDatabaseFileError` (`"File is not a Study App SQLite database (expected application_id 0x53544459)"`), refusing to modify arbitrary files (`A33`).

### 4.2 Versioned Migration Strategy
- Numbered forward SQL migration files live in `packages/server/src/db/migrations/NNN_<name>.sql` (`001_initial_schema.sql`, etc.).
- On startup, `migrator.ts` compares applied versions in `schema_migrations` (verifying `checksum_sha256` against each file on disk) and applies any pending migration inside an exclusive transaction (`BEGIN IMMEDIATE ... COMMIT`) only **after** creating a pre-migration online backup (§4.3).
- Rollback approach (`A61`): Because a pre-migration snapshot is written before every migration, rolling back a schema migration restores the pre-migration `.db` snapshot and replays any exported JSON files if needed.

### 4.3 Crash-Safe Online Backup and Restore (`REQ-N-011`, `BR-024`)
Because SQLite in WAL mode uses three files (`study.db`, `study.db-wal`, `study.db-shm`), copying `study.db` with `cp` while the server is running or mid-write can produce a truncated or inconsistent copy (`A33`).
Therefore, all backups use SQLite's online **`VACUUM INTO`** (or `better-sqlite3`'s `.backup()`) API:
1. **When backups run:** Automatically before every module import (`UC-06`, `BR-024`), before every schema migration, and on demand via `POST /api/backup/create`.
2. **How `createVerifiedBackup()` works:**
   - Executes `VACUUM INTO '<backup_dir>/study-<YYYYMMDD-HHmmss>-<batch_id>.db';` which reads a consistent transactional snapshot across `study.db` + `study.db-wal` and writes a standalone, defragmented single-file SQLite database.
   - Opens the backup file read-only, runs `PRAGMA integrity_check` and `PRAGMA foreign_key_check` (asserting both return `'ok'` / `0` rows), computes its `SHA-256` digest (`backup_sha256`), and records both in `import_batch`.
   - Retains the most recent `30` backup snapshots in `<STUDY_DATA_DIR>/backups/` (mode `0600`).
3. **Mid-Write Crash Recovery (`SIGKILL` test `TC-S-011`):**
   - Because `PRAGMA journal_mode = WAL` and `PRAGMA synchronous = FULL` are set on the primary connection, if `SIGKILL` terminates the Node.js process mid-import or mid-review, SQLite automatically rolls back the uncommitted WAL frames on the next connection open in `< 50 ms`, leaving `100%` of previously committed `card_review_log` and `question_attempt` rows intact.
   - To restore a prior backup snapshot (`POST /api/backup/restore` or CLI `study-admin restore <backup-file>`), the restore procedure verifies the backup's `application_id` (`0x53544459`) and `PRAGMA integrity_check`, checkpoints and closes the active DB connection, atomically renames the verified backup into place, and reopens the connection.

### 4.4 Encryption at Rest and File Permissions (`A33`, `A36`)
- **Local mode (`R1`–`R2`):** `<STUDY_DATA_DIR>` (`~/.local/share/studyapp/`) and `<CONFIG_DIR>` (`~/.config/studyapp/credentials.env`) are created with POSIX permissions `0700` / `0600` (owner-only read/write) on the student's disk.
- **Hosted mode (`R3`):** The Fly.io persistent NVMe volume (`/data/study.db` and `/data/backups/`) is encrypted at rest by Fly.io LUKS block-volume encryption (`AES-256-XTS`), and all backups downloaded off-host are encrypted with `AES-256-GCM` (`openssl enc` / Node `crypto`).
