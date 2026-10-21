# A07 · Baseline Project Plan

Owner: Strategic Planner. Stage 1, written 2026-10-21. A summary of A01–A06 and the procedures that govern the project. On approval at CP1, A01–A07 become the first baseline.

## 1. Summary of the initiation artifacts

| Artifact | Key content |
| :-- | :-- |
| [A01 Charter & Scope](charter-scope.md) | **Goal:** one daily checklist of reviews, quizzes, readings and countdowns, from cards and questions generated and independently reviewed from the student's own course material. **Metrics:** SM-1 to SM-6, two of them restated for the student's agreement. **Scope:** 11 pipeline items and 16 app items across R1 (Must), R2 (Should) and R3 (Could). **Out of scope:** 9 items, including the seed's non-goals, the dropped Canvas non-goal (`DEC-009`) and Mandarin (`DEC-007`) |
| [A02 Feasibility](feasibility.md) | **Verdicts:** feasible with conditions on every dimension; political N/A. **Cash:** $72–$1,800 over three years, or up to $4,680 if the subscription must be upgraded. **Payback:** most likely within one semester of lectures. **Main technical risk:** reading slide images. **Schedule:** R1 before the exam period in every case; the first midterm can't be met |
| [A03 Risk Register](risk-register.md) | 22 risks; one high-likelihood, high-impact (`RSK-002`, slide content in images), mitigated first in `SL-01` |
| [A04 Tailoring](tailoring.md) | **Classification:** tier M; flags PD, INT and AI; BIS for the app, DATA for the pipeline. **Modelling:** object-oriented for the app, DFDs for the pipeline. **Artifacts:** 43 of 48 produced (A12, A14, A38 and A71 in reduced form) and 5 skipped with reasons (A21, A51, A62, A64, A65). **Releases:** R1, R2 and R3 (`DEC-010`) |
| [A05 WBS](wbs.md) | 65 work packages with a total expected time of about 103 h; provisional slices SL-01 to SL-21, mapped to every seed story |
| [A06 Schedule](schedule.md) | **Network:** linear and resource-levelled, about 116 h including gates. **Derived dates (3 h/day):** CP1 23 Oct, CP2 29 Oct, CP3 3 Nov, pipeline 9 Nov, R1 16 Nov, R2 23 Nov, R3 27 Nov, each with a range |

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

This summary follows the protocol's pillars (P1, P2). The Master Test Plan (A20, Stage 2) details it, and its summary is added here then through a CR.
- **Test-first everywhere in BUILD mode.**
  - **Acceptance scenarios** come from the use cases (Stage 2).
  - **System and integration test cases** come from the design (Stage 3).
  - **Unit test cases** are written per slice before the code (Stage 4). Each test is seen failing for the expected reason before the code is written. A test that cannot fail first is proved by a recorded mutation.
- **Coverage by design:** normal paths, boundaries, invalid input, error and recovery paths (including a crash mid-write for the database), and a verification method for every measurable non-functional requirement.
- **Generated content:** cards and questions are checked against an evaluation set with numeric thresholds (A42), and the results are recorded in A53.
- **Contract tests** for every integration: Claude API, Canvas, and the pipeline files.
- **Regression:** the full suite runs after every batch of fixes.

## 5. Baseline on approval at CP1

A01, A02, A03, A04, A05 (with `wbs.csv`), A06 (with `schedule_calc.py`) and A07. A00 stays a working record under the rules above.
