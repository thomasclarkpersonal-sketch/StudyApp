# Clarifying Questions

Questions raised at any stage (protocol R2, Stage 0 step 5). Highest impact first within each stage. A recorded answer is never edited: clarifications are appended below it with a date (R1).

Each question gives the options, why it matters, and the default the agent assumes if it goes unanswered. The default is registered as an assumption in [`assumptions-decisions.md`](assumptions-decisions.md).

## Stage 0 questions (raised 2026-10-20)

### Q-01 · University policy on AI tools
- **Question:** Does your university allow you to put course material (slides, handbooks, past papers) into an external AI service such as the Claude API, for your own study?
- **Options:** (a) Yes, it is allowed · (b) It is restricted or not allowed · (c) I don't know; I'll check before the first real pipeline run · (d) I can't find any policy
- **Why it matters:** the pipeline sends every lecture to Anthropic. If this is not allowed, the generation pipeline (stories 1–3 and 5), which is the core of the MVP, cannot run on real material, and scope changes. [SEED §7 Privacy & compliance] [SEED §12 Risks]
- **Default if unanswered:** (c). Plan as if it is allowed, record it as a risk in A03, and hold the first run on real course material until you confirm. → `ASM-002`
- **Status:** open
- **Answer:** —

### Q-02 · Key dates and the university's time zone
- **Question:** When is your first midterm (per module, if they differ), when is the final exam period, and in which time zone does your university set deadlines?
- **Options for the first midterm:** (a) within 2 weeks · (b) 2–4 weeks away · (c) 4–8 weeks away · (d) more than 8 weeks away. Exact dates per module are better, if you have them.
- **Why it matters:** the MVP (stories 1–11) must be usable before the first midterm, with time left to study, and midterm lectures must be processed at least 7 days before it. The date decides how much fits in the MVP, whether BUILD is realistic, and every date in the schedule (A06). Deadlines keep the university's own time zone. [SEED §1 Success metrics] [SEED §7 Languages, regions, time zones] [SEED §9 Deadline] [DOC study-app-spec.md §7]. The dates in `flashcard-pipeline.md` §12 are treated as an example only.
- **Default if unanswered:** the first midterm is treated as 2–4 weeks away. The schedule gives effort ranges and no calendar dates, and the MVP is kept to the Must stories. Each deadline keeps the time zone its source gives; otherwise the student's configured time zone. → `ASM-003`, `ASM-022`
- **Status:** open
- **Answer:** —

### Q-03 · PLAN or BUILD mode
- **Question:** Should the agent only plan (PLAN), or also build the app and pipeline in this repository (BUILD)?
- **Options:** (a) BUILD: the agent writes tests and code here, test-first, slice by slice, and you review each pull request · (b) PLAN: specifications and per-slice implementation guides only; someone else builds
- **Why it matters:** decides what Stages 4–6 produce, who builds, and how gates are evidenced. The seed suggests considering BUILD because of the midterm deadline. A BUILD environment appears to be available (`ASM-005`). [SEED §9 Who will build it] [SEED §10 Mode]
- **Default if unanswered:** (b) PLAN, the protocol default. → `ASM-004`, `ASM-031`
- **Status:** open
- **Answer:** —

### Q-04 · Phone access and offline use in the MVP
- **Question:** The seed says you review and quiz mostly on a phone [SEED §2], but also that the MVP runs locally on the laptop [SEED §7 Availability], and phone access with offline study is a Could (story 17). What do you need before the first midterm?
- **Options:** (a) Laptop only until after the midterms; phone access later (story 17) · (b) Use the phone on my home Wi-Fi, with the app running on my laptop; no hosting · (c) Hosted behind a password in the MVP, with offline review on the phone
- **Why it matters:** (b) and (c) bring forward a login, network exposure of the API key and spend, and offline sync. That changes the architecture, the security design (A36), the slice order and the schedule. Note that the seed has no login for local use, so (b) would need one too. [SEED §3 story 17] [SEED §7 Availability, Security & access] [DOC study-app-spec.md §4, §7]
- **Default if unanswered:** (a) laptop only. → `ASM-008`
- **Status:** open
- **Answer:** —

### Q-05 · Where the pipeline runs
- **Question:** How should the multi-agent pipeline (Orchestrator, Extractor, Creators, Reviewers, Auditor) run?
- **Options:** (a) In Claude Code, which I start for each module or lecture · (b) As TypeScript scripts using the Claude Agent SDK, run from the command line · (c) As plain scripts calling the Claude API directly · (d) Decide for me in Stage 3, with an ADR
- **Why it matters:** this is the architecture of the half of the system that makes the cards. It affects how the API is paid for (per-token API billing or a subscription; to be verified in A22), repeatability, how the "fresh Reviewer instance that never sees the Creator's reasoning" rule is enforced, and how the pipeline is tested. [SEED §5 Pipeline agent runtime] [SEED §12 Questions] [DOC flashcard-pipeline.md §3.1]
- **Default if unanswered:** (d). Stage 3 decides by ADR; until then, assume TypeScript on the student's laptop, billed to the student's Claude API account. → `ASM-009`
- **Status:** open
- **Answer:** —

### Q-06 · Monthly budget
- **Question:** What monthly limit should Claude API spend, plus hosting if any, stay within? Please say which currency.
- **Options:** (a) under 10 a month · (b) 10–30 · (c) 30–100 · (d) over 100 · (e) no fixed limit; just show me the spend
- **Why it matters:** it is one of your success metrics, and pipeline cost is a risk you named. The number of review rounds, the model used for each agent, and how many lectures can be processed all depend on it. Anything that significantly raises spend needs your approval. [SEED §1 Success metrics] [SEED §9 Budget] [SEED §10] [SEED §12 Risks]
- **Default if unanswered:** no figure is assumed. The design includes spend reporting and a configurable monthly cap, and the agent asks before anything that raises spend. No cash build budget beyond your time and AI usage. → `ASM-010`, `ASM-030`
- **Status:** open
- **Answer:** —

### Q-07 · Where the seed and the source documents disagree
- **Question:** The seed and its source documents differ on three points. Which should win?
  1. **Extracted deadlines and readings in the MVP.** Seed stories 3, 9 and 10 (extract deadlines and readings; confirm extracted deadlines; required readings in Today) are Must, but the MVP list in `study-app-spec.md` §7 imports only cards, concepts, questions and the glossary.
  2. **Reporting a wrong card.** Story 11 ("report a wrong or unclear card or question, so that it is fixed in the next pipeline run") is Must, but exporting `feedback.json` to the pipeline (story 18) is Could, and v3 in `study-app-spec.md` §7. Reports would not reach the pipeline until then.
  3. **Variants per core concept.** Seed §12 assumes 3–5; `flashcard-pipeline.md` §6.2 says 4–5. This is a question rule, which the agent may not change without asking you.
- **Options:** (a) Seed priorities for scope (points 1 and 2); the pipeline document for card and question rules (point 3) · (b) The seed wins on all three · (c) The source documents win on all three · (d) Mixed: I'll say which for each
- **Why it matters:** decides what is in the MVP and the question rules the Question Creator follows. [SEED §3 stories 3, 9–11, 18] [SEED §12 Assumptions] [DOC study-app-spec.md §7] [DOC flashcard-pipeline.md §6.2]
- **Default if unanswered:** (a). Point 1: deadline and reading import is in the MVP. Point 2: reports are stored in the app in the MVP and reach the pipeline only once story 18 is built. Point 3: 4–5 variants per core concept, unchanged. → `ASM-011`, `ASM-018`
- **Status:** open
- **Answer:** —

### Q-08 · Modules and what the material looks like
- **Question:** How many modules are you taking this semester, in which subjects, and what is the material like?
- **Options (any that apply):** (a) mostly text slides · (b) heavy on maths and formulas · (c) heavy on diagrams, charts or images · (d) some scanned, image-only PDFs or handwritten notes
- **Why it matters:** sets pipeline volume and cost, and whether plain text extraction is enough. Diagram-heavy or scanned slides are a risk you named. It also decides how much LaTeX the app must render. Feeds technical feasibility (A02). [SEED §4 Expected volume] [SEED §12 Assumptions, Risks, Questions]
- **Default if unanswered:** 4–6 modules, mixed subjects, text that can be extracted, some maths. → `ASM-012`, `ASM-016`
- **Status:** open
- **Answer:** —

### Q-09 · What you use today, and buying instead of building
- **Question:** Do you use Anki or another flashcard tool today, and would you keep an existing tool for part of the system?
- **Options:** (a) I use Anki and would keep it for flashcards, with a custom app for the rest (hybrid) · (b) I use Anki or another tool, but want everything in one custom app · (c) I don't use a flashcard app; I'm open to whatever fits best · (d) I want a fully custom app, whatever exists
- **Why it matters:** the sourcing decision (A22) must weigh existing tools against building; Anki with FSRS already covers flashcard review (story 7). It also decides whether existing cards and review history need migrating, which would add a data migration plan (A62). [SEED §6 What's used today, Data to bring across] [SEED §8 Open to buying instead of building?, Products already considered]
- **Default if unanswered:** open to buying. A22 compares an Anki hybrid with a custom build. Nothing is imported from other apps. → `ASM-013`, `ASM-014`
- **Status:** open
- **Answer:** —

### Q-10 · Checkpoint mode and tier
- **Question (a), checkpoint mode:** STRICT (the agent waits for your approval at every checkpoint) or ADVISORY (it waits at CP1 scope and CP2 requirements, then continues on stated assumptions at CP3 and CP4)?
- **Question (b), tier:** the catalog's sizing rule gives tier **M**: 11 Must stories (more than the S limit of about 8) and two integrations (Claude API and the pipeline-to-app files) point to M, and with risk flags set the rule takes the higher tier (`DEC-001`). You may override to **S**, which is lighter: for example, no WBS, a milestone list instead of a full network schedule, `README.md` as the project plan, and fewer release and maintenance artifacts. Tier also sets review depth.
- **Options:** (a) STRICT · (b) ADVISORY; and (a) keep tier M · (b) override to tier S
- **Why it matters:** sets how much planning is produced before building starts, and where the agent stops for you. That matters against the midterm deadline. [SEED §10 Tier, Checkpoint mode] [catalog §2.1]
- **Default if unanswered:** STRICT and tier M. → `ASM-006`, `ASM-007`
- **Status:** open
- **Answer:** —

## Documents requested (Stage 0 step 6)

The agent cannot interview you or watch you study, so existing documents stand in for that (catalog A09). Useful ones, in order:

1. One module handbook or syllabus, with assessment information (formats, which lectures each assessment covers, dates) and a reading list.
2. One sample lecture's slides, ideally one with maths or diagrams.
3. A past paper or sample questions, if available.
4. The semester calendar (week 1 start, reading weeks, exam period).
5. Screenshots of anything you use today: Anki statistics, your calendar, your to-do list.

> [!CAUTION]
> Course material is copyrighted and this repository is public. Do not put course files inside the repository. Keep them in a folder outside it (for example `~/StudyApp-material/`), or ask the agent to add a git-ignored folder first. [SEED §7] [AGENTS.md §3]
