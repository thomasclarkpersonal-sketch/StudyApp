# Project Seed Specification (System Service Request)

> Filled in from `flashcard-pipeline.md` and `study-app-spec.md`, which should be attached alongside this file. **Unknown** marks anything not yet decided. Items marked *(proposed)* are suggestions to confirm.

## 1. Project Overview ★
* **App name:** Unknown (working name: *Study App*)
* **Problem / opportunity:** Making good flashcards for university modules by hand is slow. Asking an AI for flashcards without a strict process gives vague, overloaded or inaccurate cards that don't match the course. Deadlines, required readings and revision are spread across handbooks, slides and the university's online learning platform, so it's hard to know what to do each day, especially with midterms coming up.
* **Primary goal:** Every day, the student gets one checklist containing:
  * spaced-repetition flashcards for memorisation
  * targeted quiz questions on concepts that are due
  * required readings
  * deadline countdowns

  The cards and questions are generated from the student's own course material by AI agents, and every item is checked by an independent AI reviewer before it reaches the student.
* **Success metrics** *(proposed)*:
  * All lectures covered by the first midterm are processed (cards and question bank reviewed and imported) at least 7 days before the midterm.
  * Flashcard retention stays at 85–90% or higher (measured by FSRS).
  * Fewer than 2% of accepted cards or questions are later reported as wrong.
  * No missed deadlines, and the daily checklist is completed on at least 5 days a week.
  * Every concept in an assessment's scope has been quizzed at least twice before that assessment.
  * Claude API spend stays within the monthly budget (budget Unknown).

## 2. Users & Stakeholders ★

| Role | Who they are | Approx. number | Tech comfort (low / medium / high) | Accessibility or device needs |
| :-- | :-- | :-- | :-- | :-- |
| Primary user | The student (owner), studying their own university modules | 1 | Unknown (assumed medium–high) | Reviews and quizzes mostly on a phone; importing, pipeline runs and tutor chats mostly on a laptop |
| Admin / secondary user | Same person: runs the pipeline, confirms inferred deadlines and notation, reviews flagged items | 1 (same person) | Unknown (assumed medium–high) | Laptop |

* **Other stakeholders:**
  * Module lecturers and the university. They don't use the app, but they own the course material, and the university's academic integrity rules apply to coursework.
  * Anthropic, as the provider of the Claude API that processes the course material.

## 3. Core Features (Story Cards) ★
*Priorities follow the build order in `study-app-spec.md` §7. Must = MVP before midterms, Should = v2, Could = v3.*

| # | As a… | I want to… | So that… | Priority (Must / Should / Could) |
| :-- | :-- | :-- | :-- | :-- |
| 1 | student | run the pipeline on a lecture's slides to produce flashcards, with a separate Creator agent and an independent Reviewer agent (including the blind-answer test) for each lecture | the cards are accurate, atomic and answerable without hidden lecture context | Must |
| 2 | student | have the pipeline produce a reviewed question bank with several genuinely different variants per concept, matching my assessment formats | I can practise understanding, not just recall | Must |
| 3 | student | have an Extractor agent pull a notation glossary, deadlines and readings from the handbook and slides | every card uses consistent "full term (abbreviation)" notation, and my deadlines and readings are captured without retyping | Must |
| 4 | student | have lectures covered by the nearest assessment processed first | my midterm material is ready in time | Must |
| 5 | student | review flagged items, confirm inferred dates and module-specific notation, and spot-check a sample before export | errors the agents couldn't resolve don't reach my deck | Must |
| 6 | student | import the pipeline outputs into the app with a preview of what's new, changed or removed | updates never lose my review history | Must |
| 7 | student | review flashcards with FSRS spaced repetition, with keyboard shortcuts and LaTeX rendering | I memorise facts efficiently | Must |
| 8 | student | get a daily quiz of due concepts, each shown as an unseen question variant, with MCQs marked automatically and written answers self-marked | I practise applying concepts without memorising question wording | Must |
| 9 | student | see deadlines with live countdowns, add or edit them myself, and confirm extracted ones | I never miss a deadline | Must |
| 10 | student | open a "Today" checklist of reviews, quizzes, new cards, required readings and carried-over items | I know exactly what to do each day | Must |
| 11 | student | report a wrong or unclear card or question | it is fixed in the next pipeline run | Must |
| 12 | student | have Claude mark my written quiz answers against the marking points, with the option to override the mark | I get consistent feedback on written answers | Should |
| 13 | student | open a Claude tutor from any card, question or result, with my answer and the source slides already loaded, in Explain, Socratic or Quiz-me mode | I can work through what I got wrong | Should |
| 14 | student | accept, edit or discard cards and questions the tutor proposes, with accepted ones going through the pipeline's Reviewer | gaps found in chats end up in my deck safely | Should |
| 15 | student | switch on assessment mode and take timed mock exams that match the real format | I'm prepared for each midterm or exam specifically | Should |
| 16 | student | set a daily time budget so that optional items move to later days, add coursework milestones, and export deadlines as `.ics` | my workload stays realistic and deadlines appear in my calendar | Should |
| 17 | student | reach the app from my phone (hosted behind a password) and keep studying offline | I can review anywhere | Could |
| 18 | student | export `feedback.json` (reported items, requests for more variants, tutor proposals) to the pipeline | the deck and question bank keep improving | Could |
| 19 | student | fit the FSRS parameters to my own review history and see review-load forecasts | scheduling suits how I actually learn | Could |
| 20 | student | export flashcards to Anki | I'm not locked into the app | Could |

* **Reports & outputs:**
  * **Today page.** The student, daily: the checklist, countdowns and an estimate of study time.
  * **Stats page.** The student, weekly: reviews per day, retention, concept mastery per assessment's scope, review-load forecast, and Claude API spend this month.
  * **Mock exam results.** The student, before each assessment: score broken down by concept.
  * **Pipeline run summary and module audit.** The student, after each pipeline run: items accepted, rejected and flagged per lecture; coverage against learning outcomes and assessment scope.
  * **Notifications** (Could): reviews due, and a deadline within 24 h.
  * **`.ics` calendar feed** of deadlines (Should).

## 4. Key Data
* **Main things to track (nouns):**
  * Modules, Lectures, Concepts and Concept States
  * Flashcards, Card States and Card Review Logs
  * Questions and Question Attempts
  * Glossary Entries
  * Deadlines and Milestones
  * Readings, Tasks and Daily Plans
  * Tutor Threads and Tutor Messages
  * Proposals and Feedback Items
  * Settings

  On the pipeline side: concept maps, draft and final items, review records, flagged items, the module audit and `pipeline.config.json`.

  Full model: `study-app-spec.md` §2; schemas in `flashcard-pipeline.md` §4–6.
* **Sensitive data:**
  * The Claude API key, a secret that must stay on the server.
  * University course material, which is copyrighted and for personal study use only.
  * The student's study performance history and tutor conversations, which are personal data.

  There is no financial or health data, no children's data, and no data about other people.
* **Expected volume:**
  * Modules: Unknown (assumed 4–6 per semester).
  * Per module, roughly 10–12 lectures. That gives about 150–480 flashcards, about 100–200 concepts and about 300–700 question variants.
  * In total, roughly 1,000–3,000 cards and 1,500–4,000 questions per semester.
  * Review logs: about 100–400 reviews a day.
  * History kept across the whole degree (Unknown how many years).
* **Retention / deletion rules:**
  * Review history is kept indefinitely; it is needed for FSRS optimisation.
  * Removed cards and questions are suspended, not deleted.
  * Retention of tutor conversations: Unknown.
  * Pipeline intermediate files (drafts, review rounds): Unknown (proposed: keep until the module ends).

## 5. External Systems & Integrations

| System | What's exchanged | Direction (in / out / both) | How (API, file, email, manual) | Who owns it |
| :-- | :-- | :-- | :-- | :-- |
| Claude API (Anthropic) | Out: course material text, cards and questions to generate or review, student answers, tutor messages. In: generated items, review verdicts, marks, tutor replies | both | API (official TypeScript SDK; streaming for the tutor; prompt caching for course material) | Anthropic; the student's API account |
| Pipeline agent runtime | Runs the Orchestrator, Extractor, Creator, Reviewer and Auditor agents | n/a | Unknown (e.g. Claude Code or the Claude Agent SDK) | Student |
| Pipeline ↔ app | `deck.json`, `question-bank.json`, `concepts.json`, `glossary.json`, `deadlines.json`, `readings.json` into the app; `feedback.json` back out | both | File (JSON import/export) | Student |
| University learning platform | Lecture slides, handbooks, reading lists, past papers | in | Manual download into the pipeline's folder layout | University |
| Calendar app (Google / Apple / Outlook) | Deadlines and milestones | out | `.ics` file or feed | Student |
| Anki | Flashcards | out | TSV file (optional) | Student |

## 6. Existing System & Data Migration
* **What's used today:** Unknown. Presumably lecture slides and personal notes, and possibly Anki or another flashcard app, a calendar and a to-do list.
* **Data to bring across:**
  * Lecture slides, module handbooks, reading lists and past papers for current modules (Unknown how many). These go into the pipeline, not straight into the app.
  * Existing flashcards and review history from other apps: Unknown. Not planned for import.
* **Must the old system keep running during the transition?** Unknown. Assumed yes, informally: the student keeps studying their usual way until the MVP works.
* **Documents to attach:**
  * `flashcard-pipeline.md`: agent roles, card and question rules, rubrics, prompts, schemas.
  * `study-app-spec.md`: features, data model, scheduling logic, screens, stack, build order.
  * Recommended: one sample lecture's slides, one module handbook, and a past paper (if available), to test the pipeline and check the assumptions about assessment formats.
* **What will change for people:** Only the student is affected. Studying moves to a single daily checklist, with flashcards and quizzes made by the AI pipeline instead of by hand. The student is keen on the change; they initiated the project.

## 7. Quality Requirements (Non-Functional)
* **Performance** *(proposed)*:
  * Card flip and rating: under 100 ms.
  * Next card or question: under 300 ms.
  * Today page: loads in under 1 s.
  * Claude marking result: under 10 s.
  * Tutor first token: under 3 s (streamed).
  * Pipeline: one lecture finishes all stages within about 15 minutes.
* **Scale:** One user and one concurrent session. No growth is expected (see Non-Goals).
* **Availability:**
  * MVP: runs locally on the student's laptop.
  * Later: hosted, best effort.
  * Flashcards, MCQ quizzes and self-marking must work offline. Written answers given offline are queued for Claude marking.
* **Security & access:**
  * Locally: no login.
  * When hosted: the whole app sits behind a single password.
  * One role (owner).
  * The API key is held only on the server, as an environment variable, and never sent to the browser.
* **Misuse to guard against:**
  * Honest mistakes: importing the wrong file, overwriting review history. Handled by the import diff preview and stable ids.
  * A stranger finding the hosted URL and running up API spend. Handled by the password and an optional monthly spend cap.
  * Instructions hidden inside course documents (prompt injection). Course material is treated as data, never as instructions to the agents.
* **Privacy & compliance:**
  * None known; only the student's own data is stored.
  * Course material is copyrighted and kept private, never shared or published.
  * Unknown: whether the university's policies allow sending course material to an external AI service. Needs checking.
  * Coursework academic integrity: the tutor must not write or rewrite assessed work.
* **Accessibility:** WCAG 2.2 AA by default. Full keyboard support for review (space, keys 1–4). Urgency in countdowns is never shown by colour alone.
* **Languages, regions, time zones:**
  * English.
  * The daily plan is generated at midnight in the student's current time zone.
  * Deadlines are stored in UTC and keep the university's own time zone (Unknown which), so a 12:00 deadline stays correct when the student travels.
* **Devices & browsers:** A phone (installable PWA) and a laptop, in current Chrome, Safari and Firefox. Exact phone model and operating system: Unknown.

## 8. Technical Preferences & Constraints
* **Target platform:**
  * A mobile-first web app (PWA).
  * A separate multi-agent pipeline that writes JSON files for the app to import.
* **Preferred tech stack:**
  * Frontend: React + TypeScript (Vite or Next.js), Tailwind, KaTeX, Markdown rendering.
  * Spaced repetition: `ts-fsrs`, used for both cards and concepts.
  * Backend: a small Node server (Next.js API routes or Hono).
  * Database: SQLite.
  * AI: Claude API via the official TypeScript SDK.

  This is a recommendation and open to change.
* **Hosting / cloud:** Local for the MVP. Later, a small cloud host with password protection for phone access (provider Unknown).
* **Existing infrastructure, accounts, or licences to reuse:** Unknown. A Claude API account with billing is needed. A Claude.ai subscription is separate from API access.
* **Technologies to avoid:** Unknown.
* **Open to buying instead of building?** Unknown. Anki with add-ons already covers flashcards with FSRS. The parts that existing tools don't cover are:
  * the reviewed AI generation pipeline
  * concept-level quiz scheduling with question variants
  * deadline and reading extraction feeding a daily checklist
  * a tutor grounded in the course material

  A hybrid is possible: Anki for cards, with a custom app for the rest.
* **Products already considered:** Unknown (Anki implied).
* **AI / machine-learning features:**
  * Multi-agent generation of cards and question banks, with independent reviewers and a blind-answer test.
  * Extraction of the notation glossary, deadlines and readings.
  * Marking of written quiz answers against marking points.
  * A course-grounded tutor chat (Explain, Socratic and Quiz-me modes) that can propose new cards and questions.
  * FSRS scheduling, with optional fitting of its parameters to the student's history.

## 9. Project Constraints ★
* **Budget:**
  * Build: Unknown.
  * Monthly running: Unknown. The main cost is Claude API usage (pipeline runs, marking, tutor), plus hosting once deployed. A monthly spend cap is planned.
* **Deadline / key dates:**
  * The MVP (stories 1–11) must be usable before the first midterm, with time left to study. The midterm date is Unknown.
  * Final exam period: Unknown.
* **Who will build it:** Unknown (likely the agent in BUILD mode, with the student reviewing).
* **Who will run and maintain it after launch:** The student.

## 10. Agent Run Settings
* **Mode:** Unknown. Default is **PLAN**. Consider **BUILD** because of the midterm deadline; this needs a code repository, runtime and test runner.
* **Tier:** **Auto**
* **Project type:** **Auto** (expected: business information system + data/ML system)
* **Checkpoint mode:** Unknown. Default is **STRICT**. **ADVISORY** may suit the midterm deadline better.
* **Review depth:** **Standard**
* **Output location:** `./workbook/`
* **Decisions the agent must always ask you about:**
  * anything that adds a paid service, or significantly increases Claude API spend (for example, more review rounds or a larger model)
  * changes to the card rules, question rules or reviewer rubrics
  * sending course material to any third party other than Anthropic
  * anything that could delete or overwrite review history

## 11. Non-Goals (Out of Scope for v1.0)
* No multiple users, accounts, sharing of decks, or collaboration with course-mates.
* No native iOS or Android apps; the PWA only.
* No direct integration with the university's learning platform, and no scraping of university portals. Course material is downloaded manually.
* No two-way sync with Anki; one-way TSV export only (Could).
* No generation of cards or questions from general knowledge. Everything comes from the student's course material.
* The tutor does not write or rewrite assessed coursework.
* No pipeline-free "generate a fresh question every day". Quizzes draw only from the reviewed question bank.

## 12. Known Assumptions, Risks & Open Questions
* **Assumptions you're making:**
  * The app has one user, who also runs the pipeline.
  * Course material is available as files (PDF, PPTX, DOCX, Markdown) with text that can be extracted.
  * Assessment formats and lecture coverage can be taken from the handbook, or entered in `pipeline.config.json`.
  * Fixed questions are enough: 3–5 genuinely different variants per core concept cover a semester under concept-level scheduling.
  * The student has, or will set up, Claude API access with billing.
  * Everything is in English.
* **Risks you already see:**
  * **Time:** the MVP and the processing of midterm lectures might not finish before the midterm.
  * **AI errors:** wrong cards or questions may still get through despite review and spot checks.
  * **Pipeline cost:** many agent calls per lecture × review rounds × modules.
  * **Marking:** Claude's marking of written answers may be inconsistent. Mitigated by marking points and override.
  * **Visual content:** diagram-heavy or scanned slides may be poorly captured by text extraction.
  * **University policy:** may restrict sending course material to external AI services.
  * **Hosted access:** the hosted app could expose API spend if its password protection fails.
  * **Workload:** the daily load could build up and lead to burnout. Mitigated by the time budget and deferral.
* **Questions you haven't answered yet:**
  * How many modules, which subjects, and how heavy on maths or diagrams?
  * Midterm and final exam dates and formats for each module?
  * Is phone access needed in the MVP, or is laptop-only acceptable until after midterms?
  * Monthly budget for Claude API spend and hosting?
  * Where and how should the pipeline run (Claude Code, Agent SDK, scripts)?
  * PLAN or BUILD mode; STRICT or ADVISORY checkpoints?
  * Do you currently use Anki or another tool you'd keep?
  * How long should tutor conversations and pipeline intermediate files be kept?
  * Does your university have a policy on uploading course material to AI tools?
  * App name?
