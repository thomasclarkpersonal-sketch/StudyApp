# Checkpoints and Escalations

Protocol §7 and §8.1 step 8. Each checkpoint message and the user's reply is recorded here verbatim, as are escalation records.

## CP1 — Scope and Plan (2026-10-21, STRICT)

Status: **Approved** (2026-10-21). Baseline set: `A01`, `A02`, `A03`, `A04`, `A05` (with `wbs.csv`), `A06` (with `schedule_calc.py`), `A07`.

```text
HUMAN CHECKPOINT CP1 — Scope and Plan
Decision needed: Approve | Approve with changes | Reject

Summary
- Produced and reviewed Stage 1 initiation artifacts A01–A07 (plus A00 updates) on branch stage-1/initiation; Gate G1 passed at r2 (29 PASS / 0 FAIL / 2 N/A, workbook/00-governance/reviews/G1-r2.md) after resolving G1-r1's G1.10 consistency finding and all 17 observations (workbook/00-governance/dispositions.md).
- Charter & scope (A01, workbook/01-initiation/charter-scope.md): 11 generation-pipeline items (P1–P11, running in Claude Code on your subscription) and 16 study-app items (A1–A16, laptop-first PWA until R3), plus 9 explicit out-of-scope items (X1–X9, including Mandarin X8 and Anki import X9, and replacing the manual LMS download non-goal with read-only Canvas access in P8/X3 per DEC-009).
- Proposed release structure (DEC-010, for your confirmation): three releases — R1 (Must stories 1–11, including P8 Canvas reading and a minimal report export for story 11), R2 (Should stories 12–16 plus A12 Stats page so SM-3 and SM-6 are visible in R2), and R3 (Could stories 17–20: hosted phone/offline access, full feedback.json, FSRS optimiser/forecasts, Anki TSV export).
- Success metrics (A01 §3, workbook/01-initiation/charter-scope.md#3-objectives-and-success-metrics): SM-3 (<2% accepted items reported wrong), SM-4a (no missed deadlines), SM-4b (daily checklist completed ≥5 days/week) and SM-5 (each concept in scope quizzed ≥2 times before assessment) kept as in the seed; SM-1 (process all lectures covered by each assessment ≥7 days before it, starting with the CS finals by 30 Nov 2026), SM-2 (≥85% true retention over trailing 30 days from the review log, with FSRS desired retention 0.90) and SM-6 (monthly Claude API spend visible on the Stats page from R2) are proposed restatements/readings for your confirmation.
- Economic feasibility (A02 §1, workbook/01-initiation/feasibility.md#1-economic): 36-month cash TCO is $72–$1,800 ($2–$50/month: $0 in R1, $2–$40/month app Claude API in R2, $0–$10/month hosting in R3), or $72–$5,400 ($2–$150/month) if your Claude subscription needs a one-step upgrade ($80–$100/month); build session and CI critic usage are excluded (ASM-064).
- Time & payback model (A02 §1.2–§1.3): separates agent session time (ASM-052/ASM-053: 118.97 h total across 65 work packages and 7 gate/checkpoint milestones) from your active build time (ASM-055: 15–40 h, most likely 25 h). Saving 45 min/lecture most likely (60 min manual vs 15 min human review) pays back 25 h of active build time in ~34 lectures (within one semester of 40–104 lectures), or ~159 lectures (1.5–4 semesters) if you sit through all ~119 h of session time.
- Technical feasibility & riskiest-first order (A02 §2, A03, A06): the COMP 4901B sample lecture has 25 of 60 content slides image-led and 17 slides with embedded LaTeXiT equations (ASM-016 refuted, ASM-046, RSK-002 H/H). Slice SL-01 (walking skeleton) runs one real lecture (slide images + extracted text + recovered LaTeX → Card Creator → fresh Card Reviewer → app import and card review) immediately after CP3, preceded by the A42 evaluation set (WBS 3.11), and all pipeline slices (SL-01–SL-05) precede app slices (SL-06–SL-11).
- Schedule & lecture-processing window (A02 §4, A06, workbook/01-initiation/schedule.md): at 3 h/day of session time from 21 Oct 2026 (range 4 h/day fast to 2 h/day slow), CP2 is 29 Oct (26 Oct–4 Nov), CP3 is 3 Nov (30 Oct–12 Nov), pipeline complete (SL-05) is 9 Nov (3–21 Nov), R1 is 16 Nov (8 Nov–3 Dec, before the 7–19 Dec HKUST exam period in all cases), R2 is 23 Nov (12 Nov–13 Dec), R3 is 27 Nov (16 Nov–20 Dec), and closedown is 28 Nov (17 Nov–22 Dec). Processing 30–78 CS lectures by 30 Nov takes 7.5–19.5 h of Claude Code run time plus 5.0–32.5 h of your active human-review time (0.24–1.55 h/day over 21 days at 3 h/day, or 0.56–3.61 h/day over 9 days in the slow case, against a 1.5 h/day allowance in ASM-063).
- Tailoring Record (A04, workbook/01-initiation/tailoring.md): Tier M, project types BIS (study app) + DATA (generation pipeline), risk flags PD, INT and AI set; object-oriented models for the app and DFDs for the pipeline (DEC-011); 43 of 48 catalog artifacts produced (A12, A14, A38, A71 in reduced form) and 5 skipped (A21, A51, A62, A64, and A65 as a proportionality departure from an R-at-M entry for your confirmation).

Assumptions that need your confirmation (high impact, low or medium confidence, or marked for this checkpoint)
- ASM-001 (H/H): Both the study app and the multi-agent generation pipeline are in scope — if wrong: scope, WBS and schedule shrink to one subsystem.
- ASM-021 (H/H): Single user (you) who also runs the pipeline, with no accounts or multi-user features — if wrong: requires authentication, tenant isolation and MT flag.
- ASM-044 (H/L): Your Claude subscription's rolling and weekly usage limits allow the CS lectures to be processed at the pace needed between SL-05 and 30 Nov — if wrong: pipeline runs stall and require batching across windows, upgrading one plan step (+$80–$100/mo, ASM-062) or API billing (with your prior approval).
- ASM-045 (H/M): The first midterm is within 2 weeks of 20 Oct 2026 in a module other than COMP 4901B (which has no midterm), and the HKUST final exam period is 7–19 Dec 2026 — if wrong: target dates in A01 §3 (SM-1) and A02 §4 shift.
- ASM-046 (H/M): Reading slide page images alongside extracted text and recovered LaTeXiT source gives Creators and Reviewers enough content for maths- and diagram-heavy decks — if wrong: image-led slides must be flagged for manual notes (`RSK-002` contingency).
- ASM-050 (H/H): Your Canvas credential (token or browser session) is treated like the Claude API key (stored outside the repo and browser, never committed) — if wrong: credential exposure risk (`RSK-013`).
- ASM-053 (H/L): The project runs for 2–4 hours of agent session time a day (most likely 3 h/day, every day), while your active build time is 15–40 h (most likely 25 h, ASM-055) — if wrong: all derived milestone dates in A01 §9 and A06 shift proportionally (`RSK-001`, `RSK-015`).
- ASM-058 (H/M): Running your personal generation pipeline in Claude Code on your subscription is within Anthropic's terms — if wrong: the pipeline must move to API billing (`RSK-021`).
- ASM-063 (M/L): Between SL-05 and 30 Nov 2026, you can give up to 1.5 h/day of active time to the human review step for the CS lectures (10–25 min/lecture, ASM-057), vs 30–90 min/lecture to make cards by hand (ASM-056) — if wrong: only lectures in the nearest assessment's scope are processed before 30 Nov (`RSK-017` contingency), or payback takes longer (`RSK-019`).
- ASM-064 (M/M): Build sessions and the CI critic (`.github/workflows/critic.yml`) are excluded from the app's TCO and share subscription quota when run on your subscription token — if wrong: build/critic usage can contend with lecture processing (`RSK-004`).
- Other CP1-tagged assumptions in A00 (`workbook/00-governance/assumptions-decisions.md`): `ASM-015` (tech comfort medium–high, NTU not set), `ASM-019` and `ASM-043` (API billing needed only from R2), `ASM-020` (English only), `ASM-022` (default time zone `Asia/Hong_Kong`), `ASM-025` (review history kept indefinitely), `ASM-026` (working name "Study App"), `ASM-029` (no technologies to avoid), `ASM-030` (no cash build budget), `ASM-032` (keep studying your usual way until R1), `ASM-033`–`ASM-035` (FIN, REG, HA not set), `ASM-036` (SM-1, SM-2, SM-6 proposals), `ASM-038` (reported items exported for the next pipeline run in R1), `ASM-047`–`ASM-049` and `ASM-061` (read-only Canvas access for in-scope modules only, with manual download fallback if HKUST terms disallow automated access), `ASM-051` (10–26 lecture decks per module), `ASM-052` (effort estimates are agent judgement), `ASM-054` (36-month economic horizon).

Questions and observations raised since the last checkpoint
- Q-16 (open from Stage 0): What question types will the COMP 4901B closed-book final exam use (MCQ, short written, calculation/derivation, or unknown until announced on Canvas)? — default if you don't answer: record as unknown in `pipeline.config.json` until announced on Canvas, and generate a balanced mix of MCQ and short-written variants (`ASM-047`).
- Proposal DEC-010 & schedule choice (G1-r1 Obs 3, A02 §4, A06): Confirm the 3-release split (R1 Must including P8 Canvas reading, R2 Should plus A12 Stats page, R3 Could) and whether to continue straight into R2/R3 after R1 or pause R2/R3 until after the 7–19 Dec exam period — default if you don't answer: adopt `DEC-010` as written and decide at R1's CP4 whether to pause R2/R3 for exams.
- Proposal SM-1, SM-2, SM-6 (G1-r1 Obs 2, A01 §3): Confirm the restated SM-1 (lectures processed ≥7 days before each post-R1 assessment, starting with CS finals by 30 Nov), the SM-2 reading (≥85% true retention over trailing 30 days from the review log), and the restated SM-6 (monthly Claude API spend visible from R2) — default if you don't answer: adopt all three in A01 §3.
- Tailoring departure A65 (G1-r1 Obs 10, A04 §5): Confirm skipping A65 (Adoption & Change Plan, which catalog §3 marks R at tier M) because you are the sole user and commissioner and metric measurement is covered in A01 and A72 — default if you don't answer: keep A65 skipped.

Changes to baselined artifacts since the last checkpoint
- None (no artifact is baselined yet; this checkpoint sets the first baseline).

Risks you are being asked to accept
- None as unmitigated residual risks at CP1; all 22 risks in A03 (`workbook/01-initiation/risk-register.md`) have active mitigations and contingencies, with `RSK-002` (H/H, slide content in images and embedded LaTeXiT equations), `RSK-004` (M/H, subscription usage limits) and `RSK-018` (M/H, Reviewer independence in Claude Code) scheduled to be retired first in `SL-01`.

On approval, these artifacts become the baseline: A01, A02, A03, A04, A05 (with wbs.csv), A06 (with schedule_calc.py), A07
Full detail: workbook/README.md
```

### User reply (verbatim, 2026-10-21)

```text
Approve
```

---

## CP2 — Requirements Baseline and Sourcing Decision (2026-10-21, STRICT)

Status: **Approved** (2026-10-21). Baseline set: `A09` (with `02-analysis/sources/`), `A10` (with `requirements.csv`), `A11`, `A12`, `A13`, `A14`, `A15`, `A16`, `A17`, `A18` (with `data-dictionary.csv`), `A19` (with `acceptance-scenarios.csv`), `A20`, `A22`, and `traceability-matrix.md` (with `traceability-matrix.csv`), joining `A01`–`A07`.

```text
HUMAN CHECKPOINT CP2 — Requirements Baseline and Sourcing Decision
Decision needed: Approve | Approve with changes | Reject

Summary
- Produced and reviewed all Stage 2 requirements and sourcing artifacts (A09–A20, A22, plus A00 updates and the populated traceability-matrix.md/.csv) on branch stage-2/requirements; Gate G2 passed at r2 (58 PASS / 0 FAIL / 1 N/A, workbook/00-governance/reviews/G2-r2.md) after resolving all 11 G2-r1 findings and 2 observations (workbook/00-governance/dispositions.md).
- Requirements Sources & Document Analysis (A09, workbook/02-analysis/requirements-sources.md): analysed all 7 sources (SRC-01–SRC-07), including a full structural analysis of your COMP 4901B syllabus (SRC-05) and 61-page RL lecture PDF (SRC-06: 25/60 content slides image-led, 17 slides with embedded LaTeXiT equations, garbled text ligatures) with zero copyrighted prose or staff PII committed (DEC-008), and resolved all 9 cross-document contradictions (C-01–C-09).
- Requirements Catalog (A10, workbook/02-analysis/requirements.md & requirements.csv): 89 atomic, testable requirements — 66 functional (REQ-F-001–REQ-F-066: 40 Must in R1, 16 Should in R2, 10 Could in R3) and 23 non-functional with numerical targets (REQ-N-001–REQ-N-023: 18 Must, 4 Should, 1 Could) — plus 4 user decision points (UDP-01–UDP-04 from seed §10) and 9 out-of-scope items (X1–X9).
- 14 Requirements marked **(Proposal for CP2)** (listed in A10 §2–§3, workbook/02-analysis/requirements.md): 8 functional proposals (REQ-F-001 LaTeXiT equation recovery, REQ-F-023 first-lapse/retrievability fields for SM-2, REQ-F-026 daily new-card cap default 20, REQ-F-040 7-day checklist count for SM-4b, REQ-F-042 structured wrong/unclear report reason for SM-3, REQ-F-048 Stats dashboard for SM-2/3/5/6 in R2, REQ-F-052 tutor thread deletion) and 7 non-functional proposals (REQ-N-001–REQ-N-006 latency/throughput targets from seed §7, and REQ-N-017 on-demand cleanup of intermediate pipeline round files).
- System boundary & data flow models (A11, A12, workbook/02-analysis/context-diagram.md & dfd.md): Context Diagram (P0 with 6 external entities E1–E6 and 25 boundary flows CF-01–CF-25) balanced 1-for-1 against the Level-0 DFD (processes P1–P7, data stores D1–D9) and all 7 Level-1 DFDs (22 primitive processes).
- Behavioural models (A13, A14, A15, workbook/02-analysis/use-cases.md, workflows.md & decision-tables.md): 21 use cases (UC-01–UC-21: 11 Must, 6 Should, 4 Could) with 45 failure/fallback/cancel extensions; 2 end-to-end multi-lane workflow diagrams (WF-01 pipeline generation/review/audit/import, WF-02 daily study loop) with finite exit conditions on all 7 loops; and 6 complete (2^3 = 8 columns each, 48 rules) and reduced (31 rules) decision tables (DT-01–DT-06), including pass/fail 8-criterion rubric routing with round 1–2 immediate removal on reject (DT-01) and lossless re-import diffing (DT-02).
- Conceptual Data Model, Business Rules & Glossary (A16, A17, A18, workbook/02-analysis/conceptual-data-model.md, business-rules.md, glossary.md & data-dictionary.csv): 28 conceptual entities (E01–E28), 32 relationships (REL-01–REL-32), and CRUD matrix; 45 atomic business rules (BR-001–BR-045, preserving your exact <~15-word card answer limit, pass/fail 8-criterion rubrics, and <MODULE>-<WEEK>-K<nn>/-C<nnn>/-Q<nnn> IDs); and 34 domain glossary terms plus 262 attributes synchronised 1-for-1 between A16 and A18.
- Acceptance Scenarios & Master Test Plan (A19, A20, workbook/02-analysis/acceptance-scenarios.md, acceptance-scenarios.csv & master-test-plan.md): 137 observable Given/When/Then scenarios (AT-001–AT-137) covering every requirement, use case main flow, extension, and decision-table column; and a 4-level test plan (Unit, Integration/Contract, System/NFR, and single-student UAT) with concrete verification methods for all 23 REQ-Ns and SM-1–SM-6.
- Sourcing Decision (A22, workbook/02-analysis/sourcing.md, DEC-013): evaluated 4 options against your user-stated Must requirements (and separately against CP2 proposals and seed §10 guardrails) over the 36-month horizon — Opt 1 Custom Build (Pipeline + Integrated Study App, $72–$1,800 base TCO / $72–$5,400 with subscription upgrade contingency, 15–40 h active student time, 49/49 user-stated Musts met natively), Opt 2 Anki Hybrid ($96.99–$1,824.99 base / $96.99–$5,424.99 with contingency on iOS, 12–30 h active time, 29 native / 15 custom-companion / 5 unmet Musts), Opt 3 RemNote Pro SaaS ($288–$720, ruled out by third-party cloud upload of copyrighted HKUST slides and missing concept-level FSRS), and Opt 4 Obsidian + Plugins ($0–$1,728, ruled out by lack of concept-level FSRS, multi-variant quiz rotation, and fragile re-imports). Recommends Opt 1 (Custom Build).

Assumptions that need your confirmation (high impact, low or medium confidence, or marked for this checkpoint)
- ASM-037 (M/M, CP2): The performance targets in seed §7 (REQ-N-001–REQ-N-006: <=100 ms card flip/rate p95, <=300 ms page load p95, <=8 s Claude short-answer marking p90, <=3 s tutor first token p90, <=10 s module import p90, <=15 min/lecture pipeline run p90) are adopted as baseline targets — if wrong: we adjust the numerical thresholds in A10 §3 and A20 §5.
- ASM-058 (H/M, verified 2026-10-21 in A22 §1 & A00): Running your personal generation pipeline interactively in Claude Code on your individual subscription is permitted by Anthropic's Consumer Terms, while unattended cron runs and embedded web-app calls (R2 marking/tutor) are kept off the subscription (BR-006, BR-043) — if wrong: pipeline runs move to API billing with your prior approval (UDP-01, RSK-021).
- ASM-059 (M/M, verified 2026-10-21 in A22 §3 & A00): Official Anthropic API token rates (Haiku 4.5 $1/$5 per MTok, Sonnet 4.6 $3/$15 per MTok, prompt cache read 0.1x / 5-min write 1.25x) give $2–$40/month ($72–$1,440 over 36 months) for R2 marking and tutor — if wrong: we update the default cost table in REQ-F-048 and TCO figures in A02/A22.
- ASM-062 (M/M, verified 2026-10-21 in A22 §3 & A00): Official Claude subscription tiers are Pro ($20/mo), Max 5x ($100/mo, +$80/mo step), and Max 20x ($200/mo, +$100/mo step) — if wrong: we update the $0–$100/mo upgrade contingency in A02/A22.
- ASM-023 (L/M, CP2): Tutor threads are kept for the current semester with a one-click Delete Thread action (REQ-F-052, BR-040) — if wrong: we can keep threads indefinitely or auto-purge after N days.
- ASM-024 (L/M, CP2): Pipeline intermediate files (cards.round*.json, review.round*.json) are kept until module sign-off and cleaned up on demand while preserving *.final.json, flagged.json, and run-summary.json (REQ-N-017) — if wrong: we retain all intermediate round files indefinitely.
- ASM-027 (L/M, CP2): When R3 adds phone access (REQ-F-059–REQ-F-061), target mobile browsers are current iOS Safari and Android Chrome down to a 375 px viewport width (REQ-N-019) — if wrong: we narrow mobile testing to your specific phone browser/OS.
- ASM-044 (H/L, carried from CP1): Your Claude subscription's rolling and weekly limits sustain the CS lecture-processing pace between SL-05 and 30 Nov — if wrong: batch across windows, upgrade one plan step (+$80–$100/mo), or switch to API billing with your approval (tested first in SL-01).

Questions and observations raised since the last checkpoint
- Sourcing choice (A22 §4, DEC-013, protocol §6 Stage 2 step 6): Do you approve Option 1 (Custom Build — Pipeline + Integrated Study App, reusing ts-fsrs, KaTeX, SQLite, Ajv, and @anthropic-ai/sdk) or prefer Option 2 (Anki Hybrid + smaller companion app)? — default if you reply Approve: adopt Option 1 (Custom Build) for Stage 3 architecture and design.
- 14 Proposed requirements (A10 §2–§3): Do you approve the 14 requirements marked **(Proposal for CP2)** (REQ-F-001 LaTeXiT recovery, REQ-F-023/026/040/042/048 metric & cap fields, REQ-F-052 tutor thread delete, REQ-N-001–006 latency/runtime targets, REQ-N-017 intermediate file cleanup)? — default if you reply Approve: adopt all 14 into the A10 baseline.

Changes to baselined artifacts since the last checkpoint
- None (zero edits to A01–A07 or study-app-seed-spec.md).

Risks you are being asked to accept
- None as unmitigated residual risks at CP2; all 22 risks in A03 remain mitigated, with RSK-002 (image-led & LaTeXiT slides), RSK-004 (subscription rate limits), and RSK-018 (fresh Reviewer context isolation) scheduled for empirical validation in SL-01 immediately after Stage 3.

On approval, these artifacts become the baseline: A09 (with 02-analysis/sources/), A10 (with requirements.csv), A11, A12, A13, A14, A15, A16, A17, A18 (with data-dictionary.csv), A19 (with acceptance-scenarios.csv), A20, A22, and traceability-matrix.md (with traceability-matrix.csv)
Full detail: workbook/README.md
```

### User reply (verbatim, 2026-10-21)

```text
Approve
```

**Clarification (2026-10-21, post-rebase onto `main`):** The sent `CP2` message block and verbatim reply above are preserved unedited (`R1`). For exact cross-reference alignment with the baselined Stage 1–2 files:
- **Decision & Change Request IDs:** Because `DEC-014` (`Q-16` fallback) and `CR-001` were recorded on `stage-1/initiation` (PR `#4`), the `CP2` Sourcing Decision (`A22`, written `DEC-013` in lines 78 and 91 of the `CP2` summary block) is recorded as **`DEC-015`** in `assumptions-decisions.md` (`A00`), and the `CP2` approval of the 14 proposed requirements is recorded as **`DEC-016`**. In addition, **`CR-002`** updates `A07 §4` (`baseline-project-plan.md`) with the Stage 2 `A20` Master Test Plan summary as promised in `A07 §4`.
- **Requirement & Scope Counts (`A10`, `A22`):** In `A10` (`requirements.md` §1 and `requirements.csv`), the 89 requirements comprise **66 functional** (`42 Must` in `R1`, `16 Should` in `R2`, `8 Could` in `R3`) and **23 non-functional** (`17 Must`, `4 Should`, `2 Could`; `59 Must`, `20 Should`, `10 Could` overall), of which **54** (`42 REQ-F` core + `12` user-stated `REQ-N`) are user-stated `Must` requirements (`A22 §2.1–§2.3, §3`) and **14** (`7 REQ-F`: `REQ-F-001`, `023`, `026`, `040`, `042`, `048`, `052`; and `7 REQ-N`: `REQ-N-001`–`006`, `017`) are `**(Proposal for CP2)**` (`A22 §2.4`). Out-of-scope items `X1`–`X9` correspond to `SC-X01`–`SC-X09` (`A01 §5.2`, `A10 §5`).
- **Numerical Targets & Pricing (`ASM-037`, `ASM-059`):** In `A10 §3` and `A20 §5`, the `ASM-037` targets are `≤ 100 ms` card flip/rate p95 (`REQ-N-001`), `≤ 300 ms` next card/quiz p95 (`REQ-N-002`), `≤ 1,000 ms` Today load p95 (`REQ-N-003`), `≤ 10.0 s` Claude written marking p90 (`REQ-N-004`), `≤ 3.0 s` tutor first token p90 (`REQ-N-005`), and `≤ 15 min` per-lecture pipeline run (`REQ-N-006`). In `A00` (`ASM-059`), the verified Anthropic API prices used for the `$2–$40/month` (`$72–$1,440` over 36 months) calculation are Haiku 5.5 `$0.10` input / `$0.50` output per MTok and Sonnet 5.5 `$2` input / `$10` output per MTok (with cache reads at 5–10% of input).
