# A02 · Feasibility Assessment

Owner: Strategic Planner. Stage 1, written 2026-10-21. Tier M: economic feasibility as a three-year total cost of ownership with simple payback.

**Figures.** Every figure has a source tag. Estimates without a source are ranges, with their basis in the assumption register. Prices come from a web search on 2026-10-21 and are re-verified in A22 (`ASM-059`, `ASM-062`). Amounts are in US dollars, the currency Anthropic prices in; the student gave no currency [USER Q-06].

**Two kinds of time.** This assessment and the schedule keep them apart:
- **Session time** (`ASM-052`, `ASM-053`) is the elapsed time of the agent's working sessions. The student opens the sessions and stays reachable to answer, but is not working throughout. A05 and A06 are in session time, at about 3 hours a day.
- **The student's active time** is the time the student actually spends: answering questions and checkpoints, reviewing pull requests and setting things up during the build (`ASM-055`); afterwards, the human review step for each lecture (`ASM-057`). Payback (§1.3) and the processing load (§4) are in active time.
- **Pipeline runs** happen in Claude Code, separately from the agent's sessions. They need the student to start them, not to watch them (`ASM-063`).

## 1. Economic

### 1.1 Three-year total cost of ownership

Horizon: 36 months from R1, the catalog's tier-M horizon (`ASM-054`).

| Cost item | Kind | Per month | 36 months | Basis |
| :-- | :-- | :-- | :-- | :-- |
| Building the system: the agent's sessions and the CI critic's reviews | One-time | — | Not known to the agent; excluded, for the student to add | The agent cannot see what its own sessions cost the student [ASM-030]. The CI critic runs on the student's Claude subscription token when it is set, otherwise on an API key billed per token, for each pull request it reviews [DOC .github/workflows/critic.yml L212–214] [ASM-064] |
| Building the system: the student's time (checkpoints, pull-request reviews, setup) | One-time | — | 15–40 hours of student time | [ASM-055] |
| Claude subscription for the pipeline | Recurring | $0 extra: the student already holds Pro or Max | $0 | [USER Q-15]; marginal cost only if the limits run out (`ASM-044`) |
| Contingency: upgrading one plan step if the pipeline exhausts the limits | Recurring, if needed | $0–$100 | $0–$3,600 | Pro $20 → Max 5x $100 (+$80), or Max 5x $100 → Max 20x $200 (+$100), depending on the student's current plan, which is not known [ASM-062]. Needed only if `ASM-044` fails. Raising spend needs the student's approval [SEED §10] |
| Claude API for app features: marking and tutor (R2) | Recurring | $2–$40 | $72–$1,440 | Token volumes and per-token prices in [ASM-059]. 36 months is used for simplicity, although R2 starts after R1, so the range is an upper bound |
| Hosting for phone access (R3) | Recurring | $0–$10 | $0–$360 | [ASM-060]; host chosen by ADR in Stage 3 (`ASM-028`) |
| Libraries (`ts-fsrs`, KaTeX, React and others) and Canvas access | — | $0 | $0 | Open-source licences checked in A22; Canvas access uses the student's existing account [DEC-009] |
| **Total cash, base case** | | **$2–$50** | **$72–$1,800** | Sum of the rows above, without the contingency |
| **Total cash, with the upgrade contingency** | | **$2–$150** | **$72–$5,400** | Base case plus the contingency row |

Arithmetic: low end 2 × 36 = 72; high end 40 × 36 = 1,440, 10 × 36 = 360, 100 × 36 = 3,600; 1,440 + 360 = 1,800; 1,800 + 3,600 = 5,400; per month 40 + 10 = 50 and 50 + 100 = 150.

### 1.2 Benefits

**Tangible, in student time.** The student would otherwise make cards by hand. With the pipeline, the student spends time only on the human review step [SEED §1 Problem] [SEED §3 story 5].

| Quantity | Optimistic | Most likely | Pessimistic | Basis |
| :-- | --: | --: | --: | :-- |
| Making cards by hand, per lecture (avoided) | 90 min | 60 min | 30 min | [ASM-056] |
| Human review step, per lecture (incurred) | 10 min | 15 min | 25 min | [ASM-057] |
| Net time saved per lecture | 80 min | 45 min | 5 min | Row 1 − row 2 |
| Student's active time on the build | 15 h | 25 h | 40 h | [ASM-055] |
| Lectures per semester in the in-scope modules | 104 | — | 40 | 4 modules × 10–26 lectures [USER Q-08] [USER Q-13] [ASM-051] |

**Intangible:** one daily plan instead of scattered sources; better retention through FSRS; questions that test understanding in the assessment's format; deadlines not missed; cards that match the course rather than general knowledge [SEED §1] [SEED §3].

### 1.3 Simple payback

The benefits are student time and learning, not money, so payback is measured in **lectures processed** before the student's build time is recovered. Payback counts are rounded up to whole lectures.

| Case | Calculation | Payback |
| :-- | :-- | :-- |
| Optimistic | 15 h × 60 / 80 min | about 12 lectures: within this semester |
| Most likely | 25 h × 60 / 45 min | about 34 lectures: within one semester of the in-scope modules (40–104 lectures) |
| Pessimistic | 40 h × 60 / 5 min | 480 lectures: about 4.6–12 semesters, so possibly beyond the 36-month horizon |
| Sensitivity: the student attends all session time | about 119 h of planned session time (A05) × 60 / 45 min | about 159 lectures: about 1.5–4 semesters of the in-scope modules |

The sensitivity row shows how much payback depends on `ASM-055`. If the student must sit through every session, payback moves from within one semester to one and a half to four semesters (159 / 104 ≈ 1.5; 159 / 40 ≈ 4.0).

The cash cost is small next to the time at stake, and nothing is spent before R2 (`ASM-043`). Payback depends mainly on keeping the human review step well below the time needed to make cards by hand.

**Verdict: Feasible with conditions.** Conditions: the subscription limits cover pipeline runs (`ASM-044` → `RSK-004`); the human review step stays well under the time needed to make cards by hand (→ `RSK-019`).

## 2. Technical

**Project size:** small. One builder and one user. 65 work packages with a total expected time of about 103 hours, plus about 16 hours of gates and checkpoints: about 119 hours of session time in all (A05).

**Environment for BUILD mode:** available (`ASM-005`). This repository uses a pull-request workflow with push access; Node.js v22.22.1 and npm 9.2.0 are installed; the npm registry is reachable for a test runner. No SQLite command-line tool is needed if a Node SQLite library is adopted (ADR in Stage 3).

**Requirement structure:**
- **App:** high. The source documents specify features, data model, scheduling logic, screens and API [DOC study-app-spec.md §1–§5].
- **Pipeline:** medium. Roles, rules, rubrics, prompts and schemas are specified [DOC flashcard-pipeline.md §3–§12], but slide reading (`ASM-046`) and Canvas access (`DEC-009`) are new and open.

**Familiarity:**
- **App:** high. The recommended stack is mainstream (TypeScript, React, Node, SQLite), and FSRS comes as a library [SEED §8].
- **Pipeline:** low. It combines multi-agent orchestration in Claude Code on a subscription, reading slide images at scale, Canvas access, and evaluating LLM outputs.

**Technical risk rating (catalog B2):**

| Part | Familiarity | Size | Structure | Rating |
| :-- | :-- | :-- | :-- | :-- |
| Study app | High | Small | High | Very low |
| Generation pipeline | Low | Small | High (rules) to low (slide reading, Canvas) | Medium-low to high |
| **Overall** | | | | **Medium**, driven by the pipeline |

**Key technical unknowns:**
1. **Reading slide images.** Whether page images plus extracted text and recovered LaTeX give the Creators and Reviewers the full content, at what usage. The sample lecture has 25 image-led content slides [DOC COMP4901b_Sept24_RL.pdf whole file]. (`ASM-046` → `RSK-002`)
2. **Subscription limits.** Whether the Claude subscription's limits allow the Computer Science lectures to be processed at the needed pace. Anthropic does not publish exact limits; they apply in rolling windows and weekly caps (`ASM-044`, `ASM-062` → `RSK-004`).
3. **Reviewer independence in Claude Code.** Each Reviewer must be a fresh instance that never sees the Creator's reasoning [DOC flashcard-pipeline.md §3.1] (→ `RSK-018`).
4. **Canvas access.** Whether to use a Canvas API token or the student's browser session, and whether automated access is allowed (`ASM-048` → `RSK-014`).
5. **Prompt injection.** Defending against instructions hidden in course material or Canvas pages [SEED §7 Misuse] (→ `RSK-010`).
6. **Testing generated content.** Checking cards and questions against an evaluation set with numeric thresholds (A42).

**Verdict: Feasible with conditions.** The walking skeleton, `SL-01`, runs the sample lecture through the pipeline, including slide images, into the app first. That retires unknowns 1–3 before the rest is built (A06). Risks: `RSK-002`, `RSK-004`, `RSK-010`, `RSK-014`, `RSK-018`.

## 3. Operational

- **Fit:** the student initiated the project, is keen on the change, and is the only person affected [SEED §6 What will change for people]. The daily checklist replaces scattered sources [SEED §1].
- **Phone habit:** the student reviews and quizzes mostly on a phone [SEED §2], but the MVP is laptop only until story 17 (R3) [USER Q-04]. Use of R1 may be lower than intended (→ `RSK-020`).
- **Ongoing work:** each lecture needs the human review step [SEED §3 story 5]. If it takes nearly as long as making cards by hand, the benefit shrinks (→ `RSK-019`). Daily load could build up (→ `RSK-009`).
- **Maintenance:** the student runs and maintains the system after launch [SEED §9]. The pipeline is re-run every semester, so it needs clear run instructions (A63) and a maintenance path (A71).

**Verdict: Feasible with conditions.** Risks: `RSK-009`, `RSK-019`, `RSK-020`.

## 4. Schedule

The table and the processing figures below are generated from A06 by `schedule_calc.py`, so they always match it. Dates are in session time at 3 h/day (`ASM-053`); ranges run from 4 h/day at ET − 2SD to 2 h/day at ET + 2SD.

Targets: the first midterm is within 2 weeks of 2026-10-20 [USER Q-02]; the exam period starts 7 Dec 2026 [DOC ug_course_syllabus_template_doc_COMP4901B.docx.pdf p.2]; 30 Nov is the proposed SM-1 date (A01 §3). The processing load uses 3 Computer Science modules × 10–26 lectures [ASM-051], 15 minutes of pipeline time per lecture [SEED §7 Performance] [ASM-037] and 10–25 minutes of human review per lecture [ASM-057].

<!-- BEGIN GENERATED:targets by schedule_calc.py -->
| Target | Needed by | Derived date at 3 h/day (range) | Result |
| :-- | :-- | :-- | :-- |
| R1 (MVP) before the first midterm | 3 Nov 2026 | 16 Nov 2026 (8 Nov 2026 – 3 Dec 2026) | **not met** at 3 h/day |
| R1 in use before the exam period | 6 Dec 2026 | 16 Nov 2026 (8 Nov 2026 – 3 Dec 2026) | met, even in the slow case |
| Pipeline complete (SL-05), so processing can start | before 30 Nov 2026 (proposed SM-1) | 9 Nov 2026 (3 Nov 2026 – 21 Nov 2026) | met, even in the slow case |
| R2 before the exam period | none set by the student | 23 Nov 2026 (12 Nov 2026 – 13 Dec 2026) | met at 3 h/day; **not** met in the slow case |
| R3 before the exam period | none set by the student | 27 Nov 2026 (16 Nov 2026 – 20 Dec 2026) | met at 3 h/day; **not** met in the slow case |

**Processing the Computer Science lectures before 30 Nov 2026**

- Pipeline run time: 30–78 lectures × 15 min = 7.5–19.5 h of Claude Code run time.
- Human review: 30 × 10 min to 78 × 25 min = 5.0–32.5 h of the student's active time.

| Case | Processing window | Days | Review time needed per day | Review time that fits at 1.5 h/day (`ASM-063`) |
| :-- | :-- | --: | :-- | :-- |
| At 3 h/day | 9 Nov 2026 – 30 Nov 2026 | 21 | 0.24–1.55 h | 31.5 h: the load fits up to 31.5 of 32.5 h |
| Slow case | 21 Nov 2026 – 30 Nov 2026 | 9 | 0.56–3.61 h | 13.5 h: the load fits up to 13.5 of 32.5 h |
<!-- END GENERATED:targets -->

**Assessment:**
- **First midterm.** R1 cannot arrive before it. The student accepted this and chose the full MVP for later assessments [USER Q-11].
- **Where the processing time comes from.** Processing does not use the agent's session time. Pipeline runs happen in Claude Code alongside the agent's sessions (`ASM-063`); they are limited by the subscription (`RSK-004`), not by the schedule. The human review step uses the student's active time, on top of the student's part in the build (`ASM-055`).
- **SM-1 (proposed).** Whether the Computer Science lectures can be processed by 30 Nov depends on the student giving the review time per day shown above. At 3 h/day almost all of the load fits within the 1.5 h/day assumed in `ASM-063`. In the slow case the window shortens to about 9 days, and less than half of the high end of the load fits. Processing only the lectures each final covers first (`RSK-017` contingency) is the fallback.
- **R2 and R3.** Building them uses session time, not review time, so pausing them would not free much of the student's review time. It would reduce pull requests to review and subscription use by the CI critic (`ASM-064`) during the processing window and the exam period. Continuing straight on or pausing R2 and R3 until after the exams is a choice for CP1.

**Verdict: Feasible with conditions.** Conditions: about 3 hours of session time a day (`ASM-053`); up to 1.5 hours a day of the student's review time from SL-05 to 30 Nov (`ASM-063`); processing starts as soon as SL-05 is done. Risks: `RSK-001`, `RSK-015`.

## 5. Legal and contractual

| Topic | Finding | Source |
| :-- | :-- | :-- |
| Sending course material to Claude | Allowed by the university | [USER Q-01] |
| Course AI policy (COMP 4901B) | AI may help with coding and debugging; AI-generated text may not be copied into submitted work. The tutor must not write or rewrite assessed work (scope X6) | [DOC ug_course_syllabus_template_doc_COMP4901B.docx.pdf p.3] [SEED §11]; → `RSK-022` |
| Other modules' course policies | Not seen | Covered at university level by [USER Q-01] |
| Copyright of course material | Personal study use only; never published; never committed to this public repository; referenced where the student keeps it | [SEED §7] [DEC-008]; → `RSK-012` |
| Automated Canvas access | HKUST's terms on reading Canvas with a personal token or session are not known; the fallback is manual download | [ASM-048]; → `RSK-014` |
| Claude Code on a subscription for a personal pipeline | Assumed to be within Anthropic's terms for personal use; checked in A22 | [ASM-058]; → `RSK-021` |
| Personal data | Only the student's own study history and tutor conversations, stored locally in R1; no data about other people | [SEED §4 Sensitive data] [ASM-049]; mapped in A37 |
| Open-source licences | Checked for each adopted library in A22 | — |

**Verdict: Feasible with conditions.** Risks: `RSK-012`, `RSK-014`, `RSK-021`, `RSK-022`.

## 6. Political and organisational

**N/A.** At tier M this dimension is required only when stakeholder groups have conflicting interests. Here the only user is the person who commissioned and maintains the system. The lecturers' and university's interests are covered under legal (§5).

## Summary

| Dimension | Verdict | Risks raised |
| :-- | :-- | :-- |
| Economic | Feasible with conditions | RSK-004, RSK-019 |
| Technical | Feasible with conditions | RSK-002, RSK-004, RSK-010, RSK-014, RSK-018 |
| Operational | Feasible with conditions | RSK-009, RSK-019, RSK-020 |
| Schedule | Feasible with conditions | RSK-001, RSK-015 |
| Legal and contractual | Feasible with conditions | RSK-012, RSK-014, RSK-021, RSK-022 |
| Political and organisational | N/A (single stakeholder) | — |
