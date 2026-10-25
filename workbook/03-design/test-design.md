# A39 · Test Design

Owner: QA & Test Engineer. Stage 3, written 2026-10-21. Catalog entry: A39 (`03-design/test-design.md`, accompanied by [`test-cases.csv`](test-cases.csv) containing all **293** Integration and System test cases per protocol §5.3).

---

## 1. Test Plans by Level (`Unit`, `Integration`, `System`)

### 1.1 Unit Test Plan (`TC-U-nnn`, Authored per Slice in Stage 4b)

- **Scope:** Pure domain functions, decision-table evaluators (`DT-01`–`DT-06`), business-rule guards (`BR-001`–`BR-045`), FSRS wrapper calculations (`M02`, `M03`), duration estimators (`BR-036`), Markdown/KaTeX/DOMPurify sanitizers, LaTeXiT zlib decoders (`M11`), and URL/path validators.
- **Tools & Environment:** `Vitest` (`v2.x`) on Node.js 22 LTS; zero network or disk I/O (in-memory fixtures only).
- **Stage 4b Rule (P1, P2):** Per catalog `A39`, unit-level test cases (`TC-U-nnn`) are specified and committed per slice in Stage 4b (`A50`) before production code for that slice is written, with red $\rightarrow$ green $\rightarrow$ refactor evidence (or mutation-kill evidence for structural invariants) recorded in `A50` (`G4.2`).

### 1.2 Integration & Contract Test Plan (`TC-I-001`–`TC-I-262`, `TC-I-N10`, `TC-I-N12`, `TC-I-N17`, `TC-I-N20`)

- **Scope:**
  1. All **38 HTTP/SSE API operations** (`TC-I-001`–`TC-I-116`, `TC-I-256`–`TC-I-262`) through Hono routing, `authMiddleware`, `Ajv` request/response validation, domain services, and real SQLite 3 (`better-sqlite3` in WAL mode on isolated per-test temporary files).
  2. All **7 `pipeline-cli` commands** (`CLI-01`–`CLI-07` $\rightarrow$ `TC-I-117`–`TC-I-137`) on isolated temporary workspace directories.
  3. All **30 UI/API field validation rules** (`FLD-01`–`FLD-30` $\rightarrow$ `TC-I-138`–`TC-I-165`, `TC-I-174`–`TC-I-201`, `TC-I-256`, `TC-I-261`–`TC-I-262`), testing exact boundary values and invalid inputs against the plain-language error messages in `A35 §4`.
  4. All **5 external integration contracts** (`INT-01`–`INT-05` $\rightarrow$ `TC-I-166`–`TC-I-173`, `TC-I-N20`) using `Ajv` (Draft 2020-12), mock Anthropic/Canvas HTTPS servers, RFC 5545 `.ics` parsers, and Anki `.tsv` parsers.
  5. All **48 complete decision-table rules** (`DT-01-C1`–`DT-06-C8` $\rightarrow$ `TC-I-202`–`TC-I-249`, mapped 1-to-1 to `AT-051`–`AT-098`).
  6. Pipeline extraction, Creator/Reviewer rubric evaluation, Module Auditor, FSRS parameter fitting, full feedback/top-up loop, model token-rate consistency, anti-spoofing login rate-limiting, `monthly_spend_cap_mode='warn'` call progression (`TC-I-258`), assessment-mode scheduling & checklist prep (`TC-I-259`), `<24 h` deadline browser notifications (`TC-I-260`), and `SCR-10` settings boundary/invalid/unknown-key validation (`TC-I-261`–`TC-I-262`) (`TC-I-250`–`TC-I-262`, `TC-I-N10`, `TC-I-N12`, `TC-I-N17`).
- **Test Data:** Synthetic non-copyrighted course fixtures (`tests/fixtures/` and `tests/eval/fixtures/`) per `DEC-008`.

### 1.3 System, NFR, AI Evaluation & Architecture Test Plan (`TC-S-001`–`TC-S-027` / `TC-S-N01`–`TC-S-N23`)

- **Scope:** End-to-end browser workflows (`Playwright`), latency benchmarks (`SLO-01`–`SLO-06`), 4-year degree volume testing (`500,000` review logs, `SLO-07`), network-isolated local `R1` execution (`SLO-08`), PWA offline study and reconnect queue sync (`SLO-09`), `SIGKILL` mid-write crash recovery and `VACUUM INTO` backup restore (`REQ-N-011`), secret/copyright scanning (`REQ-N-013`, `REQ-N-016`), prompt-injection containment (`REQ-N-014`), hosted auth & rate limiting (`REQ-N-015`), WCAG 2.2 AA accessibility (`axe-core`, `REQ-N-018`), keyboard-only navigation (`REQ-N-019`), cross-browser/viewport rendering (`REQ-N-021`), coursework academic-integrity refusal (`REQ-N-023`), and the 4 programmable architecture rules from `A31 §7` (`ARCH-01`–`ARCH-04` $\rightarrow$ `TC-S-024`–`TC-S-027`).

---

## 2. Minimum Coverage Verification Summary (`A39.1`, `G3.9`)

Every row in [`test-cases.csv`](test-cases.csv) specifies `id`, `level`, `traces`, `preconditions`, `input_data`, `steps`, `expected_output` (concrete values, HTTP status codes, and database states — never vague phrases like *"works correctly"*, `A39.2`), `case_type`, `slice`, and `runtime_budget`.

| Coverage Requirement (`A39.1` & `G3.9`) | Target Universe | Test Case IDs in [`test-cases.csv`](test-cases.csv) | Count | Status |
| :-- | :-- | :-- | --: | :-- |
| **1. Every HTTP interface operation (`38` ops in `A34`)**: success + error + authorization-denied | `getHealth` (`1`) .. `restoreDatabaseBackup` (`38`) | `TC-I-001`–`TC-I-114` (`3` per operation: `normal`, `error/recovery`, `authorization`) + `TC-I-115`–`TC-I-116` | `116` | **100% (`38/38` ops × 3)** |
| **2. Every CLI command (`7` commands in `A34`)**: success + error + authorization/boundary | `CLI-01` (`sync-canvas`) .. `CLI-07` (`clean-rounds`) | `TC-I-117`–`TC-I-137` (`3` per command: `normal`, `error/recovery`, `authorization`) | `21` | **100% (`7/7` cmds × 3)** |
| **3. Every input validation rule (`30` fields in `A35 §4`)**: boundary + invalid | `FLD-01` .. `FLD-30` | `TC-I-138`–`TC-I-165` (`FLD-01`–`FLD-14`), `TC-I-174`–`TC-I-201` (`FLD-15`–`FLD-28`), & `TC-I-261`–`TC-I-262` (`FLD-29`–`FLD-30`) | `58` | **100% (`30/30` fields)** |
| **4. Every external integration (`5` contracts in `A34 §4`)**: contract test | `INT-01` (Pipeline JSON), `INT-02` (Claude API), `INT-03` (Canvas API), `INT-04` (`.ics`), `INT-05` (Anki `.tsv`) | `TC-I-166`–`TC-I-173`, `TC-I-N20` | `9` | **100% (`5/5` integrations)** |
| **5. Every complete decision-table rule (`48` rules in `A15`)**: 1 case each | `DT-01-C1`..`C8`, `DT-02-C1`..`C8`, `DT-03-C1`..`C8`, `DT-04-C1`..`C8`, `DT-05-C1`..`C8`, `DT-06-C1`..`C8` (`AT-051`–`AT-098`) | `TC-I-202`–`TC-I-249` | `48` | **100% (`48/48` complete rules)** |
| **6. Every measurable `REQ-N` (`23` NFRs in `A10 §3`)**: verification case | `REQ-N-001` .. `REQ-N-023` | `TC-S-001`–`TC-S-023` (matching `A10` aliases `TC-S-N01`–`TC-S-N23`) + `TC-I-N10`, `TC-I-N12`, `TC-I-N17`, `TC-I-N20` | `26` | **100% (`23/23` `REQ-N`s)** |
| **7. Every programmable architecture rule (`4` rules in `A31 §7`)** | `ARCH-01` .. `ARCH-04` | `TC-S-024`–`TC-S-027` | `4` | **100% (`4/4` `ARCH` rules)** |
| **8. Every functional requirement (`94` `REQ-F`s in `A10 §2`)** | `REQ-F-001` .. `REQ-F-094` | `TC-I-001`–`TC-I-262`, `TC-S-001`–`TC-S-023` | `11` additional (`293` total) | **100% (`94/94` `REQ-F`s, `0` orphans)** |

---

## 3. System, NFR, and Architecture Test Case Summary (`TC-S-001`–`TC-S-027`)

*(The full 293-row catalog including all `TC-I-001`–`TC-I-262` rows is in [`test-cases.csv`](test-cases.csv).)*

| TC ID (`A10` Alias) | `REQ` / `SLO` / `ARCH` Trace | Slice | Case Type | Summary of Steps & Concrete Pass Criteria (`A39.2`) | Runtime Complexity & Budget |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `TC-S-001` (`TC-S-N01`) | `REQ-N-001`, `SLO-01`, `REQ-F-024` | `SL-07` | `normal` | Run 200 sequential card flip + `POST /api/review/{cardId}/rate` calls on 3,000-card / 100,000-log SQLite DB. **Expected:** `p95 <= 100 ms`, `0` errors. | $O(N \log M)$ for $N=200$, $M=10^5$; budget `<= 20 s` |
| `TC-S-002` (`TC-S-N02`) | `REQ-N-002`, `SLO-02`, `REQ-F-024`, `REQ-F-029` | `SL-08` | `normal` | Run 100 `GET /api/review/next` and 100 `GET /api/quiz/next` calls on 3,000-card / 1,000-concept / 4,000-question DB. **Expected:** `p95 <= 300 ms`. | $O(N \log M)$ for $N=200$; budget `<= 30 s` |
| `TC-S-003` (`TC-S-N03`) | `REQ-N-003`, `SLO-03`, `REQ-F-039`, `REQ-F-040` | `SL-10` | `normal` | Run 50 `GET /api/today?rebuild=true` + render cycles across 6 modules, 3,000 cards, 4,000 questions, 50 deadlines, 100 readings. **Expected:** `p95 <= 1,000 ms`. | $O(N)$ for $N=50$ rebuilds; budget `<= 35 s` |
| `TC-S-004` (`TC-S-N04`) | `REQ-N-004`, `SLO-04`, `REQ-F-043`, `EVAL-04` | `SL-12` | `normal` | Execute 10 written-answer Claude marking calls with cached prefix + `EVAL-04` benchmark. **Expected:** `p90 <= 10.0 s`; `>= 90%` rating agreement; `10 s` timeout triggers self-mark fallback. | $O(N)$ for $N=10$ API calls; budget `<= 90 s` |
| `TC-S-005` (`TC-S-N05`) | `REQ-N-005`, `SLO-05`, `REQ-F-046`, `EVAL-05` | `SL-13` | `normal` | Execute 10 streaming tutor requests with cached prefix. **Expected:** `p90` time-to-first-token `<= 3.0 s`; `>= 93.3%` slide citation accuracy on `EVAL-05` Part A. | $O(N)$ for $N=10$ calls; budget `<= 60 s` |
| `TC-S-006` (`TC-S-N06`) | `REQ-N-006`, `SLO-06`, `REQ-F-001`, `REQ-F-008`, `REQ-F-011` | `SL-01` | `normal` | End-to-end single-lecture pipeline run (extraction + Stage A + Stage B). **Expected:** Wall-clock duration `<= 15.0 min` (`900 s`) when not rate-limited; valid `*.final.json` outputs. | $O(S \cdot R)$ ($S \le 61$ slides, $R \le 3$ rounds); budget `<= 900 s` |
| `TC-S-007` (`TC-S-N07`) | `REQ-N-007`, `SLO-07`, `REQ-F-024`, `REQ-F-029`, `REQ-F-039` | `SL-10` | `boundary` | Seed 24 modules, 12,000 cards, 16,000 questions, and 500,000 review/attempt logs; re-run `TC-S-001`–`TC-S-003`. **Expected:** `p95 <= 100 ms`, `<= 300 ms`, and `<= 1,000 ms` all hold. | Batch seed $O(M)$ in `<= 15 s` + indexed queries in `<= 45 s` (total `<= 60 s`) |
| `TC-S-008` (`TC-S-N08`) | `REQ-N-008`, `SLO-08`, `REQ-F-021`, `REQ-F-024`, `REQ-F-029`, `REQ-F-039` | `SL-11` | `normal` | Run full `R1` study workflow on `127.0.0.1` with outbound network blocked. **Expected:** `100%` pass (`HTTP 200`/`201`) with `0` outbound network requests. | $O(1)$ workflow script; budget `<= 15 s` |
| `TC-S-009` (`TC-S-N09`) | `REQ-N-009`, `SLO-09`, `REQ-F-060`, `REQ-F-061` | `SL-18` | `error/recovery` | Complete card reviews, MCQs, and 2 queued written answers while browser is offline, then restore network. **Expected:** `100%` offline completion; `100%` queue flush within `<= 30 s` of reconnect. | $O(Q)$ for $Q=2$ queued items; budget `<= 30 s` |
| `TC-S-010` (`TC-I-N10`) | `REQ-N-010`, `EVAL-06` | `SL-07` | `normal` | Compare 100 persisted `CardState` and `ConceptState` transitions against direct `ts-fsrs` v5 reference vectors. **Expected:** `100/100` match (`<= 1e-6` float tolerance, exact integer days). | $O(N)$ for $N=100$; budget `<= 5 s` |
| `TC-S-011` (`TC-S-N11`) | `REQ-N-011`, `BR-024` | `SL-06` | `error/recovery` | Send `SIGKILL` to server mid-import and mid-rating; restart and run backup restore. **Expected:** `0` committed review logs lost; `PRAGMA integrity_check = 'ok'`; backup restores cleanly. | $O(D)$ in DB size; budget `<= 15 s` |
| `TC-S-012` (`TC-I-N12`) | `REQ-N-012`, `REQ-F-071`, `REQ-F-074`, `EVAL-02`, `EVAL-03` | `SL-02` | `normal` | Inspect `reviewer-input.r<n>.json` bundles and run `EVAL-02`/`EVAL-03`. **Expected:** `0` Creator reasoning tokens in bundle; `>= 95%` card defect recall, `>= 93.3%` question defect recall, `0` unflagged context-dependent cards. | Bundle check `<= 1 s`; live eval `<= 180 s` |
| `TC-S-013` (`TC-S-N13`) | `REQ-N-013`, `BR-002` | `SL-03` | `authorization` | Inject canary secrets `sk-ant-CANARY-999` (`ANTHROPIC_API_KEY`), `canvas-CANARY-888` (`CANVAS_API_TOKEN`), `$argon2id$v=19$m=65536,t=3,p=4$CANARY-777` (`STUDY_APP_PASSWORD_HASH`), and `sess-CANARY-666` (`SESSION_SECRET`); scan frontend `dist/`, all 38 API responses, `app.log`, and git tree. **Expected:** `0` canary occurrences anywhere. | $O(F)$ file/response scan; budget `<= 10 s` |
| `TC-S-014` (`TC-S-N14`) | `REQ-N-014`, `EVAL-05`, `BR-001` | `SL-02` | `invalid` | Pass 15 adversarial prompt-injection and XSS/KaTeX payloads through `CLI-01`, `CLI-02`, UI renderer, and Tutor/Reviewer. **Expected:** `15/15` contained inside `<untrusted_course_material>`; `0` script executions or rubric bypasses. | $O(N)$ for $N=15$; budget `<= 10 s` |
| `TC-S-015` (`TC-S-N15`) | `REQ-N-015`, `BR-045` | `SL-18` | `authorization` | Probe all 37 protected routes in `R3` mode without session cookie; fire 10 bad-password logins in 10 s. **Expected:** `37/37` return `401`; login attempts `6..10` return `429` (`Retry-After: 60`). | $O(R)$ for 47 requests; budget `<= 5 s` |
| `TC-S-016` (`TC-S-N16`) | `REQ-N-016`, `DEC-008`, `BR-002` | `SL-01` | `invalid` | Scan git tree for `.pdf`/`.pptx`/`.docx`/`*.db` and scan `app.log` & Canvas sync output for slide prose or third-party PII. **Expected:** `0` course binaries, `0` logged slide text, `0` third-party PII fields. | $O(F)$ scan; budget `<= 5 s` |
| `TC-S-017` (`TC-I-N17`) | `REQ-N-017`, `CLI-07`, `ASM-024` | `SL-05` | `normal` | Run `pipeline-cli clean-rounds --module COMP4901B`. **Expected:** `0` intermediate `*.draft.json` / `*.review.r*.json` files remain; all 6 export files remain intact outside git. | $O(F)$ dir scan; budget `<= 2 s` |
| `TC-S-018` (`TC-S-N18`) | `REQ-N-018`, `BR-033` | `SL-09` | `normal` | Run `@axe-core/playwright` WCAG 2.2 AA audit across `SCR-01`–`SCR-11`. **Expected:** `0` critical/serious violations; contrast `>= 4.5:1`; all deadlines have text + icon urgency badges. | $O(S)$ across 11 screens; budget `<= 30 s` |
| `TC-S-019` (`TC-S-N19`) | `REQ-N-019`, `REQ-F-077` | `SL-07` | `normal` | Complete 10 card reviews and 5 quiz questions in Playwright with pointer events disabled (`Space`, `1`–`4`, `f`, `r`). **Expected:** `100%` keyboard completion; visible focus rings; shortcuts suppressed inside text inputs. | $O(K)$ for 15 items; budget `<= 20 s` |
| `TC-S-020` (`TC-I-N20`) | `REQ-N-020`, `INT-01` | `SL-06` | `normal` | Round-trip schema verification from `CLI-06` export to `applyModuleImport` to `exportFeedbackJson`. **Expected:** `100%` `Ajv` validation pass on valid files; `100%` field-level `422` rejection on invalid files. | $O(N)$ round-trip; budget `<= 5 s` |
| `TC-S-021` (`TC-S-N21`) | `REQ-N-021`, `ASM-027` | `SL-17` | `normal` | Render `SCR-01`–`SCR-11` in Chromium, WebKit, and Firefox at `375×812` and `1280×800`. **Expected:** `0` horizontal overflow (`scrollWidth <= clientWidth`); all smoke tests pass. | $O(B \cdot V \cdot S)$; budget `<= 60 s` |
| `TC-S-022` (`TC-S-N22`) | `REQ-N-022`, `ASM-058` | `SL-01` | `normal` | Static AST & config check of `packages/pipeline/` and `.claude/`. **Expected:** `0` OAuth token reads/exports, `0` background daemons, `0` `--dangerously-skip-permissions`. | $O(F)$ AST scan; budget `<= 2 s` |
| `TC-S-023` (`TC-S-N23`) | `REQ-N-023`, `REQ-F-051`, `BR-040`, `EVAL-05` | `SL-13` | `invalid` | Send 15 direct and indirect coursework-writing prompts (`EVAL-05` Part B) on a `coursework`-linked thread. **Expected:** `15/15` (`100%`) refused with conceptual/Socratic redirect. | $O(N)$ for $N=15$; budget `<= 30 s` |
| `TC-S-024` | `ARCH-01`, `REQ-N-020`, `G3.1`, `G3.6` | `SL-01` | `normal` | TypeScript AST import-graph and repository ownership check. **Expected:** `0` cross-tier violations; each SQLite table has exactly `1` writer repository (`M01`–`M10`). | $O(F)$ AST scan; budget `<= 2 s` |
| `TC-S-025` | `ARCH-02`, `REQ-N-010`, `REQ-N-020`, `G3.6` | `SL-01` | `normal` | Scan codebase for `@enforces BR-nnn` / `DR-nn` annotations against `A31 §6`. **Expected:** Every implemented rule lives in its single designated module in `A31 §6`. | $O(F)$ scan; budget `<= 2 s` |
| `TC-S-026` | `ARCH-03`, `REQ-N-011`, `REQ-N-020`, `A33` | `SL-01` | `normal` | Introspect migrated SQLite `sqlite_master` and `PRAGMA`s against `A33` `schema.sql`. **Expected:** Exact match on 34 tables, 3 views, 15 indexes, FKs, and `application_id = 0x53544459`. | $O(1)$ introspection; budget `<= 1 s` |
| `TC-S-027` | `ARCH-04`, `REQ-N-020`, `A34`, `A36` | `SL-01` | `normal` | Lint `openapi.yaml`, compile `pipeline-contracts.schema.json`, and check `pipeline-cli` parser against `A34` & `A36`. **Expected:** `100%` parity across all 38 HTTP ops and 7 CLI commands. | $O(1)$ contract lint; budget `<= 2 s` |

---

## 4. Adversarial Review Scope for Gate G4 (`A39.3`, `G3.16`, `G4.3`)

In BUILD mode, the independent Gate G4 Reviewer attempts to break each slice within the review scope defined below (protocol §4.2, §8.2 `G4.3`, catalog `A39`, `B10`).

### 4.1 Input and Failure Classes the System MUST Handle (In Scope for G4)

1. **All User-Typed UI Inputs and HTTP/CLI Arguments (`TB-01`, `FLD-01`–`FLD-30`):**
   - Empty strings, whitespace-only strings (`"   \t\n"`), leading/trailing whitespace, and strings at `max_length`, `max_length + 1`, and `10× max_length`.
   - ASCII and Unicode control characters (`\x00` null byte, `\x01`–`\x1F`, `\x7F`), zero-width spaces (`U+200B`, `U+FEFF`), right-to-left override characters (`U+202E`), lone UTF-16 surrogates, and invalid UTF-8 byte sequences in HTTP bodies.
   - HTML, SVG, Event-Handler, and Markdown XSS vectors (`<script>`, `<img src=x onerror=...>`, `<svg onload=...>`, `[link](javascript:alert(1))`) in card fronts/backs, question stems, explanations, task titles, and tutor messages — must be neutralized `100%` by `DOMPurify` (`REQ-N-014`).
   - Pathological KaTeX expressions (unclosed braces `\( \frac{1}{2 `, deeply nested macros, `\def` / `\newcommand` expansion attempts) — must render with `throwOnError: false` and `maxExpand: 1000` without crashing the React tree.
   - SQL injection payloads (`' OR 1=1 --`, `"; DROP TABLE card; --`) in search queries (`FLD-20`), module IDs, and card IDs — must be bound strictly as parameters (`better-sqlite3` prepared statements).
   - Path-traversal strings (`../`, `..\\`, `/etc/passwd`, null-byte paths) in `backupFileName` (`FLD-27`), `moduleId`, or CLI file flags — must be rejected with HTTP `400` / CLI exit `2` (`TC-I-116`).
2. **Untrusted Course Files and Canvas LMS Payloads (`TB-03`, `TB-04`):**
   - Corrupt, truncated, zero-byte, or password-encrypted PDFs (`AT-031`, `CLI-02` must exit `1` cleanly with a diagnostic message).
   - Image-only slides (`RSK-002`), garbled Keynote `fi`/`fl`/`ff` ligatures (`SRC-06`), and malformed zlib streams inside `LaTeXiT` annotations (`CLI-02` must catch zlib errors and fall back to the `150 DPI` slide PNG without crashing).
   - Indirect prompt-injection payloads embedded in PDF slide text, hidden white-on-white slide text, or Canvas announcements (`REQ-N-014`, `BR-001`).
   - Unannounced deadline dates (`"TBA"`, `"to be announced on Canvas"`, `SRC-05`) — must produce `due_at: null` with a reason, never a fabricated date (`BR-004`).
3. **Files Written by the System and Foreign-File Detection (`TB-04`, `TB-05`):**
   - All 6 pipeline JSON exports, `feedback.json`, `study-deadlines.ics`, `deck.anki.tsv`, and `VACUUM INTO` backups written by the system — must round-trip cleanly (`REQ-N-020`).
   - Pointing `STUDY_APP_DB_PATH` or `restoreDatabaseBackup` at a non-SQLite file or a foreign SQLite database whose `PRAGMA application_id != 0x53544459` — must be rejected immediately with `InvalidDatabaseFileError` (`TC-I-115`, `A33 §5`).
4. **Mid-Write Crashes, Disk-Full (`ENOSPC`), and External Service Failures:**
   - `SIGKILL` during `applyModuleImport`, `submitCardRating`, or `submitQuizAttempt` — SQLite WAL (`synchronous = FULL`) must recover with `0` lost committed rows (`TC-S-011`, `REQ-N-011`).
   - Simulated `ENOSPC` / read-only filesystem during `VACUUM INTO` backup or import — must clean up partial temp files, roll back the transaction, and return HTTP `503` (`TC-I-113`).
   - Anthropic API timeout (`> 10 s`), HTTP `429`, HTTP `502`/`503`/`529`, or malformed JSON output — must fall back cleanly to self-marking without losing the student's typed answer (`TC-I-169`, `UC-12 ext 3a`).
   - HKUST Canvas API HTTP `401`/`403`/`429`/`5xx` or network timeout — `CLI-01` must log a warning and fall back to local files (`TC-I-171`, `UC-03 ext 2a`).

### 4.2 Input and Failure Classes Left as Accepted Risks (`A03` for `CP3`, `A39.3`, `G3.16`)

The following classes are explicitly outside the automated recovery guarantees of the software and are recorded in **`A03` (`workbook/01-initiation/risk-register.md`)** for the student's acceptance at **Checkpoint CP3** (`G3.16`):

| Accepted Risk ID (`A03`) | Out-of-Scope Failure / Input Class | Why Left as an Accepted Risk & Residual Safeguard |
| :-- | :-- | :-- |
| **`RSK-023`** *(Added for CP3 via `CR-004`)* | **Out-of-band manual editing or corruption of `study.db` or internal `<workspace>/lectures/*.final.json` files using external tools** (e.g., hex editors, manual `sqlite3` CLI deletes bypassing app repositories, or hand-editing intermediate JSONs without running `pipeline-cli`). | The system validates `PRAGMA application_id = 0x53544459` and `PRAGMA quick_check` on startup (`A33 §5`), validates all 6 export/import JSON files via `Ajv` (`REQ-N-020`), and creates a verified `VACUUM INTO` backup before every import (`BR-024`), so the student can restore from the latest backup (`RB-04`). |
| **`RSK-024`** *(Added for CP3 via `CR-004`)* | **Local OS account compromise or malware running as the student's OS user (`R1`–`R2`).** | In local mode (`127.0.0.1`), the app runs under the student's OS account with `local_bypass` (`[USER Q-04]`, `ADR-006`). Binding strictly to `127.0.0.1` blocks network attackers, and `.env` / `study.db` use `0600` permissions; OS-level root/user malware is outside application-layer control. |
| **`RSK-004`** *(Existing in `A03`)* | **Exhaustion of Anthropic's rolling 5-hour or weekly Claude subscription usage caps** when processing many lectures + build/critic sessions concurrently. | Subscription limits are enforced by Anthropic's servers (`ASM-044`, `ASM-062`); mitigated by deterministic `--resume` checkpointing (`CLI-03`), CS-first ordering (`BR-005`), and capping revision loops at 2 rounds (`BR-013`). |
| **`RSK-014`** *(Existing in `A03`)* | **HKUST institutional policy or Canvas LMS blocking personal API token access.** | Outside the system's control (`ASM-048`); mitigated by automatic fallback to local files in `<workspace>/source/` (`ADR-005`, `UC-03 ext 2a`). |
| **`RSK-008`** *(Existing in `A03` for `R3`)* | **Compromise of the student's owner password in Hosted Mode (`R3`)** if the password itself is shared or phished. | Mitigated by `Argon2id` hashing, `__Host-study_session` (`HttpOnly; Secure; SameSite=Strict`), `<= 5`/min/IP login rate limiting (`REQ-N-015`), and `Settings.monthly_spend_cap_micro_usd` with default `monthly_spend_cap_mode = 'block'` (`BR-041`, `ASM-067`). |
