# A07 · Baseline Project Plan

Owner: Strategic Planner. Stage 1, written 2026-10-21. A summary of A01–A06 and the procedures that govern the project. Approved and baselined at CP1 (2026-10-21; updated via `CR-001`, `CR-002`, `CR-003`).

## 1. Summary of the initiation artifacts

| Artifact | Key content |
| :-- | :-- |
| [A01 Charter & Scope](charter-scope.md) | **Goal:** one daily checklist of reviews, quizzes, readings and countdowns, from cards and questions generated and independently reviewed from the student's own course material. **Metrics:** SM-1 to SM-6, adopted as project objectives at CP1 (`DEC-012`). **Scope:** 11 pipeline items (`SC-P01`–`SC-P11`) and 16 app items (`SC-A01`–`SC-A16`) across R1 (Must, including `SC-P08` Canvas reading), R2 (Should plus `SC-A12` Stats page) and R3 (Could). **Out of scope:** 9 items (`SC-X01`–`SC-X09`), including the seed's non-goals, the dropped Canvas non-goal (`DEC-009`) and Mandarin (`DEC-007`) |
| [A02 Feasibility](feasibility.md) | **Verdicts:** feasible with conditions on every dimension; political N/A. **Cash:** $72–$1,800 over three years, or up to $5,400 if the subscription must be upgraded (`ASM-062`; build and CI critic costs excluded per `ASM-064`). **Payback:** most likely about 34 lectures (within one semester) on 15–40 h (most likely 25 h) of student active build time (`ASM-055`), or about 159 lectures (1.5–4 semesters) if the student attends all ~119 h of session time. **Main technical risk:** reading slide images (`RSK-002`). **Schedule:** R1 before the exam period in every case; the first midterm can't be met; processing the CS lectures by 30 Nov uses up to 1.5 h/day of student active review time (`ASM-063`) |
| [A03 Risk Register](risk-register.md) | 22 risks; one high-likelihood, high-impact (`RSK-002`, slide content in images), mitigated first in `SL-01` |
| [A04 Tailoring](tailoring.md) | **Classification:** tier M; flags PD, INT and AI; BIS for the app, DATA for the pipeline. **Modelling:** object-oriented for the app, DFDs for the pipeline. **Artifacts:** 43 of 48 produced (A12, A14, A38 and A71 in reduced form) and 5 skipped with reasons (A21, A51, A62, A64, and A65 as a proportionality departure approved at CP1, `DEC-013`). **Releases:** R1, R2 and R3 (`DEC-010`) |
<!-- BEGIN GENERATED:bpp by schedule_calc.py -->
| [A05 WBS](wbs.md) | 65 work packages with a total expected time of 103.30 h of agent session time (plus 15.67 h of gates and checkpoints = 118.97 h in all); provisional slices SL-01 to SL-21, mapped to every seed story |
| [A06 Schedule](schedule.md) | **Network:** linear and resource-levelled, 116.27 h of agent session time on the critical path (70 tasks, zero slack). **Derived dates at 3 h/day (earliest – latest):** CP1 23 Oct 2026 (22 Oct 2026 – 25 Oct 2026); CP2 29 Oct 2026 (26 Oct 2026 – 4 Nov 2026); CP3 3 Nov 2026 (30 Oct 2026 – 12 Nov 2026); pipeline 9 Nov 2026 (3 Nov 2026 – 21 Nov 2026); R1 16 Nov 2026 (8 Nov 2026 – 3 Dec 2026); R2 23 Nov 2026 (12 Nov 2026 – 13 Dec 2026); R3 27 Nov 2026 (16 Nov 2026 – 20 Dec 2026); closedown 28 Nov 2026 (17 Nov 2026 – 22 Dec 2026) |
<!-- END GENERATED:bpp -->

## 2. Communication plan

| What | When | Channel | Recorded in |
| :-- | :-- | :-- | :-- |
| Stage log (protocol §9) | After each stage and each review cycle | Chat | Chat; the stage status in `README.md` |
| Clarifying questions | Whenever an unknown would change scope, architecture, data or compliance (R2) | Chat, multiple choice | [`questions.md`](../00-governance/questions.md) |
| Checkpoints CP1 and CP2 | After G1 and G2 | Chat; **STRICT**, so work stops until the student replies | [`checkpoints.md`](../00-governance/checkpoints.md) |
| Checkpoints CP3 and CP4 (one CP4 per release) | After G3 and each G5 | Chat; **ADVISORY**, so work continues on stated assumptions and the checkpoint is marked pending | `checkpoints.md`; `README.md` |
| Post-slice report: CRs, observations needing the student, disproved assumptions | After every slice | Chat | The slice record (A50); `checkpoints.md` when the student answers |
| Pull requests | One per stage or revision cycle; one per slice in Stage 4 | GitHub; the student reviews; the CI critic comments | The PR; critic comments are review data (AGENTS.md §6) |
| Decisions the student must always make | Before acting: paid services or more Claude spend, changes to card rules, question rules or reviewer rubrics, course material to a third party other than Anthropic, anything that could delete or overwrite review history | Chat question or checkpoint item | `questions.md`; decision log in A00 |

## 3. Management procedures

- **Change control (R7).** After CP1, A01–A07 are baselined. A change needs a `CR-nnn` in [A00](../00-governance/assumptions-decisions.md): what changes and why, the items it affects (from the traceability matrix from Stage 2 onwards), the gate checks to re-run, and a status.
  - **Exempt working fields:** risk status, likelihood, impact, trigger and owner; the matrix's status columns; the stage-status lines of `README.md`.
  - **CRs in Stage 4** are reported after each slice, not held until CP4.
- **Gate reviews.**
  - **Reviewer:** a fresh Reviewer subagent for each gate and each re-review. It works from a committed snapshot and writes only its review file and its scratch folder.
  - **Dispositions:** every FAIL and observation gets one in [`dispositions.md`](../00-governance/dispositions.md).
  - **Re-reviews (tier M, Standard depth):** the failed checks plus every check touching a changed artifact.
- **Escalation.** At `r3` (after two revision cycles at one gate), a FAIL that is unfixed from an earlier cycle, blocker or major sets ESCALATED, and the student chooses among the options in protocol §8.1 step 8.
- **Assumptions.** A high-impact, low- or medium-confidence assumption is confirmed or refuted, or else presented at the next checkpoint.
- **Repository.** One branch per stage or revision cycle and one per slice; changes reach `main` through pull requests; files are staged by name; no secrets, `.env` files or course material are committed (AGENTS.md §5, `DEC-008`).

## 4. Test strategy summary

This summary follows the protocol's pillars (P1, P2) and the Stage 2 [A20 Master Test Plan](../02-analysis/master-test-plan.md) (added here via `CR-002`, refined via `CR-003`).
- **Four test levels and objective entry/exit criteria (`A20 §1`):**
  1. **Unit testing (`TC-U-*`):** pure domain functions (`ts-fsrs` scheduling wrappers, `DT-01`–`DT-06` decision logic across all 48 complete rules, deterministic IDs `BR-020`, `DailyPlan` 9-step ordering `BR-035`, deadline urgency/timezone math `BR-033`, LaTeXiT metadata parser, Anki TSV / `.ics` formatters); exit requires `100%` pass (`0` skipped) and ≥ `90%` line/branch coverage on scheduling and decision tables.
  2. **Integration & contract testing (`TC-I-*`):** SQLite persistence (`A33`), atomic import & backup/rollback (`REQ-N-011`), JSON Schema contract validation on all 6 export files + `feedback.json` (`REQ-N-020`), REST API endpoints (`A34`), read-only Canvas client with local fallback (`REQ-F-002`), Reviewer subagent context-isolation payload check (`REQ-N-012`), and mocked/live Anthropic Claude API client with prompt caching (`REQ-F-047`); exit requires `100%` pass and ≥ 1 valid + ≥ 1 invalid (`400`/`422`) test per operation/schema.
  3. **System & NFR testing (`TC-S-*`):** end-to-end workflows (`WF-01`, `WF-02`), keyboard-only operability (`REQ-N-019`), WCAG 2.2 AA accessibility (`axe-core`, `REQ-N-018`), performance/volume benchmarks (`REQ-N-001`–`REQ-N-007` on `3,000`-card / `100,000`-log and `12,000`-card / `500,000`-log seeded databases), offline/network-isolated operation (`REQ-N-008`, `REQ-N-009`), `SIGKILL` crash recovery (`REQ-N-011`), and adversarial security/privacy suites (`REQ-N-013`–`REQ-N-016`, `REQ-N-023`); exit requires `100%` pass on the `REQ-N` targets in scope for the release under test in `A53` (`17` `Must` NFRs in `R1`, `+4` `Should` = `21` in `R2`, `+2` `Could` = all `23` `REQ-N`s in `R3`) and `0` open `S1`/`S2` defects in `A52`.
  4. **Acceptance testing (Alpha & Beta UAT, `A19`):** student validation on actual coursework against the acceptance scenarios in `acceptance-scenarios.csv` whose `req_trace` requirements belong to the release under test (`94` `Must`-only scenarios in `R1`, `+33` `Should` = `127` in `R2`, `+10` `Could` = all `137` scenarios `AT-001`–`AT-137` in `R3`) and `SM-1`–`SM-6` (`A01 §3`), plus the `A42` evaluation benchmark (≥ `95%` notation compliance, ≥ `95%` citation accuracy, `0` unflagged context-dependent cards).
- **Test-first everywhere in BUILD mode (`A20 §7`):**
  - **Acceptance scenarios (`AT-001`–`AT-137`)** come from the use cases and decision tables (`A19`, Stage 2).
  - **System and integration test cases (`TC-S-*`, `TC-I-*`)** come from the design (`A39`, Stage 3).
  - **Unit test cases (`TC-U-*`)** are written per slice in a dedicated Red-phase commit before the implementation commit (`A50`, Stage 4). Each test is seen failing for the expected reason before the code is written; any test that cannot fail first is proved by a recorded mutation.
- **Environment & PD/copyright-safe test data (`A20 §2–§3`, `ASM-005`, `ASM-022`, `ASM-066`):** runtime/database versions (`Node.js 22 LTS`, `SQLite 3` WAL) are provisional `[SEED §8]` recommendations pending Stage 3 `A30` ADRs (`ASM-066`), timezone tests run across `Asia/Hong_Kong` (`ASM-022`) plus representative travel fixtures `UTC` and `Europe/London` (`ASM-066`), and automated CI uses synthetic public-domain fixtures (including synthetic embedded `LaTeXiT` streams, prompt-injection payloads, and canary credentials) with `0` real copyrighted course files or personal tokens committed (`DEC-008`, `REQ-N-013`, `REQ-N-016`).
- **Regression (`A20 §7`):** the full unit, integration, contract, and system suite runs after every slice and every batch of fixes.

## 5. Baseline on approval at CP1

A01, A02, A03, A04, A05 (with `wbs.csv`), A06 (with `schedule_calc.py`) and A07. A00 stays a working record under the rules above.
