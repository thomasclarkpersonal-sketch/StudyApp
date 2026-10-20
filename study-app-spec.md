# Study Web App — Specification

A personal, single-user web app for studying university modules. It has five parts:

1. **Flashcards with spaced repetition**, for memorisation. Decks are imported from the AI pipeline (`flashcard-pipeline.md`).
2. **Daily quizzes** drawn from a reviewed question bank. Scheduling is per **concept**, so each review shows a different variant of the question.
3. **Deadline countdowns**, from the course material or entered manually.
4. **A daily checklist** of reviews, quizzes, required readings and study tasks.
5. **Claude as a tutor**, a chat built into the app that knows your course material and what you've been getting wrong.

---

## 1. Core features

### 1.1 Flashcards (memorisation)
- Import `deck.json`. Re-imports match cards by `id`, so review history is kept.
- Card types: `basic`, `cloze`, `reverse`, with optional `extra` text shown after the answer.
- KaTeX for maths, Markdown in cards.
- Organisation: **Module → Lecture → Cards**, plus tag filters.
- Review: show the front, reveal the back, then rate **Again / Hard / Good / Easy**.
- **Scheduler: FSRS**, via the `ts-fsrs` library. Desired retention defaults to 0.9. SM-2 is available as a fallback.
- Daily limits for new cards (default 20) and reviews, set per module.
- Suspend, flag and edit cards. **"Report problem"** sends the card to the pipeline's feedback queue. **"Ask Claude"** opens the tutor with the card loaded.

### 1.2 Daily quiz (understanding)
Each concept has its own FSRS schedule, separate from the schedule for its flashcards.

- **Picking a question.** When a concept is due, the app picks one of its question variants. It chooses the variant that has never been seen or was seen least recently, preferring a difficulty that suits the concept's current stability: easier variants while the concept is new, harder ones once it's well established.
- **Grading:**
  - `mcq`: marked automatically. The explanation for each distractor is shown after answering.
  - Written types (`short_answer`, `explain`, `scenario`, `compare`, `essay_plan`): **Claude marks the answer against the marking points**. It returns which points were met, the model answer, and a short comment. The user can always override the mark.
  - `calculation`: Claude checks the final answer and the method. The user can override.
  - Offline, or by choice: self-marking against the model answer.
- **Result → FSRS rating for the concept:**

  | Result | Rating |
  |---|---|
  | Wrong / no marking points met | Again |
  | Partial (some marking points met) | Hard |
  | Correct | Good |
  | Correct and quick, and the user marks it as easy | Easy |

- **After a wrong answer:** the app offers **"Review related cards"**, which are the concept's linked flashcards, shown right away. It also offers **"Ask Claude"**, which opens the tutor with the question, the user's answer and the marking scheme already loaded.
- **Running low on variants:** when all of a concept's variants have been seen, the least recent one is reused. The concept is also added to `feedback.json → topup`, so the pipeline can generate more.
- **Daily quiz size:** set as a number of questions per day (default 10) or as a share of the time budget.
- **Assessment mode:** within N days of a midterm or exam (default 21), concepts in that assessment's scope get priority. A **mock exam** option builds a timed set that matches the assessment's format mix, for example 60% MCQ and 30% short answer.

### 1.3 Deadlines and countdowns
- Sources:
  - **Extracted:** `deadlines.json` from the pipeline. Items marked `confidence: "inferred"` show a "Confirm" badge until checked.
  - **Manual:** add or edit a deadline at any time. Manual edits override extracted values.
- Live countdowns: days, plus hours and minutes when less than 48 h remain. Urgency colours: more than 14 days neutral, 7–14 days amber, under 7 days red, overdue grey with a "Submitted?" checkbox.
- Fields: title, module, type, due datetime, timezone, weighting, submission link, lectures covered (for exams), notes, status.
- **Coursework milestones (optional):** steps counted back from the due date, for example research at −21 d, draft at −10 d, final edit at −3 d. Each milestone appears in the daily checklist on its day.
- Calendar view, and `.ics` export so deadlines also appear in your usual calendar app.

### 1.4 Daily checklist ("Today")
Generated each day in your timezone. Items are built in this order:

1. **Carried over:** unfinished items from previous days.
2. **Flashcard reviews:** due cards per module.
3. **Daily quiz:** due concepts per module, shown as "Quiz — 10 questions (MOD101)".
4. **New cards:** the day's allowance per module.
5. **Required readings:** due within the look-ahead window (default 3 days), so you read before the lecture.
6. **Deadline milestones** due today.
7. **Assessment prep:** a mock exam or extra quiz on weak concepts, for assessments within the assessment-mode window.
8. **Recommended readings:** optional, collapsed by default.
9. **Your own tasks.**

**Workload cap.** You set a daily time budget. Each item has an estimated time:
- flashcard reviews: about 8 s per card
- new cards: about 25 s per card
- MCQs: about 45 s each
- written questions: about 3 min each
- readings: page count × minutes per page

If the total goes over the budget, optional items are moved to later days. Required items are never dropped silently; the app shows a warning instead. Readings can be marked **Done**, **Skimmed** or **Skipped**.

#### Example "Today" page

```
Monday 19 October                          Study time: ~1h 55m / 2h budget

⏳ COUNTDOWNS
  MOD101 Lab Report 2 ............ 4 days 6 h   (20%)
  MOD101 Midterm ................. 23 days       ← assessment mode on
  MOD204 Essay ................... 17 days       (40%)

☐ Carried over: Read Alberts Ch. 11, pp. 595–610 (MOD101)       ~25 min
☐ Review 34 due cards — MOD101                                   ~5 min
☐ Quiz — 12 questions (MOD101, midterm scope first)              ~20 min
☐ Quiz — 5 questions (MOD204)                                    ~12 min
☐ Learn 20 new cards — MOD101 Week 5                             ~9 min
☐ REQUIRED: Smith (2019), pp. 1–24 — before Wed lecture          ~40 min
☐ Milestone: Lab Report 2 — finish results section               (deferred: over budget ⚠)
☐ (optional) Recommended: Jones Ch. 3
☐ + Add task
```

### 1.5 Claude tutor
A chat page, plus an **"Ask Claude"** button on every card, quiz question, quiz result and reading.

- **Context loaded automatically:**
  - Opened from a card or question: the item itself, your answer, the marking scheme and the cited source slides.
  - Always included: the module glossary, your weakest concepts (lowest stability, most lapses), and upcoming assessments.
- **Grounded in your material.** Claude answers from the course material first and cites slides or pages. It says clearly when it is going beyond the course, or when the course differs from standard treatments.
- **Modes** (a toggle in the chat):
  - **Explain:** direct explanations.
  - **Socratic:** guides you to the answer with questions.
  - **Quiz me:** asks follow-up questions on the topic and marks your answers.
- **Same notation rules as the pipeline:** "full term (abbreviation)", using the glossary's forms.
- **Proposing new items.** When a chat reveals a gap, Claude can propose a new card or question. Proposals go to a **Proposed** queue in the app. Each one can be accepted (it goes into `feedback.json → proposed`, so the pipeline's Reviewer checks it before it joins the bank), edited, or discarded.
- **Academic integrity.** For deadlines of type `coursework`, Claude helps you understand the material and gives feedback on your reasoning, but does not write or rewrite assessed work.
- **History:** conversations are saved per module and can be searched.

---

## 2. Data model

```
Module           id, code, name, colour, timezone, settings (limits, retention, quiz size)
Lecture          id, module_id, week, title, date?
Concept          id, module_id, lecture_id, summary, importance, assessments[]
ConceptState     concept_id, FSRS fields (due, stability, difficulty, reps, lapses, state…)
Card             id, module_id, lecture_id, concept_id, type, front, back, extra, tags[],
                 source {file, location}, importance, suspended, flagged
CardState        card_id, FSRS fields
CardReviewLog    id, card_id, rating, reviewed_at, duration_ms
Question         id, module_id, lecture_id, concept_ids[], type, difficulty, stem,
                 options?, model_answer, marking_points[], source, assessments[], flagged
QuestionAttempt  id, question_id, concept_id, answered_at, response, points_met[],
                 grader (auto/claude/self), overridden, rating, duration_ms
GlossaryEntry    id, module_id, term, abbreviation, canonical, standard|module_specific
Deadline         id, module_id, title, type, due_at (UTC), timezone, weighting,
                 submission_url, covers_lectures[], origin (extracted/manual),
                 confidence, confirmed, status, notes
Milestone        id, deadline_id, title, due_on, est_minutes, done
Reading          id, module_id, lecture_id?, citation, pages, required, read_by,
                 est_minutes, status (todo/done/skimmed/skipped)
Task             id, title, module_id?, due_on?, recurrence?, est_minutes, done
DailyPlan        date, items[] {kind, ref_id, est_minutes, optional, carried_over, done}
TutorThread      id, module_id, title, mode, context_ref {kind, id}?, created_at
TutorMessage     id, thread_id, role, content, created_at, tokens_in, tokens_out
Proposal         id, kind (card/question), payload, origin_thread_id, status
FeedbackItem     id, kind (reported/topup/proposed), ref_id, comment, exported
Settings         daily_budget_min, new_cards_per_day, quiz_per_day, desired_retention,
                 assessment_mode_days, reading_lookahead_days, minutes_per_page, timezone
```

All datetimes are stored in UTC and shown in your timezone. Deadlines keep their original timezone.

---

## 3. Key logic

### 3.1 Flashcard scheduling
```
on rate(card, rating):
    state = fsrs.repeat(cardState, now)[rating]
    save CardState; append CardReviewLog
```

### 3.2 Concept scheduling and question selection
```
due_concepts = ConceptState where due <= end_of_today
if assessment within assessment_mode_days:
    sort concepts in its scope first, then by lowest stability
take quiz_per_day concepts

for concept in due_concepts:
    variants = questions for concept, excluding flagged
    target_difficulty = 1 if stability < 7d, 2 if < 30d, else 3
    pick variant: never seen > least recently seen;
                  tie-break by closeness to target_difficulty
    if all variants seen: add concept to feedback topup

on graded(attempt):
    rating = map(points_met / total_points, user override)
    state = fsrs.repeat(conceptState, now)[rating]
    save ConceptState, QuestionAttempt
    if rating == Again: offer related cards + Ask Claude
```

### 3.3 Daily plan generation (runs at local midnight, or on first open)
```
items  = carry_over(unfinished items from previous days)
items += card reviews per module
items += quiz per module (from 3.2)
items += new cards per module (raised in assessment mode)
items += required readings where read_by <= today + lookahead
items += milestones due today
items += assessment prep (mock exam / weak concepts) if in assessment mode
items += recommended readings (optional), user tasks
order: carried over → required → due date → importance
apply workload cap: defer optional items, warn if required items exceed budget
```

### 3.4 Claude grading call
```
input:  question stem, model answer, marking points, user response, glossary
output: { points_met: [indices], comment, suggested_rating }
```
This call uses a small structured prompt. The marking points and source are passed in, so Claude marks against the scheme rather than its own judgement.

### 3.5 Countdown
Computed on the client from `due_at`. Updates every minute, or every second in the final hour.

---

## 4. Screens

| Screen | Contents |
|---|---|
| **Today** | Countdown strip, checklist, progress, "Start" buttons for reviews and quizzes |
| **Review** | Flashcard front/back, rating buttons, keyboard shortcuts (space, 1–4), Report, Ask Claude |
| **Quiz** | One question at a time, answer input (options, text, LaTeX), marking result, model answer, override, related cards, Ask Claude |
| **Mock exam** | Timed set matching the assessment format, marked at the end, with a per-concept breakdown |
| **Decks** | Modules → lectures → concepts → cards and questions; mastery per concept |
| **Deadlines** | List and calendar, countdowns, confirm inferred items, milestones, `.ics` export |
| **Readings** | By module and week, status filters, required vs recommended |
| **Tutor** | Threads per module, mode toggle, context chip showing what's loaded, proposals queue |
| **Glossary** | Searchable notation per module, module-specific entries highlighted |
| **Import / Export** | Upload pipeline JSON with a diff preview before applying; export `feedback.json` |
| **Stats** | Reviews per day, retention, concept mastery per assessment scope, review load forecast, API spend this month |
| **Settings** | Timezone, budget, limits, retention, quiz size, assessment-mode window, model choice |

Mobile-first, installable as a PWA. Flashcards, MCQ quizzes and self-marking work offline. Claude marking and the tutor need a connection; written answers given offline are queued and marked when back online.

---

## 5. Tech stack (single user)

| Layer | Choice | Notes |
|---|---|---|
| Frontend | React + TypeScript (Vite or Next.js), Tailwind | PWA |
| SRS | `ts-fsrs` | Used for both cards and concepts |
| Rendering | KaTeX, Markdown | |
| Backend | Small Node server (Next.js API routes or Hono) | Holds the API key and calls Claude |
| Database | SQLite | One file, easy to back up |
| Claude | Claude API via the official TypeScript SDK | Streaming for the tutor, structured output for grading |
| Hosting | Run locally, **or** a small cloud host if you want phone access | If hosted, put the whole app behind a single password so nobody else can use your API key |

### Claude API notes
- **The API key lives only on the server** (environment variable) and is never sent to the browser.
- **Prompt caching:** each module's course material (glossary plus extracted slide text) is the same at the start of every tutor and grading call, so it's sent as a cached prefix. This cuts cost and response time a lot.
- **Model choice:** a smaller, faster model for grading, a stronger model for the tutor. Both can be changed in Settings.
- **Spend tracking:** token counts are logged per call, with the monthly total shown in Stats and an optional monthly cap.

### Minimal API
```
POST /import/{deck|questions|concepts|glossary|deadlines|readings}
GET  /export/feedback
GET  /today                      PATCH /plan/items/:id
GET  /review/next?module=        POST  /review/:cardId      {rating, duration_ms}
GET  /quiz/next?module=&mode=    POST  /quiz/:questionId    {response}
POST /quiz/:attemptId/override   {rating}
GET  /deadlines                  POST  /deadlines           PATCH /deadlines/:id
GET  /readings                   PATCH /readings/:id
POST /tutor/threads              POST  /tutor/threads/:id/messages (streamed)
GET  /proposals                  PATCH /proposals/:id       {accept|edit|discard}
GET  /stats                      GET   /calendar.ics
```

---

## 6. Integration with the pipeline

```
course material ──► pipeline (Extractor → Card/Question Creators ⇄ Reviewers → Auditor)
                         │
   deck.json, question-bank.json, concepts.json, glossary.json,
   deadlines.json, readings.json
                         │
                         ▼
           Import (diff preview, confirm inferred items)
                         │
                         ▼
   Cards  ·  Concepts + Questions  ·  Glossary  ·  Deadlines  ·  Readings
                         │
                         ▼
     Today → Reviews / Quizzes / Readings / Tutor
                         │
                         ▼
   feedback.json (reported items, top-up requests, tutor proposals)
                         │
                         └──► pipeline (next run)
```

- Re-importing matches on stable ids. Edited items keep their history. Removed items are suspended, not deleted.

---

## 7. Build order

Midterms are close, so the quiz is part of the first version.

**MVP (before midterms)**
1. Import cards, concepts, questions and the glossary.
2. Flashcard review with FSRS.
3. Daily quiz with concept-level FSRS: MCQ auto-marking plus self-marking for written answers.
4. Deadlines with countdowns. Today page with checklist and carry-over.
5. Runs locally with SQLite.

**v2**
- Claude marking of written answers.
- Claude tutor: contextual "Ask Claude", modes, proposals queue.
- Assessment mode and mock exams.
- Workload cap with deferral, milestones, `.ics` export.

**v3**
- Hosted with a password for phone access, offline queue.
- `feedback.json` export and pipeline top-up loop.
- FSRS optimiser fitted to your review history; stats and forecasts.
