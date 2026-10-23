# A14 · Activity / BPMN Workflow Diagrams

Owner: Systems Analyst. Stage 2, written 2026-10-21. Catalog entry: A14. Approved and baselined at CP2 (2026-10-21).

This document models the two cross-actor workflows with hand-offs, waiting states, and parallel execution (`A04`):
1. **`WF-01` · Module Generation Pipeline & Independent Reviewer Loop** (`UC-01`–`UC-05`, `REQ-F-001`–`REQ-F-019`, `REQ-F-067`–`REQ-F-075`)
2. **`WF-02` · Daily Study, Written-Answer Marking, Feedback Export & Re-Import Cycle** (`UC-06`–`UC-14`, `UC-19`, `REQ-F-020`–`REQ-F-050`, `REQ-F-063`, `REQ-F-064`, `REQ-F-076`–`REQ-F-085`)

Every diagram satisfies `A14` acceptance checks:
- **Swimlanes:** Each participant has a dedicated `subgraph` swimlane.
- **Labelled gateway branches (`A14.1`):** Every outgoing edge from every `XOR` gateway carries an explicit condition label.
- **Reachability (`A14.2`):** Every path from a start event (`([Start ...])`) reaches a terminal end event (`([End ...])`).
- **Balanced parallelism (`A14.3`):** Every `AND` parallel fork (`FORK_*`) pairs with a corresponding `AND` join (`JOIN_*`).

---

## 1. `WF-01` · Module Generation Pipeline & Independent Reviewer Loop (`UC-01`–`UC-05`)

```mermaid
flowchart TD
  subgraph Lane_Student ["Swimlane 1 · Student (E1)"]
    START_WF1(["Start: Launch Module Pipeline Run"])
    ACT_HUMAN_REV["Review Flagged Items, Confirm Glossary/Deadlines & Spot-Check 10%"]
    GW_SPOT{"XOR: Spot-Check Failure Rate > 20%?"}
    END_WF1_OK(["End: Module Export Package & Run Summary Ready"])
    END_WF1_FAIL(["End: Halted with Ingestion or Schema Error"])
  end

  subgraph Lane_Orch ["Swimlane 2 · Pipeline Orchestrator & Ingestion (P1, P5)"]
    ACT_INGEST["Ingest Canvas (Read-Only) or Local Files & Decode LaTeXiT"]
    GW_SOURCE_OK{"XOR: Readable Source Files Found?"}
    ACT_ORDER["Order CS Modules First & Assessment-Scope Lectures First"]
    FORK_LEC["AND Fork: Dispatch Module Lectures in Parallel"]
    GW_CARD_VERDICT{"XOR: Card Review Outcome?"}
    GW_Q_VERDICT{"XOR: Question Review Outcome?"}
    JOIN_LEC["AND Join: All Module Lectures Completed Stages A & B"]
    GW_SYNTH{"XOR: Synthesis Items Proposed by Auditor?"}
    ACT_QUEUE["Assemble Pre-Export Review Queue & 10% Spot-Check Sample"]
    ACT_VALIDATE["Assign Stable IDs & Validate 6 Export JSON Files Against Schemas"]
    GW_SCHEMA_OK{"XOR: Schema Validation Passed?"}
    ACT_EXPORT["Write 6 Module JSON Exports, Run Summary & Optional Anki TSV"]
  end

  subgraph Lane_Extractor ["Swimlane 3 · Extractor Subagent (E2)"]
    ACT_EXTRACT["Extract Module glossary.json, deadlines.json & readings.json"]
  end

  subgraph Lane_Creator ["Swimlane 4 · Card & Question Creator Subagents (E2)"]
    ACT_DRAFT_CARDS["Stage A: Extract Concept Map (8–20) & Draft 15–40 Atomic Cards"]
    ACT_REV_CARDS["Revise Only 'revise' Cards & Missing Concepts (Round r+1 ≤ 3)"]
    ACT_FLAG_CARDS["Route Unresolved Cards After Round 3 to flagged.json"]
    ACT_DRAFT_QS["Stage B: Draft Concept Question Variants (Core 3–5, Supporting 2–3)"]
    ACT_REV_QS["Revise Only 'revise' Questions & Variant Shortfalls (Round r+1 ≤ 3)"]
    ACT_FLAG_QS["Route Unresolved Questions After Round 3 to flagged.json"]
  end

  subgraph Lane_Reviewer ["Swimlane 5 · Fresh Independent Reviewer Subagents (E2)"]
    ACT_REV_PASS_CARDS["Fresh Card Reviewer: Pass 1 Blind Answer + Pass 2 Rubric & Coverage"]
    ACT_REV_PASS_QS["Fresh Question Reviewer: Pass 1 Blind Stem + Pass 2 Rubric & Variants"]
    ACT_REV_SYNTH["Fresh Reviewer: Evaluate Cross-Lecture Synthesis Items"]
  end

  subgraph Lane_Auditor ["Swimlane 6 · Module Auditor Subagent (E2)"]
    ACT_AUDIT["Audit Learning Outcomes, Assessment Variants, Duplicates & Notation"]
  end

  START_WF1 --> ACT_INGEST
  ACT_INGEST --> GW_SOURCE_OK
  GW_SOURCE_OK -->|No readable files| END_WF1_FAIL
  GW_SOURCE_OK -->|Source files ingested| ACT_EXTRACT
  ACT_EXTRACT --> ACT_ORDER
  ACT_ORDER --> FORK_LEC

  %% Parallel per-lecture branch (Lecture 1 .. Lecture N)
  FORK_LEC -->|Parallel lecture branch i = 1..N| ACT_DRAFT_CARDS
  ACT_DRAFT_CARDS --> ACT_REV_PASS_CARDS
  ACT_REV_PASS_CARDS --> GW_CARD_VERDICT
  GW_CARD_VERDICT -->|All cards accepted| ACT_DRAFT_QS
  GW_CARD_VERDICT -->|Has 'revise' cards and round < 3| ACT_REV_CARDS
  ACT_REV_CARDS --> ACT_REV_PASS_CARDS
  GW_CARD_VERDICT -->|Still failing at round = 3| ACT_FLAG_CARDS
  ACT_FLAG_CARDS --> ACT_DRAFT_QS

  ACT_DRAFT_QS --> ACT_REV_PASS_QS
  ACT_REV_PASS_QS --> GW_Q_VERDICT
  GW_Q_VERDICT -->|All questions accepted| JOIN_LEC
  GW_Q_VERDICT -->|Has 'revise' questions and round < 3| ACT_REV_QS
  ACT_REV_QS --> ACT_REV_PASS_QS
  GW_Q_VERDICT -->|Still failing at round = 3| ACT_FLAG_QS
  ACT_FLAG_QS --> JOIN_LEC

  JOIN_LEC --> ACT_AUDIT
  ACT_AUDIT --> GW_SYNTH
  GW_SYNTH -->|Synthesis items proposed| ACT_REV_SYNTH
  GW_SYNTH -->|No synthesis items proposed| ACT_QUEUE
  ACT_REV_SYNTH --> ACT_QUEUE

  ACT_QUEUE --> ACT_HUMAN_REV
  ACT_HUMAN_REV --> GW_SPOT
  GW_SPOT -->|Rejected > 20% of spot check: re-run lecture| FORK_LEC
  GW_SPOT -->|Approved ≤ 20% rejection rate| ACT_VALIDATE
  ACT_VALIDATE --> GW_SCHEMA_OK
  GW_SCHEMA_OK -->|Schema error| END_WF1_FAIL
  GW_SCHEMA_OK -->|All 6 files valid| ACT_EXPORT
  ACT_EXPORT --> END_WF1_OK
```

---

## 2. `WF-02` · Daily Study, Marking, Feedback Export & Re-Import Cycle (`UC-06`–`UC-14`, `UC-19`)

```mermaid
flowchart TD
  subgraph Lane_S2 ["Swimlane 1 · Student (E1)"]
    START_WF2(["Start: Open Study App or Import Module Exports"])
    ACT_CONFIRM_DIFF["Inspect Import Diff Preview & Confirm Import"]
    ACT_STUDY_PLAN["Open Today Checklist & Start Due Reviews / Quizzes"]
    ACT_RATE_CARD["Reveal Card Back & Rate Recall (Again / Hard / Good / Easy)"]
    ACT_ANS_QUIZ["Submit Quiz Answer or Report Item"]
    ACT_SELF_MARK["Self-Mark Written Answer Against Model Answer & Marking Points"]
    ACT_EXPORT_FB["Trigger Feedback JSON Export for Next Pipeline Run"]
    END_WF2_DONE(["End: Daily Study Session & Feedback Sync Complete"])
    END_WF2_CANCEL(["End: Import Cancelled or Rejected Without DB Write"])
  end

  subgraph Lane_App ["Swimlane 2 · Study App Backend & Scheduler (P7)"]
    ACT_SCHEMA_DIFF["Validate Uploaded JSON & Compute New/Changed/Suspended Diff"]
    GW_IMPORT_OK{"XOR: Valid Schema & Confirmed by Student?"}
    ACT_BACKUP_UPSERT["Create Pre-Import Backup & Upsert Items Preserving FSRS History"]
    ACT_BUILD_TODAY["Build 9-Step Today Checklist & Enforce Daily Time Budget"]
    FORK_STUDY["AND Fork: Execute Due Flashcard Reviews & Concept Quizzes"]
    ACT_FSRS_CARD["Update CardState via ts-fsrs & Append CardReviewLog"]
    GW_ITEM_REPORTED{"XOR: Item Reported as Wrong/Unclear?"}
    ACT_LOG_REPORT["Write FeedbackItem (kind = reported) & Flag Item"]
    GW_Q_TYPE{"XOR: Quiz Marking Mode?"}
    ACT_AUTO_MCQ["Auto-Mark MCQ & Show Model Answer + Distractor Explanations"]
    ACT_FSRS_CONCEPT["Map Outcome to Rating, Update ConceptState & Check Variant Pool"]
    JOIN_STUDY["AND Join: Daily Flashcard & Quiz Queue Completed"]
    GW_HAS_FB{"XOR: Unexported Feedback Items Exist?"}
  end

  subgraph Lane_ClaudeAPI ["Swimlane 3 · Anthropic Claude API (E3)"]
    ACT_CLAUDE_GRADE["Mark Written Answer with Cached Module Glossary & Slides Prefix"]
    GW_API_OK{"XOR: API Response Within 10s & Spend Under Cap?"}
  end

  subgraph Lane_PipeFB ["Swimlane 4 · Generation Pipeline Feedback Re-Run (P6)"]
    ACT_ROUTE_FB["Route reported -> Creator+Reviewer, proposed -> Reviewer, topup -> Question Creator+Reviewer"]
  end

  START_WF2 --> ACT_SCHEMA_DIFF
  ACT_SCHEMA_DIFF --> ACT_CONFIRM_DIFF
  ACT_CONFIRM_DIFF --> GW_IMPORT_OK
  GW_IMPORT_OK -->|Invalid schema or student cancelled| END_WF2_CANCEL
  GW_IMPORT_OK -->|Valid and confirmed| ACT_BACKUP_UPSERT
  ACT_BACKUP_UPSERT --> ACT_BUILD_TODAY
  ACT_BUILD_TODAY --> ACT_STUDY_PLAN
  ACT_STUDY_PLAN --> FORK_STUDY

  %% Parallel study tracks within the daily session
  FORK_STUDY -->|Track 1: Due & New Flashcards| ACT_RATE_CARD
  ACT_RATE_CARD --> ACT_FSRS_CARD
  ACT_FSRS_CARD --> JOIN_STUDY

  FORK_STUDY -->|Track 2: Due Concept Quizzes| ACT_ANS_QUIZ
  ACT_ANS_QUIZ --> GW_ITEM_REPORTED
  GW_ITEM_REPORTED -->|Reported wrong or unclear| ACT_LOG_REPORT
  ACT_LOG_REPORT --> JOIN_STUDY
  GW_ITEM_REPORTED -->|Answer submitted for marking| GW_Q_TYPE

  GW_Q_TYPE -->|MCQ question| ACT_AUTO_MCQ
  GW_Q_TYPE -->|Written self-marking (R1)| ACT_SELF_MARK
  GW_Q_TYPE -->|Written Claude marking (R2+)| ACT_CLAUDE_GRADE

  ACT_CLAUDE_GRADE --> GW_API_OK
  GW_API_OK -->|Success within 10s| ACT_FSRS_CONCEPT
  GW_API_OK -->|Timeout, error, or spend cap reached| ACT_SELF_MARK

  ACT_AUTO_MCQ --> ACT_FSRS_CONCEPT
  ACT_SELF_MARK --> ACT_FSRS_CONCEPT
  ACT_FSRS_CONCEPT --> JOIN_STUDY

  JOIN_STUDY --> GW_HAS_FB
  GW_HAS_FB -->|No pending feedback to export| END_WF2_DONE
  GW_HAS_FB -->|Feedback exported for pipeline re-run| ACT_EXPORT_FB
  ACT_EXPORT_FB --> ACT_ROUTE_FB
  ACT_ROUTE_FB --> ACT_SCHEMA_DIFF
```
