# A15 · Decision Tables

Owner: Systems Analyst. Stage 2, written 2026-10-21. Catalog entry: A15.

This document specifies the 6 decision tables (`DT-01`–`DT-06`) governing multi-condition business logic across the generation pipeline and study app.
- Each table has 3 binary conditions ($2^3 = 8$ complete rules before reduction, 48 complete rules across `DT-01`–`DT-06`).
- Both the **complete table** (`C1`–`C8`) and the **reduced table** (`R1`–`Rk`, using `–` for indifferent conditions) are shown.
- Every complete rule (`DT-01-C1` through `DT-06-C8`) maps to exactly one reduced rule (zero overlap, `A15.2`; every rule has an action, `A15.3`) and to a dedicated acceptance scenario (`AT-051`–`AT-098`) in [`acceptance-scenarios.md`](acceptance-scenarios.md) (`G2.4`, `A15.4`).

---

## 1. `DT-01` · Pipeline Reviewer Verdict & Revision Round Routing

- **Implements:** `REQ-F-009`, `REQ-F-010`, `REQ-F-013`, `REQ-F-014`; `UC-01`, `UC-02`; `BR-012`, `BR-013`, `BR-014`.
- **Complete rule count:** $2^3 = 8$ rules (`DT-01-C1`–`DT-01-C8`).

### 1.1 Complete decision table (`DT-01-C1`–`DT-01-C8`)

| Stub | `C1` | `C2` | `C3` | `C4` | `C5` | `C6` | `C7` | `C8` |
| :-- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Cond 1:** Pass 1 blind-answer matches Creator answer/key AND all non-trivia rubric criteria pass (`failed_criteria` has no fixable quality failure) | Y | Y | Y | Y | N | N | N | N |
| **Cond 2:** Item tests a worthwhile, source-grounded concept (`value` / concept validity passes; item is not trivia or unsalvageable) | Y | Y | N | N | Y | Y | N | N |
| **Cond 3:** Current review round $r < 3$ (revision budget remains) | Y | N | Y | N | Y | N | Y | N |
| **Act 1:** Assign `accept` (`failed_criteria = []`) and freeze item into `*.final.json` | X | X | · | · | · | · | · | · |
| **Act 2:** Assign `revise` (`failed_criteria = [...]`) and route item back to Creator for round $r + 1$ | · | · | · | · | X | · | · | · |
| **Act 3:** Assign `reject`, remove item immediately, and request replacement under a new ID only if concept coverage requires it | · | · | X | · | · | · | X | · |
| **Act 4:** Exhaust revision cap and route item to `flagged.json` (`failed_3_rounds`) | · | · | · | X | · | X | · | X |

### 1.2 Reduced decision table (`DT-01-R1`–`DT-01-R5`) and trace (`G2.4`)

| Reduced rule | Cond 1 | Cond 2 | Cond 3 | Action | Complete rules covered | Acceptance scenarios (`A19`) |
| :-- | :-: | :-: | :-: | :-- | :-- | :-- |
| `DT-01-R1` | Y | Y | – | **Act 1:** Freeze as `accept` (`failed_criteria = []`) | `DT-01-C1`, `DT-01-C2` | `AT-051` (`C1`), `AT-052` (`C2`) |
| `DT-01-R2` | N | Y | Y | **Act 2:** Return as `revise` (`failed_criteria = [...]`) for round $r+1$ | `DT-01-C5` | `AT-055` (`C5`) |
| `DT-01-R3` | – | N | Y | **Act 3:** Remove as `reject` (replace under new ID only if coverage requires) | `DT-01-C3`, `DT-01-C7` | `AT-053` (`C3`), `AT-057` (`C7`) |
| `DT-01-R4` | Y | N | N | **Act 4:** Route to `flagged.json` (`failed_3_rounds`) | `DT-01-C4` | `AT-054` (`C4`) |
| `DT-01-R5` | N | – | N | **Act 4:** Route to `flagged.json` (`failed_3_rounds`) | `DT-01-C6`, `DT-01-C8` | `AT-056` (`C6`), `AT-058` (`C8`) |

---

## 2. `DT-02` · Re-Import Item Matching & State Preservation

- **Implements:** `REQ-F-021`, `REQ-F-022`, `REQ-F-023`; `UC-06`; `BR-021`, `BR-022`.
- **Complete rule count:** $2^3 = 8$ rules (`DT-02-C1`–`DT-02-C8`).

### 2.1 Complete decision table (`DT-02-C1`–`DT-02-C8`)

| Stub | `C1` | `C2` | `C3` | `C4` | `C5` | `C6` | `C7` | `C8` |
| :-- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Cond 1:** Item `id` exists in local database for this lecture | Y | Y | Y | Y | N | N | N | N |
| **Cond 2:** Item `id` is present in incoming lecture export file | Y | Y | N | N | Y | Y | N | N |
| **Cond 3:** Incoming content fields differ from stored content fields | Y | N | Y | N | Y | N | Y | N |
| **Act 1:** Update content fields in place; preserve FSRS state & review logs | X | · | · | · | · | · | · | · |
| **Act 2:** Keep item and FSRS state unchanged (count as unchanged in diff) | · | X | · | · | · | · | · | · |
| **Act 3:** Set `suspended = true` (never delete item or FSRS review history) | · | · | X | X | · | · | · | · |
| **Act 4:** Insert new item and initialize `CardState`/`ConceptState` (`state = "new"`) | · | · | · | · | X | X | · | · |
| **Act 5:** No-op (item absent from both database and import file) | · | · | · | · | · | · | X | X |

### 2.2 Reduced decision table (`DT-02-R1`–`DT-02-R5`) and trace (`G2.4`)

| Reduced rule | Cond 1 | Cond 2 | Cond 3 | Action | Complete rules covered | Acceptance scenarios (`A19`) |
| :-- | :-: | :-: | :-: | :-- | :-- | :-- |
| `DT-02-R1` | Y | Y | Y | **Act 1:** Update content; preserve FSRS state & logs | `DT-02-C1` | `AT-059` (`C1`) |
| `DT-02-R2` | Y | Y | N | **Act 2:** Keep unchanged; preserve FSRS state & logs | `DT-02-C2` | `AT-060` (`C2`) |
| `DT-02-R3` | Y | N | – | **Act 3:** Mark `suspended = true`; preserve history | `DT-02-C3`, `DT-02-C4` | `AT-061` (`C3`), `AT-062` (`C4`) |
| `DT-02-R4` | N | Y | – | **Act 4:** Insert new item (`state = "new"`) | `DT-02-C5`, `DT-02-C6` | `AT-063` (`C5`), `AT-064` (`C6`) |
| `DT-02-R5` | N | N | – | **Act 5:** No-op (absent from DB and payload) | `DT-02-C7`, `DT-02-C8` | `AT-065` (`C7`), `AT-066` (`C8`) |

---

## 3. `DT-03` · Daily Concept Quiz Variant Selection & Top-Up Trigger

- **Implements:** `REQ-F-030`, `REQ-F-031`; `UC-08`; `BR-029`, `BR-030`.
- **Complete rule count:** $2^3 = 8$ rules (`DT-03-C1`–`DT-03-C8`).

### 3.1 Complete decision table (`DT-03-C1`–`DT-03-C8`)

| Stub | `C1` | `C2` | `C3` | `C4` | `C5` | `C6` | `C7` | `C8` |
| :-- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Cond 1:** Concept has ≥ 1 non-flagged, non-suspended variant | Y | Y | Y | Y | N | N | N | N |
| **Cond 2:** Concept has ≥ 1 never-seen non-flagged, non-suspended variant | Y | Y | N | N | Y | Y | N | N |
| **Cond 3:** Multiple candidate variants tie on unseen / least-recently-seen priority | Y | N | Y | N | Y | N | Y | N |
| **Act 1:** Serve unseen variant closest to stability target difficulty (`1`/`2`/`3`) | X | · | · | · | · | · | · | · |
| **Act 2:** Serve the single unseen variant | · | X | · | · | · | · | · | · |
| **Act 3:** Serve least-recently-seen variant closest to target difficulty + log `topup` | · | · | X | · | · | · | · | · |
| **Act 4:** Serve the single least-recently-seen variant + log `topup` | · | · | · | X | · | · | · | · |
| **Act 5:** Skip concept in quiz session + log `topup` `FeedbackItem` | · | · | · | · | X | X | X | X |

### 3.2 Reduced decision table (`DT-03-R1`–`DT-03-R5`) and trace (`G2.4`)

| Reduced rule | Cond 1 | Cond 2 | Cond 3 | Action | Complete rules covered | Acceptance scenarios (`A19`) |
| :-- | :-: | :-: | :-: | :-- | :-- | :-- |
| `DT-03-R1` | Y | Y | Y | **Act 1:** Serve unseen variant closest to target difficulty | `DT-03-C1` | `AT-067` (`C1`) |
| `DT-03-R2` | Y | Y | N | **Act 2:** Serve sole unseen variant | `DT-03-C2` | `AT-068` (`C2`) |
| `DT-03-R3` | Y | N | Y | **Act 3:** Serve LRS variant closest to target difficulty + log `topup` | `DT-03-C3` | `AT-069` (`C3`) |
| `DT-03-R4` | Y | N | N | **Act 4:** Serve sole LRS variant + log `topup` | `DT-03-C4` | `AT-070` (`C4`) |
| `DT-03-R5` | N | – | – | **Act 5:** Skip concept + log `topup` `FeedbackItem` | `DT-03-C5`–`DT-03-C8` | `AT-071` (`C5`), `AT-072` (`C6`), `AT-073` (`C7`), `AT-074` (`C8`) |

> *Note (`Obs 2`): Columns `C5` (`N, Y, Y`) and `C6` (`N, Y, N`) are logically unreachable because the unseen non-flagged variant set is a subset of all non-flagged variants (`|V_unseen| <= |V_avail|`); they are included for complete $2^3 = 8$ binary enumeration (`A15.1`) and handled as defensive fallback states under `DT-03-R5`.*

---

## 4. `DT-04` · Quiz Attempt Outcome to Concept FSRS Rating Mapping

- **Implements:** `REQ-F-032`–`REQ-F-034`, `REQ-F-043`; `UC-08`, `UC-12`; `BR-031`, `BR-032`.
- **Complete rule count:** $2^3 = 8$ rules (`DT-04-C1`–`DT-04-C8`).

### 4.1 Complete decision table (`DT-04-C1`–`DT-04-C8`)

| Stub | `C1` | `C2` | `C3` | `C4` | `C5` | `C6` | `C7` | `C8` |
| :-- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Cond 1:** All marking points met (or MCQ selected option == `correct_option`) | Y | Y | Y | Y | N | N | N | N |
| **Cond 2:** At least one marking point met (partial credit > 0) | Y | Y | N | N | Y | Y | N | N |
| **Cond 3:** Answered quickly and marked easy by student/grader | Y | N | Y | N | Y | N | Y | N |
| **Act 1:** Rate `Easy` (`4`); update `ConceptState` via `ts-fsrs` | X | · | X | · | · | · | · | · |
| **Act 2:** Rate `Good` (`3`); update `ConceptState` via `ts-fsrs` | · | X | · | X | · | · | · | · |
| **Act 3:** Rate `Hard` (`2`); update `ConceptState` via `ts-fsrs` | · | · | · | · | X | X | · | · |
| **Act 4:** Rate `Again` (`1`); update `ConceptState` + offer linked flashcards (`card_ids`) | · | · | · | · | · | · | X | X |

### 4.2 Reduced decision table (`DT-04-R1`–`DT-04-R4`) and trace (`G2.4`)

| Reduced rule | Cond 1 | Cond 2 | Cond 3 | Action | Complete rules covered | Acceptance scenarios (`A19`) |
| :-- | :-: | :-: | :-: | :-- | :-- | :-- |
| `DT-04-R1` | Y | – | Y | **Act 1:** Rate `Easy` (`4`) and update `ConceptState` | `DT-04-C1`, `DT-04-C3` | `AT-075` (`C1`), `AT-077` (`C3`) |
| `DT-04-R2` | Y | – | N | **Act 2:** Rate `Good` (`3`) and update `ConceptState` | `DT-04-C2`, `DT-04-C4` | `AT-076` (`C2`), `AT-078` (`C4`) |
| `DT-04-R3` | N | Y | – | **Act 3:** Rate `Hard` (`2`) and update `ConceptState` | `DT-04-C5`, `DT-04-C6` | `AT-079` (`C5`), `AT-080` (`C6`) |
| `DT-04-R4` | N | N | – | **Act 4:** Rate `Again` (`1`), update `ConceptState`, offer `card_ids` | `DT-04-C7`, `DT-04-C8` | `AT-081` (`C7`), `AT-082` (`C8`) |

---

## 5. `DT-05` · Deadline Urgency Classification & Confirmation Badge

- **Implements:** `REQ-F-035`, `REQ-F-037`, `REQ-N-018`; `UC-09`; `BR-033`, `BR-034`.
- **Complete rule count:** $2^3 = 8$ rules (`DT-05-C1`–`DT-05-C8`).

### 5.1 Complete decision table (`DT-05-C1`–`DT-05-C8`)

| Stub | `C1` | `C2` | `C3` | `C4` | `C5` | `C6` | `C7` | `C8` |
| :-- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Cond 1:** Deadline has a future UTC `due_at` (`due_at != null` and `remaining > 0`) | Y | Y | Y | Y | N | N | N | N |
| **Cond 2:** Remaining time `< 7 days` (when `Cond 1 = Y`) or past due (`due_at <= now` when `Cond 1 = N`) | Y | Y | N | N | Y | Y | N | N |
| **Cond 3:** `confidence == "inferred"` and `manually_edited == false` | Y | N | Y | N | Y | N | Y | N |
| **Act 1:** High-urgency red badge + icon/label (hours/mins if `< 48 h`) + `Confirm` badge | X | · | · | · | · | · | · | · |
| **Act 2:** High-urgency red badge + icon/label (hours/mins if `< 48 h`), no `Confirm` badge | · | X | · | · | · | · | · | · |
| **Act 3:** Standard (`> 14 d` neutral / `7–14 d` amber) badge + label + `Confirm` badge | · | · | X | · | · | · | · | · |
| **Act 4:** Standard (`> 14 d` neutral / `7–14 d` amber) badge + label, no `Confirm` badge | · | · | · | X | · | · | · | · |
| **Act 5:** Overdue grey badge + `Overdue` label + `Submitted?` control | · | · | · | · | X | X | · | · |
| **Act 6:** `Unannounced (TBD)` badge + `Confirm` badge | · | · | · | · | · | · | X | · |
| **Act 7:** `Unannounced (TBD)` badge, no `Confirm` badge | · | · | · | · | · | · | · | X |

### 5.2 Reduced decision table (`DT-05-R1`–`DT-05-R7`) and trace (`G2.4`)

| Reduced rule | Cond 1 | Cond 2 | Cond 3 | Action | Complete rules covered | Acceptance scenarios (`A19`) |
| :-- | :-: | :-: | :-: | :-- | :-- | :-- |
| `DT-05-R1` | Y | Y | Y | **Act 1:** Red urgency badge + icon/label + `Confirm` badge | `DT-05-C1` | `AT-083` (`C1`) |
| `DT-05-R2` | Y | Y | N | **Act 2:** Red urgency badge + icon/label | `DT-05-C2` | `AT-084` (`C2`) |
| `DT-05-R3` | Y | N | Y | **Act 3:** Amber/neutral badge + label + `Confirm` badge | `DT-05-C3` | `AT-085` (`C3`) |
| `DT-05-R4` | Y | N | N | **Act 4:** Amber/neutral badge + label | `DT-05-C4` | `AT-086` (`C4`) |
| `DT-05-R5` | N | Y | – | **Act 5:** Overdue grey badge + `Submitted?` control | `DT-05-C5`, `DT-05-C6` | `AT-087` (`C5`), `AT-088` (`C6`) |
| `DT-05-R6` | N | N | Y | **Act 6:** `Unannounced (TBD)` + `Confirm` badge | `DT-05-C7` | `AT-089` (`C7`) |
| `DT-05-R7` | N | N | N | **Act 7:** `Unannounced (TBD)` badge | `DT-05-C8` | `AT-090` (`C8`) |

---

## 6. `DT-06` · Daily Plan Time-Budget Enforcement (`daily_budget_min`)

- **Implements:** `REQ-F-039`, `REQ-F-055`; `UC-10`, `UC-16`; `BR-036`, `BR-037`.
- **Complete rule count:** $2^3 = 8$ rules (`DT-06-C1`–`DT-06-C8`).

### 6.1 Complete decision table (`DT-06-C1`–`DT-06-C8`)

| Stub | `C1` | `C2` | `C3` | `C4` | `C5` | `C6` | `C7` | `C8` |
| :-- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Cond 1:** Total estimated duration (`required + optional`) > `daily_budget_min` | Y | Y | Y | Y | N | N | N | N |
| **Cond 2:** Total estimated duration of `required` items alone > `daily_budget_min` | Y | Y | N | N | Y | Y | N | N |
| **Cond 3:** Candidate plan contains ≥ 1 `optional` item | Y | N | Y | N | Y | N | Y | N |
| **Act 1:** Defer all `optional` items; keep all `required` items; show over-budget warning | X | · | · | · | · | · | · | · |
| **Act 2:** Keep all `required` items; show over-budget warning | · | X | · | · | · | · | · | · |
| **Act 3:** Defer `optional` items in reverse priority order until total ≤ `daily_budget_min` | · | · | X | · | · | · | · | · |
| **Act 4:** Keep all candidate items on today's plan without deferral or warning | · | · | · | X | X | X | X | X |

### 6.2 Reduced decision table (`DT-06-R1`–`DT-06-R5`) and trace (`G2.4`)

| Reduced rule | Cond 1 | Cond 2 | Cond 3 | Action | Complete rules covered | Acceptance scenarios (`A19`) |
| :-- | :-: | :-: | :-: | :-- | :-- | :-- |
| `DT-06-R1` | Y | Y | Y | **Act 1:** Defer all `optional`, keep all `required`, warn over-budget | `DT-06-C1` | `AT-091` (`C1`) |
| `DT-06-R2` | Y | Y | N | **Act 2:** Keep all `required`, warn over-budget | `DT-06-C2` | `AT-092` (`C2`) |
| `DT-06-R3` | Y | N | Y | **Act 3:** Defer `optional` items until total ≤ `daily_budget_min` | `DT-06-C3` | `AT-093` (`C3`) |
| `DT-06-R4` | Y | N | N | **Act 4:** Keep all items (defensive no-optional state) | `DT-06-C4` | `AT-094` (`C4`) |
| `DT-06-R5` | N | – | – | **Act 4:** Keep all candidate items (within budget) | `DT-06-C5`–`DT-06-C8` | `AT-095` (`C5`), `AT-096` (`C6`), `AT-097` (`C7`), `AT-098` (`C8`) |

> *Note (`Obs 2`): Columns `C4` (`Y, N, N`), `C5` (`N, Y, Y`), and `C6` (`N, Y, N`) are logically unreachable because `total_duration = required_duration + optional_duration >= required_duration` (with `optional_duration = 0` when `Cond 3 = N`); they are included for complete $2^3 = 8$ binary enumeration (`A15.1`) and handled as defensive fallback states under `DT-06-R4` and `DT-06-R5`.*
