# A04 · Tailoring Record

Owner: Strategic Planner. Stage 1, written 2026-10-21.

## 1. Tier

**M** (`DEC-001`, confirmed by the student [USER Q-10]).

Catalog §2.1 signals point both ways:
- **S signals:** one builder [SEED §9]; one person in two roles [SEED §2]; no regulated data [SEED §4]; a personal app.
- **M signals:** 11 Must stories, above the S limit of about 8 [SEED §3]; two Must integrations, the Claude API and the pipeline-to-app files [SEED §5], with Canvas now a third (`DEC-009`).

With risk flags set, the rule takes the higher tier. Review depth is Standard [SEED §10], so re-reviews cover the failed checks plus every check that touches a changed artifact (protocol §8.3).

## 2. Risk flags

| Flag | Set? | Reasoning | Artifacts it adds |
| :-- | :-: | :-- | :-- |
| PD | yes | Study performance history and tutor conversations are personal data [SEED §4 Sensitive data] | A36, A37 |
| INT | yes | Claude API, pipeline files, Canvas, `.ics` and Anki exports [SEED §5] [DEC-009] | A34 for every integration; contract tests in A39 |
| AI | yes | LLM generation, review, marking and tutor [SEED §8 AI / machine-learning features] | A42; model-specific threats in A36; evaluation results in A53 |
| FIN | no | Spend reporting estimates usage costs; no payments or financial records (`ASM-033`) | — |
| REG | no | No regulated-domain data (`ASM-034`) | — |
| HA | no | Best-effort availability [SEED §7] (`ASM-035`) | — |
| MIG | no | Nothing is imported from other apps [USER Q-14] (`ASM-014`) | — |
| MT | no | One user [SEED §11] | — |
| NTU | no | Tech comfort medium to high (`ASM-015`) | — |

## 3. Project types

`DEC-002`:

| Part | Type | Emphasis it brings |
| :-- | :-- | :-- |
| Study app: import, review, quiz, deadlines, Today, tutor, stats | **BIS** | Use cases, conceptual data model and normalisation, business rules, decision tables, screens and reports |
| Generation pipeline: extraction, generation, review loops, audit, export | **DATA** | DFDs for the pipeline (its data flows are the system), data lineage and quality rules in A42, source and target schemas in A16/A32 (the six export files), reprocessing in A61. A35 does not apply to the pipeline beyond its human review step, which is part of the app |

## 4. Modelling approach

`DEC-011`:
- **Study app: object-oriented.** The domain has rich behaviour (FSRS scheduling of cards and concepts, variant selection, daily plan generation, import matching), and the recommended stack is TypeScript [SEED §8]. Use cases (A13), a class diagram for the conceptual model (A16), decision tables (A15) and an activity diagram (A14) fit it.
- **Generation pipeline: structured.** It is a chain of transformations from source documents to reviewed datasets. A Level-0 DFD with Level-1 for the Must processes (A12) shows it best.

The two model sets cover **different parts** of the system, so this is not "both full model sets" for the same part. One conceptual model (A16) covers the whole system, including the pipeline's export files.

## 5. Artifact decisions

**Depth.** "R" means the full entry at tier M. "Reduced" means produced with the named sections only, and the reason says why.

| ID | Artifact | Decision | Depth | Reason |
| :-- | :-- | :-- | :-- | :-- |
| A00 | Assumptions, Decisions & Change Requests | Produce | R | Required at every tier |
| A01 | Charter & Scope Statement | Produce | R | Required at M |
| A02 | Feasibility Assessment | Produce | R | Required at M; three-year TCO and simple payback. Political dimension N/A (single stakeholder) |
| A03 | Risk Register | Produce | R | Required at every tier |
| A04 | Tailoring Record | Produce | R | Required at every tier |
| A05 | Work Breakdown Structure | Produce | R | Required at M |
| A06 | Schedule | Produce | R | Required at M: PERT, network with critical path, Gantt |
| A07 | Baseline Project Plan | Produce | R | Required at M |
| A09 | Requirements Sources & Document Analysis | Produce | R | Required; the seed, two source documents, 16 answers and two course documents to analyse |
| A10 | Requirements Catalog | Produce | R | Required |
| A11 | Context Diagram | Produce | R | Required |
| A12 | Data Flow Diagrams | Produce | Reduced: the pipeline only, Level-0 plus Level-1 for Must processes | M: conditional on the structured approach, chosen for the pipeline (§4); the DATA type emphasises it. The app is modelled with use cases instead |
| A13 | Use Cases | Produce | R | Fully dressed for Must, casual for Should and Could |
| A14 | Activity / BPMN Diagrams | Produce | Reduced: the pipeline run and its review loop | The review loop crosses Orchestrator, Creators, Reviewers and the student, with hand-offs, loops and parallel lectures [DOC flashcard-pipeline.md §3, §7] |
| A15 | Decision Tables | Produce | R | Three or more interacting conditions: daily plan building and workload cap, variant selection, result-to-rating mapping, import matching, countdown urgency [DOC study-app-spec.md §1.2–§1.4, §3] |
| A16 | Conceptual Data Model | Produce | R | Persistent data in the app and the pipeline files |
| A17 | Business Rules | Produce | R | Required |
| A18 | Glossary & Data Dictionary | Produce | R | Required at M; the student's terms ("concept", "variant", "flagged", "assessment mode") need fixing early |
| A19 | Acceptance Scenarios | Produce | R | Required |
| A20 | Master Test Plan | Produce | R | Required at M |
| A21 | Elicitation Prototype | Skip | — | Conditional on an uncertain UI workflow or NTU. The workflow is specified by the student, with a screen list and a worked "Today" example [DOC study-app-spec.md §1.4, §4], and NTU is not set. The student reviews screen designs at CP3 (A35) |
| A22 | Sourcing Decision | Produce | R | Required at M. The student wants one custom app [USER Q-09], but at least one non-build option must still be evaluated (G2.11), and reusable libraries chosen |
| A30 | Architecture Decision Records | Produce | R | Required; includes the stack, data store, pipeline runtime and Canvas access method |
| A31 | Architecture Overview | Produce | R | Required |
| A32 | Logical Data Model | Produce | R | Persistent data |
| A33 | Physical Data Design | Produce | R | Persistent data; backup that survives a crash mid-write (review history must never be lost [SEED §10]) |
| A34 | Interface Contracts | Produce | R | Required at M and by INT: the app's HTTP API (OpenAPI), JSON Schemas for the six pipeline files and `feedback.json`, the Claude API and Canvas contracts, the `.ics` calendar feed, and the Anki TSV export format |
| A35 | UI & Dialogue Design | Produce | R | The app has a UI. No usability plan, since NTU is not set |
| A36 | Security Design | Produce | R | Required at M and by PD and AI: prompt injection, secrets (API key, Canvas token), the R3 password |
| A37 | Privacy Data Map | Produce | R | Required by PD |
| A38 | Observability & SLOs | Produce | Reduced: SLOs from the performance REQ-Ns, a logging standard (no personal data, secrets or course text), spend and usage metrics; no distributed tracing or alerting service | Required at M. HA is not set, and R1 is a single-user local app, so tracing and alerting services would be padding (R3) |
| A39 | Test Design | Produce | R | Required; includes the review scope and contract tests (INT) |
| A40 | Slice Plan | Produce | R | Required; replaces the provisional slices in A05 through a CR |
| A41 | Report & Output Design | Produce | R | Today page, Stats, mock exam results, run summary and module audit, notifications, `.ics` [SEED §3 Reports & outputs] |
| A42 | Data & Model Quality Plan | Produce | R | Required by AI and the DATA type: lineage, quality rules, evaluation sets with numeric thresholds |
| A50 | Slice Record | Produce | R | BUILD mode [DEC-004] |
| A51 | Implementation Guide | Skip | — | PLAN mode only |
| A52 | Defect Log | Produce | R | Required |
| A53 | NFR Verification | Produce | R | Required at M; AI evaluation results (AI flag) |
| A60 | Delivery Pipeline & Environments | Produce | R | Required at M |
| A61 | Deployment & Rollback Plan | Produce | R | Required at M; updated for hosting in R3 |
| A62 | Data Migration & Conversion Plan | Skip | — | MIG not set: nothing is imported from Anki [USER Q-14] |
| A63 | Documentation Set | Produce | R | Required at M: user guide, runbook (including running the pipeline each semester), developer README |
| A64 | Training & Support Plan | Skip | — | Optional at M; NTU not set. The only user commissioned the system and reviews every pull request; the user guide (A63) covers learning it |
| A65 | Adoption & Change Plan | Skip | — | Catalog §3 sets R at tier M unconditionally, so skipping it is a deliberate proportionality departure (R3) approved by the student at CP1 (`DEC-013`) [USER CP1]. Only the student is affected, and they initiated the project and are keen [SEED §6]. The system changes no one else's work, and NTU is not set. Success measurement is in A01 (methods and timing for each metric), with the post-launch review in A72 |
| A70 | Configuration & Change Management | Produce | R | Required at M |
| A71 | Operational Health & Maintenance Pipeline | Produce | Reduced: maintenance pipeline (intake, B8 classes, triage) and the health metrics that have a data source; continuity section N/A until hosting (R3) | The student maintains the system and re-runs the pipeline each semester. Zero-downtime updates have no meaning for a local single-user app |
| A72 | Closedown Review | Produce | R | Required at M |

All 48 catalog artifacts are listed. Every artifact a set flag requires is selected: A36, A37 (PD); A34, A39 contract tests (INT); A42, A53 (AI).

## 6. Process tailoring

| Item | Decision | Reason |
| :-- | :-- | :-- |
| Releases | R1 = Must, R2 = Should, R3 = Could. Stage 4 runs per release; Stage 5 (G5, CP4) runs after each release; Stage 6 after R3 | `DEC-010` [USER CP1]: R1 must reach the student before the final exams, and the protocol's single release would hold R1 back until the Could stories are built |
| Checkpoints | ADVISORY: STRICT at CP1 and CP2 | [USER Q-10] [DEC-005] |
| Gate reviews | A fresh Reviewer subagent per gate and per re-review, working from a committed snapshot | Protocol §4.2 [CLAUDE.md] |
