# A40 · Slice Plan

Owner: System Architect. Stage 3, written 2026-10-21. Catalog entry: A40 (`03-design/slice-plan.md`).

---

## 1. Slice Ordering Rationale and WBS Confirmation (`A40.1`, `A40.2`, `G3.11`)

Per catalog `A40` and gate check `G3.11`, vertical slices (`SL-01`–`SL-21`) are ordered by:
1. **Risk first (`A40.2`, `G3.11`):**
   - **`SL-01` (Walking Skeleton)** traverses the highest-risk architectural boundary first: deterministic slide/LaTeXiT extraction (`M09`, `CLI-02` `extract-lecture`) $\rightarrow$ Stage A Card Creator + context-isolated Card Reviewer (`M10`, `M11`, `CLI-04`) $\rightarrow$ `Ajv`-validated `deck.json`/`concepts.json` export (`M12`, `CLI-06`, `INT-01`) $\rightarrow$ atomic SQLite WAL import (`M02`, `applyModuleImport`, `R01`–`R09`) $\rightarrow$ `ts-fsrs` flashcard review (`M03`, `SCR-02`). It retires **`RSK-002`** (slide text/equation/figure extraction), **`RSK-004`** (single-lecture Claude Code session footprint), and **`RSK-018`** (Reviewer isolation and JSON schema contract) before any downstream feature work begins.
   - **`SL-02`–`SL-05`** retire the remaining pipeline quality, Canvas integration, and multi-agent orchestration risks (`RSK-001`, `RSK-003`, `RSK-010`, `RSK-012`, `RSK-014`, `RSK-015`, `RSK-019`, `RSK-021`).
   - **`SL-06`–`SL-11`** retire the core local study app risks: re-import progress preservation and crash-safe backups (`RSK-007`, `RSK-023`), FSRS scheduling fidelity (`RSK-005`), concept-level variant selection (`RSK-006`), deadline timezone/confidence tracking (`RSK-011`), and the daily Today plan (`RSK-016`).
2. **Dependencies second (`A40.2`):**
   - Within Release 1 (`R1`), pipeline generation and export (`SL-01`–`SL-05`) precede full module import diffing (`SL-06`), which precedes flashcard review (`SL-07`), concept quizzes (`SL-08`), deadlines (`SL-09`), the composite Today checklist (`SL-10`), and item problem reporting (`SL-11`).
   - Within Release 2 (`R2`), Claude written-answer marking and prompt-cache plumbing (`SL-12` — **entry gate (`[SEED §10]`, `AGENTS.md §3`, `DEC-005`, `ASM-059`, `ASM-070`):** `R29 settings` in `schema.sql` seeds `'claude-haiku-5-5'` / `'claude-sonnet-5-5'` on the approved `ASM-059` cost basis (`$0.3–$1/mo` marking + `$2–$17/mo` tutor = `$2.3–$18/mo`, within `A02`/`A22`'s `$2–$40/mo`); under `ADVISORY` mode (`DEC-005`), if the `CP3 Corrective Addendum` is still unanswered when `SL-12` starts, `SL-12` proceeds on the seeded `5.5` defaults, whereas switching the shipped defaults to the higher-cost `claude-haiku-4-5` / `claude-sonnet-4-6` (`ASM-070`, `$6–$35.5/mo`) is gated on a verbatim user reply in `workbook/00-governance/checkpoints.md` selecting `4.x`, in which case `SL-12` runs the idempotent migration `UPDATE settings SET grading_model = 'claude-haiku-4-5', tutor_model = 'claude-sonnet-4-6' WHERE id = 'default' AND grading_model = 'claude-haiku-5-5' AND tutor_model = 'claude-sonnet-5-5'`) precede the streaming Claude tutor (`SL-13`) and tutor card/question proposals (`SL-14`), followed by assessment mode/mock exams (`SL-15`), time-budgeting/milestones/`.ics` export (`SL-16`), and the composite Stats & Spend dashboard (`SL-17`).
   - Within Release 3 (`R3`), hosted authentication, PWA offline sync, and notifications (`SL-18` — **entry gate (`[SEED §10]`, `AGENTS.md §3`, `DEC-005`, `ASM-028`, `A37 §3`):** because `study.db` contains course-derived content, deploying `study.db` to Fly.io (`hkg`) is gated on a verbatim user reply in `workbook/00-governance/checkpoints.md` approving the `ASM-028` third-party Fly.io hosting ask-first item; if unanswered or declined when `SL-18` starts, `SL-18` proceeds on the local Tailscale Serve option (`ADR-006`) on the student's laptop bound strictly to loopback `127.0.0.1`/`::1` under `TRUSTED_PROXY_MODE='tailscale'` with zero third-party cloud storage, `TC-I-257`) precede full `feedback.json` + top-up runs (`SL-19`), FSRS parameter fitting (`SL-20`), and Anki `.tsv` export (`SL-21`).
3. **Priority / Release grouping third (`DEC-010`):**
   - **Release `R1` (`SL-01`–`SL-11`):** `100%` of **Must** requirements (`60` Must `REQ-F`s: `REQ-F-001`–`REQ-F-042`, `REQ-F-067`–`REQ-F-082`, `REQ-F-085`, `REQ-F-086`; and `17` Must `REQ-N`s: `REQ-N-001`–`003`, `006`–`008`, `010`–`014`, `016`–`020`, `022`; `77` Must total).
   - **Release `R2` (`SL-12`–`SL-17`):** `100%` of **Should** requirements (`25` Should `REQ-F`s: `REQ-F-043`–`REQ-F-058`, `REQ-F-083`, `REQ-F-084`, `REQ-F-087`–`REQ-F-093`; and `4` Should `REQ-N`s: `REQ-N-004`, `005`, `021`, `023`; `29` Should total).
   - **Release `R3` (`SL-18`–`SL-21`):** `100%` of **Could** requirements (`9` Could `REQ-F`s: `REQ-F-059`–`REQ-F-066`, `REQ-F-094`; and `2` Could `REQ-N`s: `REQ-N-009`, `015`; `11` Could total).

**WBS Confirmation (`A05`, `CR-004`):** This slice plan confirms the 21 provisional slice work packages (`SL-01`–`SL-21`) in `A05` (`workbook/01-initiation/wbs.md` and `wbs.csv`) with zero changes to slice IDs, order, predecessor chain, or PERT estimates (`CR-004` in `A00`).

---

## 2. Walking Skeleton Architecture Traversal (`SL-01`, `G3.11`)

```mermaid
flowchart LR
  subgraph Pipeline ["Tier 1: Pipeline Runtime & CLI (M09, M10, M11, M12)"]
    PDF["Sample Lecture PDF"] --> CLI02["CLI-02 extract-lecture\n(150 DPI PNGs + text + LaTeXiT)"]
    CLI02 --> CC["Card Creator Subagent\n(concept-map.json + cards.draft.json)"]
    CC --> CLI04["CLI-04 build-reviewer-bundle\n(0 Creator reasoning tokens)"]
    CLI04 --> CR["Fresh Card Reviewer Subagent\n(Pass 1 Blind + Pass 2 Rubric)"]
    CR --> CLI06["CLI-06 spot-check-and-export\n(Ajv INT-01: deck.json, concepts.json)"]
  end

  subgraph Backend ["Tier 2 & 3: Hono API + Domain + SQLite WAL (M01, M02, M03)"]
    CLI06 --> IMP["POST /api/import/apply\n(VACUUM INTO backup + R01..R09 tx)"]
    IMP --> NEXT["GET /api/review/next\n(R06 card + R08 card_state)"]
    NEXT --> RATE["POST /api/review/:cardId/rate\n(ts-fsrs v5 + R09 card_review_log)"]
  end

  subgraph Frontend ["Tier 1: React 18 SPA (SCR-02)"]
    NEXT --> UI["SCR-02 Flashcard Review\n(Markdown + KaTeX + DOMPurify)"]
    UI --> RATE
  end
```

---

## 3. Master Slice Plan (`SL-01`–`SL-21`)

Every slice delivers end-to-end functionality across Presentation (`SCR-*` / `RPT-*` / `.claude/` commands), Interface (`HTTP` / `CLI-*`), Business Logic (`M01`–`M12`), and Data Access (`R01`–`R34` / `<workspace>` JSON).

### 3.1 Release 1 (`R1`) — Must Slices (`SL-01`–`SL-11`)

| Slice ID & Slug | WBS Leaf & Pred. | UCs Covered | `REQ-F` & `REQ-N` Covered | End-to-End Layers Touched (UI / API-CLI / Modules / Data) | Risks Retired (`A03`) | Assigned Test Cases (`A39` `test-cases.csv`, `G4.1`) |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| **`SL-01`**<br>`SL-01-walking-skeleton` | `SL-01`<br>(Pred: `M3`) | `UC-01`, `UC-06`, `UC-07` *(core loop)* | **Must `REQ-F`:** `REQ-F-001`, `REQ-F-007`–`REQ-F-010`, `REQ-F-018`, `REQ-F-022`, `REQ-F-024`, `REQ-F-026`, `REQ-F-067`, `REQ-F-070`, `REQ-F-071`, `REQ-F-077`, `REQ-F-079`<br>**Must `REQ-N`:** `REQ-N-006`, `REQ-N-010`, `REQ-N-016`, `REQ-N-020`, `REQ-N-022` (`ARCH-01`–`04`) | **UI/Cmd:** `SCR-02` (Review), `.claude/commands/process-lecture.md`<br>**API/CLI:** `getHealth`, `listModules`, `applyModuleImport`, `getNextReviewCards`, `submitCardRating`; `CLI-02` (install & verify Python 3 + `pypdf` + `poppler-utils` `pdftoppm` helper per `ASM-066(b)`), `CLI-04`<br>**Modules:** `M01`, `M02`, `M03`, `M09`–`M12`<br>**Data:** `R01`–`R09`, `R30`, `R31`, `R34`, `<workspace>` `E23`–`E25` | `RSK-002`, `RSK-004`, `RSK-018`, `RSK-012`, `RSK-021` | **27 TCs:** `TC-I-001`, `TC-I-002`, `TC-I-010`, `TC-I-011`, `TC-I-019`, `TC-I-020`, `TC-I-022`, `TC-I-023`, `TC-I-025`, `TC-I-026`, `TC-I-120`–`122`, `TC-I-126`–`128`, `TC-I-138`, `TC-I-139`, `TC-I-166`, `TC-I-N10`, `TC-S-006`, `TC-S-016`, `TC-S-022`, `TC-S-024`–`027` |
| **`SL-02`**<br>`SL-02-card-review-loop-and-spot-check` | `SL-02`<br>(Pred: `SL-01`) | `UC-01`, `UC-05` | **Must `REQ-F`:** `REQ-F-007`–`REQ-F-010`, `REQ-F-017`, `REQ-F-070`–`REQ-F-072`<br>**Must `REQ-N`:** `REQ-N-012`, `REQ-N-014` | **UI/Cmd:** `.claude/agents/card-creator.md`, `card-reviewer.md`, human review CLI table<br>**API/CLI:** `CLI-05` (`apply-verdicts` / `DT-01`), `CLI-06` (`spot-check-and-export`)<br>**Modules:** `M10`, `M11`, `M12`<br>**Data:** `cards.draft.json`, `cards.review.r1..3.json`, `cards.final.json`, `flagged.json` | `RSK-001`, `RSK-010`, `RSK-019` | **18 TCs:** `TC-I-129`–`134`, `TC-I-202`–`209` (`DT-01-C1`–`C8`), `TC-I-251`, `TC-I-N12`, `TC-S-012`, `TC-S-014` |
| **`SL-03`**<br>`SL-03-extractor-and-canvas-sync` | `SL-03`<br>(Pred: `SL-02`) | `UC-03` | **Must `REQ-F`:** `REQ-F-001`–`REQ-F-005`, `REQ-F-067`, `REQ-F-068`<br>**Must `REQ-N`:** `REQ-N-013` | **UI/Cmd:** `.claude/agents/extractor.md`<br>**API/CLI:** `CLI-01` (`sync-canvas` / `INT-03`), `CLI-02`<br>**Modules:** `M09`, `M11`, `M12`<br>**Data:** `glossary.json`, `deadlines.json`, `readings.json`, `<workspace>/source/canvas/` | `RSK-011`, `RSK-013`, `RSK-014` | **7 TCs:** `TC-I-117`–`119`, `TC-I-170`, `TC-I-171`, `TC-I-250`, `TC-S-013` |
| **`SL-04`**<br>`SL-04-question-bank-and-module-audit` | `SL-04`<br>(Pred: `SL-03`) | `UC-02` | **Must `REQ-F`:** `REQ-F-011`–`REQ-F-016`, `REQ-F-073`–`REQ-F-075` | **UI/Cmd:** `.claude/agents/question-creator.md`, `question-reviewer.md`, `module-auditor.md`; `RPT-05`<br>**API/CLI:** `CLI-04`, `CLI-05` (Stage B & Audit synthesis)<br>**Modules:** `M10`, `M11`, `M12`<br>**Data:** `questions.draft.json`, `questions.review.r1..3.json`, `questions.final.json`, `module-audit.json` (`E26`) | `RSK-001`, `RSK-003`, `RSK-015` | **2 TCs:** `TC-I-252`, `TC-I-253` *(plus Stage B execution of `TC-I-126`–`131`, `TC-I-202`–`209`)* |
| **`SL-05`**<br>`SL-05-run-order-summary-and-exports` | `SL-05`<br>(Pred: `SL-04`) | `UC-04`, `UC-05` | **Must `REQ-F`:** `REQ-F-006`, `REQ-F-018`, `REQ-F-019`, `REQ-F-069`<br>**Must `REQ-N`:** `REQ-N-017` | **UI/Cmd:** `.claude/commands/process-module.md`, `RPT-04` (`run-summary.json`)<br>**API/CLI:** `CLI-03` (`plan-run`), `CLI-06`, `CLI-07` (`clean-rounds`)<br>**Modules:** `M10`, `M12`<br>**Data:** All 6 `export/*.json` files, `run-summary.json` (`E27`) | `RSK-004`, `RSK-012` | **8 TCs:** `TC-I-123`–`125`, `TC-I-135`–`137`, `TC-I-N17`, `TC-S-017` |
| **`SL-06`**<br>`SL-06-import-with-preview-and-glossary` | `SL-06`<br>(Pred: `SL-05`) | `UC-05`, `UC-06` | **Must `REQ-F`:** `REQ-F-021`–`REQ-F-023`, `REQ-F-028`, `REQ-F-076`, `REQ-F-086`<br>**Must `REQ-N`:** `REQ-N-011`, `REQ-N-020` | **UI:** `SCR-04` (Module Detail & Glossary), `SCR-06` (Import & Diff Preview), `SCR-10` (Backups)<br>**API:** `getModuleSummary`, `previewModuleImport`, `applyModuleImport`, `createDatabaseBackup`, `restoreDatabaseBackup`<br>**Modules:** `M01`, `M02`<br>**Data:** `R01`–`R21`, `R30`, `R31`, `VACUUM INTO` backups | `RSK-007`, `RSK-023` | **26 TCs:** `TC-I-013`, `TC-I-014`, `TC-I-016`, `TC-I-017`, `TC-I-109`, `TC-I-110`, `TC-I-112`, `TC-I-113`, `TC-I-115`, `TC-I-116`, `TC-I-167`, `TC-I-178`, `TC-I-179`, `TC-I-198`, `TC-I-199`, `TC-I-210`–`217` (`DT-02-C1`–`C8`), `TC-I-N20`, `TC-S-011`, `TC-S-020` |
| **`SL-07`**<br>`SL-07-flashcard-review` | `SL-07`<br>(Pred: `SL-06`) | `UC-07` | **Must `REQ-F`:** `REQ-F-024`–`REQ-F-027`, `REQ-F-077`–`REQ-F-079`<br>**Must `REQ-N`:** `REQ-N-001`, `REQ-N-010`, `REQ-N-019`<br>**Should `REQ-N`:** `REQ-N-021` | **UI:** `SCR-02` (Flashcard Review), `SCR-10` (Settings: FSRS & daily limits)<br>**API:** `getNextReviewCards`, `submitCardRating`, `updateCardStateOrContent`, `getSettings`, `updateSettings`<br>**Modules:** `M03` (`ts-fsrs` v5 sole `retrievability` & interval engine), `M08`<br>**Data:** `R06`, `R07`, `R08`, `R09`, `R29`, `v_card_state_with_retrievability` (`V01` `current_elapsed_days`) | `RSK-005` | **20 TCs:** `TC-I-028`, `TC-I-029`, `TC-I-097`, `TC-I-098`, `TC-I-100`, `TC-I-101`, `TC-I-140`–`145`, `TC-I-192`–`195`, `TC-I-262`, `TC-S-001`, `TC-S-010`, `TC-S-019` |
| **`SL-08`**<br>`SL-08-daily-quiz` | `SL-08`<br>(Pred: `SL-07`) | `UC-08` | **Must `REQ-F`:** `REQ-F-029`–`REQ-F-034`, `REQ-F-080`<br>**Should `REQ-F`:** `REQ-F-044`, `REQ-F-087` *(self-mark override path)*<br>**Must `REQ-N`:** `REQ-N-002`<br>**Should `REQ-N`:** `REQ-N-021` | **UI:** `SCR-03` (Daily Concept Quiz)<br>**API:** `getNextQuizQuestions`, `submitQuizAttempt`, `overrideQuizAttemptRating`<br>**Modules:** `M04` (`DT-03`, `DT-04`), `M08`<br>**Data:** `R03`, `R10`–`R15`, `R28` (`topup` queue) | `RSK-006` | **28 TCs:** `TC-I-031`, `TC-I-032`, `TC-I-034`, `TC-I-037`, `TC-I-038`, `TC-I-146`–`151`, `TC-I-218`–`233` (`DT-03-C1`–`C8`, `DT-04-C1`–`C8`), `TC-S-002` |
| **`SL-09`**<br>`SL-09-deadlines-and-countdowns` | `SL-09`<br>(Pred: `SL-08`) | `UC-09` | **Must `REQ-F`:** `REQ-F-035`–`REQ-F-038`<br>**Must `REQ-N`:** `REQ-N-018`<br>**Should `REQ-N`:** `REQ-N-021` | **UI:** `SCR-05` (Deadlines, Milestones, Readings & Tasks)<br>**API:** `listDeadlines`, `upsertDeadline`<br>**Modules:** `M05` (`DT-05`)<br>**Data:** `R17`, `R18` | `RSK-011` | **21 TCs:** `TC-I-049`, `TC-I-050`, `TC-I-052`, `TC-I-053`, `TC-I-156`–`163`, `TC-I-234`–`241` (`DT-05-C1`–`C8`), `TC-S-018` |
| **`SL-10`**<br>`SL-10-today-checklist` | `SL-10`<br>(Pred: `SL-09`) | `UC-10` | **Must `REQ-F`:** `REQ-F-027`, `REQ-F-039`–`REQ-F-041`, `REQ-F-081`, `REQ-F-082`<br>**Must `REQ-N`:** `REQ-N-003`, `REQ-N-007`<br>**Should `REQ-N`:** `REQ-N-021` | **UI:** `SCR-01` (Today Checklist / `RPT-01`), `SCR-05` (Readings & Tasks)<br>**API:** `getTodayPlan`, `updateTodayPlanItem`, `listReadings`, `updateReadingStatus`, `upsertTask`<br>**Modules:** `M05`, `M06` (`DT-06`)<br>**Data:** `R20`, `R21`, `R22`, `R23`, `v_daily_plan_summary` (`V03`) | `RSK-016` | **25 TCs:** `TC-I-058`, `TC-I-059`, `TC-I-061`, `TC-I-062`, `TC-I-064`, `TC-I-065`, `TC-I-067`, `TC-I-068`, `TC-I-070`, `TC-I-071`, `TC-I-164`, `TC-I-165`, `TC-I-174`–`177`, `TC-I-190`, `TC-I-191`, `TC-I-242`, `TC-I-243`, `TC-I-248`, `TC-I-249`, `TC-I-261`, `TC-S-003`, `TC-S-007` |
| **`SL-11`**<br>`SL-11-report-item-and-export-reports` | `SL-11`<br>(Pred: `SL-10`) | `UC-04`, `UC-11` | **Must `REQ-F`:** `REQ-F-020`, `REQ-F-042`, `REQ-F-085`<br>**Must `REQ-N`:** `REQ-N-008` | **UI:** Report Popover (`SCR-02`/`SCR-03`), `SCR-06`/`SCR-10` (`RPT-08` `reported` export)<br>**API/CLI:** `reportStudyItem`, `exportFeedbackJson`; `CLI-03` (`--feedback`)<br>**Modules:** `M08`, `M10`<br>**Data:** `R28` (`feedback_item`), `feedback.json` | `RSK-001` | **9 TCs:** `TC-I-073`, `TC-I-074`, `TC-I-076`, `TC-I-077`, `TC-I-152`–`155`, `TC-S-008` |

---

### 3.2 Release 2 (`R2`) — Should Slices (`SL-12`–`SL-17`)

| Slice ID & Slug | WBS Leaf & Pred. | UCs Covered | `REQ-F` & `REQ-N` Covered | End-to-End Layers Touched (UI / API-CLI / Modules / Data) | Risks Retired (`A03`) | Assigned Test Cases (`A39` `test-cases.csv`, `G4.1`) |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| **`SL-12`**<br>`SL-12-claude-written-marking` | `SL-12`<br>(Pred: `M4`; **Entry gate [`AGENTS.md §3`, `SEED §10`, `DEC-005`, `ASM-070`]:** proceeds on seeded `R29` `5.5` defaults [`ASM-059`] if unanswered; migrates `id='default'` to `4.5`/`4.6` only if a verbatim user reply in `checkpoints.md` selects `4.x`) | `UC-12` | **Should `REQ-F`:** `REQ-F-043`, `REQ-F-044`, `REQ-F-047`, `REQ-F-048`, `REQ-F-083`, `REQ-F-087`, `REQ-F-089`<br>**Should `REQ-N`:** `REQ-N-004` | **UI:** `SCR-03` (Written answer Claude marking & self-mark fallback)<br>**API:** `submitQuizAttempt` (`grader='claude'`), `overrideQuizAttemptRating`, `INT-02`<br>**Modules:** `M04`, `M08`<br>**Data:** `R14`, `R15`, `R32` (`grading_call_log`), `R29` (`ASM-059` / `ASM-070`) | `RSK-003`, `RSK-005`, `RSK-009`, `RSK-020` | **6 TCs:** `TC-I-035`, `TC-I-168`, `TC-I-169`, `TC-I-256`, `TC-I-258`, `TC-S-004` *(plus Claude-grader override assertions in `TC-I-037`)* |
| **`SL-13`**<br>`SL-13-claude-tutor` | `SL-13`<br>(Pred: `SL-12`) | `UC-13` | **Should `REQ-F`:** `REQ-F-045`–`REQ-F-048`, `REQ-F-051`, `REQ-F-052`, `REQ-F-083`, `REQ-F-084`, `REQ-F-088`, `REQ-F-089`<br>**Should `REQ-N`:** `REQ-N-005`, `REQ-N-023` | **UI:** `SCR-07` (Grounded Claude Tutor & Proposal Queue)<br>**API:** `listTutorThreads`, `createTutorThread`, `deleteTutorThread`, `sendTutorMessage` (SSE), `INT-02`<br>**Modules:** `M07`, `M08`<br>**Data:** `R24` (`tutor_thread`), `R25` (`tutor_message`), `R26` (`tutor_message_citation`) | `RSK-003`, `RSK-010`, `RSK-020`, `RSK-022` | **16 TCs:** `TC-I-079`, `TC-I-080`, `TC-I-082`, `TC-I-083`, `TC-I-085`, `TC-I-086`, `TC-I-088`, `TC-I-089`, `TC-I-180`–`185`, `TC-S-005`, `TC-S-023` |
| **`SL-14`**<br>`SL-14-tutor-proposals` | `SL-14`<br>(Pred: `SL-13`) | `UC-14` | **Should `REQ-F`:** `REQ-F-049`, `REQ-F-050` | **UI:** `SCR-07` (Inline Proposal Banner & Proposal Queue Drawer)<br>**API/CLI:** `reviewTutorProposal`; `CLI-04`/`CLI-05` (`feedback.json -> proposed`)<br>**Modules:** `M07`, `M08`, `M10`<br>**Data:** `R27` (`proposal`), `R28` (`feedback_item`) | `RSK-001` | **2 TCs:** `TC-I-091`, `TC-I-092` *(plus `proposed` routing in `TC-I-126`, `TC-I-129`)* |
| **`SL-15`**<br>`SL-15-assessment-mode-and-mock-exams` | `SL-15`<br>(Pred: `SL-14`) | `UC-15` | **Should `REQ-F`:** `REQ-F-053`, `REQ-F-054`, `REQ-F-090`–`REQ-F-092` | **UI:** `SCR-09` (Assessment Mode & Timed Mock Exam / `RPT-03`)<br>**API:** `startMockExam`, `submitMockExam`<br>**Modules:** `M04`, `M06`<br>**Data:** `R03`, `R05`, `R10`–`R15`, `R17`, `R18`, `v_concept_mastery` (`V02`) | `RSK-006`, `RSK-017` | **9 TCs:** `TC-I-043`, `TC-I-044`, `TC-I-046`, `TC-I-047`, `TC-I-186`–`189`, `TC-I-259` |
| **`SL-16`**<br>`SL-16-time-budget-milestones-and-ics` | `SL-16`<br>(Pred: `SL-15`) | `UC-16` | **Should `REQ-F`:** `REQ-F-055`–`REQ-F-057`, `REQ-F-093` | **UI:** `SCR-01` (Budget bar & deferral toggle), `SCR-05` (Milestones), `RPT-07` (`.ics`)<br>**API:** `upsertMilestone`, `exportCalendarIcs` (`GET /api/calendar.ics`, `INT-04`)<br>**Modules:** `M05`, `M06` (`DT-06`)<br>**Data:** `R19` (`milestone`), `R22`, `R23` | `RSK-011`, `RSK-016` | **9 TCs:** `TC-I-055`, `TC-I-056`, `TC-I-103`, `TC-I-104`, `TC-I-172`, `TC-I-244`–`247` (`DT-06-C3`–`C6`) |
| **`SL-17`**<br>`SL-17-stats-and-spend-dashboard` | `SL-17`<br>(Pred: `SL-16`) | `UC-17` | **Should `REQ-F`:** `REQ-F-048`, `REQ-F-058`, `REQ-F-083`, `REQ-F-089`<br>**Should `REQ-N`:** `REQ-N-021` | **UI:** `SCR-08` (Stats, Retention, Forecast & API Spend / `RPT-02`), `SCR-04` (Mastery Map)<br>**API:** `getStatsAndSpend`<br>**Modules:** `M08`<br>**Data:** `R08`, `R09`, `R10`, `R14`, `R25`, `R28`, `R30`, `R32`, `v_concept_mastery` (`V02`) | `RSK-003` | **5 TCs:** `TC-I-094`, `TC-I-095`, `TC-I-196`, `TC-I-197`, `TC-S-021` |

---

### 3.3 Release 3 (`R3`) — Could Slices (`SL-18`–`SL-21`)

| Slice ID & Slug | WBS Leaf & Pred. | UCs Covered | `REQ-F` & `REQ-N` Covered | End-to-End Layers Touched (UI / API-CLI / Modules / Data) | Risks Retired (`A03`) | Assigned Test Cases (`A39` `test-cases.csv`, `G4.1`) |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| **`SL-18`**<br>`SL-18-hosted-auth-pwa-offline-and-notifications` | `SL-18`<br>(Pred: `M5`; **Entry gate:** user's verbatim approval of the `ASM-028` third-party Fly.io hosting ask-first item recorded in `checkpoints.md` [`AGENTS.md §3`, `SEED §10`, `A37 §3`] before deploying `study.db` to Fly.io, or run via local Tailscale Serve bound strictly to loopback `127.0.0.1`/`::1` under `TRUSTED_PROXY_MODE='tailscale'`, `TC-I-257`) | `UC-18` | **Could `REQ-F`:** `REQ-F-059`–`REQ-F-062`, `REQ-F-094`<br>**Could `REQ-N`:** `REQ-N-009`, `REQ-N-015`<br>**Should `REQ-N`:** `REQ-N-021` | **UI:** `SCR-11` (Owner Login), `SCR-10` (Notification toggles), `RPT-06`, Service Worker + IndexedDB queue<br>**API:** `loginOwner`, `logoutOwner`, `flushOfflineQuizQueue`<br>**Modules:** `M04`, `M05`, `M08`<br>**Data:** `R14` (`question_attempt`), `R29` (`settings`), `R33` (`auth_session`) | `RSK-008` | **49 TCs:** `TC-I-003`–`009`, `TC-I-012`, `TC-I-015`, `TC-I-018`, `TC-I-021`, `TC-I-024`, `TC-I-027`, `TC-I-030`, `TC-I-033`, `TC-I-036`, `TC-I-039`–`042`, `TC-I-045`, `TC-I-048`, `TC-I-051`, `TC-I-054`, `TC-I-057`, `TC-I-060`, `TC-I-063`, `TC-I-066`, `TC-I-069`, `TC-I-072`, `TC-I-075`, `TC-I-078`, `TC-I-081`, `TC-I-084`, `TC-I-087`, `TC-I-090`, `TC-I-093`, `TC-I-096`, `TC-I-099`, `TC-I-102`, `TC-I-105`, `TC-I-111`, `TC-I-114`, `TC-I-200`, `TC-I-201`, `TC-I-257`, `TC-I-260`, `TC-S-009`, `TC-S-015` |
| **`SL-19`**<br>`SL-19-full-feedback-and-topup-loop` | `SL-19`<br>(Pred: `SL-18`) | `UC-19` | **Could `REQ-F`:** `REQ-F-063`, `REQ-F-064` | **UI/Cmd:** `SCR-06`/`SCR-10` (`RPT-08` full `feedback.json`), `.claude/commands/process-module.md --feedback`<br>**API/CLI:** `exportFeedbackJson`; `CLI-03`, `CLI-04`, `CLI-05`<br>**Modules:** `M08`, `M10`<br>**Data:** `R28` (`feedback_item`), `feedback.json` | `RSK-006` | **1 TC:** `TC-I-255` *(plus `TC-I-076`–`077`, `TC-I-129`–`131`)* |
| **`SL-20`**<br>`SL-20-fsrs-optimiser-and-load-forecast` | `SL-20`<br>(Pred: `SL-19`) | `UC-20` | **Could `REQ-F`:** `REQ-F-065` | **UI:** `SCR-10` (Fit Custom FSRS Parameters), `SCR-08` (`RPT-02` 30-day load forecast)<br>**API:** `getStatsAndSpend`, `updateSettings`<br>**Modules:** `M03`, `M08`<br>**Data:** `R08` (`card_state`), `R09` (`card_review_log`), `R29` (`settings`) | `RSK-005` | **1 TC:** `TC-I-254` |
| **`SL-21`**<br>`SL-21-anki-tsv-export` | `SL-21`<br>(Pred: `SL-20`) | `UC-21` | **Could `REQ-F`:** `REQ-F-066` | **UI:** `SCR-10` (`RPT-09` Anki TSV Export card)<br>**API:** `exportAnkiTsv` (`GET /api/export/anki.tsv`, `INT-05`)<br>**Modules:** `M02`<br>**Data:** `R06` (`card`), `R07` (`card_tag`), `R08` (`card_state`) | — | **4 TCs:** `TC-I-106`–`108`, `TC-I-173` |

---

## 4. Requirement-to-Slice Coverage Audit (`A40.1`, `G3.11`)

- **Must Functional Requirements (`60/60` covered in `R1` slices `SL-01`–`SL-11`):**
  - `REQ-F-001`, `REQ-F-067`: `SL-01`, `SL-03`
  - `REQ-F-002`–`REQ-F-005`, `REQ-F-068`: `SL-03`
  - `REQ-F-006`, `REQ-F-069`: `SL-05`
  - `REQ-F-007`–`REQ-F-010`, `REQ-F-070`, `REQ-F-071`: `SL-01`, `SL-02`
  - `REQ-F-017`, `REQ-F-072`: `SL-02`
  - `REQ-F-011`–`REQ-F-016`, `REQ-F-073`–`REQ-F-075`: `SL-04`
  - `REQ-F-018`: `SL-01`, `SL-05`
  - `REQ-F-019`: `SL-05`
  - `REQ-F-020`, `REQ-F-042`, `REQ-F-085`: `SL-11`
  - `REQ-F-021`, `REQ-F-023`, `REQ-F-028`, `REQ-F-076`, `REQ-F-086`: `SL-06`
  - `REQ-F-022`: `SL-01`, `SL-06`
  - `REQ-F-024`, `REQ-F-026`, `REQ-F-077`, `REQ-F-079`: `SL-01`, `SL-07`
  - `REQ-F-025`, `REQ-F-078`: `SL-07`
  - `REQ-F-027`: `SL-07`, `SL-10`
  - `REQ-F-029`–`REQ-F-034`, `REQ-F-080`: `SL-08`
  - `REQ-F-035`–`REQ-F-038`: `SL-09`
  - `REQ-F-039`–`REQ-F-041`, `REQ-F-081`, `REQ-F-082`: `SL-10`
- **Should Functional Requirements (`25/25` covered in `R2` slices `SL-12`–`SL-17`, plus `SL-08` for self-mark override):**
  - `REQ-F-043`: `SL-12`
  - `REQ-F-044`, `REQ-F-087`: `SL-08`, `SL-12`
  - `REQ-F-045`, `REQ-F-046`, `REQ-F-051`, `REQ-F-052`, `REQ-F-084`, `REQ-F-088`: `SL-13`
  - `REQ-F-047`: `SL-12`, `SL-13`
  - `REQ-F-048`, `REQ-F-083`, `REQ-F-089`: `SL-12`, `SL-13`, `SL-17`
  - `REQ-F-049`, `REQ-F-050`: `SL-14`
  - `REQ-F-053`, `REQ-F-054`, `REQ-F-090`–`REQ-F-092`: `SL-15`
  - `REQ-F-055`–`REQ-F-057`, `REQ-F-093`: `SL-16`
  - `REQ-F-058`: `SL-17`
- **Could Functional Requirements (`9/9` covered in `R3` slices `SL-18`–`SL-21`):**
  - `REQ-F-059`–`REQ-F-062`, `REQ-F-094`: `SL-18`
  - `REQ-F-063`, `REQ-F-064`: `SL-19`
  - `REQ-F-065`: `SL-20`
  - `REQ-F-066`: `SL-21`
- **Non-Functional Requirements (`23/23` covered across `SL-01`–`SL-19` and verified at system level in `A53`, matching `traceability-matrix.csv` 1-for-1):**
  - **Must (`17/17` in `R1`):** `REQ-N-001` (`SL-01, SL-07`; `TC-S-001` in `SL-07`), `REQ-N-002` (`SL-07, SL-08`; `TC-S-002` in `SL-08`), `REQ-N-003` (`SL-10`; `TC-S-003`), `REQ-N-006` (`SL-01, SL-05`; `TC-S-006` in `SL-01`), `REQ-N-007` (`SL-07, SL-08, SL-10`; `TC-S-007` in `SL-10`), `REQ-N-008` (`SL-01, SL-06..SL-11`; `TC-S-008` in `SL-11`), `REQ-N-010` (`SL-01, SL-07, SL-08`; `TC-I-N10` in `SL-01`, `TC-S-010` in `SL-07`), `REQ-N-011` (`SL-06, SL-07`; `TC-S-011` in `SL-06`), `REQ-N-012` (`SL-01, SL-02, SL-04`; `TC-I-N12` & `TC-S-012` in `SL-02`), `REQ-N-013` (`SL-03, SL-12, SL-13`; `TC-S-013` in `SL-03`), `REQ-N-014` (`SL-01, SL-03, SL-12, SL-13`; `TC-S-014` in `SL-02`), `REQ-N-016` (`SL-01, SL-03`; `TC-S-016` in `SL-01`), `REQ-N-017` (`SL-05`; `TC-I-N17` & `TC-S-017`), `REQ-N-018` (`SL-07..SL-10, SL-13, SL-17`; `TC-S-018` in `SL-09`), `REQ-N-019` (`SL-07, SL-08`; `TC-S-019` in `SL-07`), `REQ-N-020` (`SL-01, SL-05, SL-06, SL-19`; `TC-I-N20` & `TC-S-020` in `SL-06`), `REQ-N-022` (`SL-01..SL-05`; `TC-S-022` in `SL-01`).
  - **Should (`4/4` in `R2`):** `REQ-N-004` (`SL-12`; `TC-S-004`), `REQ-N-005` (`SL-13`; `TC-S-005`), `REQ-N-021` (`SL-07..SL-10, SL-17, SL-18`; `TC-S-021` in `SL-17`), `REQ-N-023` (`SL-13`; `TC-S-023`).
  - **Could (`2/2` in `R3`):** `REQ-N-009` (`SL-18`; `TC-S-009`), `REQ-N-015` (`SL-18`; `TC-S-015`).
- **Test Cases Assigned (`293/293` in `A39` `test-cases.csv`):** Every one of the 293 Integration and System test cases (`TC-I-001`–`TC-I-262`, `TC-I-N10`, `TC-I-N12`, `TC-I-N17`, `TC-I-N20`, `TC-S-001`–`TC-S-027`) is assigned to a slice in the table above (`27 + 18 + 7 + 2 + 8 + 26 + 20 + 28 + 21 + 25 + 9 + 6 + 16 + 2 + 9 + 9 + 5 + 49 + 1 + 1 + 4 = 293`).
