# A41 · Report & Output Design

Owner: System Architect. Stage 3, written 2026-10-21. Catalog entry: A41 (`03-design/reports.md`).

This document specifies every report, dashboard, file export, pipeline summary, and notification produced by the Study App and the Generation Pipeline (`[SEED §3 Reports & outputs]`, `[DOC flashcard-pipeline.md §8, §10, §11]`, `[DOC study-app-spec.md §1.4, §3.5, §4, §5]`), following catalog Appendix B5 (*Form and report guidelines*) and the `DATA` project-type requirements (`DEC-002`: refresh frequency and data freshness indicators).

---

## 1. Report & Output Inventory

Every report traces to one or more requirements in `A10` and names its audience role from `A13`/`A36` (`Student (Learner)` or `Student (Pipeline Operator)`, `[SEED §2]`, `ASM-021`).

| ID | Name | Purpose (decision or task supported) | Audience role | Trigger / frequency | Delivery channel | Freshness / refresh cadence (`DATA` type) | REQ / UC trace |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| `RPT-01` | **Today Daily Study Plan & Workload Summary** | Decide what to study today across all 4 modules, monitor daily time budget vs required workload, and track completion (`SM-4a`, `SM-4b`). | `Student (Learner)` | Automatic at local midnight (`00:00` in `Settings.timezone`, default `Asia/Hong_Kong`) or first app open of the day; manual rebuild via `GET /api/today?rebuild=true` (`getTodayPlan`). | Screen (`SCR-01` Today) | Real-time on item completion (`PATCH /api/today/items/{itemId}`, `updateTodayPlanItem`); header shows `Plan date: YYYY-MM-DD (HKT) · Last updated: HH:MM:SS · Last pipeline import: <relative time>` (`ImportBatch.imported_at`). | `REQ-F-038`, `REQ-F-039`, `REQ-F-040`, `REQ-F-041`, `REQ-F-055`, `REQ-N-003`, `UC-10`, `UC-16` |
| `RPT-02` | **Study & Spend Statistics Dashboard (`Stats` & Module Mastery)** | Evaluate 30-day flashcard retention (`SM-2`), concept mastery by assessment scope (`SM-5`), pipeline processing lead time (`SM-1`), reported-item error rate (`SM-3`), 7-day checklist completion consistency (`SM-4b`, no streak counter per `REQ-F-040`), monthly Claude API spend vs cap (`SM-6`), and 30-day review-load forecast. | `Student (Learner)` | On demand when opening `SCR-08` (`GET /api/stats`, `getStatsAndSpend`) and `SCR-04` (`GET /api/modules/{moduleId}`, `getModuleSummary`). | Screen (`SCR-08` Stats & `SCR-04` Module Mastery) | Recomputed on page load and on `[Refresh]`; displays `Data as of: YYYY-MM-DD HH:MM HKT · Last import: YYYY-MM-DD HH:MM HKT` (`ImportBatch.imported_at`). | `REQ-F-058`, `REQ-F-065`, `REQ-F-023`, `REQ-F-026`, `REQ-F-040`, `REQ-F-042`, `REQ-F-048`, `REQ-F-076`, `REQ-F-079`, `REQ-F-081`, `REQ-F-083`, `REQ-F-085`, `REQ-F-089`, `UC-17`, `UC-20` |
| `RPT-03` | **Mock Exam Results & Weak-Concept Breakdown** | Assess readiness after a timed practice exam, review per-question marking feedback, and launch targeted flashcard drills or tutor explanations for weak concepts. | `Student (Learner)` | Event-driven immediately upon submitting a mock exam (`POST /api/exams/mock/{examId}/submit`, `submitMockExam`). | Screen (`SCR-09` Mock Exam Results view) | Immutable attempt snapshot in `question_attempt` (`R14` where `mode = 'mock_exam'`), with live `ConceptState.stability` and `Retrievability R` joined at view time (`As of: YYYY-MM-DD HH:MM HKT`). | `REQ-F-054`, `REQ-F-032`, `REQ-F-033`, `REQ-F-034`, `UC-15` |
| `RPT-04` | **Pipeline Run Summary (`run-summary.json` & CLI Report)** | Verify which modules and lectures were processed, how many cards/questions were accepted vs flagged per review round, how long the run took (`REQ-N-006`), and what awaits human review (`UC-05`). | `Student (Pipeline Operator)` | Event-driven at the end of every `pipeline-cli plan-run` / `spot-check-and-export` run (`CLI-03`, `CLI-06`) and recorded on `applyModuleImport` (`POST /api/import/apply`). | JSON file (`<workspace>/run-summary.json`), CLI stdout table, and `SCR-06` Import history table | Written atomically at run completion (`completed_at` UTC ISO-8601 timestamp); `SCR-06` displays `Run finished: YYYY-MM-DD HH:MM HKT`. | `REQ-F-006`, `REQ-F-018`, `REQ-F-023`, `REQ-N-006`, `UC-04`, `UC-06` |
| `RPT-05` | **Module Audit Report (`module-audit.json` & Audit View)** | Identify syllabus learning outcomes with zero cards/questions, concepts below minimum variant count for upcoming assessments, cross-lecture duplicates, and non-canonical notation before final export. | `Student (Pipeline Operator)` | Event-driven after all lectures in a module complete Stage A and Stage B (`Module Auditor` subagent + `CLI-06`). | JSON file (`<workspace>/module-audit.json`) and rendered summary on `SCR-06` (`Pipeline Module Import & Diff Preview`) | Generated per module audit run (`audited_at` UTC ISO-8601 timestamp + `source_lectures_count` freshness badge). | `REQ-F-015`, `REQ-F-016`, `UC-04`, `UC-05` |
| `RPT-06` | **Deadline Urgency & Daily Study Notifications** | Alert the student to approaching deadlines (`< 7 days`, `< 48 hours`, overdue) and unfinished daily study plans without relying on colour alone (`[SEED §3]`, `[SEED §7]`). | `Student (Learner)` | Event-driven at app open, on deadline urgency transitions (`DT-05`), and optional daily reminder when browser notifications are enabled (`Settings.notifications_enabled` in `R3`). | In-app urgency banner (`SCR-01`, `SCR-05`) in `R1`–`R3`; Web Notifications API (`Notification`) in `R3` (`SL-18`). | Evaluated every 60 s (every 1 s when `< 1 h` remains on `SCR-01`/`SCR-05`, `BR-033`). | `REQ-F-037`, `REQ-F-056`, `REQ-F-062`, `REQ-N-018`, `UC-09`, `UC-16`, `UC-18` |
| `RPT-07` | **iCalendar Deadlines & Milestones Feed (`study-deadlines.ics`)** | View module deadlines and coursework milestones in an external calendar application (Apple Calendar, Google Calendar, Outlook). | `Student (Learner)` | On demand via `[Download .ics]` on `SCR-05` / `SCR-10` (`GET /api/calendar.ics`, `exportCalendarIcs`). | RFC 5545 `.ics` file download (`text/calendar; charset=utf-8`). | Generated live from `deadline` (`R17`) and `milestone` (`R19`) tables with `DTSTAMP` set to current UTC timestamp. | `REQ-F-057`, `UC-16`, `INT-04` |
| `RPT-08` | **Pipeline & Feedback JSON Dataset Exports (`6` App Files + `feedback.json`)** | Exchange reviewed flashcards, questions, concepts, glossary terms, deadlines, readings, and reported/top-up/proposed feedback items between the pipeline and the study app. | `Student (Pipeline Operator)` | On demand at the end of `UC-05` (`CLI-06` `spot-check-and-export` writes the 6 files) and via `[Export feedback.json]` on `SCR-10` (`GET /api/export/feedback`, `exportFeedbackJson`). | JSON files conforming to `pipeline-contracts.schema.json` (`A34`). | Stamped with `exported_at` UTC ISO-8601 timestamp and `version: "1.0"`. | `REQ-F-019`, `REQ-F-020`, `REQ-F-042`, `REQ-F-063`, `UC-05`, `UC-11`, `UC-19`, `INT-01` |
| `RPT-09` | **Anki Tab-Separated Deck Export (`deck.anki.tsv`)** | Optional portable export of accepted flashcards (`front<TAB>back<TAB>tags`) for backup or external review (`[SEED §3 story 20]`). | `Student (Learner)` | On demand via `pipeline-cli spot-check-and-export --anki-tsv` (`CLI-06`) or `[Export Anki TSV]` on `SCR-10` (`GET /api/export/anki.tsv`, `exportAnkiTsv`). | UTF-8 TSV file (`text/tab-separated-values; charset=utf-8`). | Generated live from active `card` (`R06`) and `card_tag` (`R07`) rows with `#exported_at:` header comment. | `REQ-F-066`, `UC-21`, `INT-05` |

---

## 2. Detailed Report & Output Specifications

### 2.1 `RPT-01` · Today Daily Study Plan & Workload Summary

- **Purpose:** Single daily checklist (`[SEED §1 Primary goal]`) combining carried-over tasks, due flashcard reviews, due concept quizzes, new flashcards, required readings, coursework milestones, assessment-mode prep, recommended readings, and personal tasks, bounded by the student's daily time budget (`BR-035`–`BR-037`, `DT-06`).
- **Data items and sources (`A16`/`A32`/`A33`):**
  - `DailyPlan` (`R22` `daily_plan`) & `v_daily_plan_summary`: `id`, `plan_date`, `budget_min`, `generated_at`, `total_est_minutes`, `required_minutes`, `over_budget_warning`, `completed`.
  - `DailyPlanItem` (`R23` `daily_plan_item`): `id`, `plan_id`, `kind` (`carryover`, `card_review`, `quiz`, `new_cards`, `required_reading`, `milestone`, `assessment_prep`, `recommended_reading`, `task`), `order_index` (`1..N`), `module_id`, `ref_id`, `title`, `est_minutes`, `priority` (`required`, `optional`), `completed` (`0` or `1`), `completed_at`, `carried_over` (`0` or `1`), `deferred` (`0` or `1`).
  - `Deadline` (`R17` `deadline`): top 4 upcoming unsubmitted deadlines (`status NOT IN ('submitted', 'done')`), joined with derived urgency badge (`DT-05`, `BR-033`) and live countdown string (`days + hours + minutes` when `< 48 h`, `days` when `>= 48 h`).
  - **Derived values & rules:**
    - `Estimated item time` (`BR-035`): `card_review = count * 8 / 60 min`, `new_cards = count * 25 / 60 min`, `quiz = mcq_count * 0.75 min + written_count * 3.0 min`, `required_reading / recommended_reading = page_count * settings.minutes_per_page`, `milestone = est_minutes`, `task = est_minutes`.
    - `Progress percentage` (`v_daily_plan_summary`): `ROUND(100.0 * completed_required_min / NULLIF(required_minutes, 0), 0)`.
    - `Assessment mode banner` (`BR-043`): active when any unsubmitted `exam` or `midterm` deadline has `0 <= (due_at - now) <= settings.assessment_mode_days` (default `21` days).
- **Filters, sorting, grouping, and totals:**
  - Grouped into: (1) **Assessment Mode & Over-Budget Alerts** (if active), (2) **Deadline Countdowns Strip** (sorted by `due_at ASC`), (3) **Required Checklist Items** (sorted by `order_index ASC`, then `module_id ASC`), (4) **Optional & Deferred Items** (collapsed by default for `deferred = 1` items, `BR-036`).
  - Totals right-aligned in header: `Completed: X / Y required items · Est. remaining: MM min / Budget: BB min`.
- **Display choice (`Appendix B5`):** Structured checklist table with right-aligned item counts and minute totals, horizontal progress bar with text fraction (`65% · 52 / 80 min`), and dual-coded urgency badges (`[!! HIGH · <48h]`, `[! MED · <=7d]`, `[OK LOW · >7d]`, `[OVERDUE · Past due]`).
- **Volume and performance expectation:** `5–25` plan items and `1–10` deadlines per day; full query and render `< 1,000 ms` (`p95`, `REQ-N-003`).
- **Sample layout (`SCR-01`):**
  ```text
  ================================================================================
  TODAY'S STUDY PLAN · Wed 28 Oct 2026 (HKT)           Last import: 2h ago · 14:10
  [ASSESSMENT MODE: COMP4901B Final Exam in 18 days — scoping & new-card cap 30/d]
  Progress: [#############-------] 65% (52 / 80 min budget)    [Rebuild plan]
  --------------------------------------------------------------------------------
  UPCOMING DEADLINES
  1. [!! HIGH · <48h]     COMP4901B Homework 2     Due in 01d 09h 49m  [Submitted?]
  2. [OK LOW  · >7d]      COMP3211  Project MS 1   Due in 11d          [Submitted?]
  --------------------------------------------------------------------------------
  REQUIRED TODAY (Est. 68 min total · 16 min remaining)                 Est. Time
  [x] 1. [carryover]   COMP4901B · 4 due flashcards from Tue 27 Oct          1 min
  [x] 2. [card_review] COMP4901B · 38 / 38 due flashcards reviewed           5 min
  [ ] 3. [card_review] COMP3211  · 12 / 24 due flashcards remaining          2 min
  [ ] 4. [quiz]        COMP4901B · 6 due concepts (assessment scope first)  11 min
  [ ] 5. [new_cards]        COMP4901B · 15 new flashcards (Lecture W10: RL)       6 min
  [x] 6. [required_reading] COMP4901B · Sutton & Barto Ch. 13 (pp. 321-336)      32 min
  [ ] 7. [milestone]        COMP4901B · Draft HW2 Q2 policy gradient proof       11 min
  --------------------------------------------------------------------------------
  ▸ OPTIONAL & DEFERRED (2 items · 24 min deferred by 80 min budget cap)
  ================================================================================
  ```

---

### 2.2 `RPT-02` · Study & Spend Statistics Dashboard (`Stats` Page & Module Mastery)

- **Purpose:** Provide a single factual dashboard (`SCR-08` and `SCR-04`) for all 6 project success metrics (`SM-1`–`SM-6` in `A01 §3`), concept mastery per assessment scope, and 30-day FSRS workload forecasting (`[SEED §3 story 19 & Reports]`, `[DOC study-app-spec.md §4, §5]`).
- **Data items and sources (`A16`/`A32`/`A33`):**
  - **KPI Summary Cards (Table / Metric Tiles per `B5`):**
    1. **Trailing 30-Day True Retention (`SM-2`):** derived from `card_review_log` (`R09`) where `state_before = 'Review'` and `reviewed_at >= now - 30 days`:
       $$\text{True Retention} = \frac{\text{COUNT}(\text{rating} \in \{2, 3, 4\})}{\text{COUNT}(*)}$$
       Displays percentage, numerator/denominator count, target (`>= 85.0%`), and warning banner if `< 85.0%` recommending increasing `Settings.desired_retention` from `0.90` (`BR-026`, `BR-044`).
    2. **7-Day Checklist Completion Consistency (`SM-4b`, no streak counter per `REQ-F-040`):** derived from `daily_plan` (`R22`), `daily_plan_item` (`R23`), and `v_daily_plan_summary` over the trailing 7 days: days where all `priority = 'required'` items have `completed = 1` (`Target: >= 5 / 7 days`).
    3. **Reported-Item Error Rate (`SM-3`):** derived from `feedback_item` (`R28` where `kind = 'reported'` and `reason = 'wrong'`) divided by total reviewed distinct cards + questions per module (`Target: < 2.0%`).
    4. **Pipeline Processing Lead Time (`SM-1`):** derived from `import_batch` (`R30`) and `import_batch_lecture` (`R31`, `MIN(imported_at)` per lecture) compared against `deadline.due_at` (`R17`) and `deadline_lecture` (`R18`) for each assessment covering that lecture (`Target: >= 7.0 days before assessment`).
    5. **Monthly Claude API Spend (`SM-6`):** derived from `grading_call_log` (`R32`) + `tutor_message` (`R25`) for the current calendar month bounded in `Settings.timezone` (default `Asia/Hong_Kong` per `ASM-022`, `ASM-067`):
       $$\text{Spend (USD)} = \frac{\sum \text{cost\_micro\_usd}}{1,000,000}$$
       Broken down by feature (`marking` vs `tutor`), model (`claude-haiku-4-5` vs `claude-sonnet-4-6`, or `claude-haiku-5-5` / `claude-sonnet-5-5` per `Settings.token_rates_json`, `ASM-070`, `ASM-059`), and token category (`input_tokens`, `cached_tokens`, `output_tokens`), compared against `Settings.monthly_spend_cap_micro_usd` and `Settings.monthly_spend_cap_mode` (`'block'` [default] or `'warn'`, `BR-041`, `ASM-067`).
  - **Charts and Breakdown Tables (chosen per `Appendix B5`):**
    - **Daily Review Count & Retention Trend (Line Graph + Tabular Toggle):** 30-day daily time series (`date`, `cards_reviewed`, `questions_attempted`, `retention_pct`) — line graph for trend over time (`B5`), with an accessible table view for keyboard/screen-reader inspection.
    - **Concept Mastery by Module & Assessment Scope (Horizontal Stacked Bar Chart + Table on `SCR-04` & `SCR-08`):** derived from `v_concept_mastery` (`A32 §4.3`, `BR-044`): counts of concepts per module/assessment in `mastered (stability >= 21d AND attempts >= 2)`, `strong (stability >= 14d AND attempts >= 2)`, `developing (stability >= 3d)`, `weak (stability < 3d)`, and `unseen (state = 'New')` — bar chart for category comparison (`B5`).
    - **30-Day Review Load Forecast (`R3`, `REQ-F-065`, Bar Chart + Table):** projected daily due cards and concepts for `today + 1` to `today + 30` from `card_state.due` (`R08`) and `concept_state.due` (`R10`), plus FSRS optimizer comparison (`default` vs `fitted` weights log-loss / RMSE on `card_review_log` when `COUNT(*) >= 400`).
- **Filters, sorting, grouping, and totals:** Filter by `module_id` (`All modules` or specific module) and time window (`7d`, `30d`, `90d`, `Semester`); tables right-align all numeric counts, percentages (1 decimal place), and USD amounts (`$0.00`).
- **Volume and performance expectation:** Aggregates up to `500,000` `card_review_log` rows using `idx_card_review_log_reviewed_at`; response time `< 500 ms` (`p95`).
- **Sample layout (`SCR-08`):**
  ```text
  ================================================================================
  STATISTICS & SPEND DASHBOARD               Data as of: 2026-10-28 14:15 HKT
  Filter: [All Modules v]   Window: [Last 30 Days v]        [Refresh] [Fit FSRS]
  --------------------------------------------------------------------------------
  KEY METRICS (A01 §3 Success Metrics)
  +-------------------------+-------------------------+--------------------------+
  | 30d True Retention(SM-2)| 7d Plan Days (SM-4b)    | Reported "Wrong" (SM-3)  |
  |   88.4% (1,255 / 1,420) |   6 / 7 days complete   |   0.6% (3 / 480 items)   |
  |   [PASS: Target >= 85%] |   [PASS: Target >= 5/7] |   [PASS: Target < 2.0%]  |
  +-------------------------+-------------------------+--------------------------+
  | Assessment Lead (SM-1)  | Oct Claude Spend (SM-6) | Cache Hit Ratio          |
  |   18.2d before Final    |   $4.12 / $15.00 cap    |   86.4% cached input     |
  |   [PASS: 10/10 lecs]    |   [OK: 27.5% of cap]    |   Haiku $0.24·Sonnet$3.88|
  +-------------------------+-------------------------+--------------------------+
  CONCEPT MASTERY BY ASSESSMENT SCOPE (v_concept_mastery)
  Module / Assessment        Mastered(>=21d) Strong(>=14d) Developing Weak Unseen
  COMP4901B Final (120 conc)       42 (35.0%)    30 (25.0%)  20(16.7%)  18   10
  COMP3211  Midterm (64 conc)      28 (43.8%)    14 (21.9%)  10(15.6%)  12    0
  --------------------------------------------------------------------------------
  MONTHLY CLAUDE API SPEND BREAKDOWN (October 2026)
  Feature        Model                  Calls   Input Tok  Cached Tok  Output Tok   Spend
  Quiz Marking   claude-haiku-4-5         112      84,200   4,120,000      29,400   $0.24
  Course Tutor   claude-sonnet-4-6         48     192,000   1,850,000      34,100   $3.88
  TOTAL                                   160     276,200   5,970,000      63,500   $4.12
  ================================================================================
  ```

---

### 2.3 `RPT-03` · Mock Exam Results & Weak-Concept Breakdown

- **Purpose:** Present immediate post-exam diagnostic feedback (`SCR-09`) showing overall score, time spent, per-question marking breakdown, and one-click recovery actions (`[Review N related flashcards]` and `[Ask Claude]`) for weak concepts (`[SEED §3 story 15 & Reports]`, `REQ-F-054`).
- **Data items and sources (`A16`/`A32`/`A33`):**
  - `QuestionAttempt` (`R14` `question_attempt` where `mode = 'mock_exam'` and `mock_exam_id = ?`): `id`, `question_id`, `concept_id`, `mock_exam_id`, `user_answer`, `rating`, `grader`, `feedback`, `duration_ms`, `attempted_at`.
  - `QuestionAttemptPoint` (`R15` `question_attempt_point`) joined with `Question` (`R11`), `QuestionMarkingPoint` (`R13`), `Concept` (`R03`), and `ConceptState` (`R10`): `attempt_id`, `point_index`, `met`, `point_text`, `stem`, `model_answer`, `type`, `difficulty`, `stability`.
  - **Derived values:**
    - `Concept performance rollup`: groups exam attempts by `concept_id`, computes `score_pct` (`100%` for correct MCQ or `SUM(met) / COUNT(point_index)` for written questions), flags any concept with `rating IN (1, 2)` (`Again` or `Hard`) or `score_pct < 60` as `Weak Concept`, and counts linked active flashcards in `concept_card` (`R05`).
- **Filters, sorting, grouping, and totals:** Weak concepts sorted by `score_pct ASC`, then `ConceptState.stability ASC`; question review list filterable by `[All | Incorrect / Partial | Correct]`.
- **Display choice (`Appendix B5`):** Summary score banner, weak-concept action table (for immediate remedial action), and expandable per-question comparison cards with side-by-side student answer vs marking points.
- **Volume and performance expectation:** `10–35` questions per mock exam; renders immediately (`< 300 ms`) once marking completes.
- **Sample layout (`SCR-09` Results View):**
  ```text
  ================================================================================
  MOCK EXAM RESULTS · COMP4901B Final Practice #1       Submitted: 28 Oct 15:42 HKT
  Score: 76.5% (15.3 / 20.0 pts) · Time: 48m 12s / 60m 00s · Weak concepts: 3
  --------------------------------------------------------------------------------
  WEAK CONCEPTS REQUIRING DRILL (Sorted by lowest score)
  Concept ID          Topic Summary                  Exam Score  Stability  Action
  COMP4901B-W10-K04   PPO clipped surrogate objective     25.0%      3.2 d  [Drill 4 cards] [Ask Claude]
  COMP4901B-W09-K02   RLHF Bradley-Terry reward model     50.0%      5.8 d  [Drill 3 cards] [Ask Claude]
  --------------------------------------------------------------------------------
  QUESTION BREAKDOWN (Filter: [Incorrect / Partial (4)] [All (15)])
  Q4 · [calculation · Diff 3] COMP4901B-W10-K04 · Score: 25% (1/4 marking points)
    Your answer:    L_CLIP = E[ min(r_t A_t, clip(r_t, 1-eps, 1+eps)) ]
    Missing points: (1) Missing A_t inside the second argument of min: clip(...) * A_t;
                    (2) Did not state behavior when A_t < 0 vs A_t > 0.
    Override rating: [1: Again (active)] [2: Hard] [3: Good] [4: Easy]   [Report problem]
  ================================================================================
  ```

---

### 2.4 `RPT-04` · Pipeline Run Summary (`run-summary.json` & CLI Report)

- **Purpose:** Give the student (`Pipeline Operator`) a deterministic record of what a pipeline run processed, module/lecture ordering (`[USER Q-12]`), per-round Reviewer acceptance/revision/rejection counts, flagged item counts awaiting `UC-05`, and wall-clock duration per lecture (`REQ-F-018`, `REQ-N-006`).
- **Data items and sources (`A16`/`A32`):**
  - Pipeline workspace files (`E24` `ReviewRecord`, `E25` `FlaggedItem`, `E26` `ModuleAudit`, `E27` `PipelineRunSummary`) aggregated by `pipeline-cli plan-run` / `spot-check-and-export` (`CLI-03`, `CLI-06`).
  - Fields in `run-summary.json` (`E27`): `run_id`, `module_id`, `started_at`, `completed_at`, `lectures_processed`, `concepts_extracted`, `cards_accepted`, `cards_revised`, `cards_rejected`, `cards_flagged`, `questions_accepted`, `questions_revised`, `questions_rejected`, `questions_flagged`, `spot_check_sample_size`, `spot_check_rejected_count`.
- **Filters, sorting, grouping, and totals:** Sorted in exact execution order (`BR-005`: CS modules first, then nearest assessment); column totals at bottom.
- **Display choice (`Appendix B5`):** Fixed-width CLI table + structured JSON file + `SCR-06` import batch history table.
- **Volume and performance expectation:** `1–26` lectures per run; summary generation `< 100 ms`.
- **Sample layout (CLI stdout & `SCR-06` summary):**
  ```text
  ================================================================================
  PIPELINE RUN SUMMARY · Run ID: run-20261028-061500Z     Order: CS-first (BR-005)
  Started: 2026-10-28T06:15:00Z · Finished: 2026-10-28T06:24:18Z (Total: 09m 18s)
  --------------------------------------------------------------------------------
  Module     Lecture  Time    Concepts  Cards(Acc/Flg/Rej/Rnds)  Questions(Acc/Flg/Rej/Rnds)
  COMP4901B  W10      09m 18s       14     28 /  1 /  2 (2 rnds)        42 /  1 /  1 (2 rnds)
  --------------------------------------------------------------------------------
  HUMAN REVIEW QUEUE BEFORE EXPORT (UC-05):
  - Flagged items requiring decision: 2 (1 card, 1 question)
  - Module-specific glossary entries: 9
  - Inferred deadlines/readings:      2
  - 10% spot-check sample:            7 items (3 cards, 4 questions)
  ================================================================================
  ```

---

### 2.5 `RPT-05` · Module Audit Report (`module-audit.json` & Audit View)

- **Purpose:** Cross-lecture quality gate (`[DOC flashcard-pipeline.md §3.7, §8]`, `REQ-F-015`, `REQ-F-016`) verifying that every syllabus learning outcome has coverage, every concept in an upcoming assessment's scope meets its variant count target (`DEC-006`: `core` 3–5, `supporting` 2–3), cross-lecture duplicate cards/questions are identified, and notation drift from `glossary.json` is flagged.
- **Data items and sources (`A16`/`A32`):**
  - `ModuleAudit` (`E26` `module-audit.json`): `module_id`, `audited_at`, `duplicate_groups[]`, `notation_drifts[]`, `prerequisite_gaps[]`, `coverage_gaps[]`, `exam_alignment_score`.
- **Display choice (`Appendix B5`):** 4-section diagnostic table on `SCR-06` (`Pipeline Module Import & Diff Preview`) with `[Accept audit fix]` / `[Dismiss]` actions.
- **Volume and performance expectation:** `1` report per module (`10–26` lectures); `< 50` rows per section.
- **Sample layout (`SCR-06` Module Audit panel):**
  ```text
  ================================================================================
  MODULE AUDIT REPORT · COMP4901B (Lectures W01–W10)   Audited: 2026-10-28 14:25 HKT
  --------------------------------------------------------------------------------
  1. LEARNING OUTCOME COVERAGE (4 / 4 outcomes covered · 0 missing)
     [COVERED] LO-3: Formulate alignment & RLHF objectives -> W09-K01..K04, W10-K01..K06
  2. ASSESSMENT VARIANT GAPS (0 gaps — all core concepts have 3–5 variants)
  3. CROSS-LECTURE DUPLICATES (1 pair found)
     - Cards COMP4901B-W09-C012 & COMP4901B-W10-C002 (KL divergence penalty in RLHF)
       Recommendation: Keep W09-C012, suspend W10-C002
  4. NOTATION CONSISTENCY (1 issue found)
     - Question COMP4901B-W10-Q008: uses bare "MDP" -> expected "Markov decision process (MDP)"
  ================================================================================
  ```

---

### 2.6 `RPT-06` · Deadline Urgency & Daily Study Notifications

- **Purpose:** Warn the student of imminent or overdue assessments/coursework and daily study plan reminders (`[SEED §3 Reports & outputs: Notifications]`, `REQ-F-037`, `REQ-F-056`, `REQ-F-062`).
- **Trigger events, recipient, content, and opt-out (`Catalog A41` notification rules):**
  - **Recipient:** `Student (Learner)` (single user, `ASM-021`).
  - **Triggers & Content:**
    1. **Deadline Urgency Transition (`DT-05`, `BR-033`):** When an unsubmitted deadline (`status NOT IN ('submitted', 'done')`) enters `<= 7 days` (`medium` urgency), `< 48 hours` (`high` urgency, switches to `days + hours + minutes`), `< 1 hour` (switches to `MMm SSs`), or `< 0 seconds` (`overdue` with `[Submitted?]` prompt). Content: `"[!! HIGH <48h] <Module> <Title> is due in <Countdown> (<Due Date HKT>)"`.
    2. **Daily Study Plan Ready / Unfinished Reminder (`R3`, `SL-18`):** At `09:00` local time if `daily_plan` (`R22`) has pending required items, and at `20:00` local time if required items remain unfinished when `Settings.notifications_enabled = 1` (`R29`). Content: `"Study App: <N> required items (<MM> min) remaining on Today's plan."`
  - **How the recipient turns them off:**
    - In `SCR-10` (`Settings`), the student can toggle `notifications_enabled` (`0` by default until explicitly enabled by the student via `PATCH /api/settings`, `updateSettings`).
    - In-app urgency badges on `SCR-01` (`Today`) and `SCR-05` (`Schedule`) are silenced per deadline as soon as the student checks `[Submitted?]` (`PUT /api/deadlines/{deadlineId}`, `upsertDeadline` setting `status = 'submitted'`).
- **Accessibility (`Appendix B5`, `BR-033`, `REQ-N-018`):** Urgency is never conveyed by colour alone; every badge pairs colour with an explicit text label and icon (`[!! HIGH <48h]`, `[! MED <=7d]`, `[OK LOW >7d]`, `[OVERDUE — Submitted?]`).

---

### 2.7 `RPT-07` · iCalendar Deadlines & Milestones Feed (`study-deadlines.ics`)

- **Purpose:** Export all active module deadlines and coursework milestones as a standard RFC 5545 `.ics` file (`[SEED §3 story 16 & Reports]`, `REQ-F-057`, `INT-04`).
- **Data items and sources (`A16`/`A32`/`A33`):**
  - `Deadline` (`R17`): `id`, `module_id`, `title`, `type`, `due_at`, `timezone`, `weighting`, `confidence`, `status`.
  - `Milestone` (`R19`): `id`, `deadline_id`, `title`, `due_on`, `est_minutes`, `done`.
  - **Derivation rules:**
    - Unsubmitted deadlines (`status NOT IN ('submitted', 'done')`) with `due_at IS NOT NULL` emit a `VEVENT` with `UID:<id>@studyapp.local`, `DTSTART;TZID=<timezone>:<local_time>` (or UTC `Z`), `SUMMARY:[<module_id>] <title> (<type>, <weighting>%)`, `DESCRIPTION:Confidence: <confidence>`, and two `VALARM` blocks (`-P7D` and `-PT24H`).
    - Deadlines with `due_at IS NULL` (`BR-004` unannounced dates) are excluded from `VEVENT` generation so invalid calendar entries are never emitted.
    - Milestones emit all-day `VEVENT` entries (`DTSTART;VALUE=DATE:<YYYYMMDD>`).
- **Sample output (`study-deadlines.ics`):**
  ```ics
  BEGIN:VCALENDAR
  VERSION:2.0
  PRODID:-//StudyApp//HKUST Personal Study App v1.0//EN
  CALSCALE:GREGORIAN
  BEGIN:VEVENT
  UID:COMP4901B-D002@studyapp.local
  DTSTAMP:20261028T061500Z
  DTSTART;TZID=Asia/Hong_Kong:20261101T235900
  SUMMARY:[COMP4901B] Homework 2 (homework, 10%)
  DESCRIPTION:Confidence: explicit | Source: Canvas Assignments
  END:VEVENT
  END:VCALENDAR
  ```

---

### 2.8 `RPT-08` · Pipeline & Feedback JSON Dataset Exports (`6` App Files + `feedback.json`)

- **Purpose:** Deterministic file-based data exchange (`INT-01`) between the pipeline (`CLI-06`) and the study app (`SCR-06`, `SCR-10`).
- **Files, schemas (`A34`), and sources (`A16`/`A32`/`A33`):**
  1. `deck.json`: accepted & spot-checked flashcards (`R06` `card`, `R07` `card_tag`).
  2. `question-bank.json`: accepted & spot-checked questions (`R11` `question`, `R12` `question_option`, `R13` `question_marking_point`).
  3. `concepts.json`: module/lecture concept graph (`R01` `module`, `R02` `lecture`, `R03` `concept`, `R04` `concept_prerequisite`, `R05` `concept_card`).
  4. `glossary.json`: canonical glossary entries (`R16` `glossary_entry`).
  5. `deadlines.json`: extracted deadlines (`R17` `deadline`, `R18` `deadline_lecture`, with `due_at: null` allowed when unannounced per `BR-004`).
  6. `readings.json`: extracted required and recommended readings (`R21` `reading`).
  7. `feedback.json` (`R1` `reported` items, `REQ-F-020`, `REQ-F-042`; `R3` `reported` + `topup` + `proposed` items, `REQ-F-063`): exported from `feedback_item` (`R28`) and accepted `proposal` (`R27`) rows.
- **Validation:** Validated by `Ajv` against `workbook/03-design/api/schemas/pipeline-contracts.schema.json` on both export and import (`BR-024`, `REQ-N-020`).

---

### 2.9 `RPT-09` · Anki Tab-Separated Deck Export (`deck.anki.tsv`)

- **Purpose:** Export flashcards in Anki's native UTF-8 tab-separated format (`front<TAB>back<TAB>tags`) so the student is never locked into the custom app (`[SEED §3 story 20]`, `REQ-F-066`, `INT-05`).
- **Data items and derivation rules (`A16`/`A32`/`A33`):**
  - Source: `card` (`R06` where `suspended = 0 AND flagged = 0`) joined with `card_tag` (`R07`).
  - `Col 1 (front)`: `card.front` with newlines converted to `<br>` and tabs escaped as spaces.
  - `Col 2 (back)`: `card.back` + (if `card.extra != ''`, `"<br><hr><small>" + card.extra + "</small>"`).
  - `Col 3 (tags)`: space-separated tags including `module:<module_id>`, `lecture:<lecture_id>`, and all `card_tag.tag` values.
- **Sample output (`deck.anki.tsv`):**
  ```tsv
  #separator:tab
  #html:true
  #tags column:3
  In a Markov decision process (MDP), what does the state-value function \(V^\pi(s)\) represent, where \(\pi\) is a policy and \(s \in \mathcal{S}\) is a state?	The expected discounted return when starting in state \(s\) and following policy \(\pi\) thereafter: \(V^\pi(s) = \mathbb{E}_\pi\left[\sum_{k=0}^{\infty} \gamma^k R_{t+k+1} \mid S_t = s\right]\), where \(\gamma \in [0,1]\) is the discount factor and \(R\) is reward.<br><hr><small>Bellman expectation equation for V^pi.</small>	module:COMP4901B lecture:COMP4901B-W10 rl mdp
  ```

---

## 3. Compliance with Form & Report Guidelines (`Appendix B5`)

1. **Titles and timestamps:** Every screen report (`RPT-01`–`RPT-05`) and file export (`RPT-07`–`RPT-09`) includes a specific title and an explicit `Data as of` / `exported_at` timestamp with timezone (`HKT` on screen, `UTC` in JSON/ICS).
2. **No modification needed:** Outputs are immediately actionable (e.g., `RPT-01` launches review/quiz sessions in one click; `RPT-03` drills weak concepts in one click; `RPT-07` imports directly into calendar clients).
3. **Alignment and sorting:** All numeric columns (counts, percentages, stability days, USD spend) are right-aligned with fixed decimal precision; lists are sorted by urgency or priority rank (`BR-033`, `BR-035`).
4. **Accessible highlighting (`WCAG 2.2 AA`):** Colour is always paired with a bracketed text status and symbol (`[PASS]`, `[!! HIGH <48h]`, `[OVERDUE]`).

---

## 4. Disposition of Current-State Reports & Outputs (`A09`, `A41.3`, `G3.13`)

Every report, dashboard, or export referenced in the current-state and source documents (`A09`: `SRC-01`–`SRC-06`) is accounted for below:

| Source document & report / output | Disposition | Target `A41` report or reason |
| :-- | :-- | :-- |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **Today page** (due flashcards, quiz concepts, readings, countdowns, progress) | **Replaced / Implemented** | `RPT-01` (`SCR-01` Today Daily Study Plan & Workload Summary) |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **Stats page** (reviews/day, retention, concept mastery by assessment scope, monthly Claude API spend) | **Replaced / Implemented** | `RPT-02` (`SCR-08` & `SCR-04` Study & Spend Statistics Dashboard) |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **Mock exam results** (score, per-question feedback, weak concepts to revisit) | **Replaced / Implemented** | `RPT-03` (`SCR-09` Mock Exam Results & Weak-Concept Breakdown) |
| `SRC-01` (`[SEED §3 Reports & outputs]`), `SRC-03` (`§3.1, §3.7, §8`): **Pipeline run summary and module audit** | **Replaced / Implemented** | `RPT-04` (`run-summary.json` & CLI report) and `RPT-05` (`module-audit.json` & `SCR-06` Audit View) |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **Notifications** (reminders for due reviews and approaching deadlines) | **Replaced / Implemented** | `RPT-06` (In-app urgency banners in `R1` + Web Notifications in `R3`) |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **`.ics` calendar feed** of deadlines | **Replaced / Implemented** | `RPT-07` (`study-deadlines.ics` RFC 5545 export) |
| `SRC-03` (`flashcard-pipeline.md §10, §11`): **Six pipeline export JSON files** (`deck.json`, `question-bank.json`, `concepts.json`, `glossary.json`, `deadlines.json`, `readings.json`) and **`feedback.json`** | **Replaced / Implemented** | `RPT-08` (Pipeline & Feedback JSON Dataset Exports, `INT-01`) |
| `SRC-03` (`flashcard-pipeline.md §11`), `SRC-01` (`story 20`): **Anki `.tsv` export (`deck.anki.tsv`)** | **Replaced / Implemented** | `RPT-09` (`deck.anki.tsv`, `INT-05`) |
| `SRC-05` (`COMP4901B` syllabus PDF) & HKUST Canvas course pages: **Manual syllabus assessment weight tables and Canvas assignment due-date lists** | **Replaced** | Extracted by `P1` (`Extractor` + Canvas read-only adapter `INT-03`) into `deadlines.json` (`RPT-08`) and displayed with live countdowns on `SCR-01` (`RPT-01`) and `SCR-05`. |
| Existing manual Anki Desktop decks & statistics (`[SEED §6]`, `[USER Q-14]`) | **Retired with user's agreement** | Student chose a fresh start with no Anki import (`[USER Q-14]`, `ASM-014`) and one integrated custom app (`[USER Q-09]`, `DEC-015`), while keeping `RPT-09` (`deck.anki.tsv`) as an optional outbound export. |
| Mandarin course vocabulary decks/lists (`[USER Q-08]`, `[USER Q-13]`) | **Out of scope** | Excluded by the student (`[USER Q-13]`, `DEC-007`, `A01 §5.2 item SC-X08`). |
