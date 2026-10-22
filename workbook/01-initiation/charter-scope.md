# A01 · Project Charter & Scope Statement

Owner: Strategic Planner. Stage 1, written 2026-10-21. Tier M (`DEC-001`). Status: baselined at CP1 (2026-10-21; updated via `CR-001`).

## 1. Problem and opportunity

Making good flashcards for university modules by hand is slow. Asking an AI for flashcards without a strict process gives vague, overloaded or inaccurate cards that don't match the course. Deadlines, required readings and revision are spread across handbooks, slides and the university's online learning platform, so it is hard to know what to do each day, especially with midterms coming up. [SEED §1 Problem / opportunity]

## 2. Primary goal

Every day, the student gets one checklist containing spaced-repetition flashcards, targeted quiz questions on concepts that are due, required readings and deadline countdowns. The cards and questions are generated from the student's own course material by AI agents, and every item is checked by an independent AI reviewer before it reaches the student. [SEED §1 Primary goal]

## 3. Objectives and success metrics

The seed marks its metrics as proposals (`ASM-036`). Three (SM-3, SM-4, SM-5) are kept as the seed states them. SM-2 makes the seed's target and measurement formula concrete, and SM-1 and SM-6 are restated to match the student's answers; all six were approved by the student at CP1 and adopted as project objectives in `DEC-012` [USER CP1] (G1.8).

| ID | Metric (target) | Source | Baseline | Measurement method | When measured |
| :-- | :-- | :-- | :-- | :-- | :-- |
| SM-1 | **Restated objective (`DEC-012`).** Seed: "All lectures covered by the first midterm are processed (cards and question bank reviewed and imported) at least 7 days before the midterm." The first midterm is under 2 weeks away and the student chose the full MVP even if it arrives after it, so the approved target is: *for each assessment after R1 is in use, all lectures it covers in the in-scope modules are processed at least 7 days before it. First target: the final exams of the Computer Science modules, in the exam period 7–19 Dec 2026, so processed by 30 Nov 2026.* | [SEED §1] [USER Q-02] [USER Q-11] [USER Q-12] [USER CP1] [DEC-012] [DOC ug_course_syllabus_template_doc_COMP4901B.docx.pdf p.2] | 0 lectures processed (the system is new) | For each assessment: the lectures it covers (from `pipeline.config.json` or Canvas), compared with the dates on which their cards and questions were imported (the import log); a lecture counts when both its deck and its question bank are imported | 7 days before each assessment |
| SM-2 | **Approved reading (`DEC-012`).** Flashcard retention at least 85% (the seed says "85–90% or higher, measured by FSRS"; this reading sets the lower bound as the pass target and defines the formula over the review log). The FSRS desired retention is set to 0.90. | [SEED §1] [USER CP1] [DEC-012] [DOC study-app-spec.md §1.1] | None: the student starts fresh, with no imported history [USER Q-14] | True retention = reviews of cards already in the FSRS review state that are rated Hard, Good or Easy, divided by all such reviews, over the trailing 30 days, from the card review log | Weekly, from 30 days after R1 is in use |
| SM-3 | Fewer than 2% of accepted cards and questions are later reported as wrong. | [SEED §1] [DEC-012] | None (new system) | Distinct items reported with the reason "wrong" (story 11), divided by all accepted items imported, per module per semester. Reports with the reason "unclear" are counted separately and not in this metric | End of each semester; running figure on the Stats page from R2 |
| SM-4a | No missed deadlines. | [SEED §1] [DEC-012] | Unknown: not recorded today | Deadlines whose due time has passed without being marked submitted or done, counted from the deadline records | Continuously; reviewed weekly |
| SM-4b | The daily checklist is completed on at least 5 days a week. | [SEED §1] [DEC-012] | None (new system) | A day counts as completed when every required (non-optional) item on that day's checklist is marked done by the end of that day, in the student's time zone; counted per calendar week from the daily plan records | Weekly |
| SM-5 | Every concept in an assessment's scope has been quizzed at least twice before that assessment. | [SEED §1] [DEC-012] | None (new system) | For each assessment: the concepts whose assessment list includes it, each with its count of quiz attempts before the assessment's due time; target 100% of those concepts with 2 or more | Before each assessment |
| SM-6 | **Restated objective (`DEC-012`).** Seed: "Claude API spend stays within the monthly budget (budget Unknown)". The student set no fixed limit and asked to see the spend, so the approved target is: *each month's Claude API spend by the app is visible to the student.* The pipeline runs on the student's Claude subscription, so it makes no API spend; the R1 app makes no Claude calls (`ASM-043`), so this applies from R2. | [SEED §1] [USER Q-06] [USER Q-15] [USER CP1] [DEC-012] | None | Token counts logged per Claude call, priced at the configured per-token rates and summed per calendar month; the student confirms the Stats page shows the month's total | Monthly, from R2 |

### QA & Test Engineer confirmation (Stage 1 step 2)

Each metric above is measurable from data the seed's data model already holds or that a requirement will have to record [DOC study-app-spec.md §2]:

| Metric | Data needed | Recorded by | Gap to carry into Stage 2 |
| :-- | :-- | :-- | :-- |
| SM-1 | Assessment dates and lecture coverage; import dates per lecture | Deadline records (`covers_lectures`); the import step | The import log with a date per lecture is not in the seed's data model: a requirement for A10 |
| SM-2 | Each card review with its rating and the card's state before the review | Card review log and card state | The state *before* each review must be logged: a requirement for A10 |
| SM-3 | Reports with a reason; accepted items imported | Feedback items; the import step | A report reason ("wrong" or "unclear") is not in the seed's data model: a requirement for A10 |
| SM-4a | Due time and submitted status | Deadline records (`status`) | None |
| SM-4b | Each day's required items and when they were marked done | Daily plan items (`optional`, `done`) | The time an item is marked done is needed to judge "by the end of that day": a requirement for A10 |
| SM-5 | Concept assessment lists; quiz attempts with times | Concepts (`assessments`); question attempts (`answered_at`) | None |
| SM-6 | Tokens per call; per-token prices | Tutor messages (`tokens_in`, `tokens_out`); grading calls | Token logging for grading calls, and configured prices: a requirement for A10 |

Every metric therefore has a stated method; none relies on a judgement that can't be recomputed.

## 4. Stakeholders and interests

| Stakeholder | Role | Interests |
| :-- | :-- | :-- |
| The student (owner) | The only user, who also runs the pipeline, confirms inferred items, reviews flagged items and maintains the system [SEED §2] [SEED §9] | A clear daily plan; accurate cards that match the course; less time making cards; never missing a deadline; affordable running costs; review history never lost |
| Module lecturers and HKUST | Don't use the app; own the course material; set the academic integrity rules [SEED §2] | Course material kept private and not published [SEED §7]; coursework written by the student. COMP 4901B's AI policy allows AI help with coding and debugging but not copying AI-generated text into submitted work [DOC ug_course_syllabus_template_doc_COMP4901B.docx.pdf p.3] |
| Anthropic | Provider of Claude: the API and Claude Code [SEED §2] [USER Q-05] | Use within its terms (`ASM-058`) |

## 5. Scope

### 5.1 In scope

Releases follow the seed's priorities: **R1 = the Must stories (the MVP)**, **R2 = the Should stories**, **R3 = the Could stories**, as approved at CP1 (`DEC-010`) [USER CP1].

**Generation pipeline** (runs in Claude Code on the student's Claude subscription [USER Q-05] [USER Q-15]):

| # | Item | Release | Source |
| :-- | :-- | :-- | :-- |
| SC-P01 | An Extractor that builds the notation glossary and pulls deadlines and readings from the handbook, the slides and Canvas | R1 | [SEED §3 story 3] [DEC-009] |
| SC-P02 | A Card Creator and an independent Card Reviewer for each lecture, with the blind-answer test and at most 2 revision rounds | R1 | [SEED §3 story 1] [DOC flashcard-pipeline.md §3.3–3.4, §7] |
| SC-P03 | A Question Creator and an independent Question Reviewer, writing several genuinely different variants per concept that match the assessment formats; `core` concepts get 3–5 variants | R1 | [SEED §3 story 2] [DEC-006] |
| SC-P04 | A Module Auditor checking coverage, duplicates and notation, and proposing cross-lecture items | R1 | [SEED §5] [SEED §3 Reports & outputs] [DOC flashcard-pipeline.md §3.7] |
| SC-P05 | Processing order: Computer Science modules first (Theory of Computation, Machine Learning, LLMs), then the other in-scope modules by nearest assessment; lectures covered by the nearest assessment first within a module | R1 | [SEED §3 story 4] [USER Q-12] |
| SC-P06 | A human review step before export: flagged items, inferred dates, module-specific notation and a spot-check sample | R1 | [SEED §3 story 5] [DOC flashcard-pipeline.md §9] |
| SC-P07 | Export of the six app files with stable ids, plus a pipeline run summary and module audit per run | R1 | [SEED §5] [SEED §3 Reports & outputs] |
| SC-P08 | Reading course material from Canvas directly, or from local files, including maths- and diagram-heavy slides (placed in R1 under `DEC-010` [USER CP1]) | R1 | [DEC-009] [DEC-010] [USER Q-08] [USER CP1] |
| SC-P09 | Taking reported items (story 11) back into the next run | R1 | [SEED §3 story 11] [ASM-038] |
| SC-P10 | Reviewing tutor proposals before they join the bank | R2 | [SEED §3 story 14] |
| SC-P11 | Top-up runs for concepts running low on unseen variants, from the full `feedback.json` | R3 | [SEED §3 story 18] [DOC flashcard-pipeline.md §10] |

**Study app** (a mobile-first web app, laptop only until story 17 [USER Q-04]):

| # | Item | Release | Source |
| :-- | :-- | :-- | :-- |
| SC-A01 | Import of the pipeline files with a preview of what is new, changed or removed; stable ids keep review history; removed items are suspended, not deleted | R1 | [SEED §3 story 6] [SEED §4 Retention] |
| SC-A02 | Flashcard review with FSRS, keyboard shortcuts and LaTeX rendering | R1 | [SEED §3 story 7] |
| SC-A03 | A daily quiz of due concepts, each shown as an unseen variant; MCQs marked automatically, written answers self-marked | R1 | [SEED §3 story 8] |
| SC-A04 | Deadlines with live countdowns; adding and editing them by hand; confirming extracted ones | R1 | [SEED §3 story 9] |
| SC-A05 | A "Today" checklist of reviews, quizzes, new cards, required readings and carried-over items | R1 | [SEED §3 story 10] |
| SC-A06 | Reporting a wrong or unclear card or question, with the reports exported for the next pipeline run | R1 | [SEED §3 story 11] [ASM-038] |
| SC-A07 | Claude marking of written answers, with override | R2 | [SEED §3 story 12] |
| SC-A08 | A Claude tutor (Explain, Socratic, Quiz me) opened from any card, question or result, with context loaded | R2 | [SEED §3 story 13] |
| SC-A09 | Accepting, editing or discarding tutor proposals | R2 | [SEED §3 story 14] |
| SC-A10 | Assessment mode and timed mock exams, with mock exam results | R2 | [SEED §3 story 15] [SEED §3 Reports & outputs] |
| SC-A11 | A daily time budget with deferral, coursework milestones and `.ics` export of deadlines | R2 | [SEED §3 story 16] [SEED §3 Reports & outputs] |
| SC-A12 | A Stats page: reviews per day, retention, concept mastery per assessment's scope, Claude API spend this month (placed in R2 under `DEC-010` [USER CP1], so SM-3 and SM-6 are visible in R2; the review-load forecast comes with `SC-A15` in R3) | R2 | [SEED §3 Reports & outputs] [DEC-010] [USER CP1] |
| SC-A13 | Hosted access behind a password, offline study, and notifications | R3 | [SEED §3 story 17] [SEED §3 Reports & outputs] |
| SC-A14 | Full `feedback.json` export (reports, top-up requests, tutor proposals) | R3 | [SEED §3 story 18] |
| SC-A15 | FSRS parameters fitted to the student's history, and review-load forecasts | R3 | [SEED §3 story 19] |
| SC-A16 | Flashcard export to Anki (TSV) | R3 | [SEED §3 story 20] |

The quality requirements in seed §7 (performance, offline behaviour, security, accessibility, time zones) apply to these items and are catalogued in A10 at Stage 2.

### 5.1a Key data in scope

The things the system tracks, modelled in A16 at Stage 2 [SEED §4 Main things to track] [DOC study-app-spec.md §2] [DOC flashcard-pipeline.md §4–§6]:
- **App:** modules, lectures, concepts and concept states; flashcards, card states and card review logs; questions and question attempts; glossary entries; deadlines and milestones; readings, tasks and daily plans; tutor threads and tutor messages; proposals and feedback items; settings.
- **Pipeline:** concept maps, draft and final items, review records, flagged items, the module audit, and `pipeline.config.json`.

**Sensitive data:**
- **Secrets:** the Claude API key [SEED §4] and the Canvas credential (`ASM-050`).
- **Copyrighted material:** course material (`DEC-008`).
- **Personal data:** the student's study history and tutor conversations [SEED §4].

**Retention:**
- **Kept:** review history is kept indefinitely; removed cards and questions are suspended, not deleted [SEED §4].
- **Assumed:** tutor conversations and pipeline intermediate files follow `ASM-023` and `ASM-024`.
- **Volumes:** `ASM-025`, `ASM-051`.

### 5.2 Out of scope

| # | Item | Source |
| :-- | :-- | :-- |
| SC-X01 | Multiple users, accounts, sharing of decks, collaboration with course-mates | [SEED §11] |
| SC-X02 | Native iOS or Android apps; the PWA only | [SEED §11] |
| SC-X03 | ~~Direct integration with the university's learning platform~~: **dropped by the student**; reading Canvas is in scope (`SC-P08`). Still out: scraping university portals other than Canvas, writing to Canvas, submitting work through it, and reading Canvas discussions, class rosters or other students' data | [SEED §11] [DEC-009] [ASM-049] [ASM-061] |
| SC-X04 | Two-way sync with Anki; one-way TSV export only (`SC-A16`) | [SEED §11] |
| SC-X05 | Generating cards or questions from general knowledge; everything comes from the student's course material | [SEED §11] |
| SC-X06 | The tutor writing or rewriting assessed coursework | [SEED §11] |
| SC-X07 | A pipeline-free "generate a fresh question every day"; quizzes draw only from the reviewed question bank | [SEED §11] |
| SC-X08 | The Mandarin module | [DEC-007] [USER Q-13] |
| SC-X09 | Importing existing Anki cards or review history | [USER Q-14] |

## 6. Deliverables

| # | Deliverable | Release |
| :-- | :-- | :-- |
| D1 | The study app: a local web app with its database, built test-first in this repository | R1–R3 |
| D2 | The generation pipeline as a Claude Code project: agent definitions, commands, prompts, and scripts that validate and export the pipeline files | R1–R3 |
| D3 | The Workbook artifacts selected in the Tailoring Record (A04) | All stages |
| D4 | The documentation set (A63): user guide, runbook, developer README | R1 (work package `5.4`), updated inside each R2 and R3 slice leaf (`A05` §"Structure and rules") |

## 7. Constraints

| Constraint | Detail | Source |
| :-- | :-- | :-- |
| Budget | No fixed monthly limit; spend must be visible. No cash build budget beyond the student's time and AI usage | [USER Q-06] [ASM-030] |
| Dates | The first midterm is within 2 weeks of 2026-10-20 and the MVP may arrive after it. The HKUST exam period is 7–19 Dec 2026. Exact midterm dates are unknown | [USER Q-02] [USER Q-11] [DOC ug_course_syllabus_template_doc_COMP4901B.docx.pdf p.2] [ASM-045] |
| Team | The agent builds, test-first; the student reviews each pull request and answers checkpoints | [USER Q-03] [DEC-004] |
| Checkpoints | ADVISORY: STRICT at CP1 and CP2 | [USER Q-10] [DEC-005] |
| Pipeline runtime | Claude Code, on the student's Claude subscription | [USER Q-05] [USER Q-15] |
| Platform | Mobile-first PWA, laptop only until story 17. The seed's stack (React + TypeScript, `ts-fsrs`, Node, SQLite, Claude TypeScript SDK) is a recommendation until an ADR adopts it | [SEED §8] [USER Q-04] |
| Repository | Public: no course material, no secrets, no `.env` files | [SEED §7] [AGENTS.md §3] [DEC-008] |
| Ask first | Paid services or significant Claude spend; changes to card rules, question rules or reviewer rubrics; sending course material to a third party other than Anthropic; anything that could delete or overwrite review history | [SEED §10] |

## 8. Key assumptions

High impact: `ASM-001` (pipeline and app both in scope), `ASM-016` (refuted: text extraction is not enough) and `ASM-046` (slides read as images), `ASM-021` (one user), `ASM-044` (subscription limits), `ASM-045` (dates), `ASM-050` (Canvas credential kept secret), `ASM-053` (3 h/day of agent session time), `ASM-058` (Anthropic's terms on subscription pipeline runs). Medium impact and confirmed or accepted for planning at CP1: `ASM-022`, `ASM-036`, `ASM-038`, `ASM-047`, `ASM-048`, `ASM-049`, `ASM-051`, `ASM-061`, `ASM-062`, `ASM-063`, `ASM-064`. The full register is in [assumptions-decisions.md](../00-governance/assumptions-decisions.md).

## 9. High-level milestones

Dates are derived from effort estimates at 3 hours of agent session time per day (`ASM-052`, `ASM-053`), not promised; the range is in [schedule.md](schedule.md).

<!-- BEGIN GENERATED:milestones by schedule_calc.py -->
| Milestone | Derived date at 3 h/day | Range (earliest – latest) |
| :-- | :-- | :-- |
| CP1: scope and plan approved | 23 Oct 2026 | 22 Oct 2026 – 25 Oct 2026 |
| CP2: requirements baseline and sourcing decision | 29 Oct 2026 | 26 Oct 2026 – 4 Nov 2026 |
| CP3: design baseline (ADVISORY) | 3 Nov 2026 | 30 Oct 2026 – 12 Nov 2026 |
| Pipeline complete: real lectures can be processed (after SL-05) | 9 Nov 2026 | 3 Nov 2026 – 21 Nov 2026 |
| R1 (MVP) ready: G5 and CP4 for R1 | 16 Nov 2026 | 8 Nov 2026 – 3 Dec 2026 |
| R2 ready: G5 and CP4 for R2 | 23 Nov 2026 | 12 Nov 2026 – 13 Dec 2026 |
| R3 ready: G5 and CP4 for R3 | 27 Nov 2026 | 16 Nov 2026 – 20 Dec 2026 |
| Closedown: Gate G6 | 28 Nov 2026 | 17 Nov 2026 – 22 Dec 2026 |
<!-- END GENERATED:milestones -->
