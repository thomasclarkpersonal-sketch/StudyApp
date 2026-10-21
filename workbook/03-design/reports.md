# A41 · Report & Output Design

Owner: System Architect. Stage 3, written 2026-10-21. Catalog entry: A41 (`03-design/reports.md`).

This document specifies every report, dashboard, file export, pipeline summary, and notification produced by the Study App and the Generation Pipeline (`[SEED §3 Reports & outputs]`, `[DOC flashcard-pipeline.md §8, §10, §11]`, `[DOC study-app-spec.md §1.4, §3.5, §4, §5]`), following catalog Appendix B5 (*Form and report guidelines*) and the `DATA` project-type requirements (`DEC-002`: refresh frequency and data freshness indicators).

---

## 1. Report & Output Inventory

Every report traces to one or more requirements in `A10` and names its audience role from `A13`/`A36` (`Student (Learner)` or `Student (Pipeline Operator)`, `[SEED §2]`, `ASM-021`).

| ID | Name | Purpose (decision or task supported) | Audience role | Trigger / frequency | Delivery channel | Freshness / refresh cadence (`DATA` type) | REQ / UC trace |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| `RPT-01` | **Today Daily Study Plan & Workload Summary** | Decide what to study today across all 4 modules, monitor daily time budget vs required workload, and track completion (`SM-4a`, `SM-4b`). | `Student (Learner)` | Automatic at local midnight (`00:00` in `Settings.timezone`, default `Asia/Hong_Kong`) or first app open of the day; manual rebuild via `GET /api/today?rebuild=true` (`getTodayPlan`). | Screen (`SCR-01` Today) | Real-time on item completion (`PATCH /api/today/items/{itemId}`, `updateTodayPlanItem`); header shows `Plan date: YYYY-MM-DD (HKT) · Last updated: HH:MM:SS · Last pipeline import: <relative time>` (`ImportBatch.imported_at`). | `REQ-F-038`, `REQ-F-039`, `REQ-F-040`, `REQ-F-041`, `REQ-F-055`, `REQ-N-003`, `UC-10`, `UC-16` |
| `RPT-02` | **Study & Spend Statistics Dashboard (`Stats` page)** | Evaluate 30-day flashcard retention (`SM-2`), concept mastery by assessment scope, pipeline processing lead time (`SM-1`), reported-item error rate (`SM-3`), checklist streak (`SM-4b`), monthly Claude API spend vs cap (`SM-6`), and 30-day review-load forecast. | `Student (Learner)` | On demand when opening `SCR-10` (`GET /api/stats`, `getStatsAndSpend`, including FSRS parameter fitting `fitFsrs=true`). | Screen (`SCR-10` Stats) | Recomputed on page load and on `[Refresh stats]`; displays `Data as of: YYYY-MM-DD HH:MM HKT · Last import: YYYY-MM-DD HH:MM HKT` (`ImportBatch.imported_at`). | `REQ-F-058`, `REQ-F-065`, `REQ-F-023`, `REQ-F-026`, `REQ-F-040`, `REQ-F-042`, `REQ-F-048`, `UC-17`, `UC-20` |
| `RPT-03` | **Mock Exam Results & Weak-Concept Breakdown** | Assess readiness after a timed practice exam, review per-question marking feedback, and launch targeted flashcard drills or tutor explanations for weak concepts. | `Student (Learner)` | Event-driven immediately upon submitting a mock exam (`POST /api/exams/mock/{examId}/submit`, `submitMockExam`). | Screen (`SCR-04` Mock Exam Results view) | Immutable snapshot at `MockExam.submitted_at`, with live `ConceptState.stability` and `Retrievability R` joined at view time (`As of: YYYY-MM-DD HH:MM HKT`). | `REQ-F-054`, `REQ-F-032`, `REQ-F-033`, `REQ-F-034`, `UC-15` |
| `RPT-04` | **Pipeline Run Summary (`run-summary.json` & CLI Report)** | Verify which modules and lectures were processed, how many cards/questions were accepted vs flagged per review round, how long the run took (`REQ-N-006`), and what awaits human review (`UC-05`). | `Student (Pipeline Operator)` | Event-driven at the end of every `pipeline-cli plan-run` / `spot-check-and-export` run (`CLI-03`, `CLI-06`) and recorded on `applyModuleImport` (`POST /api/import/apply`). | JSON file (`<workspace>/export/run-summary.json`), CLI stdout table, and `SCR-09` Import history table | Written atomically at run completion (`run_finished_at` UTC ISO-8601 timestamp); `SCR-09` displays `Run finished: YYYY-MM-DD HH:MM HKT`. | `REQ-F-006`, `REQ-F-018`, `REQ-F-023`, `REQ-N-006`, `UC-04`, `UC-06` |
| `RPT-05` | **Module Audit Report (`module-audit.json` & Audit View)** | Identify syllabus learning outcomes with zero cards/questions, concepts below minimum variant count for upcoming assessments, cross-lecture duplicates, and non-canonical notation before final export. | `Student (Pipeline Operator)` | Event-driven after all lectures in a module complete Stage A and Stage B (`Module Auditor` subagent + `CLI-06`). | JSON file (`<workspace>/export/module-audit.json`) and rendered summary on `SCR-09` (`Import / Export & Human Review`) | Generated per module audit run (`audited_at` UTC ISO-8601 timestamp + `source_lectures_count` freshness badge). | `REQ-F-015`, `REQ-F-016`, `UC-04`, `UC-05` |
| `RPT-06` | **Deadline Urgency & Daily Study Notifications** | Alert the student to approaching deadlines (`< 7 days`, `< 48 hours`, overdue) and unfinished daily study plans without relying on colour alone (`[SEED §3]`, `[SEED §7]`). | `Student (Learner)` | Event-driven at app open, on deadline urgency transitions (`DT-05`), and optional daily reminder time (`Settings.daily_reminder_time`, default `09:00` local time) when browser notifications are enabled (`R3`). | In-app urgency banner (`SCR-01`, `SCR-06`) in `R1`–`R3`; Web Notifications API (`Notification`) in `R3` (`SL-18`). | Evaluated every 60 s (every 1 s when `< 1 h` remains on `SCR-01`/`SCR-06`, `BR-033`). | `REQ-F-037`, `REQ-F-056`, `REQ-F-061`, `REQ-N-015`, `UC-09`, `UC-16`, `UC-18` |
| `RPT-07` | **iCalendar Deadlines & Milestones Feed (`study-deadlines.ics`)** | View module deadlines and coursework milestones in an external calendar application (Apple Calendar, Google Calendar, Outlook). | `Student (Learner)` | On demand via `[Export .ics]` on `SCR-06` / `SCR-09` (`GET /api/calendar.ics`, `exportCalendarIcs`). | RFC 5545 `.ics` file download (`text/calendar; charset=utf-8`). | Generated live from `deadline` (`R13`) and `milestone` (`R14`) tables with `DTSTAMP` set to current UTC timestamp. | `REQ-F-057`, `UC-16`, `INT-04` |
| `RPT-08` | **Pipeline & Feedback JSON Dataset Exports (`6` App Files + `feedback.json`)** | Exchange reviewed flashcards, questions, concepts, glossary terms, deadlines, readings, and reported/top-up/proposed feedback items between the pipeline and the study app. | `Student (Pipeline Operator)` | On demand at the end of `UC-05` (`CLI-06` `spot-check-and-export` writes the 6 files) and via `[Export reported items]` (`R1`) / `[Export feedback.json]` (`R3`) on `SCR-09` (`GET /api/export/feedback`, `exportFeedbackJson`). | JSON files conforming to `pipeline-contracts.schema.json` (`A34`). | Stamped with `exported_at` UTC ISO-8601 timestamp and `version: "1.0"`. | `REQ-F-019`, `REQ-F-020`, `REQ-F-042`, `REQ-F-063`, `UC-05`, `UC-11`, `UC-19`, `INT-01` |
| `RPT-09` | **Anki Tab-Separated Deck Export (`deck.anki.tsv`)** | Optional portable export of accepted flashcards (`front<TAB>back<TAB>tags`) for backup or external review (`[SEED §3 story 20]`). | `Student (Learner)` | On demand via `pipeline-cli spot-check-and-export --anki-tsv` (`CLI-06`) or `[Export Anki .tsv]` on `SCR-09` (`GET /api/export/anki.tsv`, `exportAnkiTsv`). | UTF-8 TSV file (`text/tab-separated-values; charset=utf-8`). | Generated live from active `card` (`R05`) and `card_tag` (`R06`) rows with `#exported_at:` header comment. | `REQ-F-066`, `UC-21`, `INT-05` |

---

## 2. Detailed Report & Output Specifications

### 2.1 `RPT-01` · Today Daily Study Plan & Workload Summary

- **Purpose:** Single daily checklist (`[SEED §1 Primary goal]`) combining carried-over tasks, due flashcard reviews, due concept quizzes, new flashcards, required readings, coursework milestones, assessment-mode prep, recommended readings, and personal tasks, bounded by the student's daily time budget (`BR-035`–`BR-037`, `DT-06`).
- **Data items and sources (`A16`/`A32`):**
  - `DailyPlan` (`R17` `daily_plan`): `plan_date`, `timezone`, `in_assessment_mode`, `total_required_est_s`, `total_optional_est_s`, `budget_s`, `over_budget_warning`, `generated_at`.
  - `DailyPlanItem` (`R18` `daily_plan_item`): `id`, `kind` (`carry_over`, `due_reviews`, `due_quizzes`, `new_cards`, `required_reading`, `milestone`, `assessment_prep`, `recommended_reading`, `user_task`), `priority_rank` (`1`–`9`), `module_id`, `ref_id`, `title`, `target_count`, `completed_count`, `est_seconds`, `is_required`, `status` (`pending`, `in_progress`, `done`, `deferred`, `skipped`), `completed_at`.
  - `Deadline` (`R13` `deadline`): top 4 upcoming unsubmitted deadlines (`submitted = 0`), joined with derived urgency badge (`DT-05`, `BR-033`) and live countdown string (`days + hours + minutes` when `< 48 h`, `days` when `>= 48 h`).
  - **Derived values & rules:**
    - `Estimated item time` (`BR-036`): `due_reviews = count * 8 s`, `new_cards = count * 25 s`, `due_quizzes = mcq_count * 45 s + written_count * 180 s`, `reading = (page_end - page_start + 1) * settings.minutes_per_page * 60 s` (or `default_reading_minutes * 60 s` if `pages IS NULL`), `milestone = est_minutes * 60 s`, `user_task = est_minutes * 60 s`.
    - `Progress percentage` (`v_daily_plan_summary`): `ROUND(100.0 * completed_est_s / NULLIF(total_required_est_s, 0), 0)`.
    - `Assessment mode banner` (`BR-029`): active when any unsubmitted `exam` or `midterm` deadline has `0 <= (due_at - now) <= settings.assessment_mode_days` (default `21` days).
- **Filters, sorting, grouping, and totals:**
  - Grouped into: (1) **Assessment Mode & Over-Budget Alerts** (if active), (2) **Deadline Countdowns Strip** (sorted by `due_at ASC`), (3) **Required Checklist Items** (sorted by `priority_rank ASC`, then `module_id ASC`), (4) **Optional & Deferred Items** (collapsed by default for `recommended_reading` and `deferred` items, `BR-035`).
  - Totals right-aligned in header: `Completed: X / Y required items · Est. remaining: MM min / Budget: BB min`.
- **Display choice (`Appendix B5`):** Structured checklist table with right-aligned item counts and minute totals, horizontal progress bar with text fraction (`65% · 52 / 80 min`), and dual-coded urgency badges (`[RED · <7d]`, `[AMBER · 7-14d]`, `[NEUTRAL · >14d]`, `[OVERDUE · Past due]`).
- **Volume and performance expectation:** `5–25` plan items and `1–10` deadlines per day; full query and render `< 1,000 ms` (`p95`, `REQ-N-003`).
- **Sample layout (`SCR-01`):**
  ```text
  ================================================================================
  TODAY'S STUDY PLAN · Wed 28 Oct 2026 (HKT)           Last import: 2h ago · 14:10
  [ASSESSMENT MODE: COMP4901B Final Exam in 18 days — scoping & new-card cap 30/d]
  Progress: [#############-------] 65% (52 / 80 min budget)    [Rebuild plan]
  --------------------------------------------------------------------------------
  UPCOMING DEADLINES
  1. [RED · URGENT <7d]   COMP4901B Homework 2     Due in 04d 09h 49m  [Submitted?]
  2. [AMBER · SOON 7-14d] COMP3211  Project MS 1   Due in 11d          [Submitted?]
  --------------------------------------------------------------------------------
  REQUIRED TODAY (Est. 68 min total · 16 min remaining)                 Est. Time
  [x] 1. [Carry-over] COMP4901B · 4 due flashcards from Tue 27 Oct          1 min
  [x] 2. [Reviews]    COMP4901B · 38 / 38 due flashcards reviewed           5 min
  [ ] 3. [Reviews]    COMP3211  · 12 / 24 due flashcards remaining          2 min
  [ ] 4. [Quiz]       COMP4901B · 6 due concepts (assessment scope first)  11 min
  [ ] 5. [New cards]  COMP4901B · 15 new flashcards (Lecture 10: RL)        6 min
  [x] 6. [Reading]    COMP4901B · Sutton & Barto Ch. 13 (pp. 321-336)      32 min
  [ ] 7. [Milestone]  COMP4901B · Draft HW2 Q2 policy gradient proof       11 min
  --------------------------------------------------------------------------------
  ▸ OPTIONAL & DEFERRED (2 items · 24 min deferred by 80 min budget cap)
  ================================================================================
  ```

---

### 2.2 `RPT-02` · Study & Spend Statistics Dashboard (`Stats` Page)

- **Purpose:** Provide a single factual dashboard (`SCR-10`) for all 6 project success metrics (`SM-1`–`SM-6` in `A01 §3`), concept mastery per assessment scope, and 30-day FSRS workload forecasting (`[SEED §3 story 19 & Reports]`, `[DOC study-app-spec.md §4, §5]`).
- **Data items and sources (`A16`/`A32`):**
  - **KPI Summary Cards (Table / Metric Tiles per `B5`):**
    1. **Trailing 30-Day True Retention (`SM-2`):** derived from `card_review_log` (`R08`) where `state_before = 'review'` and `reviewed_at >= now - 30 days`:
       $$\text{True Retention} = \frac{\text{COUNT}(\text{rating} \in \{\text{'hard'}, \text{'good'}, \text{'easy'}\})}{\text{COUNT}(*)}$$
       Displays percentage, numerator/denominator count, target (`>= 85.0%`), and warning banner if `< 85.0%` recommending increasing `Settings.desired_retention` from `0.90` (`BR-027`).
    2. **7-Day Checklist Completion & Streak (`SM-4b`):** derived from `daily_plan` (`R17`) and `daily_plan_item` (`R18`) over the trailing 7 days: days where all `is_required = 1` items have `status = 'done'` (`Target: >= 5 / 7 days`).
    3. **Reported-Item Error Rate (`SM-3`):** derived from `feedback_item` (`R23` where `kind = 'reported'` and `reason = 'wrong'`) divided by total reviewed distinct cards + questions per module (`Target: < 2.0%`).
    4. **Pipeline Processing Lead Time (`SM-1`):** derived from `import_batch` (`R24` `MIN(imported_at)` per lecture where `deck_imported = 1 AND question_bank_imported = 1`) compared against `deadline.due_at` (`R13`) for each assessment covering that lecture (`Target: >= 7.0 days before assessment`).
    5. **Monthly Claude API Spend (`SM-6`):** derived from `grading_call_log` (`R25`) + `tutor_message` (`R21`) for the current UTC/local calendar month:
       $$\text{Spend (USD)} = \frac{\sum \text{cost\_micro\_usd}}{1,000,000}$$
       Broken down by feature (`marking` vs `tutor`), model (`haiku` vs `sonnet`), and token category (`input_tokens`, `cached_input_tokens`, `output_tokens`), compared against `Settings.monthly_spend_cap_micro_usd` (`BR-041`).
  - **Charts and Breakdown Tables (chosen per `Appendix B5`):**
    - **Daily Review Count & Retention Trend (Line Graph + Tabular Toggle):** 30-day daily time series (`date`, `cards_reviewed`, `questions_attempted`, `retention_pct`) — line graph for trend over time (`B5`), with an accessible table view for keyboard/screen-reader inspection.
    - **Concept Mastery by Module & Assessment Scope (Horizontal Stacked Bar Chart + Table):** derived from `v_concept_mastery` (`A32 §4.2`): counts of concepts per module/assessment in `Mastered (stability >= 30d)`, `Consolidating (7d <= stability < 30d)`, `Learning / Weak (stability < 7d or lapses >= 2)`, and `Unseen (state = 'new')` — bar chart for category comparison (`B5`).
    - **30-Day Review Load Forecast (`R3`, `REQ-F-065`, Bar Chart + Table):** projected daily due cards and concepts for `today + 1` to `today + 30` from `card_state.due` and `concept_state.due`, plus FSRS optimizer comparison (`default 19 weights` vs `fitted 19 weights` log-loss / RMSE on `card_review_log` when `COUNT(*) >= 400`).
- **Filters, sorting, grouping, and totals:** Filter by `module_id` (`All modules` or specific module) and time window (`7d`, `30d`, `90d`, `Semester`); tables right-align all numeric counts, percentages (1 decimal place), and USD amounts (`$0.00`).
- **Volume and performance expectation:** Aggregates up to `50,000` `card_review_log` rows using `IDX-06` (`idx_review_log_reviewed_at`); response time `< 500 ms` (`p95`).
- **Sample layout (`SCR-10`):**
  ```text
  ================================================================================
  STATISTICS & SPEND DASHBOARD               Data as of: 2026-10-28 14:15 HKT
  Filter: [All Modules v]   Window: [Last 30 Days v]        [Refresh] [Fit FSRS]
  --------------------------------------------------------------------------------
  KEY METRICS (A01 §3 Success Metrics)
  +-------------------------+-------------------------+--------------------------+
  | 30d True Retention(SM-2)| 7d Plan Streak (SM-4b)  | Reported "Wrong" (SM-3)  |
  |   88.4% (1,255 / 1,420) |   6 / 7 days complete   |   0.6% (3 / 480 items)   |
  |   [PASS: Target >= 85%] |   [PASS: Target >= 5/7] |   [PASS: Target < 2.0%]  |
  +-------------------------+-------------------------+--------------------------+
  | Assessment Lead (SM-1)  | Oct Claude Spend (SM-6) | Cache Hit Ratio          |
  |   18.2d before Final    |   $4.12 / $15.00 cap    |   86.4% cached input     |
  |   [PASS: 10/10 lecs]    |   [OK: 27.5% of cap]    |   Haiku $0.24·Sonnet$3.88|
  +-------------------------+-------------------------+--------------------------+
  CONCEPT MASTERY BY ASSESSMENT SCOPE (v_concept_mastery)
  Module / Assessment        Mastered(>=30d) Consolidating(7-30d) Weak(<7d) Unseen
  COMP4901B Final (120 conc)       42 (35.0%)          50 (41.7%)  18(15.0%) 10(8.3%)
  COMP3211  Midterm (64 conc)      28 (43.8%)          24 (37.5%)  12(18.8%)  0(0.0%)
  --------------------------------------------------------------------------------
  MONTHLY CLAUDE API SPEND BREAKDOWN (October 2026)
  Feature        Model                  Calls   Input Tok  Cached Tok  Output Tok   Spend
  Quiz Marking   claude-haiku-4-5         112      84,200   4,120,000      29,400   $0.24
  Course Tutor   claude-sonnet-4-5         48     192,000   1,850,000      34,100   $3.88
  TOTAL                                   160     276,200   5,970,000      63,500   $4.12
  ================================================================================
  ```

---

### 2.3 `RPT-03` · Mock Exam Results & Weak-Concept Breakdown

- **Purpose:** Present immediate post-exam diagnostic feedback (`SCR-04`) showing overall score, time spent, per-question marking breakdown, and one-click recovery actions (`[Review N related flashcards]` and `[Ask Claude]`) for weak concepts (`[SEED §3 story 15 & Reports]`, `REQ-F-054`).
- **Data items and sources (`A16`/`A32`):**
  - `MockExam` (`R26` `mock_exam`): `id`, `module_id`, `assessment_id`, `title`, `question_count`, `time_limit_s`, `started_at`, `submitted_at`, `total_score_pct`.
  - `MockExamQuestion` (`R27`) joined with `Question` (`R09`), `QuestionAttempt` (`R11`), and `Concept` (`R03`): `position`, `question_id`, `concept_id`, `type`, `difficulty`, `student_answer`, `score_pct`, `rating`, `marking_feedback_json`, `time_taken_ms`.
  - **Derived values:**
    - `Concept performance rollup`: groups exam questions by `concept_id`, computes `avg_score_pct`, flags any concept with `rating IN ('again', 'hard')` or `score_pct < 60` as `Weak Concept`, and counts linked active flashcards in `concept_card_link` (`R07`).
- **Filters, sorting, grouping, and totals:** Weak concepts sorted by `score_pct ASC`, then `ConceptState.stability ASC`; question review list filterable by `[All | Incorrect / Partial | Correct]`.
- **Display choice (`Appendix B5`):** Summary score banner, weak-concept action table (for immediate remedial action), and expandable per-question comparison cards with side-by-side student answer vs marking points.
- **Volume and performance expectation:** `10–35` questions per mock exam; renders immediately (`< 300 ms`) once marking completes.
- **Sample layout (`SCR-04` Results View):**
  ```text
  ================================================================================
  MOCK EXAM RESULTS · COMP4901B Final Practice #1       Submitted: 28 Oct 15:42 HKT
  Score: 76.5% (15.3 / 20.0 pts) · Time: 48m 12s / 60m 00s · Weak concepts: 3
  --------------------------------------------------------------------------------
  WEAK CONCEPTS REQUIRING DRILL (Sorted by lowest score)
  Concept ID          Topic Summary                  Exam Score  Stability  Action
  COMP4901B-L10-C04   PPO clipped surrogate objective     25.0%      3.2 d  [Drill 4 cards] [Ask Claude]
  COMP4901B-L09-C02   RLHF Bradley-Terry reward model     50.0%      5.8 d  [Drill 3 cards] [Ask Claude]
  --------------------------------------------------------------------------------
  QUESTION BREAKDOWN (Filter: [Incorrect / Partial (4)] [All (15)])
  Q4 · [calculation · Diff 3] COMP4901B-L10-C04 · Score: 25% (1/4 marking points)
    Your answer:    L_CLIP = E[ min(r_t A_t, clip(r_t, 1-eps, 1+eps)) ]
    Missing points: (1) Missing A_t inside the second argument of min: clip(...) * A_t;
                    (2) Did not state behavior when A_t < 0 vs A_t > 0.
    Override rating: [Again (active)] [Hard] [Good] [Easy]   [Report problem]
  ================================================================================
  ```

---

### 2.4 `RPT-04` · Pipeline Run Summary (`run-summary.json` & CLI Report)

- **Purpose:** Give the student (`Pipeline Operator`) a deterministic record of what a pipeline run processed, module/lecture ordering (`[USER Q-12]`), per-round Reviewer acceptance/revision/rejection counts, flagged item counts awaiting `UC-05`, and wall-clock duration per lecture (`REQ-F-018`, `REQ-N-006`).
- **Data items and sources (`A16`/`A32`):**
  - Pipeline workspace files (`E24` `Concept`, `E25` `ReviewRecord`, `E26` `FlaggedItem`, `E27` `ModuleAudit`) aggregated by `pipeline-cli run-order` / `export` (`CLI-05`, `CLI-06`).
  - Fields in `run-summary.json`: `run_id`, `started_at`, `finished_at`, `ordering_rule` (`cs_first_then_nearest_assessment`), `lectures_processed[]` (`module_id`, `lecture_id`, `duration_s`, `concepts_extracted`, `cards_accepted`, `cards_flagged`, `cards_rejected`, `card_review_rounds`, `questions_accepted`, `questions_flagged`, `questions_rejected`, `question_review_rounds`, `spot_check_sample_size`), `totals`, `human_review_pending_count`.
- **Filters, sorting, grouping, and totals:** Sorted in exact execution order (`BR-005`: CS modules first, then nearest assessment); column totals at bottom.
- **Display choice (`Appendix B5`):** Fixed-width CLI table + structured JSON file + `SCR-09` import batch history table.
- **Volume and performance expectation:** `1–26` lectures per run; summary generation `< 100 ms`.
- **Sample layout (CLI stdout & `SCR-09` summary):**
  ```text
  ================================================================================
  PIPELINE RUN SUMMARY · Run ID: run-20261028-061500Z     Order: CS-first (BR-005)
  Started: 2026-10-28T06:15:00Z · Finished: 2026-10-28T06:24:18Z (Total: 09m 18s)
  --------------------------------------------------------------------------------
  Module     Lecture  Time    Concepts  Cards(Acc/Flg/Rej/Rnds)  Questions(Acc/Flg/Rej/Rnds)
  COMP4901B  L10      09m 18s       14     28 /  1 /  2 (2 rnds)        42 /  1 /  1 (2 rnds)
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
  - `ModuleAudit` (`E27` `module-audit.json`): `module`, `audited_at`, `outcome_coverage[]` (`outcome`, `covered_by_concepts[]`, `status: covered|partial|missing`), `under_covered_concepts[]` (`concept_id`, `importance`, `current_variants`, `required_min_variants`, `assessment_id`), `duplicates[]` (`ids[]`, `reason`, `recommended_keep_id`), `notation_issues[]` (`item_id`, `found`, `expected_canonical`), `proposed_synthesis_items[]` (reviewed by fresh Reviewer).
- **Display choice (`Appendix B5`):** 4-section diagnostic table on `SCR-09` (`Import / Export & Human Review`) with `[Accept audit fix]` / `[Dismiss]` actions.
- **Volume and performance expectation:** `1` report per module (`10–26` lectures); `< 50` rows per section.
- **Sample layout (`SCR-09` Module Audit panel):**
  ```text
  ================================================================================
  MODULE AUDIT REPORT · COMP4901B (Lectures L01–L10)   Audited: 2026-10-28 14:25 HKT
  --------------------------------------------------------------------------------
  1. LEARNING OUTCOME COVERAGE (4 / 4 outcomes covered · 0 missing)
     [COVERED] LO-3: Formulate alignment & RLHF objectives -> L09-C01..C04, L10-C01..C06
  2. ASSESSMENT VARIANT GAPS (0 gaps — all core concepts have 3–5 variants)
  3. CROSS-LECTURE DUPLICATES (1 pair found)
     - Cards COMP4901B-L09-FC12 & COMP4901B-L10-FC02 (KL divergence penalty in RLHF)
       Recommendation: Keep L09-FC12, suspend L10-FC02
  4. NOTATION CONSISTENCY (1 issue found)
     - Question COMP4901B-L10-Q08: uses bare "MDP" -> expected "Markov decision process (MDP)"
  ================================================================================
  ```

---

### 2.6 `RPT-06` · Deadline Urgency & Daily Study Notifications

- **Purpose:** Warn the student of imminent or overdue assessments/coursework and daily study plan reminders (`[SEED §3 Reports & outputs: Notifications]`, `REQ-F-037`, `REQ-F-056`).
- **Trigger events, recipient, content, and opt-out (`Catalog A41` notification rules):**
  - **Recipient:** `Student (Learner)` (single user, `ASM-021`).
  - **Triggers & Content:**
    1. **Deadline Urgency Transition (`DT-05`, `BR-033`):** When an unsubmitted deadline (`submitted = 0`) enters `< 7 days` (`red` urgency), `< 48 hours` (switches to `days + hours + minutes`), `< 1 hour` (switches to `MMm SSs`), or `< 0 seconds` (`overdue` with `[Submitted?]` prompt). Content: `"[URGENT <7d] <Module> <Title> is due in <Countdown> (<Due Date HKT>)"`.
    2. **Daily Study Plan Ready / Unfinished Reminder (`R3`, `SL-18`):** At `Settings.daily_reminder_time` (default `09:00` local time) if `daily_plan` has pending required items, and at `20:00` local time if required items remain unfinished. Content: `"Study App: <N> required items (<MM> min) remaining on Today's plan."`
  - **How the recipient turns them off:**
    - In `SCR-11` (`Settings`), the student can toggle:
      1. `Browser notifications enabled` (`off` by default until explicitly enabled by the student);
      2. `Daily study reminder notification` (`on` / `off` + configurable local time `HH:MM`);
      3. `Deadline 7-day / 48-hour browser alerts` (`on` / `off`).
    - In-app urgency badges on `SCR-01` (`Today`) and `SCR-06` (`Deadlines`) are silenced per deadline as soon as the student checks `[Submitted?]` (`PATCH /api/v1/deadlines/{deadlineId}`).
- **Accessibility (`Appendix B5`, `BR-033`, `REQ-N-015`):** Urgency is never conveyed by colour alone; every badge pairs colour with an explicit text label and icon (`[! URGENT <7d]`, `[~ SOON 7-14d]`, `[OK >14d]`, `[OVERDUE — Submitted?]`).

---

### 2.7 `RPT-07` · iCalendar Deadlines & Milestones Feed (`study-deadlines.ics`)

- **Purpose:** Export all active module deadlines and coursework milestones as a standard RFC 5545 `.ics` file (`[SEED §3 story 16 & Reports]`, `REQ-F-057`, `INT-04`).
- **Data items and sources (`A16`/`A32`):**
  - `Deadline` (`R13`): `id`, `module_id`, `title`, `type`, `due_at`, `timezone`, `weighting`, `confidence`, `submitted`.
  - `Milestone` (`R14`): `id`, `deadline_id`, `title`, `due_on`, `est_minutes`, `done`.
  - **Derivation rules:**
    - Unsubmitted deadlines with `due_at IS NOT NULL` emit a `VEVENT` with `UID:<id>@studyapp.local`, `DTSTART;TZID=<timezone>:<local_time>` (or UTC `Z`), `SUMMARY:[<module_id>] <title> (<type>, <weighting>%)`, `DESCRIPTION:Confidence: <confidence>`, and two `VALARM` blocks (`-P7D` and `-PT24H`).
    - Deadlines with `due_at IS NULL` (`BR-004` unannounced dates) are excluded from `VEVENT` generation so invalid calendar entries are never emitted.
    - Milestones emit all-day `VEVENT` entries (`DTSTART;VALUE=DATE:<YYYYMMDD>`).
- **Sample output (`study-deadlines.ics`):**
  ```ics
  BEGIN:VCALENDAR
  VERSION:2.0
  PRODID:-//StudyApp//HKUST Personal Study App v1.0//EN
  CALSCALE:GREGORIAN
  BEGIN:VEVENT
  UID:COMP4901B-DL-HW2@studyapp.local
  DTSTAMP:20261028T061500Z
  DTSTART;TZID=Asia/Hong_Kong:20261101T235900
  SUMMARY:[COMP4901B] Homework 2 (homework, 10%)
  DESCRIPTION:Confidence: explicit | Source: Canvas Assignments
  END:VEVENT
  END:VCALENDAR
  ```

---

### 2.8 `RPT-08` · Pipeline & Feedback JSON Dataset Exports (`6` App Files + `feedback.json`)

- **Purpose:** Deterministic file-based data exchange (`INT-01`) between the pipeline (`CLI-06`) and the study app (`SCR-09`).
- **Files, schemas (`A34`), and sources (`A16`/`A32`):**
  1. `deck.json`: accepted & spot-checked flashcards (`R05` `card`, `R06` `card_tag`).
  2. `question-bank.json`: accepted & spot-checked questions (`R09` `question`, `R10` `question_option`).
  3. `concepts.json`: module/lecture concept graph (`R03` `concept`, `R07` `concept_card_link`).
  4. `glossary.json`: canonical glossary entries (`R12` `glossary_entry`).
  5. `deadlines.json`: extracted deadlines (`R13` `deadline`, with `due_at: null` allowed when unannounced per `BR-004`).
  6. `readings.json`: extracted required and recommended readings (`R15` `reading`).
  7. `reported-items.json` (`R1` Must, `REQ-F-020`, `ASM-038`) / `feedback.json` (`R3` Could, `REQ-F-063`): exported from `feedback_item` (`R23`) and accepted `proposal` (`R22`) rows.
- **Validation:** Validated by `Ajv` against `workbook/03-design/api/schemas/pipeline-contracts.schema.json` on both export and import (`BR-021`).

---

### 2.9 `RPT-09` · Anki Tab-Separated Deck Export (`deck.anki.tsv`)

- **Purpose:** Export flashcards in Anki's native UTF-8 tab-separated format (`front<TAB>back<TAB>tags`) so the student is never locked into the custom app (`[SEED §3 story 20]`, `REQ-F-066`, `INT-05`).
- **Data items and derivation rules (`A16`/`A32`):**
  - Source: `card` (`R05` where `status = 'active'`) joined with `card_tag` (`R06`).
  - `Col 1 (front)`: `card.front` with newlines converted to `<br>` and tabs escaped as spaces.
  - `Col 2 (back)`: `card.back` + (if `card.extra IS NOT NULL`, `"<br><hr><small>" + card.extra + "</small>"`).
  - `Col 3 (tags)`: space-separated tags including `module:<module_id>`, `lecture:<lecture_id>`, `importance:<importance>`, and all `card_tag.tag` values.
- **Sample output (`deck.anki.tsv`):**
  ```tsv
  #separator:tab
  #html:true
  #tags column:3
  In a Markov decision process (MDP), what does the state-value function \(V^\pi(s)\) represent, where \(\pi\) is a policy and \(s \in \mathcal{S}\) is a state?	The expected discounted return when starting in state \(s\) and following policy \(\pi\) thereafter: \(V^\pi(s) = \mathbb{E}_\pi\left[\sum_{k=0}^{\infty} \gamma^k R_{t+k+1} \mid S_t = s\right]\), where \(\gamma \in [0,1]\) is the discount factor and \(R\) is reward.<br><hr><small>Bellman expectation equation for V^pi.</small>	module:COMP4901B lecture:COMP4901B-L10 importance:core rl mdp
  ```

---

## 3. Compliance with Form & Report Guidelines (`Appendix B5`)

1. **Titles and timestamps:** Every screen report (`RPT-01`–`RPT-05`) and file export (`RPT-07`–`RPT-09`) includes a specific title and an explicit `Data as of` / `exported_at` timestamp with timezone (`HKT` on screen, `UTC` in JSON/ICS).
2. **No modification needed:** Outputs are immediately actionable (e.g., `RPT-01` launches review/quiz sessions in one click; `RPT-03` drills weak concepts in one click; `RPT-07` imports directly into calendar clients).
3. **Alignment and sorting:** All numeric columns (counts, percentages, stability days, USD spend) are right-aligned with fixed decimal precision; lists are sorted by urgency or priority rank (`BR-033`, `BR-035`).
4. **Accessible highlighting (`WCAG 2.2 AA`):** Colour is always paired with a bracketed text status and symbol (`[PASS]`, `[URGENT <7d]`, `[OVERDUE]`).

---

## 4. Disposition of Current-State Reports & Outputs (`A09`, `A41.3`, `G3.13`)

Every report, dashboard, or export referenced in the current-state and source documents (`A09`: `SRC-01`–`SRC-06`) is accounted for below:

| Source document & report / output | Disposition | Target `A41` report or reason |
| :-- | :-- | :-- |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **Today page** (due flashcards, quiz concepts, readings, countdowns, progress) | **Replaced / Implemented** | `RPT-01` (`SCR-01` Today Daily Study Plan & Workload Summary) |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **Stats page** (reviews/day, retention, concept mastery by assessment scope, monthly Claude API spend) | **Replaced / Implemented** | `RPT-02` (`SCR-10` Study & Spend Statistics Dashboard) |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **Mock exam results** (score, per-question feedback, weak concepts to revisit) | **Replaced / Implemented** | `RPT-03` (`SCR-04` Mock Exam Results & Weak-Concept Breakdown) |
| `SRC-01` (`[SEED §3 Reports & outputs]`), `SRC-03` (`§3.1, §3.7, §8`): **Pipeline run summary and module audit** | **Replaced / Implemented** | `RPT-04` (`run-summary.json` & CLI report) and `RPT-05` (`module-audit.json` & `SCR-09` Audit View) |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **Notifications** (reminders for due reviews and approaching deadlines) | **Replaced / Implemented** | `RPT-06` (In-app urgency banners in `R1` + Web Notifications in `R3`) |
| `SRC-01` (`[SEED §3 Reports & outputs]`): **`.ics` calendar feed** of deadlines | **Replaced / Implemented** | `RPT-07` (`study-deadlines.ics` RFC 5545 export) |
| `SRC-03` (`flashcard-pipeline.md §10, §11`): **Six pipeline export JSON files** (`deck.json`, `question-bank.json`, `concepts.json`, `glossary.json`, `deadlines.json`, `readings.json`) and **`feedback.json`** | **Replaced / Implemented** | `RPT-08` (Pipeline & Feedback JSON Dataset Exports, `INT-01`) |
| `SRC-03` (`flashcard-pipeline.md §11`), `SRC-01` (`story 20`): **Anki `.tsv` export (`deck.anki.tsv`)** | **Replaced / Implemented** | `RPT-09` (`deck.anki.tsv`, `INT-05`) |
| `SRC-05` (`COMP4901B` syllabus PDF) & HKUST Canvas course pages: **Manual syllabus assessment weight tables and Canvas assignment due-date lists** | **Replaced** | Extracted by `P1` (`Extractor` + Canvas read-only adapter `INT-03`) into `deadlines.json` (`RPT-08`) and displayed with live countdowns on `SCR-01` (`RPT-01`) and `SCR-06`. |
| Existing manual Anki Desktop decks & statistics (`[SEED §6]`, `[USER Q-14]`) | **Retired with user's agreement** | Student chose a fresh start with no Anki import (`[USER Q-14]`, `ASM-014`) and one integrated custom app (`[USER Q-09]`, `DEC-014`), while keeping `RPT-09` (`deck.anki.tsv`) as an optional outbound export. |
| Mandarin course vocabulary decks/lists (`[USER Q-08]`, `[USER Q-13]`) | **Out of scope** | Excluded by the student (`[USER Q-13]`, `DEC-007`, `A01 §5.2 item X8`). |
