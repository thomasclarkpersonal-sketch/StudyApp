# ADR-007 · Third Normal Form (`3NF`) Relational Schema and Controlled JSON Columns for Immutable Snapshots & Audit Logs

- **Artifact ID:** `A30` (`ADR-007`)
- **Stage:** Stage 3 — Architecture & Design
- **Date:** `2026-10-21`
- **Status:** Accepted
- **Deciders:** System Architect
- **Drivers:** `G3.2`, `A32`, `A33`, `REQ-F-021`–`022`, `REQ-F-048`, `REQ-F-049`, `REQ-F-063`, `REQ-N-001`–`003`, `REQ-N-007`

---

## 1. Context and Forces

Gate check `G3.2` and catalog entry `A32` require that **every relation in the logical data model is in Third Normal Form (`3NF`)**, or that any denormalization / non-atomic attribute is explicitly justified by an ADR.
In our conceptual data model (`A16`, `A18`), several entities have multivalued attributes or M:N relationships that come from the JSON export files (`flashcard-pipeline.md`), plus a small number of opaque configuration/audit payload attributes:
1. **Queryable domain collections & relationships:**
   - `Concept.card_ids` (M:N between `Concept` and `Card`, used when a wrong quiz answer offers linked flashcards in `REQ-F-034`, `BR-032`).
   - `Concept.prerequisites` (unary M:N on `Concept`, `REL-05`).
   - `Card.tags` (multivalued tags on `Card`, used for filtering and Anki export `REQ-F-066`).
   - `Question.options` (ordered MCQ choices `A`–`D` on `Question`, `REQ-F-032`) and `Question.marking_points` / `QuestionAttempt.points_met` (rubric marking points on `Question` and which points were met on `QuestionAttempt`, `REQ-F-033`, `REQ-F-043`).
   - `TutorMessage.citations` (slide citations on `TutorMessage`, `REQ-F-046`).
2. **Opaque configuration blobs and immutable audit/staging payloads:**
   - `Settings.fsrs_weights_json` (`NULL` by default until fitted in `UC-20`, or a `21`-element FSRS-6 numerical weight vector — or `17`/`19`-element legacy vector migrated via `migrateParameters` — passed as a unit to `ts-fsrs` v5, `ASM-066`) and `Settings.token_rates_json` (rate table snapshot).
   - `Proposal.payload_json` (unreviewed candidate card or question draft waiting in the tutor proposal queue before export to `feedback.json`, `REQ-F-049`).
   - `FeedbackItem.payload_json` (snapshot exported to `feedback.json`, `REQ-F-063`).
   - `Deadline.format_json` (optional free-form exam format breakdown object `{ mcq_weight, written_weight, ... }` imported from `deadlines.json`, `A18`).
   - `CardState.retrievability` (derived in real time in the domain service `M03` via `ts-fsrs` v5 from `stability`, `current_elapsed_days` in view `v_card_state_with_retrievability`, and `settings.fsrs_weights_json`, `A16 §3 E05`, `TC-I-022`, `TC-I-N10`).

---

## 2. Decision

1. **Strict `3NF` Normalization for All Domain Entities and Relationships (`A32`):**
   - Every multivalued attribute and M:N relationship on core domain entities (`Module`, `Lecture`, `Concept`, `Card`, `CardState`, `CardReviewLog`, `ConceptState`, `Question`, `QuestionAttempt`, `GlossaryEntry`, `Deadline`, `Milestone`, `Task`, `Reading`, `DailyPlan`, `DailyPlanItem`, `TutorThread`, `TutorMessage`) is decomposed into dedicated `3NF` relations with composite primary keys and foreign keys (`A32 §2`):
     - `concept_card (concept_id, card_id)` resolves `REL-06` (`Concept` ↔ `Card`).
     - `concept_prerequisite (concept_id, prerequisite_concept_id)` resolves `REL-05` (`Concept` ↔ `Concept`).
     - `card_tag (card_id, tag)` resolves `Card.tags` into `1NF`/`3NF`.
     - `question_option (question_id, option_key, option_text, distractor_explanation)` resolves `Question.options` and `Question.distractor_explanations` into `1NF`/`3NF`.
     - `question_marking_point (question_id, point_index, point_text)` and `question_attempt_point (attempt_id, point_index, met)` resolve `Question.marking_points` and `QuestionAttempt.points_met` into `1NF`/`3NF`.
     - `tutor_message_citation (message_id, citation_index, source_ref)` resolves `TutorMessage.citations` into `1NF`/`3NF`.
   - Derived attributes (`CardState.retrievability`, `ConceptState.mastery_level`, `DailyPlan.total_est_minutes`, `DailyPlan.required_minutes`) are **not stored as mutable columns** on base tables (which would create transitive/update anomalies); `CardState.retrievability` is computed strictly in the domain service (`M03`) via `ts-fsrs` v5 from its injected `nowIso` clock and `settings.fsrs_weights_json` (`REQ-N-010`, `TC-I-022`, `TC-I-N10`), while `v_card_state_with_retrievability` (`V01` `current_elapsed_days`) provides an ad-hoc SQL inspection helper and `mastery_level` / `DailyPlan` totals are computed in SQL views `v_concept_mastery` (`V02`) and `v_daily_plan_summary` (`V03`) (`A32 §4`).

2. **Justified JSON Columns for Five Opaque / Staging / Snapshot Attributes (`G3.2`):**
   We permit `TEXT` columns validated by `CHECK (json_valid(...))` and `Ajv` schemas in **five specific places** where the value is an atomic opaque vector or an immutable staging/audit snapshot that is never partially updated or joined in SQL:
   - `settings.fsrs_weights_json` and `settings.token_rates_json`: passed as a single configuration object to `ts-fsrs` v5 (`NULL` by default until fitted in `UC-20`, or a `17`/`19`/`21`-element JSON float array enforced by `CHECK (fsrs_weights_json IS NULL OR (json_valid(fsrs_weights_json) = 1 AND json_type(fsrs_weights_json) = 'array' AND json_array_length(fsrs_weights_json) IN (17, 19, 21)))`) and `StatsService`/`SpendGuard`. In `R29 settings`, `grading_model` and `tutor_model` are validated dynamically against keys in `token_rates_json` (via `COALESCE(json_extract(token_rates_json, '$."' || grading_model || '".input_micro_per_mtok'), 0) > 0` and domain check `FLD-26` / `TC-I-256`) rather than hard-coding a fixed model enum in SQLite, so adopting a newer Claude model or retiring an old one in `Settings` (`[DOC study-app-spec.md §5]`) never requires a `STRICT` table rebuild migration.
   - `proposal.payload_json`: holds an unapproved candidate card or question draft (`Proposal` queue, `E19`) until it is exported into `feedback.json → proposed` (`REQ-F-049`).
   - `feedback_item.payload_json`: immutable export snapshot written when a `FeedbackItem` (`E20`) is queued for `feedback.json`.
   - `deadline.format_json`: optional informational JSON object (`{ mcq_weight, written_weight, notes }`) imported from `deadlines.json` (`A18`).

---

## 3. Alternatives Considered

### Alternative A: Storing `tags`, `card_ids`, `prerequisites`, `options`, and `marking_points` as JSON Arrays in SQLite
- **Pros:** Fewer SQLite tables (`22` instead of `34`, eliminating the `12` normalized child and associative tables `R04`, `R05`, `R07`, `R12`, `R13`, `R15`, `R18`, `R19`, `R23`, `R26`, `R31`, and `R34`).
- **Why rejected:** Violates `1NF`/`3NF` (`G3.2`, Appendix `B3`) and prevents SQLite foreign-key enforcement (`ON DELETE CASCADE`) when linking `Concept` to `Card` (`concept_card`) or `QuestionAttempt` to `question_marking_point`.

### Alternative B: Splitting `Settings.fsrs_weights_json` into 21 Separate Columns (`w0`..`w20`) and `Proposal.payload_json` into Polymorphic Draft Tables
- **Pros:** Eliminates all JSON columns from SQLite.
- **Why rejected:** `ts-fsrs` v5 passes FSRS-6 weights (`21` floats, or `17`/`19` legacy floats migrated by `migrateParameters`, or `NULL` when using default parameters) as an opaque float array, and `Proposal` items are transient staging drafts exported directly to `feedback.json` (`REQ-F-049`), so polymorphic draft tables add schema complexity with zero query benefit.

---

## 4. Consequences

- **Positive:**
  - Every relation in `A32` and `A33` satisfies `1NF`, `2NF`, and `3NF` with foreign-key referential integrity on all concept-card links, prerequisites, options, marking points, and citations.
  - Zero update, insertion, or deletion anomalies on derived attributes (`retrievability`, `mastery_level`, `total_est_minutes`).
- **Negative / Trade-offs:**
  - `CardRepo` and `QuizRepo` join or batch-load child rows (`card_tag`, `question_option`, `question_marking_point`) via indexed foreign keys in local SQLite (`better-sqlite3`), within the `REQ-N-001` (`<= 100 ms` p95) and `REQ-N-002` (`<= 300 ms` p95) targets (measured in `SL-07` and `SL-08`).
