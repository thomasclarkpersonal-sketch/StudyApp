# ADR-004 · Pipeline Runtime in Claude Code CLI, Fresh-Context Subagent Isolation, and Multimodal + LaTeXiT Slide Ingestion

- **Artifact ID:** `A30` (`ADR-004`)
- **Stage:** Stage 3 — Architecture & Design
- **Date:** `2026-10-21`
- **Status:** Accepted
- **Deciders:** System Architect & Student (`[USER Q-05]`, `[USER Q-15]`, `CP1`, `CP2`)
- **Drivers:** `[USER Q-05, Q-15]`, `ASM-044`, `ASM-046`, `ASM-058`, `REQ-F-001`–`020`, `REQ-N-006`, `REQ-N-012`, `REQ-N-014`, `REQ-N-016`, `REQ-N-017`, `REQ-N-022`, `RSK-002`, `RSK-004`, `RSK-010`, `RSK-018`, `RSK-021`

---

## 1. Context and Forces

The Generation Pipeline must transform raw university course files (PDF slide decks, syllabi, homework sheets, reading lists, and Canvas pages) into reviewed, schema-valid flashcards (`deck.json`), multi-variant concept questions (`question-bank.json`), concepts (`concepts.json`), deadlines (`deadlines.json`), readings (`readings.json`), and notation glossaries (`glossary.json`). Four critical forces govern its design:
1. **Runtime & billing constraint (`[USER Q-05, Q-15]`, `ASM-058`, `REQ-N-022`, `RSK-021`):** The pipeline runs interactively inside the official **Claude Code CLI** on the student's personal Claude Pro/Max subscription, and must never extract or replay consumer OAuth tokens outside the official CLI.
2. **Visual & mathematical slide reality (`SRC-06`, `ASM-046`, `REQ-F-001`, `RSK-002`):** Analysis of the real 61-page COMP 4901B RL lecture PDF (`A09 §3.5`) proved that plain text extraction (`ASM-016`) fails: `25/60` content slides are image-led, `17` slides embed equations as PDF streams (`LaTeXiT` base64/zlib metadata), and extracted text has garbled ligatures (`fi`, `fl`, `ff`).
3. **Strict Reviewer independence (`[DOC flashcard-pipeline.md §3.1, §5.1, §6.3]`, `BR-011`, `REQ-N-012`, `RSK-018`):** Every Reviewer round (`r = 1, 2, 3`) must run in a **fresh subagent context** that receives only the candidate JSON, the source slide text/images/LaTeX, the module glossary, and the Reviewer rubric — never the Creator's chain-of-thought or prior-round Reviewer transcripts.
4. **Prompt-injection containment (`REQ-N-014`, `BR-002`, `RSK-010`):** Course slides and Canvas text are untrusted data and must never be able to execute shell commands, modify repo files, or override Reviewer rubrics.

---

## 2. Decision

We design the Generation Pipeline as a hybrid of **Deterministic Local Pre/Post-Processing (`pipeline-cli`)** and **Isolated Claude Code Native Subagents (`.claude/agents/*.md`)** orchestrated by slash commands (`.claude/commands/pipeline-*.md`):

### 2.1 Deterministic Local Helper CLI (`packages/pipeline` / `pipeline-cli`)
Before and between subagent invocations, `pipeline-cli` (TypeScript + a small Python PDF/LaTeXiT extraction script `scripts/pdf_ingest.py`) performs all deterministic I/O so LLM subagents never need arbitrary shell or network access:
1. **`pipeline-cli extract-lecture --module <id> --week <Wnn> --pdf <path>`:**
   - Renders each slide page to a `150 DPI` PNG (`pdftoppm -png -r 150`) in `<workspace>/lectures/<Wnn>/pages/page-<nnn>.png`.
   - Extracts raw text per page (`pypdf`), normalising Unicode ligatures (`\ufb00`–`\ufb04` $\rightarrow$ `ff`, `fi`, `fl`, `ffi`, `ffl`).
   - Scans PDF `/Contents` and `/PieceInfo` / `LaTeXiT` streams to recover embedded LaTeX equation strings per slide (`REQ-F-001`, `ASM-046`).
   - Classifies each slide as `text_sufficient`, `image_led`, or `unreadable_visual` (`BR-007`) and writes `<workspace>/lectures/<Wnn>/ingested-slides.json` wrapped in `<untrusted_course_material>` tags (`REQ-N-014`).
2. **`pipeline-cli build-reviewer-bundle --stage <cards|questions|cross_lecture> --round <1|2|3>`:**
   - Constructs a clean, self-contained input file `<workspace>/lectures/<Wnn>/reviewer-input.r<n>.json` containing **only** the candidate items (`cards.draft.json` or `questions.draft.json`), `ingested-slides.json` (plus paths to slide PNGs), and `glossary.json`.
   - Asserts programmatically (`TC-I-N12`) that `0` keys or files from `creator-notes`, `*.review.r<n-1>.json`, or conversation history are present (`BR-011`, `REQ-N-012`).
3. **`pipeline-cli apply-verdicts --stage <cards|questions|cross_lecture> --round <1|2|3>`:**
   - Deterministically executes Decision Table `DT-01` (`BR-012`–`BR-014`): freezes `accept` items into `*.final.json`, immediately removes `reject` items in rounds `1`–`2` (recording concept IDs that need a replacement under a new ID), prepares the `revise` delta for round `r + 1`, and routes any round-3 non-`accept` items into `flagged.json` (`reason = "failed_3_rounds"`).
4. **`pipeline-cli spot-check` & `pipeline-cli export`:**
   - Samples `ceil(0.10 * N)` accepted items for the student's interactive CLI review (`REQ-F-017`, `BR-015`), validates all 6 export JSON files against `A34` JSON Schemas (`Ajv`, `REQ-N-020`), and writes `run-summary.json`.

### 2.2 Native Claude Code Subagent Definitions (`.claude/agents/`)
Six dedicated subagent files with least-privilege tool allowlists (`Read` only on the staging bundle and slide PNGs, `Write` only on their designated output JSON file, `Bash` disabled):
- `extractor.md` (`AI-01`): reads syllabus/Canvas bundle $\rightarrow$ writes `glossary.json`, `deadlines.json`, `readings.json`, `concepts.skeleton.json`.
- `card-creator.md` (`AI-02`): reads `ingested-slides.json`, slide PNGs, `glossary.json`, and (on round `r > 1`) the current round's `revise` feedback $\rightarrow$ writes `cards.draft.json` and `concept-map.json`.
- `card-reviewer.md` (`AI-03`): spawned as a **fresh subagent invocation per round**; reads only `reviewer-input.r<r>.json` and slide PNGs; performs Pass 1 (blind answer) and Pass 2 (8-criterion pass/fail rubric `failed_criteria`, `verdict: "accept" | "revise" | "reject"`) $\rightarrow$ writes `cards.review.r<r>.json`.
- `question-creator.md` (`AI-04a`) & `question-reviewer.md` (`AI-04b`): analogous fresh-context loop for `questions.draft.json` and `questions.review.r<r>.json`.
- `module-auditor.md` (`AI-05`): reads all lecture finals for a module $\rightarrow$ writes `module-audit.json` (`REQ-F-016`, `BR-019`).

---

## 3. Alternatives Considered

### Alternative A: Standalone Node.js Pipeline Calling `@anthropic-ai/sdk` Directly
- **Pros:** Fully automated script outside Claude Code.
- **Why rejected:** Either bills the student's pay-per-token API account for heavy multimodal slide processing (violating `[USER Q-15]`, where the pipeline uses the student's Pro/Max subscription) or requires extracting Claude Code's consumer OAuth token into a custom harness (violating Anthropic's Consumer Terms, `ASM-058`, `REQ-N-022`, `RSK-021`).

### Alternative B: Running Creator and Reviewer in a Single Prompt / Single Subagent Session
- **Pros:** Fewer subagent launches and lower token usage.
- **Why rejected:** Violates `[DOC flashcard-pipeline.md §3.1, §5.1]`, `BR-011`, and `REQ-N-012` (`RSK-018`): when the same context both writes and reviews items, confirmation bias causes flawed cards to pass review.

### Alternative C: Text-Only PDF Extraction (`pypdf` / `pdf-parse` without Slide Images or LaTeXiT Recovery)
- **Pros:** Faster ingestion and lower token usage per lecture.
- **Why rejected:** Refuted by `SRC-06` (`ASM-016` refuted, `ASM-046`): misses 25/60 image-led slides and 17 slides of embedded LaTeXiT equations in COMP 4901B.

---

## 4. Consequences

- **Positive:**
  - `100%` compliance with Anthropic subscription terms (`REQ-N-022`) and `100%` verifiable Reviewer context isolation (`REQ-N-012`).
  - Deterministic enforcement of `DT-01` (`accept` freeze, `reject` immediate removal, `revise` loop cap `r = 3`, `flagged.json` routing) and `Ajv` schema validation in tested TypeScript code rather than relying on an LLM to merge JSON files.
- **Negative / Trade-offs:**
  - Multimodal slide PNG inspection uses more subscription quota per lecture (`RSK-004`); to optimise quota, `pipeline-cli extract-lecture` only attaches full-page PNGs to the Creator/Reviewer bundle for slides classified as `image_led` or containing figures/diagrams, while passing recovered LaTeXiT source + clean text as text tokens for text-only slides.
