# A18 · Glossary & Data Dictionary

Owner: Systems Analyst. Stage 2, written 2026-10-21. Catalog entry: A18.

The complete attribute dictionary is also stored in [`data-dictionary.csv`](data-dictionary.csv) beside this file (protocol §5.3). Preferred terms defined in §1–§3 are used consistently across `A10`–`A17`.

---

## 1. Domain glossary (preferred terms)

| Preferred term | Definition | Source |
| :-- | :-- | :-- |
| **Assessment** | A graded university evaluation (such as a midterm exam, final exam, quiz, homework assignment, or project) belonging to a module, represented as a `Deadline` whose `covers_lectures` and format weights guide pipeline ordering and quiz preparation. | `[SEED §1]`, `[DOC flashcard-pipeline.md §2, §12]` |
| **Assessment mode** | A study mode active when an exam or midterm is within `assessment_mode_days` (default 21 days): concepts in that assessment's scope are prioritised in daily quizzes, new-card allowances are raised, and assessment prep / mock exams are offered. | `[SEED §3 story 15]`, `[DOC study-app-spec.md §1.2, §3.2, §3.3]` |
| **Blind-answer test** | Pass 1 of a Card Reviewer or Question Reviewer round, in which the Reviewer receives only the card fronts (or question stems and MCQ options) without backs, model answers, or lecture sources, and attempts to answer each item as a subject expert who never attended the module. | `[SEED §3 story 1]`, `[DOC flashcard-pipeline.md §5.1, §6.3]` |
| **Canonical notation** | The exact `"full term (abbreviation)"` or `"full term (symbol in this module)"` string recorded in `GlossaryEntry.canonical` that every card, question, and tutor message must use on both sides of an item. | `[SEED §3 story 3]`, `[DOC flashcard-pipeline.md §3.2, §4 rule 2]` |
| **Card** (or **Flashcard**) | An atomic memorisation prompt (`basic`, `cloze`, or `reverse`) generated from a lecture's source material, reviewed by a Card Reviewer, and scheduled individually by FSRS in the study app. | `[SEED §1]`, `[DOC flashcard-pipeline.md §4]` |
| **Card Creator** | The per-lecture pipeline agent role that builds the lecture's concept map (8–20 concepts) and drafts flashcards for facts that need memorising. | `[SEED §3 story 1]`, `[DOC flashcard-pipeline.md §3.3]` |
| **Card Reviewer** | A fresh, independent pipeline agent instance per review round that runs the blind-answer test and the 8-criterion card rubric on a lecture's draft flashcards without seeing the Card Creator's reasoning. | `[SEED §3 story 1]`, `[DOC flashcard-pipeline.md §3.4, §5.1]` |
| **Carried-over item** | An unfinished required item from a previous day's `DailyPlan` that is placed at the top of today's checklist. | `[SEED §3 story 10]`, `[DOC study-app-spec.md §1.4, §3.3]` |
| **Concept** | A distinct teachable unit in a lecture (8–20 per lecture), rated `core`, `supporting`, or `detail`, linked to flashcards (`card_ids`) and question variants (`question_ids`), and scheduled in its own right by FSRS (`ConceptState`) for daily quizzes. | `[SEED §3 stories 2, 8]`, `[DOC flashcard-pipeline.md §3.3, §6.1, §6.5]` |
| **Concept map** | The per-lecture list of 8–20 `Concept` records produced by the Card Creator and checked for source coverage by the Card Reviewer before the Question Creator runs. | `[DOC flashcard-pipeline.md §3.1, §3.3]` |
| **Coursework** | An assessed assignment (`homework` or `project` deadline type) where the student submits written or coded work; for coursework deadlines, the tutor is forbidden from writing or rewriting submittable text. | `[SEED §7]`, `[SEED §11]`, `[DOC study-app-spec.md §1.5]` |
| **Daily plan** (or **Today checklist**) | The ordered list of study items (`DailyPlanItem`) generated for a calendar date in the student's timezone, subject to the daily time budget (`daily_budget_min`). | `[SEED §1]`, `[SEED §3 story 10]`, `[DOC study-app-spec.md §1.4]` |
| **Deadline** | A dated obligation or assessment for a module (extracted from course material/Canvas or entered manually), displayed with a live countdown and urgency status. | `[SEED §3 story 9]`, `[DOC study-app-spec.md §1.3]` |
| **Extractor** | The pipeline agent role that runs first on a module's handbook, slides, and Canvas pages to produce `glossary.json`, `deadlines.json`, and `readings.json`. | `[SEED §3 story 3]`, `[DOC flashcard-pipeline.md §3.2]` |
| **Feedback queue** (`feedback.json`) | The export from the study app to the pipeline containing `reported` cards/questions (wrong or unclear), `topup` concepts needing more unseen variants, and `proposed` items accepted from tutor chats. | `[SEED §3 stories 11, 18]`, `[DOC flashcard-pipeline.md §10]` |
| **Flagged item** | In the pipeline (`flagged.json`), a source point that is unclear/contradictory or a card/question still failing after 2 revision rounds; in the study app (`Card.flagged`, `Question.flagged`), an item marked by the student to exclude from quiz selection or inspect later. (See §3 Homonyms.) | `[SEED §3 story 5]`, `[DOC flashcard-pipeline.md §3.3, §7]`, `[DOC study-app-spec.md §1.1, §3.2]` |
| **FSRS** | The Free Spaced Repetition Scheduler (`ts-fsrs`), used independently for flashcard scheduling (`CardState`) and concept quiz scheduling (`ConceptState`). | `[SEED §3 story 7]`, `[DOC study-app-spec.md §1.1, §1.2]` |
| **Human review step** | The pre-export step (`story 5`) in which the student inspects `flagged.json`, confirms `module_specific` glossary entries and `inferred` deadlines/readings, and spot-checks ~10% of accepted items per lecture. | `[SEED §3 story 5]`, `[DOC flashcard-pipeline.md §9]` |
| **Inferred item** | An extracted deadline or reading whose date was resolved from the semester calendar rather than stated explicitly (`confidence: "inferred"`), requiring student confirmation. | `[SEED §3 stories 5, 9]`, `[DOC flashcard-pipeline.md §3.2]` |
| **LaTeXiT object** | An embedded PDF equation XObject produced by LaTeXiT in Keynote slides whose original LaTeX source is stored in a base64/zlib metadata annotation inside the PDF. | `[DOC COMP4901b_Sept24_RL.pdf]`, `ASM-046` |
| **Lecture** | A single lecture session or topic deck within a module (one folder of slides/notes), identified by a stable ID such as `COMP4901B-W04-RL`. | `[DOC flashcard-pipeline.md §2]`, `[DOC study-app-spec.md §2]` |
| **Marking points** | The list of 2–5 explicit criteria on a written or calculation `Question` against which self-marking or Claude grading evaluates the student's response. | `[SEED §3 story 12]`, `[DOC flashcard-pipeline.md §6.2 rule 6]` |
| **Milestone** | A backward-counted intermediate step (e.g. draft at −10 days) attached to a coursework `Deadline` that appears on the Today checklist on its `due_on` date. | `[SEED §3 story 16]`, `[DOC study-app-spec.md §1.3]` |
| **Mock exam** | A timed quiz session assembled in assessment mode whose question types match the target assessment's format weights and whose results are broken down by concept. | `[SEED §3 story 15]`, `[DOC study-app-spec.md §1.2, §4]` |
| **Module** | A university course taken by the student in a semester (e.g. `COMP 4901B Large Language Models`). | `[SEED §1]`, `[USER Q-08]` |
| **Module Auditor** | The pipeline agent role that runs after all lectures in a module to check learning-outcome and assessment coverage, detect cross-lecture duplicates and notation drift, and propose cross-lecture items. | `[SEED §5]`, `[DOC flashcard-pipeline.md §3.7]` |
| **Module-specific notation** | A symbol or abbreviation defined by a lecturer for a particular module (`kind: "module_specific"`), written as `"full term (symbol in this module)"` and confirmed by the student during human review. | `[SEED §3 stories 3, 5]`, `[DOC flashcard-pipeline.md §3.2, §4 rule 2]` |
| **Pipeline Orchestrator** | The coordinating agent in the generation pipeline that reads `pipeline.config.json`, orders modules and lectures, invokes the Extractor, Creators, fresh Reviewers, and Module Auditor, enforces the 2-revision-round cap, and writes the exports. (See §3 Homonyms.) | `[DOC flashcard-pipeline.md §3.1]` |
| **Proposal** | A new flashcard or quiz question suggested by the Claude tutor during a study chat, held in the app's `Proposal` queue until the student accepts, edits, or discards it. | `[SEED §3 story 14]`, `[DOC study-app-spec.md §1.5]` |
| **Question Creator** | The per-lecture pipeline agent role that writes genuinely different question variants per concept from the reviewed concept map, source material, glossary, and assessment formats. | `[SEED §3 story 2]`, `[DOC flashcard-pipeline.md §3.5]` |
| **Question Reviewer** | A fresh, independent pipeline agent instance per review round that runs the blind-answer test and the 8-criterion question rubric on a lecture's draft question variants. | `[SEED §3 story 2]`, `[DOC flashcard-pipeline.md §3.6, §6.3]` |
| **Question variant** (or **Question**) | A quiz question testing a `Concept` (`variant_of`), differing from sibling variants in scenario, numbers, angle, or direction of reasoning, so the student tests understanding rather than memorising wording. | `[SEED §3 stories 2, 8]`, `[DOC flashcard-pipeline.md §6.1, §6.2]` |
| **Reading** | A required or recommended text chapter/paper extracted from course material or added to a module, scheduled on the Today checklist before its `read_by` date. | `[SEED §1]`, `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §1.4]` |
| **Suspended item** | A `Card` or `Question` (`suspended = true`) that is excluded from daily reviews and quizzes while keeping its `id` and full review/attempt history (used when an item is removed in a re-import or manually paused). | `[SEED §3 story 6]`, `[SEED §4 Retention]`, `[DOC study-app-spec.md §1.1, §6]` |
| **Top-up run** | A targeted pipeline run (`Orchestrator` top-up mode) triggered by `feedback.json → topup` that runs only the Question Creator and Question Reviewer for concepts where all existing variants have been seen. | `[SEED §3 story 18]`, `[DOC flashcard-pipeline.md §3.1, §10]` |
| **True retention** | The fraction of reviews of cards already in the FSRS `Review` state (`state_before = Review`) rated `Hard`, `Good`, or `Easy` over the trailing 30 days (`SM-2`). | `A01 §3 SM-2`, `DEC-012` |
| **Tutor** | The course-grounded Claude chat inside the study app (`Explain`, `Socratic`, and `Quiz me` modes) that loads the active item, glossary, source slides, weakest concepts, and upcoming assessments. | `[SEED §3 story 13]`, `[DOC study-app-spec.md §1.5]` |

---

## 2. Synonyms (one preferred term each)

| Avoid / synonym in source docs | Preferred term (use in A10–A17) | Reason |
| :-- | :-- | :-- |
| Course / subject / class | **Module** | Used throughout `[SEED §1–§4]`, `flashcard-pipeline.md` and `study-app-spec.md`. |
| Handbook / syllabus / course outline | **Handbook** (or **Module handbook / syllabus**) | Used in `[SEED §3 story 3]` and `flashcard-pipeline.md` §2. |
| Deck (when meaning a single item) | **Card** (reserve **Deck** for `deck.json` or a module/lecture collection of cards) | Prevents confusion between one card and `deck.json`. |
| Quiz question / variant / problem | **Question** (entity) / **Question variant** (when emphasising multiple per concept) | Matches `Question` entity in `study-app-spec.md` §2 and "question variant" in `[SEED §3 stories 2, 8]`. |
| Grading / marking | **Marking** (prose) / `grader` (attribute name) | Matches British English convention (`AGENTS.md §4`) and `[SEED §3 story 12]`, while keeping exact schema field names from `study-app-spec.md` §2. |
| Today page / daily checklist / daily plan | **Today checklist** (UI/report) / `DailyPlan` (entity) | Matches `[SEED §3 story 10]` ("Today checklist") and `study-app-spec.md` §2 (`DailyPlan`). |

---

## 3. Homonyms (separate term per meaning)

| Ambiguous word | Distinct term 1 | Distinct term 2 |
| :-- | :-- | :-- |
| **Orchestrator** | **Pipeline Orchestrator**: the runtime coordinator in `flashcard-pipeline.md` §3.1 that runs the Extractor, Creators, Reviewers, and Module Auditor. | **Protocol Orchestrator**: the planning/building agent role under `master_planning_agent_protocol.md` §4. |
| **Reviewer** | **Card Reviewer / Question Reviewer**: the pipeline AI agents in `flashcard-pipeline.md` §3.4 and §3.6 that check generated content. | **Gate Reviewer**: the independent protocol agent role (`master_planning_agent_protocol.md` §4.2) that runs Gates G1–G6. |
| **Status / State** | **Pipeline item status** (`Card.status`, `Question.status` in pipeline drafts: `draft`, `accept`, `revise`, `reject`, `flagged`). | **FSRS scheduling state** (`CardState.state`, `ConceptState.state`: `New`, `Learning`, `Review`, `Relearning`). |
| **Flagged** | **Pipeline flagged item** (`FlaggedItem` in `flagged.json`): an unclear source point or an item that failed after 2 revision rounds, shown in the human review step. | **App-flagged item** (`Card.flagged`, `Question.flagged`): a boolean bookmark/exclusion flag set by the student in the study app. |
| **Proposal** | **Tutor proposal** (`Proposal` entity): a candidate card or question suggested by the Claude tutor in `study-app-spec.md` §1.5. | **CP2 requirement proposal** (`**(Proposal for CP2)**`): a requirement in `A10` not explicitly stated by the user that awaits `CP2` confirmation under `G2.13`. |

---

## 4. Data dictionary — Study App entities (`A16`)

Type classes (catalog A18): `identifier`, `text`, `number`, `money`, `date-time`, `enumeration`, `boolean`. Composite and multivalued attributes are noted; they are normalised into 3NF relations in `A32` (Stage 3).

### 4.1 Curriculum, concepts, and flashcards (`Module`, `Lecture`, `Concept`, `ConceptState`, `Card`, `CardState`, `CardReviewLog`)

| Entity | Attribute | Definition | Type class | Allowed values / range | Source |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `Module` | `id` | Stable unique module identifier (e.g. `COMP4901B`). | `identifier` | Non-empty ASCII slug (`1..64` chars), unique | `[DOC study-app-spec.md §2]` |
| `Module` | `code` | Official university course code. | `text` | `1..32` chars (e.g. `COMP 4901B`) | `[DOC study-app-spec.md §2]` |
| `Module` | `name` | Module title. | `text` | `1..200` chars | `[DOC study-app-spec.md §2]` |
| `Module` | `colour` | Display accent colour for the module in the UI. | `text` | Hex colour `#RRGGBB` or named token | `[DOC study-app-spec.md §2]` |
| `Module` | `timezone` | Default IANA timezone for module deadlines and schedule. | `text` | Valid IANA timezone (default `Asia/Hong_Kong`) | `[DOC study-app-spec.md §2]`, `ASM-022` |
| `Module` | `new_cards_per_day` | Per-module daily cap on new flashcards introduced. | `number` | Integer `0..500` (default `20`) | `[DOC study-app-spec.md §1.1, §2]` |
| `Module` | `max_reviews_per_day` | Per-module daily cap on due flashcard reviews. | `number` | Integer `1..2000` (default `200`) | `[DOC study-app-spec.md §1.1, §2]` |
| `Module` | `quiz_per_day` | Per-module daily cap on due concept quiz questions. | `number` | Integer `0..100` (default `10`) | `[DOC study-app-spec.md §1.2, §2]` |
| `Module` | `desired_retention` | Target FSRS retention probability for the module. | `number` | Decimal `0.70..0.99` (default `0.90`) | `[DOC study-app-spec.md §1.1, §2]` |
| `Lecture` | `id` | Stable unique lecture identifier (e.g. `COMP4901B-W04-RL`). | `identifier` | Non-empty slug (`1..80` chars), unique | `[DOC study-app-spec.md §2]` |
| `Lecture` | `module_id` | Owning `Module.id`. | `identifier` | Foreign key → `Module.id` | `[DOC study-app-spec.md §2]` |
| `Lecture` | `week` | Teaching week number in the semester. | `number` | Integer `1..20` | `[DOC study-app-spec.md §2]` |
| `Lecture` | `title` | Lecture topic title. | `text` | `1..200` chars | `[DOC study-app-spec.md §2]` |
| `Lecture` | `date` | Optional calendar date the lecture was delivered. | `date-time` | ISO-8601 date `YYYY-MM-DD` or `null` | `[DOC study-app-spec.md §2]` |
| `Concept` | `id` | Stable unique concept identifier (`<MODULE>-<WEEK>-K<nn>`). | `identifier` | Non-empty slug (`1..80` chars), unique | `[DOC flashcard-pipeline.md §6.5]`, `[DOC study-app-spec.md §2]` |
| `Concept` | `module_id` | Owning `Module.id`. | `identifier` | Foreign key → `Module.id` | `[DOC study-app-spec.md §2]` |
| `Concept` | `lecture_id` | Owning `Lecture.id`. | `identifier` | Foreign key → `Lecture.id` | `[DOC study-app-spec.md §2]` |
| `Concept` | `summary` | One-line summary of the concept. | `text` | `1..500` chars | `[DOC flashcard-pipeline.md §3.3, §6.5]` |
| `Concept` | `importance` | Curriculum importance tier driving card coverage and variant count. | `enumeration` | `core` \| `supporting` \| `detail` | `[DOC flashcard-pipeline.md §3.3, §6.2]` |
| `Concept` | `assessments` | Multivalued list of assessment `Deadline.id`s whose scope includes this concept. | `identifier` (multivalued) | `0..*` `Deadline.id` values | `[DOC flashcard-pipeline.md §6.5]`, `[DOC study-app-spec.md §2]` |
| `ConceptState` | `concept_id` | Identifier of the scheduled `Concept` (1:1). | `identifier` | Primary/foreign key → `Concept.id` | `[DOC study-app-spec.md §2]` |
| `ConceptState` | `due` | Next scheduled quiz timestamp in UTC. | `date-time` | ISO-8601 UTC timestamp | `[DOC study-app-spec.md §2]` |
| `ConceptState` | `stability` | FSRS memory stability $S$ in days. | `number` | Real `>= 0.0` | `[DOC study-app-spec.md §2]` |
| `ConceptState` | `difficulty` | FSRS item difficulty $D$. | `number` | Real `1.0..10.0` (or `0.0` when `New`) | `[DOC study-app-spec.md §2]` |
| `ConceptState` | `reps` | Total number of completed quiz reviews for this concept. | `number` | Integer `>= 0` | `[DOC study-app-spec.md §2]` |
| `ConceptState` | `lapses` | Number of times the concept was rated `Again` after reaching `Review`. | `number` | Integer `>= 0` | `[DOC study-app-spec.md §2]` |
| `ConceptState` | `state` | Current FSRS state of the concept. | `enumeration` | `New` \| `Learning` \| `Review` \| `Relearning` | `[DOC study-app-spec.md §2]` |
| `ConceptState` | `last_review` | UTC timestamp of the most recent quiz attempt for this concept. | `date-time` | ISO-8601 UTC timestamp or `null` | `[DOC study-app-spec.md §2]` |
| `Card` | `id` | Stable unique flashcard identifier (`<MODULE>-<WEEK>-C<nnn>`). | `identifier` | Non-empty slug (`1..80` chars), unique | `[DOC flashcard-pipeline.md §4]`, `[DOC study-app-spec.md §2]` |
| `Card` | `module_id` | Owning `Module.id`. | `identifier` | Foreign key → `Module.id` | `[DOC study-app-spec.md §2]` |
| `Card` | `lecture_id` | Owning `Lecture.id` (or `null` for cross-lecture cards). | `identifier` | Foreign key → `Lecture.id` or `null` | `[DOC study-app-spec.md §2]` |
| `Card` | `concept_id` | Linked `Concept.id`. | `identifier` | Foreign key → `Concept.id` | `[DOC flashcard-pipeline.md §4]`, `[DOC study-app-spec.md §2]` |
| `Card` | `type` | Flashcard prompt format. | `enumeration` | `basic` \| `cloze` \| `reverse` | `[DOC flashcard-pipeline.md §4 rule 7]` |
| `Card` | `front` | Prompt text (Markdown + LaTeX, or `{{c1::...}}` cloze template). | `text` | `1..2000` chars | `[DOC flashcard-pipeline.md §4]` |
| `Card` | `back` | Answer text (empty string permitted for `cloze` cards). | `text` | `0..2000` chars (aim <~15 words for `basic`/`reverse`) | `[DOC flashcard-pipeline.md §4 rule 6]` |
| `Card` | `extra` | Optional post-answer explanation or labelled general-knowledge context. | `text` | `0..4000` chars | `[DOC flashcard-pipeline.md §4 rules 6, 9]` |
| `Card` | `tags` | Multivalued hierarchical tags (e.g. `COMP4901B::Week04::RL`). | `text` (multivalued) | `0..20` tag strings | `[DOC flashcard-pipeline.md §4]`, `[DOC study-app-spec.md §2]` |
| `Card` | `source` | Composite citation `{file, location}` pointing to the course slide/page. | `text` (composite) | `file`: relative path; `location`: e.g. `slide 12` | `[DOC flashcard-pipeline.md §4]`, `[DOC study-app-spec.md §2]` |
| `Card` | `importance` | Importance tier inherited from or aligned with the concept. | `enumeration` | `core` \| `supporting` \| `detail` | `[DOC flashcard-pipeline.md §4]` |
| `Card` | `suspended` | Whether the card is excluded from scheduling while preserving history. | `boolean` | `true` \| `false` (default `false`) | `[DOC study-app-spec.md §2, §6]` |
| `Card` | `flagged` | Whether the student flagged the card in the app. | `boolean` | `true` \| `false` (default `false`) | `[DOC study-app-spec.md §2]` |
| `CardState` | `card_id` | Identifier of the scheduled `Card` (1:1). | `identifier` | Primary/foreign key → `Card.id` | `[DOC study-app-spec.md §2]` |
| `CardState` | `due` | Next scheduled review timestamp in UTC. | `date-time` | ISO-8601 UTC timestamp | `[DOC study-app-spec.md §2]` |
| `CardState` | `stability` | FSRS memory stability $S$ in days. | `number` | Real `>= 0.0` | `[DOC study-app-spec.md §2]` |
| `CardState` | `difficulty` | FSRS item difficulty $D$. | `number` | Real `1.0..10.0` (or `0.0` when `New`) | `[DOC study-app-spec.md §2]` |
| `CardState` | `reps` | Total number of reviews completed for this card. | `number` | Integer `>= 0` | `[DOC study-app-spec.md §2]` |
| `CardState` | `lapses` | Number of `Again` ratings on this card from `Review` state. | `number` | Integer `>= 0` | `[DOC study-app-spec.md §2]` |
| `CardState` | `state` | Current FSRS state of the card. | `enumeration` | `New` \| `Learning` \| `Review` \| `Relearning` | `[DOC study-app-spec.md §2]` |
| `CardState` | `last_review` | UTC timestamp of the most recent review of this card. | `date-time` | ISO-8601 UTC timestamp or `null` | `[DOC study-app-spec.md §2]` |
| `CardReviewLog` | `id` | Unique review log entry identifier. | `identifier` | UUID or integer sequence | `[DOC study-app-spec.md §2]` |
| `CardReviewLog` | `card_id` | Reviewed `Card.id`. | `identifier` | Foreign key → `Card.id` | `[DOC study-app-spec.md §2]` |
| `CardReviewLog` | `rating` | FSRS rating chosen by the student. | `enumeration` | `Again` \| `Hard` \| `Good` \| `Easy` | `[DOC study-app-spec.md §1.1, §2]` |
| `CardReviewLog` | `state_before` | Card's FSRS state immediately before this review, required to compute `SM-2` true retention **(Proposal for CP2)**. | `enumeration` | `New` \| `Learning` \| `Review` \| `Relearning` | `A01 §3 SM-2`, `DEC-012` **(Proposal for CP2)** |
| `CardReviewLog` | `reviewed_at` | UTC timestamp when the review was recorded. | `date-time` | ISO-8601 UTC timestamp | `[DOC study-app-spec.md §2]` |
| `CardReviewLog` | `duration_ms` | Elapsed time spent answering the card in milliseconds. | `number` | Integer `>= 0` | `[DOC study-app-spec.md §2]` |

### 4.2 Quiz bank, attempts, and notation glossary (`Question`, `QuestionAttempt`, `GlossaryEntry`)

| Entity | Attribute | Definition | Type class | Allowed values / range | Source |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `Question` | `id` | Stable unique question identifier (`<MODULE>-<WEEK>-Q<nnn>`). | `identifier` | Non-empty slug (`1..80` chars), unique | `[DOC flashcard-pipeline.md §6.4]`, `[DOC study-app-spec.md §2]` |
| `Question` | `module_id` | Owning `Module.id`. | `identifier` | Foreign key → `Module.id` | `[DOC study-app-spec.md §2]` |
| `Question` | `lecture_id` | Owning `Lecture.id` (or `null` for cross-lecture questions). | `identifier` | Foreign key → `Lecture.id` or `null` | `[DOC study-app-spec.md §2]` |
| `Question` | `variant_of` | Primary `Concept.id` for which this question is a scheduled variant. | `identifier` | Foreign key → `Concept.id` | `[DOC flashcard-pipeline.md §6.4]` |
| `Question` | `concept_ids` | Multivalued list of `Concept.id`s tested (1 for standard, `2..*` for cross-lecture). | `identifier` (multivalued) | `1..*` `Concept.id` values | `[DOC flashcard-pipeline.md §6.4]`, `[DOC study-app-spec.md §2]` |
| `Question` | `type` | Question assessment format type. | `enumeration` | `mcq` \| `short_answer` \| `calculation` \| `explain` \| `compare` \| `scenario` \| `essay_plan` | `[DOC flashcard-pipeline.md §6.2 rule 3]` |
| `Question` | `difficulty` | Question difficulty tier. | `enumeration` | `1` (recall/apply) \| `2` (multi-step) \| `3` (exam-hard) | `[DOC flashcard-pipeline.md §6.2 rule 7]` |
| `Question` | `stem` | Question prompt text (Markdown + LaTeX). | `text` | `1..4000` chars | `[DOC flashcard-pipeline.md §6.4]`, `[DOC study-app-spec.md §2]` |
| `Question` | `options` | Multivalued MCQ options `{label, text, is_correct, distractor_explanation}` when `type = mcq`, else `null`. | `text` (composite/multivalued) | `2..6` options for `mcq` (exactly 1 `is_correct = true`); `null` otherwise | `[DOC flashcard-pipeline.md §6.2 rule 6, §6.4]`, `[DOC study-app-spec.md §2]` |
| `Question` | `model_answer` | Full reference answer supported by the source material. | `text` | `1..4000` chars | `[DOC flashcard-pipeline.md §6.4]`, `[DOC study-app-spec.md §2]` |
| `Question` | `marking_points` | Multivalued list of 2–5 explicit marking criteria for written/calculation types. | `text` (multivalued) | `2..5` non-empty strings (or `0..5` for `mcq`) | `[DOC flashcard-pipeline.md §6.2 rule 6, §6.4]` |
| `Question` | `source` | Composite citation `{file, location}` pointing to the course slide/page. | `text` (composite) | `file`: relative path; `location`: e.g. `slides 14, 18–19` | `[DOC flashcard-pipeline.md §6.4]` |
| `Question` | `assessments` | Multivalued list of assessment `Deadline.id`s this question prepares for. | `identifier` (multivalued) | `0..*` `Deadline.id` values | `[DOC flashcard-pipeline.md §6.4]`, `[DOC study-app-spec.md §2]` |
| `Question` | `suspended` | Whether the question is excluded from quizzes after removal on re-import. | `boolean` | `true` \| `false` (default `false`) | `[SEED §4 Retention]`, `[DOC study-app-spec.md §6]` |
| `Question` | `flagged` | Whether the student flagged the question in the app (excludes it from quizzes). | `boolean` | `true` \| `false` (default `false`) | `[DOC study-app-spec.md §2, §3.2]` |
| `QuestionAttempt` | `id` | Unique attempt identifier. | `identifier` | UUID or integer sequence | `[DOC study-app-spec.md §2]` |
| `QuestionAttempt` | `question_id` | Answered `Question.id`. | `identifier` | Foreign key → `Question.id` | `[DOC study-app-spec.md §2]` |
| `QuestionAttempt` | `concept_id` | Scheduled `Concept.id` updated by this attempt. | `identifier` | Foreign key → `Concept.id` | `[DOC study-app-spec.md §2]` |
| `QuestionAttempt` | `mode` | Whether the attempt occurred in a daily quiz, mock exam, or offline queue. | `enumeration` | `daily_quiz` \| `mock_exam` | `[DOC study-app-spec.md §1.2, §4]` |
| `QuestionAttempt` | `answered_at` | UTC timestamp when the student submitted the response. | `date-time` | ISO-8601 UTC timestamp | `[DOC study-app-spec.md §2]` |
| `QuestionAttempt` | `response` | Student's selected option or written/calculated answer text. | `text` | `1..10000` chars | `[DOC study-app-spec.md §2]` |
| `QuestionAttempt` | `points_met` | Multivalued indices of `marking_points` satisfied (`0..k-1`). | `number` (multivalued) | Subset of `0..len(marking_points)-1` | `[DOC study-app-spec.md §2, §3.4]` |
| `QuestionAttempt` | `comment` | Grader feedback comment returned by Claude or recorded during marking. | `text` | `0..2000` chars | `[DOC study-app-spec.md §1.2, §3.4]` |
| `QuestionAttempt` | `grader` | How the attempt was marked (`pending_claude` when queued offline in R3). | `enumeration` | `auto` \| `claude` \| `self` \| `pending_claude` | `[DOC study-app-spec.md §2, §4]` |
| `QuestionAttempt` | `overridden` | Whether the student overrode the automatic or Claude-assigned rating. | `boolean` | `true` \| `false` (default `false`) | `[DOC study-app-spec.md §1.2, §2]` |
| `QuestionAttempt` | `rating` | Final FSRS rating applied to `ConceptState` (`null` while `pending_claude`). | `enumeration` | `Again` \| `Hard` \| `Good` \| `Easy` \| `null` | `[DOC study-app-spec.md §1.2, §2]` |
| `QuestionAttempt` | `duration_ms` | Elapsed time spent answering the question in milliseconds. | `number` | Integer `>= 0` | `[DOC study-app-spec.md §2]` |
| `GlossaryEntry` | `id` | Stable unique glossary entry identifier (`<MODULE>-G<nnn>`). | `identifier` | Non-empty slug (`1..80` chars), unique | `[DOC study-app-spec.md §2]` |
| `GlossaryEntry` | `module_id` | Owning `Module.id`. | `identifier` | Foreign key → `Module.id` | `[DOC study-app-spec.md §2]` |
| `GlossaryEntry` | `term` | Full expanded term in words. | `text` | `1..300` chars | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `GlossaryEntry` | `abbreviation` | Symbol or abbreviation string. | `text` | `1..64` chars | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `GlossaryEntry` | `canonical` | Exact mandatory format string (`"full term (abbreviation)"` or `"full term (symbol in this module)"`). | `text` | `1..400` chars | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `GlossaryEntry` | `kind` | Whether notation is standard across the field or specific to this module. | `enumeration` | `standard` \| `module_specific` | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `GlossaryEntry` | `where_defined` | Source file and slide/page where the symbol is first defined. | `text` | `1..300` chars | `[DOC flashcard-pipeline.md §3.2]` |
| `GlossaryEntry` | `confirmed` | Whether a `module_specific` entry has been confirmed by the student. | `boolean` | `true` \| `false` | `[SEED §3 story 5]`, `[DOC flashcard-pipeline.md §3.2, §9]` |

---

### 4.3 Deadlines, milestones, readings, tasks, and daily plans (`Deadline`, `Milestone`, `Reading`, `Task`, `DailyPlan`, `DailyPlanItem`)

| Entity | Attribute | Definition | Type class | Allowed values / range | Source |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `Deadline` | `id` | Stable unique deadline identifier (`<MODULE>-D<nnn>` or UUID). | `identifier` | Non-empty slug (`1..80` chars), unique | `[DOC study-app-spec.md §2]` |
| `Deadline` | `module_id` | Owning `Module.id`. | `identifier` | Foreign key → `Module.id` | `[DOC study-app-spec.md §2]` |
| `Deadline` | `title` | Deadline or assessment title. | `text` | `1..200` chars | `[DOC study-app-spec.md §2]` |
| `Deadline` | `type` | Assessment/deadline category (`homework` and `project` are coursework types). | `enumeration` | `exam` \| `midterm` \| `quiz` \| `homework` \| `project` \| `coursework` \| `other` | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §1.5, §2]`, `SRC-05` |
| `Deadline` | `due_at` | Due timestamp in UTC (`null` when unannounced in source, with reason in `notes`). | `date-time` | ISO-8601 UTC timestamp or `null` | `[DOC flashcard-pipeline.md §8]`, `[DOC study-app-spec.md §2]` |
| `Deadline` | `timezone` | Original IANA timezone of the deadline (default `Asia/Hong_Kong`). | `text` | Valid IANA timezone | `[SEED §7]`, `[DOC study-app-spec.md §2]`, `ASM-022` |
| `Deadline` | `weighting` | Percentage weight of the module grade. | `number` | Real `0.0..100.0` or `null` | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `Deadline` | `submission_url` | Submission method or URL (e.g. Canvas assignment URL or exam hall). | `text` | `0..500` chars | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `Deadline` | `covers_lectures` | Multivalued list of `Lecture.id`s (or `"all"`) covered by an exam/midterm. | `identifier` (multivalued) | `0..*` `Lecture.id`s | `[DOC flashcard-pipeline.md §3.2, §12]`, `[DOC study-app-spec.md §2]` |
| `Deadline` | `format` | Optional map of question-type weights summing to `1.0` for exams/midterms. | `number` (composite) | Keys from `Question.type`, values `0.0..1.0`, sum `= 1.0` | `[DOC flashcard-pipeline.md §12]`, `[DOC study-app-spec.md §1.2]` |
| `Deadline` | `origin` | Whether the deadline was extracted by the pipeline or entered manually. | `enumeration` | `extracted` \| `manual` | `[DOC study-app-spec.md §2]` |
| `Deadline` | `confidence` | Whether an extracted date was explicit in the source or inferred from the calendar. | `enumeration` | `explicit` \| `inferred` | `[DOC flashcard-pipeline.md §3.2, §8]`, `[DOC study-app-spec.md §2]` |
| `Deadline` | `confirmed` | Whether an `inferred` deadline has been confirmed by the student. | `boolean` | `true` \| `false` | `[SEED §3 story 9]`, `[DOC study-app-spec.md §1.3, §2]` |
| `Deadline` | `status` | Completion status of the deadline (`SM-4a`). | `enumeration` | `upcoming` \| `submitted` \| `done` \| `missed` | `A01 §3 SM-4a`, `[DOC study-app-spec.md §1.3, §2]` |
| `Deadline` | `notes` | Optional notes or source location/reason for an unannounced date. | `text` | `0..2000` chars | `[DOC study-app-spec.md §2]` |
| `Milestone` | `id` | Unique milestone identifier. | `identifier` | UUID or slug | `[DOC study-app-spec.md §2]` |
| `Milestone` | `deadline_id` | Parent coursework `Deadline.id`. | `identifier` | Foreign key → `Deadline.id` | `[DOC study-app-spec.md §2]` |
| `Milestone` | `title` | Milestone step description (e.g. `Draft report`). | `text` | `1..200` chars | `[DOC study-app-spec.md §1.3, §2]` |
| `Milestone` | `due_on` | Local calendar date on which the milestone is due. | `date-time` | ISO-8601 date `YYYY-MM-DD` | `[DOC study-app-spec.md §2]` |
| `Milestone` | `est_minutes` | Estimated duration in minutes. | `number` | Integer `1..600` | `[DOC study-app-spec.md §2]` |
| `Milestone` | `done` | Whether the milestone has been completed. | `boolean` | `true` \| `false` (default `false`) | `[DOC study-app-spec.md §2]` |
| `Reading` | `id` | Stable unique reading identifier (`<MODULE>-R<nnn>`). | `identifier` | Non-empty slug (`1..80` chars), unique | `[DOC study-app-spec.md §2]` |
| `Reading` | `module_id` | Owning `Module.id`. | `identifier` | Foreign key → `Module.id` | `[DOC study-app-spec.md §2]` |
| `Reading` | `lecture_id` | Optional linked `Lecture.id`. | `identifier` | Foreign key → `Lecture.id` or `null` | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `Reading` | `citation` | Title/author citation of the reading. | `text` | `1..500` chars | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `Reading` | `pages` | Chapter or page range string and page count. | `text` | `1..100` chars | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `Reading` | `page_count` | Numeric page count used to compute `est_minutes = page_count × minutes_per_page`. | `number` | Integer `1..1000` | `[DOC study-app-spec.md §1.4]` |
| `Reading` | `required` | True if required reading, false if recommended reading. | `boolean` | `true` \| `false` | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `Reading` | `read_by` | Local calendar date by which the reading should be completed (default: lecture date). | `date-time` | ISO-8601 date `YYYY-MM-DD` | `[DOC flashcard-pipeline.md §3.2]`, `[DOC study-app-spec.md §2]` |
| `Reading` | `confidence` | Whether `read_by` was explicit or inferred. | `enumeration` | `explicit` \| `inferred` | `[DOC flashcard-pipeline.md §9]` |
| `Reading` | `est_minutes` | Derived/stored estimated reading time in minutes (`page_count × minutes_per_page`). | `number` | Integer `1..1000` | `[DOC study-app-spec.md §1.4, §2]` |
| `Reading` | `status` | Student's completion status for the reading. | `enumeration` | `todo` \| `done` \| `skimmed` \| `skipped` | `[DOC study-app-spec.md §1.4, §2]` |
| `Task` | `id` | Unique user task identifier. | `identifier` | UUID or integer sequence | `[DOC study-app-spec.md §2]` |
| `Task` | `title` | Task description entered by the student. | `text` | `1..300` chars | `[DOC study-app-spec.md §2]` |
| `Task` | `module_id` | Optional linked `Module.id`. | `identifier` | Foreign key → `Module.id` or `null` | `[DOC study-app-spec.md §2]` |
| `Task` | `due_on` | Optional local calendar due date. | `date-time` | ISO-8601 date `YYYY-MM-DD` or `null` | `[DOC study-app-spec.md §2]` |
| `Task` | `recurrence` | Optional recurrence rule (e.g. `daily`, `weekly`). | `text` | `none` \| `daily` \| `weekly` or `null` | `[DOC study-app-spec.md §2]` |
| `Task` | `est_minutes` | Estimated duration in minutes. | `number` | Integer `1..600` | `[DOC study-app-spec.md §2]` |
| `Task` | `done` | Whether the task is completed. | `boolean` | `true` \| `false` (default `false`) | `[DOC study-app-spec.md §2]` |
| `DailyPlan` | `date` | Local calendar date of the plan in `Settings.timezone`. | `date-time` | Primary key, ISO-8601 date `YYYY-MM-DD` | `[DOC study-app-spec.md §2]` |
| `DailyPlan` | `generated_at` | UTC timestamp when the plan was generated. | `date-time` | ISO-8601 UTC timestamp | `[DOC study-app-spec.md §3.3]` |
| `DailyPlan` | `over_budget_warning` | Derived flag true when required items exceed `Settings.daily_budget_min`. | `boolean` | `true` \| `false` | `[DOC study-app-spec.md §1.4, §3.3]` |
| `DailyPlanItem` | `id` | Unique checklist item identifier within a `DailyPlan`. | `identifier` | UUID or integer sequence | `[DOC study-app-spec.md §2, §5]` |
| `DailyPlanItem` | `plan_date` | Owning `DailyPlan.date`. | `date-time` | Foreign key → `DailyPlan.date` | `[DOC study-app-spec.md §2]` |
| `DailyPlanItem` | `kind` | Checklist item type corresponding to the 9 ordered categories. | `enumeration` | `card_review` \| `quiz` \| `new_cards` \| `required_reading` \| `milestone` \| `assessment_prep` \| `recommended_reading` \| `task` | `[DOC study-app-spec.md §1.4, §2]` |
| `DailyPlanItem` | `ref_id` | Identifier of the referenced `Module`, `Reading`, `Milestone`, or `Task`. | `identifier` | Non-empty ID string | `[DOC study-app-spec.md §2]` |
| `DailyPlanItem` | `est_minutes` | Estimated study time for this item in minutes. | `number` | Real `>= 0.0` | `[DOC study-app-spec.md §1.4, §2]` |
| `DailyPlanItem` | `optional` | Whether the item may be deferred when the daily budget is exceeded. | `boolean` | `true` \| `false` | `[DOC study-app-spec.md §1.4, §2]` |
| `DailyPlanItem` | `carried_over` | Whether the item was carried over from an earlier day's unfinished plan. | `boolean` | `true` \| `false` | `[DOC study-app-spec.md §1.4, §2]` |
| `DailyPlanItem` | `deferred` | Whether the item was deferred by the workload cap. | `boolean` | `true` \| `false` | `[DOC study-app-spec.md §1.4]` |
| `DailyPlanItem` | `done` | Whether the item has been completed. | `boolean` | `true` \| `false` (default `false`) | `[DOC study-app-spec.md §2]` |
| `DailyPlanItem` | `completed_at` | UTC timestamp when `done` was set to `true`, needed to verify same-day completion for `SM-4b` **(Proposal for CP2)**. | `date-time` | ISO-8601 UTC timestamp or `null` | `A01 §3 SM-4b`, `DEC-012` **(Proposal for CP2)** |

### 4.4 Tutor, feedback, settings, and pipeline records (`TutorThread`, `TutorMessage`, `Proposal`, `FeedbackItem`, `Settings`, `ImportBatch`, `GradingCallLog`, `PipelineConfig`, `ReviewRecord`, `FlaggedItem`, `ModuleAudit`, `PipelineRunSummary`)

| Entity | Attribute | Definition | Type class | Allowed values / range | Source |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `TutorThread` | `id` | Unique tutor conversation thread identifier. | `identifier` | UUID | `[DOC study-app-spec.md §2]` |
| `TutorThread` | `module_id` | Owning `Module.id`. | `identifier` | Foreign key → `Module.id` | `[DOC study-app-spec.md §2]` |
| `TutorThread` | `title` | Thread title for browsing and searching. | `text` | `1..200` chars | `[DOC study-app-spec.md §2]` |
| `TutorThread` | `mode` | Current pedagogical mode of the tutor thread. | `enumeration` | `explain` \| `socratic` \| `quiz_me` | `[SEED §3 story 13]`, `[DOC study-app-spec.md §1.5, §2]` |
| `TutorThread` | `context_ref` | Optional composite reference `{kind, id}` (`card`, `question`, `attempt`, `reading`) from which the thread was opened. | `identifier` (composite) | `kind`: `card`\|`question`\|`attempt`\|`reading`; `id`: target ID; or `null` | `[DOC study-app-spec.md §1.5, §2]` |
| `TutorThread` | `created_at` | UTC timestamp when the thread was created. | `date-time` | ISO-8601 UTC timestamp | `[DOC study-app-spec.md §2]` |
| `TutorMessage` | `id` | Unique message identifier within a `TutorThread`. | `identifier` | UUID | `[DOC study-app-spec.md §2]` |
| `TutorMessage` | `thread_id` | Owning `TutorThread.id`. | `identifier` | Foreign key → `TutorThread.id` | `[DOC study-app-spec.md §2]` |
| `TutorMessage` | `role` | Message sender role. | `enumeration` | `user` \| `assistant` | `[DOC study-app-spec.md §2]` |
| `TutorMessage` | `content` | Message text (Markdown + LaTeX + slide citations). | `text` | `1..20000` chars | `[DOC study-app-spec.md §2]` |
| `TutorMessage` | `created_at` | UTC timestamp when the message was sent. | `date-time` | ISO-8601 UTC timestamp | `[DOC study-app-spec.md §2]` |
| `TutorMessage` | `tokens_in` | Uncached + cached input token count billed for this call (`0` for `user` role). | `number` | Integer `>= 0` | `[DOC study-app-spec.md §2, §5]` |
| `TutorMessage` | `tokens_out` | Output token count billed for this call (`0` for `user` role). | `number` | Integer `>= 0` | `[DOC study-app-spec.md §2, §5]` |
| `TutorMessage` | `cost_usd` | Computed USD cost of this message at the configured token rates (`SM-6`). | `money` | Exact decimal `>= 0.0000` (USD) | `A01 §3 SM-6`, `[DOC study-app-spec.md §5]` |
| `Proposal` | `id` | Unique tutor proposal identifier. | `identifier` | UUID | `[DOC study-app-spec.md §2]` |
| `Proposal` | `kind` | Whether the tutor proposed a flashcard or a quiz question. | `enumeration` | `card` \| `question` | `[DOC study-app-spec.md §2]` |
| `Proposal` | `payload` | Draft card or question JSON structure (matching `Card` or `Question` fields). | `text` (composite) | Valid JSON object | `[DOC study-app-spec.md §2]` |
| `Proposal` | `origin_thread_id` | `TutorThread.id` in which the proposal was generated. | `identifier` | Foreign key → `TutorThread.id` | `[DOC study-app-spec.md §2]` |
| `Proposal` | `status` | Review status of the proposal in the app queue. | `enumeration` | `pending` \| `accepted` \| `edited` \| `discarded` | `[SEED §3 story 14]`, `[DOC study-app-spec.md §1.5, §2]` |
| `FeedbackItem` | `id` | Unique feedback queue entry identifier. | `identifier` | UUID | `[DOC study-app-spec.md §2]` |
| `FeedbackItem` | `kind` | Feedback category for the pipeline. | `enumeration` | `reported` \| `topup` \| `proposed` | `[DOC flashcard-pipeline.md §10]`, `[DOC study-app-spec.md §2]` |
| `FeedbackItem` | `target_kind` | Whether `ref_id` refers to a `card`, `question`, `concept`, or `proposal`. | `enumeration` | `card` \| `question` \| `concept` \| `proposal` | `[DOC flashcard-pipeline.md §10]` |
| `FeedbackItem` | `ref_id` | Identifier of the reported `Card`/`Question`, top-up `Concept`, or accepted `Proposal`. | `identifier` | Non-empty ID string | `[DOC study-app-spec.md §2]` |
| `FeedbackItem` | `reason` | Reason for a `reported` item (`wrong` vs `unclear`), needed to compute `SM-3` (`<2%` reported as `wrong`) **(Proposal for CP2)**. | `enumeration` | `wrong` \| `unclear` \| `null` (when `kind != reported`) | `A01 §3 SM-3`, `[SEED §3 story 11]` **(Proposal for CP2)** |
| `FeedbackItem` | `comment` | Student's explanation of what is wrong/unclear or top-up note. | `text` | `0..2000` chars | `[DOC flashcard-pipeline.md §10]`, `[DOC study-app-spec.md §2]` |
| `FeedbackItem` | `created_at` | UTC timestamp when the feedback item was queued. | `date-time` | ISO-8601 UTC timestamp | `[DOC study-app-spec.md §2]` |
| `FeedbackItem` | `exported` | Whether the item has been exported in `feedback.json`. | `boolean` | `true` \| `false` (default `false`) | `[DOC study-app-spec.md §2]` |
| `Settings` | `id` | Singleton settings row identifier (`"default"`). | `identifier` | Constant `"default"` | `[DOC study-app-spec.md §2]` |
| `Settings` | `daily_budget_min` | Global daily study time budget in minutes. | `number` | Integer `15..720` (default `120`) | `[DOC study-app-spec.md §1.4, §2]` |
| `Settings` | `new_cards_per_day` | Default daily new-card limit per module. | `number` | Integer `0..500` (default `20`) | `[DOC study-app-spec.md §1.1, §2]` |
| `Settings` | `quiz_per_day` | Default daily concept quiz count per module. | `number` | Integer `0..100` (default `10`) | `[DOC study-app-spec.md §1.2, §2]` |
| `Settings` | `desired_retention` | Default FSRS target retention probability. | `number` | Decimal `0.70..0.99` (default `0.90`) | `[DOC study-app-spec.md §1.1, §2]` |
| `Settings` | `assessment_mode_days` | Look-ahead window in days before an exam/midterm that activates assessment mode. | `number` | Integer `1..90` (default `21`) | `[DOC study-app-spec.md §1.2, §2]` |
| `Settings` | `reading_lookahead_days` | Days before `read_by` that a required reading joins the Today checklist. | `number` | Integer `0..30` (default `3`) | `[DOC study-app-spec.md §1.4, §2]` |
| `Settings` | `minutes_per_page` | Reading speed factor in minutes per page. | `number` | Real `0.5..15.0` (default `2.5`) | `[DOC study-app-spec.md §1.4, §2]` |
| `Settings` | `timezone` | Student's current IANA timezone for generating the Today checklist. | `text` | Valid IANA timezone (default `Asia/Hong_Kong`) | `[SEED §7]`, `[DOC study-app-spec.md §2]`, `ASM-022` |
| `Settings` | `grading_model` | Claude model ID used for marking written answers. | `text` | Model identifier string | `[DOC study-app-spec.md §4, §5]` |
| `Settings` | `tutor_model` | Claude model ID used for the tutor chat. | `text` | Model identifier string | `[DOC study-app-spec.md §4, §5]` |
| `Settings` | `monthly_spend_cap_usd` | Optional monthly Claude API spend cap in USD (`null` = no cap, `[USER Q-06]`). | `money` | Exact decimal `> 0.00` (USD) or `null` | `[SEED §7 Misuse]`, `[USER Q-06]`, `[DOC study-app-spec.md §5]` |
| `Settings` | `token_rates_json` | Per-million-token input/output/cache prices per model for computing `SM-6` **(Proposal for CP2)**. | `money` (composite) | JSON map of exact decimal USD rates per 1M tokens | `A01 §3 SM-6`, `DEC-012` **(Proposal for CP2)** |
| `ImportBatch` | `id` | Unique import log record identifier, needed to verify `SM-1` **(Proposal for CP2)**. | `identifier` | UUID | `A01 §3 SM-1`, `DEC-012` **(Proposal for CP2)** |
| `ImportBatch` | `module_id` | Imported `Module.id`. | `identifier` | Foreign key → `Module.id` | `A01 §3 SM-1` **(Proposal for CP2)** |
| `ImportBatch` | `lecture_ids` | Multivalued list of `Lecture.id`s whose items were imported in this batch. | `identifier` (multivalued) | `0..*` `Lecture.id` values | `A01 §3 SM-1` **(Proposal for CP2)** |
| `ImportBatch` | `file_kind` | Which pipeline export file was imported (`deck`, `questions`, `concepts`, `glossary`, `deadlines`, `readings`). | `enumeration` | `deck` \| `questions` \| `concepts` \| `glossary` \| `deadlines` \| `readings` | `A01 §3 SM-1`, `[DOC study-app-spec.md §5]` **(Proposal for CP2)** |
| `ImportBatch` | `imported_at` | UTC timestamp when the import was applied. | `date-time` | ISO-8601 UTC timestamp | `A01 §3 SM-1` **(Proposal for CP2)** |
| `ImportBatch` | `counts` | Composite summary `{added, updated, suspended}` of items in the import. | `number` (composite) | Non-negative integers | `[SEED §3 story 6]`, `[DOC study-app-spec.md §4, §6]` **(Proposal for CP2)** |
| `GradingCallLog` | `id` | Unique Claude grading API call log identifier, needed for `SM-6` **(Proposal for CP2)**. | `identifier` | UUID | `A01 §3 SM-6`, `[DOC study-app-spec.md §5]` **(Proposal for CP2)** |
| `GradingCallLog` | `attempt_id` | Linked `QuestionAttempt.id`. | `identifier` | Foreign key → `QuestionAttempt.id` | `A01 §3 SM-6` **(Proposal for CP2)** |
| `GradingCallLog` | `model` | Claude model ID used for the grading call. | `text` | Non-empty string | `A01 §3 SM-6` **(Proposal for CP2)** |
| `GradingCallLog` | `called_at` | UTC timestamp of the grading API call. | `date-time` | ISO-8601 UTC timestamp | `A01 §3 SM-6` **(Proposal for CP2)** |
| `GradingCallLog` | `tokens_in` | Input token count (cached + uncached) for the grading call. | `number` | Integer `>= 0` | `A01 §3 SM-6`, `[DOC study-app-spec.md §5]` **(Proposal for CP2)** |
| `GradingCallLog` | `tokens_out` | Output token count for the grading call. | `number` | Integer `>= 0` | `A01 §3 SM-6`, `[DOC study-app-spec.md §5]` **(Proposal for CP2)** |
| `GradingCallLog` | `cost_usd` | Computed USD cost of the grading call at `Settings.token_rates_json`. | `money` | Exact decimal `>= 0.0000` (USD) | `A01 §3 SM-6` **(Proposal for CP2)** |
| `PipelineConfig` | `module_code` | Module code configured in `pipeline.config.json`. | `identifier` | Non-empty string | `[DOC flashcard-pipeline.md §12]` |
| `PipelineConfig` | `semester` | Composite `{week1_start, reading_weeks[], exam_period[], timezone}`. | `text` (composite) | Valid dates and IANA timezone | `[DOC flashcard-pipeline.md §12]` |
| `PipelineConfig` | `assessments` | Multivalued list of `{id, date, covers_lectures, format}` entries. | `text` (composite/multivalued) | `0..*` assessment config objects | `[DOC flashcard-pipeline.md §12]` |
| `PipelineConfig` | `cards_per_lecture` | Composite `{min, max}` target card count per lecture (default `15..40`). | `number` (composite) | `min = 15`, `max = 40` | `[DOC flashcard-pipeline.md §4 rule 10, §12]` |
| `PipelineConfig` | `variants` | Composite `{core: [3,5], supporting: [2,3], detail: [0,1]}` variant ranges (`DEC-006`). | `number` (composite) | Integer ranges per importance tier | `[DOC flashcard-pipeline.md §6.2, §12]`, `DEC-006` |
| `PipelineConfig` | `max_review_rounds` | Maximum Creator revision rounds per stage (default `2`). | `number` | Integer `1..2` (default `2`) | `[DOC flashcard-pipeline.md §7, §12]` |
| `PipelineConfig` | `parallel_lectures` | Maximum lectures processed in one parallel batch (default `6`). | `number` | Integer `1..10` (default `6`) | `[DOC flashcard-pipeline.md §12]` |
| `PipelineConfig` | `human_spot_check_rate` | Fraction of accepted items sampled for human spot-check (default `0.10`). | `number` | Decimal `0.05..1.00` (default `0.10`) | `[DOC flashcard-pipeline.md §9, §12]` |
| `ReviewRecord` | `id` | Composite identifier `(lecture, stage, round)` of a Reviewer output file. | `identifier` | Unique per `(lecture, stage, round)` | `[DOC flashcard-pipeline.md §5.2]` |
| `ReviewRecord` | `stage` | Pipeline stage reviewed. | `enumeration` | `cards` \| `questions` \| `cross_lecture` | `[DOC flashcard-pipeline.md §5.2, §3.7]` |
| `ReviewRecord` | `round` | Review round number (`1` initial, `2` after revision 1, `3` after revision 2). | `number` | Integer `1..3` | `[DOC flashcard-pipeline.md §5.2, §7]` |
| `ReviewRecord` | `items` | Multivalued per-item verdicts `{id, verdict, failed[], blind_answer, feedback}`. | `text` (composite/multivalued) | `verdict`: `accept` \| `revise` \| `reject` | `[DOC flashcard-pipeline.md §5.2]` |
| `ReviewRecord` | `missing_concepts` | Multivalued `{summary, source}` gaps found in the concept map. | `text` (composite/multivalued) | `0..*` gap objects | `[DOC flashcard-pipeline.md §5.2]` |
| `ReviewRecord` | `overall` | Overall stage verdict for the round. | `enumeration` | `accept` \| `revise` | `[DOC flashcard-pipeline.md §5.2]` |
| `FlaggedItem` | `id` | Unique flagged item identifier in `flagged.json`. | `identifier` | Non-empty string | `[DOC flashcard-pipeline.md §2, §7, §9]` |
| `FlaggedItem` | `lecture_id` | Lecture in which the item was flagged. | `identifier` | `Lecture.id` | `[DOC flashcard-pipeline.md §2, §9]` |
| `FlaggedItem` | `kind` | Whether the flag is an unclear source point or an unresolved card/question after round 3. | `enumeration` | `unclear_source` \| `unresolved_card` \| `unresolved_question` | `[DOC flashcard-pipeline.md §3.3, §7]` |
| `FlaggedItem` | `reason` | Explanation and Reviewer feedback history for the human review step. | `text` | `1..2000` chars | `[DOC flashcard-pipeline.md §7, §9]` |
| `FlaggedItem` | `resolution` | Student's decision during the human review step (`accept_with_edit`, `discard`). | `enumeration` | `pending` \| `accepted_with_edit` \| `discarded` | `[SEED §3 story 5]`, `[DOC flashcard-pipeline.md §9]` |
| `ModuleAudit` | `module_id` | Audited `Module.id` (`module-audit.json`). | `identifier` | `Module.id` | `[DOC flashcard-pipeline.md §3.7, §8]` |
| `ModuleAudit` | `outcome_coverage` | Mapping of module learning outcomes to covering cards/questions and any gaps. | `text` (composite) | JSON object | `[DOC flashcard-pipeline.md §8]` |
| `ModuleAudit` | `assessment_coverage` | Check of variant counts per concept in each assessment's scope. | `text` (composite) | JSON object | `[DOC flashcard-pipeline.md §8]` |
| `ModuleAudit` | `duplicates` | Cross-lecture duplicate or near-duplicate card/question pairs detected. | `text` (composite/multivalued) | `0..*` duplicate pairs | `[DOC flashcard-pipeline.md §3.7, §8]` |
| `ModuleAudit` | `notation_issues` | Items whose text deviates from `GlossaryEntry.canonical`. | `text` (composite/multivalued) | `0..*` notation findings | `[DOC flashcard-pipeline.md §3.7, §8]` |
| `ModuleAudit` | `proposed_items` | Cross-lecture synthesis cards and questions proposed by the Auditor. | `text` (composite/multivalued) | `0..N` draft items | `[DOC flashcard-pipeline.md §3.7, §8]` |
| `PipelineRunSummary` | `run_id` | Unique pipeline run identifier. | `identifier` | Timestamp/UUID slug | `[SEED §3 Reports & outputs]`, `[DOC flashcard-pipeline.md §3.1]` |
| `PipelineRunSummary` | `module_id` | Processed `Module.id`. | `identifier` | `Module.id` | `[DOC flashcard-pipeline.md §3.1]` |
| `PipelineRunSummary` | `lecture_counts` | Per-lecture counts `{accepted, rejected, flagged}` for cards and questions. | `number` (composite/multivalued) | Non-negative integers per lecture | `[SEED §3 Reports & outputs]`, `[DOC flashcard-pipeline.md §3.1]` |
