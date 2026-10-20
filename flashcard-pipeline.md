# AI Flashcard & Question Bank Pipeline for University Modules

A multi-agent workflow that turns lecture material into two outputs:

1. **Flashcards.** Short, self-contained cards for memorising facts, terms and definitions, reviewed with spaced repetition.
2. **A question bank.** Quiz-style questions, with several variants per concept, used for the daily quizzes in the study app (see `study-app-spec.md`).

Each lecture or topic gets its own **Creator** agents (one for cards, one for questions), and each Creator's work is checked by a separate **Reviewer** agent. An **Orchestrator** coordinates the process. An **Extractor** pulls deadlines, readings and a notation glossary from the course material, and a **Module Auditor** checks the whole module for coverage and consistency.

---

## 1. Goals

- **Answerable without context.** A subject expert who never attended the module should be able to answer every card and question. Nothing depends on the lecturer's arbitrary letters, abbreviations or slide layout.
- **Accurate to the course material.** The lecture slides and notes decide what is taught and examined. Answers must be supported by them.
- **Flashcards are for memorisation.** They are atomic, unambiguous and fast to review.
- **Questions are for understanding.** They test application, explanation and problem-solving, in formats that match the module's real assessments.
- **Nothing is accepted on its author's word.** Every card and question is checked by an independent Reviewer.
- **Assessments come first.** Lectures covered by the nearest midterm or exam are processed before the rest.

---

## 2. Inputs

| Input | Required | Notes |
|---|---|---|
| Lecture slides / notes (per lecture) | Yes | PDF, PPTX, DOCX or Markdown. One folder per lecture. |
| Module handbook / syllabus | Strongly recommended | Learning outcomes, assessment info, reading list, deadlines. |
| Assessment details | Strongly recommended | For each midterm or exam: format (MCQ, short answer, problems, essay), the lectures it covers, and its date. Set in `pipeline.config.json`. |
| Required / recommended readings | Optional | Used for the daily reading checklist. |
| Past papers / sample questions | Optional | Used to match the style and difficulty of the question bank. |
| User-supplied deadlines | Optional | Merged with the extracted deadlines. The user's entry wins if they conflict. |
| `feedback.json` from the app | Optional | Cards or questions the user reported as wrong, concepts that need more question variants, and new cards proposed in tutor chats. |

### Suggested folder layout

```
module-CODE/
├── handbook/                   # syllabus, assessment briefs, reading list
├── lectures/
│   ├── week01-intro/
│   └── ...
├── past-papers/
├── output/
│   ├── glossary.json           # notation glossary (built first)
│   ├── week01-intro/
│   │   ├── concept-map.json
│   │   ├── cards.draft.json
│   │   ├── cards.review.r1.json
│   │   ├── cards.final.json
│   │   ├── questions.draft.json
│   │   ├── questions.review.r1.json
│   │   ├── questions.final.json
│   │   └── flagged.json        # items needing human attention
│   ├── module-audit.json
│   ├── concepts.json           # → study app (concept-level scheduling)
│   ├── deck.json               # → study app (flashcards)
│   ├── question-bank.json      # → study app (daily quizzes)
│   ├── deadlines.json          # → study app
│   ├── readings.json           # → study app
│   └── deck.anki.tsv           # optional Anki export
└── pipeline.config.json
```

---

## 3. Agents and roles

```
                     ┌──────────────────┐
                     │   Orchestrator   │
                     └────────┬─────────┘
                              ▼
                  ┌───────────────────────┐
                  │ Extractor (runs first)│  glossary, deadlines, readings
                  └───────────┬───────────┘
                              ▼
        Lectures, ordered by nearest assessment, in parallel batches
     ┌────────────────────────┼────────────────────────┐
     ▼                        ▼                        ▼
  Lecture 1                Lecture 2       ...      Lecture N
  ┌─────────────────────────────────────────┐
  │ A. Card Creator ──► Card Reviewer       │  concept map + flashcards
  │        ▲  revise ≤2 rounds   │          │
  │        └─────────────────────┘          │
  │ B. Question Creator ──► Question Reviewer│  question bank
  │        ▲  revise ≤2 rounds   │          │
  │        └─────────────────────┘          │
  └─────────────────────────────────────────┘
                              ▼
                     ┌─────────────────┐
                     │ Module Auditor  │  coverage, duplicates, glossary
                     └────────┬────────┘  consistency, cross-lecture items
                              ▼
                     Human review → Export
```

### 3.1 Orchestrator
- Reads `pipeline.config.json`. Runs the **Extractor** first, because every Creator needs the glossary.
- **Orders lectures by the nearest assessment that covers them.** For example, if the midterm covers weeks 1–5, those lectures go first.
- For each lecture:
  - **Stage A:** Card Creator, then Card Reviewer.
  - **Stage B:** Question Creator, then Question Reviewer. Stage B starts once Stage A has a reviewed concept map.
- Every review uses a **new Reviewer instance**. Reviewers never see the Creator's reasoning.
- Caps the revise/review loop at 2 revision rounds per stage.
- Runs the **Module Auditor**, then writes the exports and a run summary: cards and questions accepted, rejected and flagged per lecture.
- **Top-up mode:** when `feedback.json` lists concepts that are running low on unseen question variants, it runs only the Question Creator and Question Reviewer for those concepts.

### 3.2 Extractor (runs first)
Reads the handbook, assessment briefs and all lecture slides, and produces three things.

- **Notation glossary (`glossary.json`).** Every abbreviation and symbol used in the module, with:
  - its full term
  - whether it is `standard` (used the same way across the field) or `module-specific` (the lecturer's own choice)
  - where it is defined
  - the canonical way to write it, for example `marginal propensity to consume (MPC)` or `association constant (Kₐ in this module)`

  Creators must use these forms exactly.
- **Deadlines:** title, type, date and time, timezone, weighting, submission method, the lectures it covers (for exams and midterms), and the source location. Ambiguous dates are resolved from the semester calendar and marked `confidence: "inferred"`.
- **Readings:** citation, chapters or pages, required or recommended, the linked week or lecture, a read-by date (default: before that lecture), and the source location.

Inferred dates and module-specific notation are shown to the user for confirmation.

### 3.3 Card Creator (one per lecture)
1. **Concept map:** 8–20 concepts, each with a stable id, a one-line summary, its source location, and an importance rating (`core` / `supporting` / `detail`).
2. **Flashcards** for the facts that need memorising (terms, definitions, key facts, formulas), following §4.
3. Every card cites its source location and uses the glossary's canonical notation.
4. Anything unclear or contradictory in the source goes in `flagged`, with no card written for it.

### 3.4 Card Reviewer (fresh instance per round)
Follows the **blind-answer test**, then the rubric in §5.1. It gives each card a verdict of `accept`, `revise` or `reject`, and also checks that the concept map covers the source. It does not rewrite cards itself.

### 3.5 Question Creator (one per lecture)
Works from the reviewed concept map, the source material, the glossary, and the module's assessment formats. It writes **question variants per concept** following §6, and every question cites its source.

### 3.6 Question Reviewer (fresh instance per round)
Follows the blind-answer test, then the rubric in §6.3. It checks correctness, that the variants are genuinely different from each other, that they match the assessment format, and that the marking schemes are usable.

### 3.7 Module Auditor (runs after all lectures)
- Checks coverage against the learning outcomes and past papers, for both cards and questions.
- Finds duplicate and near-duplicate cards across lectures.
- Checks notation against the glossary, flagging any term written differently from its canonical form.
- Proposes **cross-lecture questions** (compare, relate, synthesise) and cross-lecture cards. These also go through a Reviewer.

---

## 4. Flashcard rules (given to every Card Creator)

Flashcards are for memorisation. Understanding, application and explanation go in the question bank.

1. **Answerable without context.** A subject expert who never saw these lectures must be able to answer the card. Avoid prompts like "What does K represent?" or "What are the three factors from slide 12?"
2. **Write the full term and the abbreviation together, on both sides of the card.** Write `marginal propensity to consume (MPC)`, never `MPC` alone, even for well-known abbreviations. Module-specific notation is marked as such, for example `association constant (Kₐ in this module)`. Always use the glossary's canonical form.
   - **Exception:** when the card is testing the abbreviation itself ("What does MPC stand for?"), the full term goes only on the back.
3. **Name course-specific frameworks.** If something exists only in this module, such as the lecturer's own model, the prompt names it explicitly, for example "In the Smith four-stage model of…". It must not rely on the student knowing which lecture the card came from.
4. **One fact per card.** No "list all X" cards. Split them up, or use one cloze per item.
5. **Unambiguous.** Only one correct answer should fit.
6. **Short answers.** Aim for under about 15 words. Longer explanations go in `extra`, which is shown after the answer.
7. **Card types:** `cloze` (definitions, key facts), `basic` (Q→A), and `reverse` (term↔definition where both directions matter).
8. **Maths in LaTeX** (`\( ... \)`), with symbols defined in words, following rule 2.
9. **Nothing beyond the source.** General-knowledge context may go in `extra`, labelled as such.
10. **No trivia.** Target roughly 15–40 cards per lecture, scaled to how much there is to memorise.

### Card schema

```json
{
  "id": "MOD101-W03-C014",
  "module": "MOD101",
  "lecture": "week03-membrane-transport",
  "concept_id": "MOD101-W03-K05",
  "type": "cloze",
  "front": "{{c1::Facilitated diffusion}} moves solutes down their concentration gradient through carrier or channel proteins without using ATP.",
  "back": "",
  "extra": "",
  "tags": ["MOD101::Week03::Transport"],
  "source": { "file": "lectures/week03/slides.pdf", "location": "slide 12" },
  "importance": "core",
  "status": "draft"
}
```

---

## 5. Card review

### 5.1 Blind-answer test, then rubric
1. **Blind pass.** The Reviewer gets only the card fronts, with no source and no backs, and answers each one as a subject expert would.
2. **Compare.** The Reviewer's blind answer is compared with the card's back:
   - It can't answer, or asks "which K?" → hidden context. The card fails `context_free`.
   - It gives a different valid answer → ambiguous. The card fails `clarity`.
3. **Source pass.** The Reviewer checks each card against the source and the rubric below.

| Criterion | Question the Reviewer asks |
|---|---|
| **Context-free** | Could an expert answer this without the lectures? (blind pass) |
| **Notation** | Are terms written in the glossary's canonical "full term (abbreviation)" form on both sides? |
| **Accuracy** | Does the cited source support this? Is the cited location correct? |
| **Atomicity** | Does the card test exactly one fact? |
| **Clarity** | Is there only one correct answer? (blind pass) |
| **Brevity** | Can it be recalled in a few seconds? |
| **Value** | Is this worth memorising for months? |
| **Duplication** | Is it already covered by another card? |

**Lecture-level checks:** every `core` concept that has something to memorise has at least one card, and the concept map covers the source.

### 5.2 Review output schema (cards and questions)

```json
{
  "lecture": "week03-membrane-transport",
  "stage": "cards",
  "round": 1,
  "items": [
    { "id": "MOD101-W03-C014", "verdict": "accept" },
    { "id": "MOD101-W03-C015", "verdict": "revise",
      "failed": ["context_free"],
      "blind_answer": "Unclear — 'the pump' could be several transporters.",
      "feedback": "Name it: 'sodium–potassium pump (Na⁺/K⁺-ATPase)'." },
    { "id": "MOD101-W03-C016", "verdict": "reject",
      "failed": ["accuracy"],
      "feedback": "Slide 14 says 3 Na⁺ out / 2 K⁺ in; card has them reversed." }
  ],
  "missing_concepts": [
    { "summary": "Secondary active transport (symport/antiport)", "source": "slides 18–19" }
  ],
  "overall": "revise"
}
```

---

## 6. Question bank

### 6.1 Purpose
The study app schedules **concepts**, not individual questions. When a concept is due, the app shows a question variant for that concept that the user hasn't seen recently. A small set of genuinely different variants per concept is enough for a semester, because a concept the user knows well comes up only every few weeks.

### 6.2 Question rules (given to every Question Creator)
1. **Number of variants:**
   - `core` concepts: 4–5 variants
   - `supporting` concepts: 2–3 variants
   - `detail` concepts: 0–1 variants

   Concepts covered by the next assessment get the higher end of each range.
2. **Variants must be genuinely different.** Each variant should change the scenario, the numbers, the angle (cause, effect, comparison, application), or the direction of reasoning. Rewording the same question doesn't count.
3. **Match the assessment format.** Weight question types by how the relevant assessment is actually set:
   - `mcq`: one best answer; distractors based on common misconceptions
   - `short_answer`: 1–3 sentences
   - `calculation`: a worked problem with numbers
   - `explain`: why or how
   - `compare`: X vs Y
   - `scenario`: applying a concept to a new case
   - `essay_plan`: outline an argument, with key points and evidence
4. **Same context and notation rules as flashcards** (§4 rules 1–3). Questions must be self-contained and use the glossary's forms.
5. **Grounded in the source.** The model answer must be supported by the cited material. Scenarios can be new, but the principles they test must come from the lectures.
6. **Every question has a marking scheme.** For written answers, list 2–5 marking points that the app (or Claude) marks against. For MCQs, include a short explanation of why each distractor is wrong.
7. **Difficulty:** 1 (recall and apply), 2 (multi-step), or 3 (exam-hard). Spread the difficulty across each concept's variants.

### 6.3 Question Reviewer rubric
The Reviewer first runs a blind pass: it answers every question without seeing the source or the model answers. It then checks each question against the following:

| Criterion | Question the Reviewer asks |
|---|---|
| **Context-free** | Could an expert answer this without the lectures? |
| **Correctness** | Is the model answer right and supported by the source? |
| **Single best answer** | For MCQs, is exactly one option correct? Is every distractor clearly wrong but plausible? |
| **Variant distinctness** | Is this variant genuinely different from the others for the same concept? |
| **Format fit** | Does it look like a question from this module's real assessment? |
| **Markable** | Could a grader apply the marking scheme consistently? |
| **Notation** | Does it use the glossary's canonical forms? |
| **Difficulty** | Is the stated difficulty accurate? |

### 6.4 Question schema

```json
{
  "id": "MOD101-W03-Q031",
  "module": "MOD101",
  "lecture": "week03-membrane-transport",
  "concept_ids": ["MOD101-W03-K07"],
  "variant_of": "MOD101-W03-K07",
  "type": "scenario",
  "difficulty": 2,
  "stem": "A cell is treated with ouabain, which inhibits the sodium–potassium pump (Na⁺/K⁺-ATPase). Predict what happens to glucose uptake via the sodium–glucose cotransporter (SGLT) over the next hour, and explain why.",
  "options": null,
  "model_answer": "Glucose uptake falls. With the pump inhibited, the Na⁺ gradient dissipates, removing the driving force SGLT uses to move glucose against its gradient.",
  "marking_points": [
    "States glucose uptake decreases",
    "Pump inhibition dissipates the Na⁺ gradient",
    "SGLT depends on the Na⁺ gradient (secondary active transport)"
  ],
  "source": { "file": "lectures/week03/slides.pdf", "location": "slides 14, 18–19" },
  "assessments": ["MOD101-MIDTERM"],
  "status": "draft"
}
```

### 6.5 Concepts export (`concepts.json`)

```json
{
  "id": "MOD101-W03-K07",
  "module": "MOD101",
  "lecture": "week03-membrane-transport",
  "summary": "Secondary active transport uses an existing ion gradient to move another solute against its gradient.",
  "importance": "core",
  "card_ids": ["MOD101-W03-C020", "MOD101-W03-C021"],
  "question_ids": ["MOD101-W03-Q031", "MOD101-W03-Q032", "MOD101-W03-Q033", "MOD101-W03-Q034"],
  "assessments": ["MOD101-MIDTERM"]
}
```

---

## 7. Review loop (same for cards and questions)

```
Creator drafts → Reviewer (round 1: blind pass → source pass)
  ├─ all accept and coverage OK → final
  └─ otherwise → Creator revises only the flagged items and fills missing concepts
        → NEW Reviewer instance (round 2)
          ├─ OK → final
          └─ still failing → Creator revises once more → NEW Reviewer (round 3, final)
                └─ items still failing → flagged.json for the human
```

- At most **2 revision rounds** per stage. After that, failing items go to the human.
- Rejected items are removed. They are not silently rewritten.
- Accepted items are frozen.

---

## 8. Agent prompt templates

### Extractor

```
From the handbook, assessment briefs and ALL lecture slides for [MODULE], produce:

1. glossary: every abbreviation and symbol, with full term, standard vs
   module-specific, where defined, and canonical form, written
   "full term (abbreviation)" or "full term (symbol in this module)".
2. deadlines: title, type, due datetime, timezone, weighting, submission
   method, lectures covered (for exams/midterms), source location,
   confidence (explicit/inferred).
3. readings: citation, pages, required/recommended, linked week/lecture,
   read_by date, source location.

Semester calendar: [week 1 start, reading weeks, exam period].
Never invent dates; use null with a reason if a date cannot be determined.
Output JSON: { "glossary": [...], "deadlines": [...], "readings": [...] }
```

### Card Creator

```
You are creating memorisation flashcards for [MODULE CODE – NAME], [LEVEL],
lecture: [LECTURE TITLE].

Source material (the source of truth for what is taught): [files]
Learning outcomes: [from handbook]
Notation glossary (use these canonical forms exactly): [glossary.json]

Step 1. Concept map: 8–20 concepts with id, one-line summary, source
location, importance (core/supporting/detail).
Step 2. Flashcards for facts that need memorising, following the rules
below. Every card cites its source. Understanding/application belongs in the
question bank, not here.
Step 3. List unclear or contradictory points under "flagged" — no cards for them.

Key test for every card: could a subject expert who never attended these
lectures answer it? Always write "full term (abbreviation)" on both sides.

[FLASHCARD RULES from §4]

Output JSON: { "concept_map": [...], "cards": [...], "flagged": [...] }
```

### Card Reviewer

```
You are an independent reviewer of flashcards for [MODULE], lecture [LECTURE].
You did not write these cards. Be strict: a bad card costs the student
review time for months.

Pass 1 (blind): You are given ONLY the card fronts. Answer each as a subject
expert who never attended this module. Record your answer or "cannot
answer — reason".
Pass 2 (source): You are now given the backs, the source material, the
concept map and the glossary. For every card: compare with your blind
answer, then apply the rubric. Verdict: accept / revise / reject, with
failed criteria and specific feedback. Do NOT rewrite cards.
Then check concept-map coverage of the source; list missing concepts.

[RUBRIC from §5.1]
Output JSON matching the review schema.
```

### Question Creator

```
You are writing a quiz question bank for [MODULE], lecture [LECTURE].

Reviewed concept map: [concept-map.json]
Source material: [files]
Glossary: [glossary.json]
Assessment formats: [e.g. "Midterm: 30 MCQ + 3 short answer, covers weeks 1–5"]
Past paper examples: [if any]

For each concept, write variants following the rules below. Variants must
differ in scenario, numbers, angle or direction of reasoning, not wording.
Weight question types toward the assessment format. Every question needs a
model answer, marking points (or distractor explanations for MCQs), a
difficulty rating, and a source citation. Questions must be answerable by a
subject expert without the lectures; use the glossary's canonical forms.

[QUESTION RULES from §6.2]
Output JSON: { "questions": [...], "flagged": [...] }
```

### Question Reviewer

```
You are an independent reviewer of quiz questions for [MODULE], lecture
[LECTURE]. You did not write them.

Pass 1 (blind): You are given ONLY the stems (and options for MCQs). Answer
each as a subject expert without the lectures.
Pass 2 (source): You are now given model answers, marking points, source,
glossary, and assessment formats. For every question: compare with your
blind answer, then apply the rubric. Verdict: accept / revise / reject, with
specific feedback. Do NOT rewrite questions.
Also check: does every core concept have enough distinct variants?

[RUBRIC from §6.3]
Output JSON matching the review schema.
```

### Revision round (either Creator)

```
Revise ONLY the items marked "revise", using the reviewer's feedback, and
add items for any listed missing concepts. Do not change accepted items.
Rejected items are removed; replace them only if the concept still needs
coverage, with a new id.
```

### Module Auditor

```
Audit the full module [MODULE]: all accepted cards, questions, concept
maps, glossary, learning outcomes, assessments and past papers.
1. Map each learning outcome to the cards and questions that cover it; list gaps.
2. Check each assessment's scope has enough question variants.
3. Find duplicate or near-duplicate cards and questions across lectures.
4. Flag any term not written in its glossary canonical form.
5. Propose up to [N] cross-lecture questions and cards.
Output JSON: { "outcome_coverage", "assessment_coverage", "duplicates",
"notation_issues", "proposed_items" }
```

---

## 9. Human review step

Before export, the user sees:
- `flagged.json` from every lecture.
- Glossary entries marked `module-specific`, to confirm the notation.
- Deadlines and readings marked `inferred`.
- A spot-check sample of about 10% of accepted cards and questions per lecture.

---

## 10. Feedback loop from the app

The study app exports `feedback.json` containing:
- `reported`: cards or questions the user marked as wrong or unclear, with a comment. These go back to the relevant Creator, followed by a Reviewer.
- `topup`: concepts whose unseen variants are running low. These are run through the Question Creator in top-up mode.
- `proposed`: cards or questions suggested during tutor chats. These go straight to a Reviewer, and on to the Creator for fixes if needed.

---

## 11. Export

| File | Contents | Used by |
|---|---|---|
| `deck.json` | Accepted flashcards | Study app |
| `question-bank.json` | Accepted questions | Study app |
| `concepts.json` | Concepts with linked card and question ids, plus assessment scope | Study app |
| `glossary.json` | Notation glossary | Study app (glossary page, tutor context) |
| `deadlines.json` | Deadlines and assessments | Study app |
| `readings.json` | Readings | Study app |
| `deck.anki.tsv` | Flashcards as `front<TAB>back<TAB>tags` | Anki (optional) |

Ids are stable across re-runs. When a lecture is updated, its existing items are updated in place, so the review history in the app is kept.

---

## 12. `pipeline.config.json` (example)

```json
{
  "module": { "code": "MOD101", "name": "Cell Biology", "level": "Year 2" },
  "semester": {
    "week1_start": "2026-09-14",
    "reading_weeks": [6],
    "exam_period": ["2026-12-07", "2026-12-18"],
    "timezone": "Europe/London"
  },
  "assessments": [
    {
      "id": "MOD101-MIDTERM",
      "date": "2026-11-11T10:00",
      "covers_lectures": ["week01", "week02", "week03", "week04", "week05"],
      "format": { "mcq": 0.6, "short_answer": 0.3, "calculation": 0.1 }
    },
    {
      "id": "MOD101-FINAL",
      "date": "2026-12-10T14:00",
      "covers_lectures": "all",
      "format": { "short_answer": 0.4, "explain": 0.3, "essay_plan": 0.3 }
    }
  ],
  "cards_per_lecture": { "min": 15, "max": 40 },
  "variants": { "core": [4, 5], "supporting": [2, 3], "detail": [0, 1] },
  "max_review_rounds": 2,
  "parallel_lectures": 6,
  "human_spot_check_rate": 0.1
}
```
