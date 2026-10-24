# ADR-003 · Architecture Style, Three-Tier Layering, Single-Writer Table Ownership, and Database Constraint Backstops

- **Artifact ID:** `A30` (`ADR-003`)
- **Stage:** Stage 3 — Architecture & Design
- **Date:** `2026-10-21`
- **Status:** Accepted
- **Deciders:** System Architect
- **Drivers:** `G3.1`, `G3.6`, `A31`, `REQ-N-008`, `REQ-N-010`, `REQ-N-011`, `REQ-N-013`, `REQ-N-020`

---

## 1. Context and Forces

Gate G3 and catalog entry `A31` enforce four structural architecture rules:
1. **Strict three-tier layering (`G3.1`, `A31`):** Presentation components must never access the data store directly, no presentation logic may live in the business or data layers, and no business rules may live in UI code unless an ADR justifies a specific exception.
2. **Single-writer module ownership (`A31`):** Each module must have a single clear responsibility, and no two modules may write the same database table without an ADR.
3. **Single business-rule enforcement location (`G3.6`):** Every business rule (`BR-001`–`BR-045`) must have a single authoritative enforcement location, and any secondary backstop (such as a SQLite `CHECK`, `UNIQUE`, or `FOREIGN KEY` constraint behind a domain validation check, or client-side form validation mirroring server validation) must be explicitly justified by an ADR.
4. **Offline PWA review capability in `R3` (`REQ-F-060`, `REQ-N-009`):** When the student reviews flashcards or answers MCQ quizzes offline on their phone in `R3`, the browser PWA must compute the immediate next FSRS preview state locally via `ts-fsrs` while queueing the rating mutation for authoritative server reconciliation upon reconnect.

---

## 2. Decision

### 2.1 Modular Monolith Architecture Style
We structure the system as a **Modular Monolith** in four workspace packages (`packages/shared`, `packages/server`, `packages/web`, `packages/pipeline`) with strict dependency direction:
- `packages/web` (Presentation Tier) $\rightarrow$ imports types/schemas from `packages/shared`; communicates with `packages/server` exclusively via HTTP REST/SSE (`A34`). Never imports `packages/server` or `better-sqlite3`.
- `packages/server/src/routes` (Presentation / HTTP Controller Tier) $\rightarrow$ parses HTTP requests, enforces session auth (`ADR-006`) and schema validation (`Ajv`), calls `packages/server/src/services` (Business Logic Tier), and formats HTTP/RFC 9457 responses. Never imports `packages/server/src/repositories` or executes SQL directly.
- `packages/server/src/services` (Business Logic Tier) $\rightarrow$ implements all domain rules (`BR-021`–`BR-045`), decision tables (`DT-02`–`DT-06`), and FSRS transitions (`ts-fsrs`), calling `packages/server/src/repositories`. Never constructs SQL strings or HTML/JSX.
- `packages/server/src/repositories` (Data Management Tier) $\rightarrow$ encapsulates all SQLite prepared statements and transactions. Each table has **exactly one owning repository module** (`A31 §3`).
- `packages/pipeline` (Pipeline CLI & Subagents) $\rightarrow$ implements pipeline extraction, validation, round merging, and export (`BR-001`–`BR-020`, `DT-01`), communicating with the Study App exclusively via the 6 JSON export files and `feedback.json`.

### 2.2 Single-Writer Table Ownership & Cross-Module Coordination
No two modules write the same SQLite table (`A31 §3`). Where a workflow spans multiple domain entities — specifically **Module Import (`UC-06`)**, which ingests `Module`, `Lecture`, `Concept`, `Card`, `Question`, `GlossaryEntry`, `Deadline`, `Reading`, and initial `CardState`/`ConceptState` rows inside a single atomic SQLite transaction (`REQ-F-021`, `REQ-N-011`) — `ImportService` coordinates the transaction via a unit-of-work handle passed to each entity's owning repository (`ModuleRepo`, `CatalogRepo`, `CardRepo`, `QuizRepo`, `DeadlineRepo`, `ReadingRepo`, `GlossaryRepo`) rather than executing cross-table SQL itself.

### 2.3 Justified Dual-Location Backstops (`G3.1`, `G3.6`)
Each business rule `BR-001`–`BR-045` has one authoritative enforcement location in the Business Logic Tier (`A31 §6`). We explicitly authorise three defensive backstop layers:
1. **SQLite DDL Constraints (`CHECK`, `NOT NULL`, `UNIQUE`, `FOREIGN KEY`) behind Business-Layer Validation (`G3.6`):**
   - *Authoritative location:* Domain Services (`packages/server/src/services/*`) and `Ajv` request/import validators, which return structured field-level RFC 9457 error messages (`A34`, `A35`).
   - *Backstop:* `schema.sql` (`A33`) defines SQLite `CHECK` constraints (e.g., `rating BETWEEN 1 AND 4`, `weighting BETWEEN 0 AND 100`, valid enumeration values) and `FOREIGN KEY` constraints so that even a future code bug or direct SQL script cannot corrupt study history (`REQ-N-011`, `UDP-04`).
2. **Client-Side Form Validation (`packages/web`) in front of Server API Validation (`G3.1`, `G3.6`):**
   - *Authoritative location:* Server HTTP boundary (`Ajv` + Domain Services).
   - *UX Pre-check:* React forms (`A35 §4`) run the shared schema/field validators from `packages/shared` to give instant keyboard-accessible feedback (`REQ-N-018`, `B6`) before round-tripping to the server.
3. **Offline PWA `ts-fsrs` Preview (`R3`, `REQ-F-060`, `REQ-N-009`):**
   - *Authoritative location:* `ReviewService` and `QuizService` on the server.
   - *Offline client execution (`R3` only):* When offline in `R3`, the Service Worker / IndexedDB queue invokes the identical `ts-fsrs` package from `packages/shared` so the student can continue reviewing cards and MCQs offline; when connectivity returns, queued review events (carrying their exact client UTC `reviewed_at` timestamp) are replayed in chronological order through `ReviewService`/`QuizService`.

---

## 3. Alternatives Considered

### Alternative A: Microservices (Separate Node/Python Services for Pipeline, Review, Tutor, and Planner)
- **Pros:** Process-level isolation per bounded context.
- **Why rejected:** Massive operational overhead for a single-user application (`ASM-021`), complicates local startup (`REQ-N-008`), and breaks single-file atomic SQLite transactions (`REQ-N-011`).

### Alternative B: Two-Tier "Fat Route Handlers" or Direct ORM Queries in Controllers
- **Pros:** Fewer files initially.
- **Why rejected:** Violates `G3.1` and `B10`, scatters business rules (`BR-001`–`BR-045`) across HTTP handlers and UI components, and makes unit testing decision tables (`DT-01`–`DT-06`) without HTTP/DB scaffolding difficult.

### Alternative C: Enforcing Rules Only in Code (No SQLite `CHECK` Constraints) or Only in SQLite
- **Pros:** Zero overlap between code checks and DDL constraints.
- **Why rejected:** Enforcing rules only in SQLite produces cryptic SQLite constraint error strings instead of field-level RFC 9457 problem details (`A34`, `A35`); enforcing rules only in code leaves `study.db` unprotected against bugs that could corrupt review history (`[SEED §10]`, `REQ-N-011`).

---

## 4. Consequences

- **Positive:**
  - Every business rule (`BR-001`–`BR-045`) has a single authoritative service method testable in isolation (`TC-U-*`), backed by database integrity constraints (`A33`) and verified by an automated dependency/layering test (`TC-S-024`–`TC-S-027` in `A31 §7`).
- **Negative / Trade-offs:**
  - Adding a new enum value requires updating both the shared TypeScript schema (`packages/shared`) and a versioned SQLite migration (`A33`).
