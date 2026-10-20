# A00 · Assumptions, Decisions & Change Requests

Catalog entry: A00. Opened at Stage 0 (2026-10-20). No artifact is baselined yet, so there are no change requests.

**Columns.** *Impact if wrong* and *Confidence* are H, M or L. *Status* is open, confirmed, refuted, or carried to the maintenance backlog. *Resolved by* names the `Q-nn`, checkpoint, CR or closedown that settles the assumption.

## Assumption register

### Stage 0 defaults for open questions

| ID | Statement | Basis | Impact if wrong | Confidence | Status | Resolved by |
| :-- | :-- | :-- | :-: | :-: | :-- | :-- |
| ASM-001 | Both the study app and the multi-agent generation pipeline are in scope for this project. | Seed stories 1–5 (pipeline) are Must, and the target platform names both [SEED §3] [SEED §8 Target platform] | H | H | open | CP1 |
| ASM-002 | The university allows course material to be sent to Anthropic's Claude API for personal study. The first run on real course material waits until the student confirms. | No policy known [SEED §7 Privacy & compliance] [SEED §12 Risks] | H | L | open | Q-01 |
| ASM-003 | The first midterm is 2–4 weeks away. The schedule uses effort ranges and no calendar dates until the real dates are known, and the MVP is limited to the Must stories. | The MVP must be usable before the first midterm; the date is Unknown [SEED §9]. "Midterms are close" [DOC study-app-spec.md §7] | H | L | open | Q-02 |
| ASM-004 | The run is in PLAN mode until the user chooses. | Protocol default; seed mode Unknown [SEED §10 Mode] | H | M | open | Q-03 |
| ASM-005 | A BUILD environment is available: this git repository with a pull-request workflow, a Node.js runtime and npm, with a test runner installable through npm. There is no SQLite command-line tool, which a Node SQLite library would make unnecessary. Push access to `origin` is assumed. | Agent's environment check on 2026-10-20 found Node.js v22.22.1, npm 9.2.0, git 2.53.0 and gh 2.102.0; `sqlite3` not found | M | H | open | Q-03; A02 technical feasibility |
| ASM-006 | Checkpoint mode is STRICT. | Protocol default; seed Unknown [SEED §10 Checkpoint mode] | M | M | open | Q-10 |
| ASM-007 | The tier is M, as set provisionally by `DEC-001`. | Catalog §2.1 sizing rule applied to the seed [SEED §3] [SEED §5] | M | M | open | Q-10; CP1 |
| ASM-008 | The MVP runs on the laptop only. Phone access and offline study wait for story 17 (Could). | "MVP: runs locally on the student's laptop" [SEED §7 Availability]; story 17 is Could [SEED §3]; hosting is v3 [DOC study-app-spec.md §7]. In tension with "reviews and quizzes mostly on a phone" [SEED §2] and the offline requirement [SEED §7 Availability] | H | M | open | Q-04 |
| ASM-009 | The pipeline runtime is chosen by an ADR in Stage 3. Until then, assume TypeScript on the student's laptop, billed to the student's Claude API account. | Runtime Unknown [SEED §5]; recommended stack [SEED §8] | H | L | open | Q-05 |
| ASM-010 | No monthly budget figure is assumed. The design includes spend reporting and a configurable monthly cap. | Budget Unknown; cap planned [SEED §1 Success metrics] [SEED §9 Budget] [DOC study-app-spec.md §5] | H | L | open | Q-06 |
| ASM-011 | Where the seed and the source documents disagree on scope, the seed's priorities apply: extracted deadline and reading import is in the MVP, and reported items are stored in the app in the MVP but reach the pipeline only once story 18 (Could) is built. | Default for Q-07 [SEED §3 stories 3, 9–11, 18] [DOC study-app-spec.md §7] | M | L | open | Q-07; CP1 |
| ASM-012 | 4–6 modules per semester, about 10–12 lectures each, in mixed subjects, some with maths. | [SEED §4 Expected volume] (module count assumed there) | M | L | open | Q-08 |
| ASM-013 | The student is open to buying or adopting existing software. The sourcing decision (A22) compares an Anki hybrid with a custom build. | Unknown; Anki implied [SEED §8 Open to buying instead of building?, Products already considered] | H | M | open | Q-09; CP2 |
| ASM-014 | No flashcards or review history are imported from other apps, so the MIG risk flag is not set. | "Not planned for import" [SEED §6 Data to bring across] | M | M | open | Q-09 |
| ASM-018 | 4–5 question variants per `core` concept, as the pipeline's question rules say. Seed §12 assumes 3–5; question rules change only with the user's approval. | [DOC flashcard-pipeline.md §6.2] [SEED §12 Assumptions] [SEED §10] | M | M | open | Q-07 |
| ASM-022 | Each deadline keeps the time zone its source gives (handbook or `pipeline.config.json`); where none is given, the student's configured time zone applies. | University time zone Unknown [SEED §7 Languages, regions, time zones] [DOC flashcard-pipeline.md §12] | M | M | open | Q-02 |
| ASM-030 | There is no cash build budget beyond the student's time and AI usage costs. | Build budget Unknown [SEED §9 Budget] | M | L | open | Q-06 |
| ASM-031 | If BUILD is chosen, the agent builds and the student reviews. | "likely the agent in BUILD mode, with the student reviewing" [SEED §9 Who will build it] | M | M | open | Q-03 |

### Seed assumptions and other Unknown items

| ID | Statement | Basis | Impact if wrong | Confidence | Status | Resolved by |
| :-- | :-- | :-- | :-: | :-: | :-- | :-- |
| ASM-015 | The student's tech comfort is medium to high, so the NTU risk flag is not set. | "Unknown (assumed medium–high)" [SEED §2] | M | M | open | CP1 |
| ASM-016 | Course material is PDF, PPTX, DOCX or Markdown with text that can be extracted. | User's assumption [SEED §12 Assumptions] [DOC flashcard-pipeline.md §2] | H | M | open | Q-08; sample documents |
| ASM-017 | Assessment formats and lecture coverage can be taken from the handbook, or entered in `pipeline.config.json`. | User's assumption [SEED §12 Assumptions] [DOC flashcard-pipeline.md §2, §12] | M | M | open | Sample handbook; CP1 |
| ASM-019 | The student has, or will set up, Claude API access with billing. A Claude.ai subscription is separate from API access. | User's assumption [SEED §8 Existing infrastructure] [SEED §12 Assumptions] | H | M | open | Q-05; CP1 |
| ASM-020 | Everything is in English. | [SEED §7 Languages] [SEED §12 Assumptions] | L | H | open | CP1 |
| ASM-021 | There is one user, who also runs the pipeline. There are no accounts and no other users. | [SEED §2] [SEED §11] [SEED §12 Assumptions] | H | H | open | CP1 |
| ASM-023 | Tutor conversations are kept until the student deletes them, one thread at a time. | Retention Unknown [SEED §4 Retention / deletion rules]; history saved and searchable [DOC study-app-spec.md §1.5] | L | M | open | Stage 2 (A10, A37) |
| ASM-024 | Pipeline intermediate files (drafts, review rounds) are kept until the module ends, and are stored outside this public repository. | "(proposed: keep until the module ends)" [SEED §4]; copyright [SEED §7] | L | M | open | Stage 2 (A10, A37) |
| ASM-025 | Review history is kept indefinitely across the degree (its length in years is unknown). Data volumes are as in seed §4. | [SEED §4 Expected volume, Retention / deletion rules] | L | H | open | CP1 |
| ASM-026 | The app's working name is "Study App". | App name Unknown [SEED §1] | L | H | open | CP1 |
| ASM-027 | The phone, if used, runs a current version of Safari on iOS or Chrome on Android; the model is unknown. | [SEED §7 Devices & browsers] | L | M | open | Q-04 |
| ASM-028 | The host for the later hosted version is chosen by an ADR in Stage 3; the MVP is local. | Provider Unknown [SEED §8 Hosting / cloud] | M | M | open | Q-04; Stage 3 |
| ASM-029 | No technologies are to be avoided. | Unknown [SEED §8 Technologies to avoid] | L | M | open | CP1 |
| ASM-032 | The student keeps studying their usual way until the MVP works. | [SEED §6 Must the old system keep running] | L | H | open | CP1 |
| ASM-033 | The FIN risk flag is not set: API spend tracking estimates token costs, and the system handles no payments or financial records. | [SEED §3 Reports & outputs] [SEED §4 Sensitive data] | M | M | open | CP1 |
| ASM-034 | The REG risk flag is not set: there is no regulated-domain data (no financial, health or children's data). University rules on course material and academic integrity are assessed as legal and contractual feasibility in A02. | [SEED §4 Sensitive data] [SEED §7 Privacy & compliance] | M | M | open | Q-01; CP1 |
| ASM-035 | The HA risk flag is not set: availability is best effort. | [SEED §7 Availability] | L | H | open | CP1 |
| ASM-036 | The success metrics in seed §1 are proposals, to be confirmed at CP1. | Marked *(proposed)* [SEED §1] | M | M | open | CP1 |
| ASM-037 | The performance targets in seed §7 are proposals, to be confirmed with the requirements baseline. | Marked *(proposed)* [SEED §7 Performance] | M | M | open | CP2 |

## Decision log

| ID | Decision | Alternatives considered | Rationale | Decided by | Stage |
| :-- | :-- | :-- | :-- | :-- | :-- |
| DEC-001 | Provisional tier **M**, pending Q-10 and CP1. | S; L | Catalog §2.1 size signals point both ways. **S signals:** one builder [SEED §9]; one person in two roles [SEED §2]; no regulated data [SEED §4]; a personal app. **M signals:** 11 Must stories, above the S limit of about 8 [SEED §3]; two Must integrations, the Claude API and the pipeline-to-app file exchange, above the S limit of one [SEED §5]. L does not fit: there are no multiple teams, regulated data, HA target or legacy migration. Because risk flags are set (`DEC-003`), the rule takes the higher tier, M. The user may override [SEED §10 Tier]. | Agent | 0 |
| DEC-002 | Provisional project types: **BIS** for the study app (Today, review, quiz, deadlines, tutor) and **DATA** for the generation pipeline (extraction, generation, review, audit, export). | BIS only; DATA only | The app is a single-user information system with forms, reports and business rules [SEED §3]. The pipeline turns source documents into reviewed datasets through stages, so data flow, lineage and quality rules dominate there [SEED §8 AI / machine-learning features] [DOC flashcard-pipeline.md §3, §7]. The seed expects both types [SEED §10 Project type]. | Agent | 0 |
| DEC-003 | Provisional risk flags: **PD**, **INT** and **AI** set. FIN, REG, HA, MIG, MT and NTU not set. | Setting FIN (spend cap) or MIG (course files) | **PD:** study performance history and tutor conversations are personal data [SEED §4 Sensitive data]. **INT:** Claude API, pipeline files, `.ics` and Anki exports [SEED §5]. **AI:** LLM generation, review, marking and tutor [SEED §8 AI / machine-learning features]. The flags not set rest on `ASM-014`, `ASM-015`, `ASM-033`, `ASM-034` and `ASM-035`; MT is not set because there is one user [SEED §11]. | Agent | 0 |

## Change requests

None. Nothing is baselined yet; the first baseline is set at CP1.
