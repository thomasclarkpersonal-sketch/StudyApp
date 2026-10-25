# Study App — Project Workbook

The single source of truth for planning (and possibly building) the Study App, following the Master Planning Agent Protocol v2.3. Seed spec: [`study-app-seed-spec.md`](../study-app-seed-spec.md). Source documents: [`flashcard-pipeline.md`](../flashcard-pipeline.md), [`study-app-spec.md`](../study-app-spec.md).

## Run settings

| Setting | Value | Status | Source |
| :-- | :-- | :-- | :-- |
| Mode | BUILD | Set by the user | `DEC-004` [USER Q-03] |
| Checkpoint mode | ADVISORY (CP1 and CP2 always STRICT) | Set by the user | `DEC-005` [USER Q-10] |
| Tier | M | Confirmed by the user; recorded in A04 | `DEC-001` [USER Q-10] |
| Project types | BIS (study app) + DATA (generation pipeline) | Approved at CP1; recorded in A04 | `DEC-002` [USER CP1] |
| Risk flags | PD, INT, AI | Approved at CP1; recorded in A04 | `DEC-003` [USER CP1] |
| Review depth | Standard | Set by seed | [SEED §10] |
| Output location | `./workbook/` | Set by seed | [SEED §10] |
| Always ask the user first | Adding a paid service or significantly raising Claude API spend; changing card rules, question rules or reviewer rubrics; sending course material to any third party other than Anthropic; anything that could delete or overwrite review history | Set by seed | [SEED §10] |

## Stage status

| Stage | Status | Gate | Checkpoint |
| :-- | :-- | :-- | :-- |
| 0 Intake & Clarification | Complete (2026-10-21): Q-01 to Q-15 answered (Q-02 and Q-12 in part); Q-16 resolved at CP1; Q-17 answered (direct Canvas access); two of the requested documents received and skimmed | none (reviewed at G1) | — |
| 1 Initiation, Feasibility & Tailoring | Complete (2026-10-21): Gate G1 APPROVED (r2, plus `CR-001` re-review); CP1 Approved | G1 (`reviews/G1-r1.md`, `reviews/G1-r2.md`, `reviews/G1-CR001.md`) | CP1 Approved (`checkpoints.md`) |
| 2 Requirements Analysis & Sourcing | Complete (2026-10-21; CP2 Corrective Addendum approved 2026-10-23; `CR-003` carried in CP3 Corrective Addendum): Gate G2 APPROVED (`r2`–`r15`); CP2 Approved | G2 (`reviews/G2-r1.md` .. `reviews/G2-r15.md`) | CP2 Approved (`checkpoints.md`) |
| 3 Architecture & Design | Complete (original CP3 2026-10-21; post-rebase `CR-003`/`CR-004` alignment APPROVED in `G3-r4` on 2026-10-25 — see provenance note in `checkpoints.md`) | G3 (`reviews/G3-r1.md` .. `reviews/G3-r4.md`) | Original CP3 Approved [USER CP3]; CP3 Corrective Addendum pending user reply (`checkpoints.md`, ADVISORY) |
| 4 Slice loop | Not started (next: `SL-01-walking-skeleton`) | G4 per slice | — |
| 5 Release Readiness | Not started | G5 | CP4 |
| 6 Maintenance Setup & Closedown | Not started | G6 | — |

- **Current baseline:**
  - **Stage 1 (Initiation, CP1 2026-10-21):** `A01`, `A02`, `A03` (updated via `CR-004`), `A04`, `A05` (with `wbs.csv`), `A06` (with `schedule_calc.py`), `A07` (updated via `CR-001`, `CR-002`, `CR-003`).
  - **Stage 2 (Requirements, CP2 2026-10-21 & Corrective Addendum 2026-10-23):** `A09` (with `02-analysis/sources/`), `A10` (with `requirements.csv`), `A11`, `A12`, `A13` (updated via `CR-004`), `A14`–`A17`, `A18` (with `data-dictionary.csv`, updated via `CR-004`), `A19` (with `acceptance-scenarios.csv`), `A20`, `A22`, and `traceability-matrix.md`/`.csv` (updated via `CR-003`, `CR-004`).
  - **Stage 3 (Design, original CP3 2026-10-21 [USER CP3]; post-rebase `CR-003`/`CR-004` alignment APPROVED in `G3-r4` on 2026-10-25):** `A30` (`ADR-001`–`ADR-007`, `DEC-017`–`DEC-023`), `A31`, `A32`, `A33` (with `schema.sql`), `A34` (with `openapi.yaml` and `pipeline-contracts.schema.json`), `A35`–`A38`, `A39` (with `test-cases.csv`), `A40`–`A42`. *(Provenance note: commits `37e8142`, `b5f96b2`, and `c68dc01` cited in `G3-r1.md`/`G3-r2.md` predate the rebase onto `main` `3ca0121`, `G3-r1.md`/`G3-r2.md` used non-conforming `G3.1`–`G3.16` checklists, and `G3-r3.md` had evidence errata on `G3-r1` commit/date, `G3.12`, `A42.2`, `A42.3`, and `ASM-059` cost figures; `reviews/G3-r4.md` on snapshot `b03f918` is the conforming Gate G3 review of record.)*
- **Pending checkpoint:** **CP3 Corrective Addendum (ADVISORY)** in [`workbook/00-governance/checkpoints.md`](00-governance/checkpoints.md) — pending user reply (`DEC-005`):
  - **Change requests & assumptions:** `CR-003`, `CR-004`, `ASM-058` downgrade disclosure (`H`/`confirmed` $\to$ `M`/`open`), `ASM-059`, `ASM-060`, and `ASM-066`–`ASM-070`.
  - **Ask-first item 1 (`ASM-070`, before `R2` / `SL-12`):** default `grading_model` / `tutor_model` choice between seeded `claude-haiku-5-5` / `claude-sonnet-5-5` (`[ASM-059]`) and `claude-haiku-4-5` / `claude-sonnet-4-6` (`[ASM-070]`); under `ADVISORY` mode (`DEC-005`), `SL-12` proceeds on the seeded `5.5` defaults if unanswered and migrates `id='default'` to `4.x` only if a verbatim user reply in `checkpoints.md` selects `4.x`.
  - **Ask-first item 2 (`ASM-028` & `A37 §3`, before `R3` / `SL-18`):** storing course-derived `study.db` on third-party cloud host Fly.io `hkg` (`[ASM-069]`) vs local Tailscale Serve (`$0/mo`); `SL-18` requires a verbatim user approval in `checkpoints.md` before deploying to Fly.io (`R1`–`R2` slices `SL-01`–`SL-17` run strictly on `127.0.0.1`).
- **Carried to Next Checkpoint (`CP4`):** post-slice reports from Stage 4 (`SL-01`–`SL-21`, including empirical measurements for `ASM-044` and `ASM-046` in `SL-01`, `ASM-068` in `SL-02`, `ASM-048` in `SL-03`, and `ASM-060`/`ASM-069` in `SL-18`) and Stage 5 release readiness (`A60`–`A65`, system-level `A53`).
- **Branch:** `stage-3/design` (branched from `main` at `3ca0121`).

## Seed intake (Stage 0 step 1)

Each section of the seed is classified as *Filled*, *Unknown* or *Blank*. A section counts as Filled when its main content is present, even if some items in it are Unknown; every Unknown item that matters is covered by a question or an assumption.

| Seed § | Section | Classification | Unknown or open items → where covered |
| :-- | :-- | :-- | :-- |
| 1 | Project Overview | Filled | App name → `ASM-026`. Success metrics are proposals → `ASM-036`. Monthly budget in the metrics → Q-06 (no fixed limit) |
| 2 | Users & Stakeholders | Filled | Tech comfort → `ASM-015`. Phone vs laptop use → Q-04 (laptop only for the MVP) |
| 3 | Core Features (Story Cards) | Filled | Scope disagreements with the source documents → Q-07 (seed wins), `ASM-038`, `DEC-006`. Story 4 order refined → Q-12, `ASM-040`. What matters before the first midterm → Q-11 |
| 4 | Key Data | Filled | Modules → Q-08, Q-13, `ASM-012`, `DEC-007`. Years of history → `ASM-025`. Tutor conversation retention → `ASM-023`. Pipeline intermediate files → `ASM-024` |
| 5 | External Systems & Integrations | Filled | Pipeline agent runtime → Q-05 (Claude Code), Q-15 (subscription), `ASM-044`. University learning platform: manual download replaced by direct Canvas access → Q-17, `DEC-009`, `ASM-048`–`ASM-050` |
| 6 | Existing System & Data Migration | Unknown | What's used today, existing cards and history → Q-09, Q-14 (Anki, start fresh), `ASM-014`. Old system kept during transition → `ASM-032`. Documents → requested in [`questions.md`](00-governance/questions.md#documents-requested-stage-0-step-6) |
| 7 | Quality Requirements | Filled | Performance targets are proposals → `ASM-037`. University AI policy → Q-01 (allowed). University time zone → `ASM-022`. Phone model → `ASM-027`. Offline vs MVP on laptop → Q-04, `ASM-008`. Language → `ASM-020` |
| 8 | Technical Preferences & Constraints | Filled | Hosting provider → `ASM-028`. Existing accounts → `ASM-019`, `ASM-043`. Technologies to avoid → `ASM-029`. Buy vs build and products considered → Q-09 (one custom app) |
| 9 | Project Constraints | Unknown | Build and running budget → Q-06, `ASM-010`, `ASM-030`. Midterm and exam dates → Q-02, Q-12, `ASM-045`. Who builds → Q-03 (the agent), `ASM-031`. Maintainer is the student (Filled) |
| 10 | Agent Run Settings | Unknown | Mode → Q-03, `DEC-004`. Checkpoint mode and tier → Q-10, `DEC-005`, `DEC-001`. Project type set provisionally → `DEC-002`. Review depth, output location and the ask-first list are Filled |
| 11 | Non-Goals | Filled | Carried to the out-of-scope list in A01 (Stage 1), with Mandarin added (`DEC-007`) and the learning-platform non-goal dropped (`DEC-009`) |
| 12 | Known Assumptions, Risks & Open Questions | Filled | User assumptions → `ASM-016`–`ASM-021`. Risks → carried to the Risk Register (A03) in Stage 1. Every open question in §12 → Q-01, Q-02, Q-03, Q-04, Q-05, Q-06, Q-08, Q-09, Q-10, `ASM-023`, `ASM-024`, `ASM-026` |

No section is Blank.

## Source documents

| Document | Supplied | Status |
| :-- | :-- | :-- |
| `study-app-seed-spec.md` | With the repository | Read in full at Stage 0; analysed in A09 |
| `flashcard-pipeline.md` | With the repository | Copied to `02-analysis/sources/flashcard-pipeline.md` and analysed in full in A09 (Stage 2) |
| `study-app-spec.md` | With the repository | Copied to `02-analysis/sources/study-app-spec.md` and analysed in full in A09 (Stage 2) |
| Handbook, sample slides, past paper, semester calendar, screenshots | Requested | Two received 2026-10-21 (below). Past paper, calendar and screenshots not supplied yet. Must not be committed to this public repository |
| `ug_course_syllabus_template_doc_COMP4901B.docx.pdf` (COMP 4901B Large Language Models syllabus, HKUST, Fall 2026-27, 4 pages) | 2026-10-21; kept in the student's local course-material folder, outside the repository (`DEC-008`) | Analysed in full in A09 (Stage 2) |
| `COMP4901b_Sept24_RL.pdf` (COMP 4901B lecture on reinforcement learning, Keynote export, 61 pages) | 2026-10-21; same location (`DEC-008`) | Analysed in full in A09 (Stage 2) |

**Stage 0 skim findings** (high-impact items only; A09 analyses both documents in full):
- **COMP 4901B has no midterm.** Its assessments are attendance and in-class quizzes, three individual programming assignments, a group mini-project, and a closed-book final in the HKUST exam period, 7–19 Dec 2026. The first midterm (Q-02) is therefore in another module. → `ASM-045`
- **The syllabus gives little for the Extractor to find.** Coursework dates are "to be announced on Canvas", and there is no weekly schedule, no reading list and no question-type mix for the final. The pipeline may now read Canvas directly (`DEC-009`). → `ASM-047`, Q-16
- **The university is HKUST,** so deadlines default to Hong Kong time. → `ASM-022`
- **The course AI policy** allows generative AI for help with coding and debugging, but not copying AI-generated text into submitted writing. This fits the tutor guardrail [SEED §7] [SEED §11] and goes into A09 and A10.
- **Plain text extraction is not enough for the slides.** 25 of the 60 content slides carry their content mainly in images. Equations are embedded LaTeXiT objects, whose LaTeX source can be recovered. Extracted text has garbled ligatures. → `ASM-016` (refuted), `ASM-046`. This is the main new technical risk for A02 and A03.

## Workbook index

| Path | Contents |
| :-- | :-- |
| [`00-governance/assumptions-decisions.md`](00-governance/assumptions-decisions.md) | A00: assumption register, decision log, change requests |
| [`00-governance/questions.md`](00-governance/questions.md) | Clarifying questions and answers |
| [`00-governance/traceability-matrix.md`](00-governance/traceability-matrix.md), [`traceability-matrix.csv`](00-governance/traceability-matrix.csv) | Requirement traceability (`REQ-F-001`–`REQ-F-094`, `REQ-N-001`–`REQ-N-023`) |
| [`00-governance/checkpoints.md`](00-governance/checkpoints.md) | Checkpoint messages and replies |
| [`00-governance/dispositions.md`](00-governance/dispositions.md) | Review dispositions |
| `00-governance/reviews/` | Gate review files |
| [`01-initiation/charter-scope.md`](01-initiation/charter-scope.md) | A01: charter and scope |
| [`01-initiation/feasibility.md`](01-initiation/feasibility.md) | A02: feasibility |
| [`01-initiation/risk-register.md`](01-initiation/risk-register.md) | A03: risk register |
| [`01-initiation/tailoring.md`](01-initiation/tailoring.md) | A04: tailoring record |
| [`01-initiation/wbs.md`](01-initiation/wbs.md), [`wbs.csv`](01-initiation/wbs.csv) | A05: work breakdown structure (the CSV is the single source) |
| [`01-initiation/schedule.md`](01-initiation/schedule.md), [`schedule_calc.py`](01-initiation/schedule_calc.py) | A06: schedule (regenerate with `python3 workbook/01-initiation/schedule_calc.py`) |
| [`01-initiation/baseline-project-plan.md`](01-initiation/baseline-project-plan.md) | A07: baseline project plan |
| [`02-analysis/requirements-sources.md`](02-analysis/requirements-sources.md), `02-analysis/sources/` | A09: requirements sources & document analysis |
| [`02-analysis/requirements.md`](02-analysis/requirements.md), [`requirements.csv`](02-analysis/requirements.csv) | A10: requirements catalog (`REQ-F-001`–`REQ-F-094`, `REQ-N-001`–`REQ-N-023`) |
| [`02-analysis/context-diagram.md`](02-analysis/context-diagram.md) | A11: context diagram (`P0`, `E1`–`E6`) |
| [`02-analysis/dfd.md`](02-analysis/dfd.md) | A12: Level-0 and Level-1 data flow diagrams (`P1`–`P7`, `D1`–`D9`) |
| [`02-analysis/use-cases.md`](02-analysis/use-cases.md) | A13: use cases (`UC-01`–`UC-21`) |
| [`02-analysis/workflows.md`](02-analysis/workflows.md) | A14: activity / swimlane workflow diagram (`WF-01`) |
| [`02-analysis/decision-tables.md`](02-analysis/decision-tables.md) | A15: complete and reduced decision tables (`DT-01`–`DT-06`) |
| [`02-analysis/conceptual-data-model.md`](02-analysis/conceptual-data-model.md) | A16: conceptual data model (`E01`–`E28`, relationships, CRUD matrix) |
| [`02-analysis/business-rules.md`](02-analysis/business-rules.md) | A17: business rules (`BR-001`–`BR-045`) |
| [`02-analysis/glossary.md`](02-analysis/glossary.md), [`data-dictionary.csv`](02-analysis/data-dictionary.csv) | A18: glossary & data dictionary (34 terms, 263 attributes) |
| [`02-analysis/acceptance-scenarios.md`](02-analysis/acceptance-scenarios.md), [`acceptance-scenarios.csv`](02-analysis/acceptance-scenarios.csv) | A19: Given / When / Then acceptance scenarios (`AT-001`–`AT-141`) |
| [`02-analysis/master-test-plan.md`](02-analysis/master-test-plan.md) | A20: master test plan |
| [`02-analysis/sourcing.md`](02-analysis/sourcing.md) | A22: sourcing decision |
| [`03-design/adr/README.md`](03-design/adr/README.md) (`ADR-001`–`ADR-007`) | A30: architecture decision records (`DEC-017`–`DEC-023`) |
| [`03-design/architecture.md`](03-design/architecture.md) | A31: architecture overview (`C4`, modules `M01`–`M12`, rule enforcement `BR-001`–`BR-045` & `DR-01`–`DR-06`, `ARCH-01`–`ARCH-04`) |
| [`03-design/db/logical-model.md`](03-design/db/logical-model.md) | A32: logical data model (`3NF` relations `R01`–`R34`, views, JSON collections) |
| [`03-design/db/physical-design.md`](03-design/db/physical-design.md), [`03-design/db/schema.sql`](03-design/db/schema.sql) | A33: physical data design, SQLite 3 `STRICT` DDL, indexes `IDX-01`–`IDX-15`, migrations, `VACUUM INTO` backups |
| [`03-design/api/interfaces.md`](03-design/api/interfaces.md), [`03-design/api/openapi.yaml`](03-design/api/openapi.yaml), [`03-design/api/schemas/pipeline-contracts.schema.json`](03-design/api/schemas/pipeline-contracts.schema.json) | A34: interface contracts (`38` HTTP/SSE operations, `20` JSON Schemas, `CLI-01`–`CLI-07`, `INT-01`–`INT-05`) |
| [`03-design/ui.md`](03-design/ui.md) | A35: UI & dialogue design (`SCR-01`–`SCR-11`, wireframes, field rules `FLD-01`–`FLD-30`, WCAG 2.2 AA) |
| [`03-design/security.md`](03-design/security.md) | A36: security design (assets `AS-01`–`AS-07`, STRIDE across `TB-01`–`TB-05`, auth/secrets, `38+7` authorization matrix) |
| [`03-design/privacy.md`](03-design/privacy.md) | A37: privacy data map (`A18` personal data attributes, retention/deletion, cross-border transfer, minimization) |
| [`03-design/observability.md`](03-design/observability.md) | A38: observability & SLOs (`SLO-01`–`SLO-09`, NDJSON logging & redaction, metrics `MET-01`–`MET-05`, alerts `ALT-01`–`ALT-06`) |
| [`03-design/test-design.md`](03-design/test-design.md), [`03-design/test-cases.csv`](03-design/test-cases.csv) | A39: test design (`293` Integration & System test cases `TC-I-001`–`TC-I-262`, `TC-I-N10`/`12`/`17`/`20`, `TC-S-001`–`TC-S-027`, G4 review scope) |
| [`03-design/slice-plan.md`](03-design/slice-plan.md) | A40: slice plan (`SL-01`–`SL-21` across `R1`, `R2`, `R3`) |
| [`03-design/reports.md`](03-design/reports.md) | A41: report & output design (`RPT-01`–`RPT-09`, `Appendix B5` display choices, `A09` report disposition) |
| [`03-design/data-model-quality.md`](03-design/data-model-quality.md) | A42: data & model quality plan (lineage, rules `DQR-01`–`DQR-15`, AI specs `AI-01`–`AI-09`, evaluation sets `EVAL-01`–`EVAL-06`) |
| `04-construction/` … `06-maintenance/` | Later stage artifacts, as selected by the Tailoring Record (A04) |
