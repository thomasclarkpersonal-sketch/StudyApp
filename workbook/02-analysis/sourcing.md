# A22 · Sourcing Decision

Owner: Systems Analyst / Solution Architect. Stage 2, written 2026-10-21. Catalog entry: A22 (Appendix B11).

Buying, subscribing to, or reusing existing software is evaluated here **after** structuring the requirements (`A10`–`A20`) and **before** Stage 3 architecture and design.

Per catalog entry `A22` and gate checks `G2.11` and `G2.16`:
1. **Options are judged and ruled in/out using only user-stated requirements** (`[SEED]`, `[USER]`, `[DOC]`).
2. **Agent-proposed requirements (`**(Proposal for CP2)**`, `G2.13`)** and **approval-style user decision points (`UDP-01`–`UDP-04` from `[SEED §10]`)** are evaluated in separate tables (§2.4 and §2.5) and never rule out an option on their own.
3. Product capabilities, pricing, and Anthropic subscription terms were verified via web search on `2026-10-21`.

---

## 1. Candidate sourcing options (`B11`)

All six categories in Appendix `B11` were considered; four realistic options (`Opt 1`–`Opt 4`) are evaluated in full below, and two (`B11` enterprise-wide and outsourcing) are dispositioned first:

| Option ID | Category (`B11`) | Description | Initial disposition |
| :-- | :-- | :-- | :-- |
| **Opt 1** | **Custom in-house build + OSS libraries** | Custom local TypeScript/React + Node + SQLite study app (`ts-fsrs`, KaTeX) paired with a custom multi-agent generation pipeline implemented as native Claude Code commands and subagent definitions (`.claude/agents/`). | **Evaluated in full** |
| **Opt 2** | **Hybrid: Packaged OSS (Anki) + custom pipeline & companion app** | Use **Anki** (Desktop + AnkiWeb + native FSRS) as the flashcard scheduler/reviewer via `deck.anki.tsv`, paired with the custom Claude Code pipeline and a stripped-down custom app for concept quizzes, deadlines, Today plan, and tutor. | **Evaluated in full** |
| **Opt 3** | **SaaS / cloud application (RemNote Pro with AI)** | Subscribe to **RemNote Pro with AI** (~$18–$20/mo billed annually) for PDF annotation, AI flashcard/quiz generation, FSRS spaced repetition, and AI tutor chat. | **Evaluated in full** |
| **Opt 4** | **Open-source PKM + plugins (Obsidian / Logseq + FSRS plugin)** | Combine **Obsidian** (or Logseq) with community FSRS flashcard plugins (`obsidian-spaced-repetition`), community task/deadline plugins, and manual interactive Claude Code / `claude.ai` prompting. | **Evaluated in full** |
| *(B11.5)* | *Enterprise-wide solution (Canvas LMS / institutional EdTech)* | Rely on HKUST Canvas native quizzes/calendar alone. | **Ruled out:** HKUST Canvas is controlled by university staff (`BR-002` read-only) and provides no student-side FSRS flashcards, multi-agent generation, or personal study scheduler (`[SEED §1, §3]`). |
| *(B11.6)* | *IT services firm / commercial outsourcing* | Hire an external agency to build and maintain the app. | **Ruled out:** Single-student personal project with zero capital outsourcing budget (`[SEED §2, §6]`, `A02 §2`). |

---

## 2. Requirement coverage across `Opt 1`–`Opt 4` (`A22`, `G2.11`, `G2.16`)

Legend: **`Met`** = supported natively or within the option's planned build scope; **`Workaround / Partial`** = requires manual steps, plugin scripting, or loses fidelity; **`Gap`** = not supported without building the custom subsystem anyway.

### 2.1 User-stated `Must` functional requirements — Generation pipeline (`REQ-F-001`–`REQ-F-020`, 20 rows)

*(Note: For `REQ-F-001`, only the user-stated PDF/PPTX/DOCX/MD + rendered page image ingestion is judged here; the agent-proposed LaTeXiT metadata decoder is separated in §2.4.)*

| ID | User-stated requirement summary | Opt 1 (Custom Build) | Opt 2 (Anki Hybrid) | Opt 3 (RemNote AI SaaS) | Opt 4 (Obsidian + Manual Claude) |
| :-- | :-- | :-: | :-: | :-: | :-: |
| `REQ-F-001` | Ingest local PDF/PPTX/DOCX/MD + slide page images | **Met** | **Met** (custom pipeline) | **Partial** (PDF/doc import; no `pipeline.config.json`) | **Workaround** (manual file attachment) |
| `REQ-F-002` | Read-only HKUST Canvas ingestion + local fallback (`Q-17`) | **Met** | **Met** (custom pipeline) | **Gap** (no HKUST Canvas API reader) | **Gap** (manual download only) |
| `REQ-F-003` | Extractor runs first to build `glossary.json` (`standard` vs `module_specific`) | **Met** | **Met** (custom pipeline) | **Gap** (single-pass AI; no pre-extracted notation contract) | **Workaround** (manual prompt) |
| `REQ-F-004` | Extract `deadlines.json` with UTC, timezone, weighting, `explicit`/`inferred` | **Met** | **Met** (custom pipeline) | **Gap** | **Workaround** (manual copy to markdown) |
| `REQ-F-005` | Extract `readings.json` with `required`/`recommended` & default `read_by` | **Met** | **Met** (custom pipeline) | **Gap** | **Workaround** |
| `REQ-F-006` | Order CS modules first (`Q-12`) & nearest-assessment lectures first | **Met** | **Met** (custom pipeline) | **Gap** | **Workaround** (manual ordering) |
| `REQ-F-007` | Stage A Card Creator extracts 8–20 concepts (`core`/`supporting`/`detail`) | **Met** | **Met** (custom pipeline) | **Gap** (no structured concept map with importance tiers) | **Workaround** (manual prompt) |
| `REQ-F-008` | Draft 15–40 atomic cards following 10 card rules; flag unclear slides | **Met** | **Met** (custom pipeline) | **Partial** (generates cards, but no 10-rule contract or `flagged.json`) | **Workaround** |
| `REQ-F-009` | Fresh context-isolated Card Reviewer: Pass 1 blind answer + Pass 2 8-rubric | **Met** | **Met** (custom pipeline) | **Gap** (no independent blind-answer Reviewer agent) | **Workaround** (manual 2nd chat) |
| `REQ-F-010` | Cap Card revision loop at 2 rounds; freeze `accept`, route round-3 fails to `flagged` | **Met** | **Met** (custom pipeline) | **Gap** | **Gap** (manual file merging) |
| `REQ-F-011` | Stage B Question Creator (after Stage A): `3–5` core (`Q-07`), `2–3` supporting, `0–1` detail | **Met** | **Met** (custom pipeline) | **Gap** (no per-concept variant quota) | **Workaround** |
| `REQ-F-012` | Weight question types to assessment format + 2–5 marking points + distractor notes | **Met** | **Met** (custom pipeline) | **Partial** (basic MCQ/open quiz; no assessment-weight config) | **Workaround** |
| `REQ-F-013` | Fresh context-isolated Question Reviewer: Pass 1 blind stem + Pass 2 rubric | **Met** | **Met** (custom pipeline) | **Gap** | **Workaround** |
| `REQ-F-014` | Cap Question revision loop at 2 rounds; route round-3 fails to `flagged.json` | **Met** | **Met** (custom pipeline) | **Gap** | **Gap** |
| `REQ-F-015` | Module Auditor checks outcome coverage, assessment variants, duplicates, notation | **Met** | **Met** (custom pipeline) | **Gap** | **Gap** |
| `REQ-F-016` | Route Auditor synthesis items through fresh Reviewer before inclusion | **Met** | **Met** (custom pipeline) | **Gap** | **Gap** |
| `REQ-F-017` | Pre-export human review of `flagged.json`, `module_specific` glossary, `inferred` dates, 10% spot check | **Met** | **Met** (custom pipeline) | **Gap** | **Gap** |
| `REQ-F-018` | Export 6 JSON files (`deck`, `question-bank`, `concepts`, `glossary`, `deadlines`, `readings`) with stable IDs | **Met** | **Met** (custom pipeline) | **Gap** (proprietary export format) | **Gap** |
| `REQ-F-019` | Write pipeline run summary report (accepted/rejected/flagged per lecture + audit) | **Met** | **Met** (custom pipeline) | **Gap** | **Gap** |
| `REQ-F-020` | Ingest `R1` reported items and route with comment to Creator + fresh Reviewer | **Met** | **Met** (custom pipeline) | **Gap** | **Gap** |

---

### 2.2 User-stated `Must` functional requirements — Study app (`REQ-F-021`–`REQ-F-042`, 22 rows)

*(Note: The user-stated core behaviours of `REQ-F-023`, `REQ-F-026`, `REQ-F-040`, and `REQ-F-042` are judged here; their `**(Proposal for CP2)**` telemetry columns for `SM-1`–`SM-4b` are separated in §2.4.)*

| ID | User-stated requirement summary | Opt 1 (Custom Build) | Opt 2 (Anki Hybrid) | Opt 3 (RemNote AI SaaS) | Opt 4 (Obsidian + Plugins) |
| :-- | :-- | :-: | :-: | :-: | :-: |
| `REQ-F-021` | Validate 6 export JSON files against schema & show diff preview before import | **Met** | **Partial** (Anki TSV has no schema/diff preview; companion app must still be built) | **Gap** | **Gap** |
| `REQ-F-022` | Match re-imported items by stable ID; update content while keeping FSRS history | **Met** | **Partial** (Anki matches by first field or GUID note ID, but split across Anki + companion DB) | **Gap** | **Partial** (plugin ID comments fragile on edit) |
| `REQ-F-023` *(core)* | Suspend (`suspended = true`, never delete) items absent from a lecture re-import | **Met** | **Workaround** (Anki TSV import does not auto-suspend absent notes without custom add-on) | **Gap** | **Gap** |
| `REQ-F-024` | Organise cards `Module → Lecture → Concept → Cards` with tags, Markdown, KaTeX, `extra` | **Met** | **Met** (Anki decks/tags + MathJax) | **Met** | **Met** |
| `REQ-F-025` | Card review controls: `Space` reveal, `1`–`4` (`Again`/`Hard`/`Good`/`Easy`), suspend, flag, edit | **Met** | **Met** (native in Anki) | **Met** | **Partial** |
| `REQ-F-026` *(core)* | Update `CardState` on rating via `ts-fsrs` (retention `0.90`, SM-2 fallback) & log review | **Met** | **Met** (Anki native FSRS) | **Met** (RemNote FSRS) | **Partial** (community plugin FSRS) |
| `REQ-F-027` | Per-module daily limits on new cards (default 20) and due reviews (default 200) | **Met** | **Met** (Anki deck options) | **Met** | **Partial** |
| `REQ-F-028` | Searchable module notation glossary view with `module_specific` highlight & confirmation | **Met** | **Gap** in Anki (requires custom companion app) | **Workaround** (plain note page) | **Workaround** (markdown note) |
| `REQ-F-029` | Separate FSRS `ConceptState` per concept; select due concepts up to `quiz_per_day` (10) | **Met** | **Gap** in Anki (requires building custom quiz engine in companion app) | **Gap** (no separate concept-level FSRS state distinct from cards) | **Gap** |
| `REQ-F-030` | Variant rotation: exclude flagged/suspended, prefer unseen over LRS, match stability difficulty (`1`/`2`/`3`) | **Met** | **Gap** in Anki (requires custom quiz engine) | **Gap** | **Gap** |
| `REQ-F-031` | Reuse LRS variant when all variants seen & record `topup` `FeedbackItem` | **Met** | **Gap** in Anki (requires custom quiz engine) | **Gap** | **Gap** |
| `REQ-F-032` | Auto-mark MCQs and show model answer + explanation for each distractor | **Met** | **Gap** in Anki | **Partial** (MCQ support, not tied to concept variant FSRS) | **Gap** |
| `REQ-F-033` | Self-marking of written & calculation questions against `model_answer` & `marking_points` | **Met** | **Gap** in Anki | **Workaround** | **Gap** |
| `REQ-F-034` | Map attempt to concept FSRS rating (`1`–`4`), update `ConceptState`, offer `card_ids` on `Again` | **Met** | **Gap** (`card_ids` lives in Anki while `ConceptState` lives in companion app; no deep link) | **Gap** | **Gap** |
| `REQ-F-035` | Live deadline countdowns (`< 48 h` hours/mins) + colour & non-colour urgency indicators | **Met** | **Gap** in Anki (requires custom companion app) | **Gap** | **Partial** (community task plugins) |
| `REQ-F-036` | Manual deadline creation/editing overriding pipeline-extracted values on re-import | **Met** | **Gap** in Anki (requires custom companion app) | **Gap** | **Gap** |
| `REQ-F-037` | `Confirm` badge on `inferred` deadlines until student confirms/edits | **Met** | **Gap** in Anki | **Gap** | **Gap** |
| `REQ-F-038` | Store timestamps in UTC with source `timezone` preserved across local timezone changes | **Met** | **Gap** in Anki | **Gap** | **Gap** |
| `REQ-F-039` | Generate 9-step ordered `DailyPlan` ("Today" checklist) at local midnight / first open | **Met** | **Gap** (Anki due counts aren't readable by browser app without AnkiConnect running on desktop) | **Gap** (no 9-step unified card + concept quiz + reading + milestone plan) | **Gap** |
| `REQ-F-040` *(core)* | Compute formula-derived `est_minutes` per `DailyPlanItem` (8 s/due card, 25 s/new, 45 s/MCQ, 3 m/written, pages×rate) | **Met** | **Gap** | **Gap** | **Gap** |
| `REQ-F-041` | Readings list by module/week (`done`/`skimmed`/`skipped`) and personal `Task` items | **Met** | **Gap** in Anki | **Workaround** | **Partial** |
| `REQ-F-042` *(core)* | Report card or question with comment & export reported items to JSON for pipeline re-run | **Met** | **Workaround** (cards in Anki cannot export structured `feedback.json` alongside quiz items) | **Gap** | **Gap** |

---

### 2.3 User-stated `Must` non-functional requirements & `Should`/`Could` summary

| Requirement group | Opt 1 (Custom Build) | Opt 2 (Anki Hybrid) | Opt 3 (RemNote AI SaaS) | Opt 4 (Obsidian + Plugins) |
| :-- | :-: | :-: | :-: | :-: |
| **User-stated `Must` NFRs (`REQ-N-007`, `008`, `010`–`014`, `016`, `018`–`020`, `022` — 12 NFRs)** | **12 / 12 Met** (`100%` local offline `R1`, `ts-fsrs` fidelity, crash-safe SQLite backup, `100%` Reviewer isolation, server-only secrets, prompt-injection delimiters, WCAG 2.2 AA, keyboard-only, schema validation, native Claude Code CLI) | **8 / 12 Met, 4 Partial** (splitting state between Anki SQLite and companion SQLite breaks unified atomic backup `REQ-N-011` and unified keyboard/accessibility flow `REQ-N-018`/`019`) | **3 / 12 Met, 9 Gap** (cloud SaaS requires outbound network, no Reviewer isolation `REQ-N-012`, no `A34` schema contract `REQ-N-020`) | **4 / 12 Met, 8 Partial/Gap** (no schema contract, no automated crash-safe import diff, limited keyboard/accessibility guarantees) |
| **User-stated `Should` (`R2`) requirements (`REQ-F-043`–`058`, `REQ-N-021`, `023` — 18 items)** | **18 / 18 Met** (Claude written marking with cached prefix, course-grounded tutor with slide citations & coursework refusal, tutor proposals → Reviewer, assessment mode & mock exams, daily time budget, `.ics`, Stats) | **Partial** (companion app must still build `100%` of `R2` quiz marking, tutor, assessment mode, budget, `.ics`, and stats, while lacking access to Anki's `CardReviewLog` on mobile) | **Partial** (`2/18` partial: generic AI chat/grading without module glossary contract, prompt caching control, coursework refusal rule, or tutor-proposal Reviewer pipeline) | **Gap** (`0/18` native) |
| **User-stated `Could` (`R3`) requirements (`REQ-F-059`–`066`, `REQ-N-009`, `015` — 10 items)** | **10 / 10 Met** (hosted password auth, offline PWA + `pending_claude` queue, notifications, full `feedback.json` loop, custom FSRS fitting, Anki `.tsv` export) | **Partial** (AnkiMobile on iOS costs $24.99 and still leaves the companion web app to be hosted/PWA-enabled separately) | **Partial** (has mobile/offline app and FSRS, but no `feedback.json` top-up loop) | **Partial** |

---

### 2.4 Separate evaluation of Agent-Proposed Requirements (`**(Proposal for CP2)**`, `G2.13`, `G2.16`)

Per `G2.16`, none of the 14 `**(Proposal for CP2)**` items below are used to rule out any option:

| Proposal ID(s) | Agent-proposed requirement summary | Basis | Opt 1 | Opt 2 | Opt 3 | Opt 4 |
| :-- | :-- | :-- | :-: | :-: | :-: | :-: |
| `REQ-F-001` *(part)* | Decode embedded `LaTeXiT` base64/zlib PDF metadata streams into LaTeX | `A09` finding on `COMP4901b_Sept24_RL.pdf` (`ASM-046`) | **Met** | **Met** | **Gap** | **Gap** |
| `REQ-F-023`, `026`, `040`, `042`, `048` *(parts)* | Metric logging fields (`ImportBatch`, `state_before`, `completed_at`, `wrong`/`unclear` reason, `GradingCallLog` tokens) | Required to compute `A01 §3` `SM-1`, `SM-2`, `SM-3`, `SM-4b`, `SM-6` (`DEC-012`) | **Met** | **Partial** | **Gap** | **Gap** |
| `REQ-F-052` *(part)* | Per-thread tutor deletion (`ASM-023`) | Privacy/retention hygiene (`[SEED §4]`) | **Met** | **Met** | **Met** | **Met** |
| `REQ-N-017` | Pipeline intermediate file (`*.draft.json`, `*.review.r*.json`) cleanup command (`ASM-024`) | Storage/privacy hygiene (`[SEED §4]`) | **Met** | **Met** | **N/A** | **N/A** |
| `REQ-N-001`–`REQ-N-006` | Concrete latency & runtime targets (`≤ 100 ms` flip, `≤ 300 ms` next, `≤ 1 s` Today, `≤ 10 s` grade, `≤ 3 s` tutor, `≤ 15 m` lecture) | Marked *(proposed)* in `[SEED §7 Performance]` (`ASM-037`) | **Met** | **Met** | **Partial** | **Partial** |

---

### 2.5 Separate evaluation of Approval-Style User Decision Points (`UDP-01`–`UDP-04`, `G2.16`)

Per `G2.16`, the `[SEED §10]` approval rules do not automatically disqualify any option, but any option that triggers one requires the student's explicit approval at `CP2`:

| Decision Point | Rule (`[SEED §10]`) | Impact on `Opt 1` (Custom Build) | Impact on `Opt 2` (Anki Hybrid) | Impact on `Opt 3` (RemNote AI SaaS) | Impact on `Opt 4` (Obsidian) |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `UDP-01` | Ask before adding a paid service or significantly increasing Claude spend | **No new paid service** ($0 local stack; uses existing Claude subscription + $3–$15/mo `R2` API). | **$24.99 one-time fee** if using AnkiMobile on iOS (free on desktop/web/Android). | **Triggers `UDP-01`:** Requires a paid RemNote Pro with AI subscription (~$18–$20/mo = $648–$720 over 36 months). | **No paid service** for local files (Obsidian Sync is optional). |
| `UDP-02` | Ask before changing card rules, question rules, or reviewer rubrics | Preserves `100%` of rules and rubrics unchanged. | Preserves pipeline rules; drops concept-card link on failed quizzes. | **Triggers `UDP-02`:** Replaces the 10 card rules and 8-criterion Reviewer rubrics with generic black-box SaaS generation. | Requires manual adherence to rules. |
| `UDP-03` | Ask before sending course material to any third party other than Anthropic | Sends course material **only to Anthropic** (local + Claude Code / Claude API). | Sends course material only to Anthropic (unless synced to AnkiWeb cloud). | **Triggers `UDP-03`:** Uploads copyrighted HKUST PDFs and notes to RemNote's third-party cloud servers and sub-processors. | Local vault (unless third-party cloud sync used). |
| `UDP-04` | Ask before anything that could delete or overwrite review history | Enforces atomic non-destructive upsert (`BR-021`, `REQ-N-011`). | Splitting cards (Anki) and concepts (companion app) complicates unified backup/restore. | Managed in vendor cloud. | Community plugin markdown comments can be overwritten if note text is edited manually. |

---

## 3. Evaluation against Appendix `B11` criteria and 36-month TCO

| Criterion (`B11`) | Opt 1 · Custom Build + OSS Libraries | Opt 2 · Anki + Custom Pipeline & Companion App | Opt 3 · RemNote Pro with AI (SaaS) | Opt 4 · Obsidian + FSRS Plugin + Manual Claude |
| :-- | :-- | :-- | :-- | :-- |
| **User-stated `Must` (`R1`) coverage** | **54 / 54 (`100%`)** (`42/42` `REQ-F`, `12/12` user-stated `REQ-N`) | **25 / 42 `REQ-F` Met**, 4 Partial, **13 Gap** (unless the custom companion app is built anyway, saving only the flashcard UI) | **5 / 42 `REQ-F` Met**, 5 Partial, **32 Gap** | **2 / 42 `REQ-F` Met**, 14 Workaround/Partial, **26 Gap** |
| **Unique differentiating workflow fit** | Purpose-built for the two-pass blind Reviewer pipeline, concept-level FSRS variant rotation, linked card recovery on `Again`, 9-step Today plan, and course-grounded tutor. | Replaces only the flashcard review screen (`UC-07`) while breaking the tight coupling between failed concept quizzes (`UC-08` ext 6a), `DailyPlan` due counts (`UC-10`), `FeedbackItem` reporting (`UC-11`), and unified stats (`UC-17`). | Lacks multi-agent Creator–Reviewer verification, concept-level variant rotation, Canvas ingestion, and coursework-refusal guardrails. | High manual friction per lecture (~1–2 hours of copy-pasting prompts and formatting markdown per lecture), defeating `SM-1` (≤ 15 min/lecture). |
| **36-month TCO (`A02 §2` horizon)** | **$0–$5,340** (`$0` in `R1` when covered by existing Claude plan; `$90–$450` in `R2` grading/tutor API over 30 active study months; `$0–$3,600` optional Claude Max upgrade contingency if needed; `$0–$216` optional `R3` hosting). | **$0–$5,365** (same pipeline/API/hosting cost as `Opt 1` + `$0` desktop/Android or `$24.99` iOS AnkiMobile, while saving only ~10–15% of build effort because the pipeline, quiz engine, deadline tracker, Today planner, and tutor still have to be built). | **$648–$720** subscription (`$18–$20/mo × 36 mo`) + existing Claude subscription, **plus** requires user approval under `UDP-01`, `UDP-02`, and `UDP-03`. | **$0–$288** (`$0` local or `$4–$8/mo` optional sync) + high ongoing student manual labour (~60–120 hours/semester formatting cards/questions). |
| **Lock-in & exit cost** | **Zero lock-in:** All data lives in open JSON files (`A34`) and local SQLite (`A33`), with one-way Anki `.tsv` (`REQ-F-066`) and `.ics` (`REQ-F-057`) exports built in. | Low lock-in, but data is split across two incompatible SQLite schemas (Anki `.apkg` collection vs companion app DB). | **High lock-in:** Concept hierarchy, quiz items, and scheduling metadata are tied to RemNote's proprietary cloud graph. | Low lock-in (plain Markdown files), but fragile scheduling metadata embedded in HTML comments. |
| **Anthropic Consumer Terms compliance (`ASM-058`, `REQ-N-022`)** | **Compliant:** Pipeline executes interactively inside the official **Claude Code CLI** using native `.claude/agents/` subagents (no OAuth token extraction); `R2` app backend uses a standard Console API key under Commercial Terms. | **Compliant** (same pipeline & `R2` API model as `Opt 1`). | Uses vendor-managed LLM routing (triggers `UDP-03`). | **Compliant** (manual interactive Claude usage). |

---

## 4. Recommendation and what would change it (`A22`)

### 4.1 Recommendation: **Option 1 — Custom build adopting mature open-source libraries**

We recommend **Option 1 (Custom in-house build of the Study App & Claude Code Pipeline, adopting open-source libraries)** for three concrete reasons grounded strictly in the user-stated requirements:
1. **No off-the-shelf or SaaS product supports the two core architectural pillars of the seed (`[SEED §1, §3]`):**
   - Pillar 1 is the **multi-agent Creator + context-isolated two-pass Reviewer pipeline** (`REQ-F-001`–`REQ-F-020`, `REQ-N-012`), which eliminates bad/ambiguous cards before study begins (`SM-3 < 5%`).
   - Pillar 2 is **concept-level FSRS quiz scheduling with unseen variant rotation and immediate linked-card recovery** (`REQ-F-029`–`REQ-F-034`), unified with flashcards, readings, and deadlines in a single 9-step **Today** plan (`REQ-F-039`).
2. **Option 2 (Anki Hybrid) saves very little build effort while breaking workflow integration:** Because Anki handles only flashcards (`UC-07`), we would still have to custom-build the entire pipeline (`UC-01`–`UC-05`), the concept quiz engine (`UC-08`), the deadline tracker (`UC-09`), the Today checklist (`UC-10`), the feedback loop (`UC-11`, `UC-19`), the Claude grader (`UC-12`), and the course tutor (`UC-13`). Splitting flashcards into Anki while keeping concepts and quizzes in the web app breaks `REQ-F-034` (offering linked flashcards immediately when a concept quiz is rated `Again`), breaks `REQ-F-039` (building the Today checklist offline without desktop AnkiConnect), and breaks `REQ-F-022`/`REQ-F-042` (unified non-destructive re-import and single-click error reporting). Meanwhile, `REQ-F-066` (`UC-21`) already gives the student a one-way Anki `.tsv` export as a built-in escape hatch.
3. **Option 3 (RemNote AI SaaS) fails 32 of 42 user-stated `Must` functional requirements** and would also require explicit user waivers on `UDP-01` ($648–$720 subscription cost), `UDP-02` (abandoning the card/question rules and Reviewer rubrics), and `UDP-03` (uploading copyrighted HKUST course files to a third-party cloud).

### 4.2 What would change this recommendation
- If the student decided at `CP2` to **drop concept-level variant quizzes (`UC-08`), the unified Today checklist (`UC-10`), and the in-app Claude tutor (`UC-13`)**, keeping **only** pipeline flashcard generation (`UC-01`, `UC-03`, `UC-05`) and flashcard review (`UC-07`), then **Option 2 (Pipeline → Anki TSV export only)** would become the recommended choice, cutting build effort by ~65% and changing Stage 3 in `A04` to pipeline-only design.

---

## 5. Reusable open-source components to adopt in Option 1 (`A22`)

Rather than writing algorithms or parsers from scratch, Option 1 adopts the following open-source libraries (evaluated formally in Stage 3 `A30` ADRs):

| Capability | Adopted open-source component / service | Why adopt rather than write |
| :-- | :-- | :-- |
| **FSRS v4/v5 scheduling & parameter fitting** | `ts-fsrs` (MIT, TypeScript) | Reference implementation of FSRS (`REQ-F-026`, `REQ-F-029`, `REQ-F-065`, `REQ-N-010`); eliminates custom memory-math bugs (`RSK-004`). |
| **LaTeX mathematics rendering** | `KaTeX` (MIT) | Fast, deterministic client-side math rendering (`REQ-F-024`, `REQ-N-001`). |
| **Markdown rendering & sanitization** | `marked` / `remark` + `DOMPurify` (MIT/Apache-2.0) | Safe rendering of card/question/tutor Markdown without XSS (`REQ-F-024`, `REQ-F-046`). |
| **Embedded relational store & FTS** | `SQLite 3` via `better-sqlite3` (MIT) with SQLite `FTS5` | ACID transactions, WAL crash safety (`REQ-N-011`), zero-config single-file backups, and native full-text search for glossary and tutor threads (`REQ-F-028`, `REQ-F-052`). |
| **JSON Schema validation** | `Ajv` (MIT) | Validates all 6 pipeline export files and `feedback.json` in both pipeline and study app (`REQ-N-020`). |
| **PDF text, page rendering & LaTeXiT extraction** | `pypdf` (BSD) + `poppler-utils` (`pdftoppm` / `pdfimages`) + Python `zlib`/`base64` | Proven local extraction of text, rendered slide images, and embedded macOS `LaTeXiT` equation streams (`REQ-F-001`, `ASM-046`). |
| **iCalendar `.ics` generation** | `ical-generator` (MIT) or RFC 5545 formatter | Standards-compliant `.ics` feed generation (`REQ-F-057`). |
| **Multi-agent pipeline runtime** | **Claude Code CLI** native `.claude/agents/` & slash commands | Zero-harness interactive subagent orchestration with fresh context windows per Reviewer (`DEC-005`, `REQ-N-012`, `REQ-N-022`). |
| **In-app grading & tutor LLM client (`R2`+)** | `@anthropic-ai/sdk` (MIT, TypeScript) | Official SDK with first-class prompt caching (`cache_control: { type: "ephemeral" }`) and SSE streaming (`REQ-F-043`–`REQ-F-048`). |
