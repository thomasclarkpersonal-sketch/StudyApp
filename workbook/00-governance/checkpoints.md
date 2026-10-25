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

Status: **Approved** (initial reply 2026-10-21; CP2 Corrective Addendum approved 2026-10-23). Baseline set: `A09` (with `02-analysis/sources/`), `A10` (with `requirements.csv`), `A11`, `A12`, `A13`, `A14`, `A15`, `A16`, `A17`, `A18` (with `data-dictionary.csv`), `A19` (with `acceptance-scenarios.csv`), `A20`, `A22`, and `traceability-matrix.md` (with `traceability-matrix.csv`), joining `A01`–`A07` (updated via `CR-001` and `CR-002`).

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

### CP2 Corrective Addendum (2026-10-21, STRICT — Approved 2026-10-23)

Because the initial `CP2` summary block above contained summary figures and descriptions that differed from the underlying Stage 2 artifacts and omitted `CR-001` and `CR-002`, the corrective checkpoint message below presents the exact figures, assumptions, decisions (`DEC-015`, `DEC-016`), and change requests (`CR-001`, `CR-002`) for explicit user confirmation (`R1`, `R6`, `R7`). The original `CP2` message and reply above are preserved unedited (`R1`).

```text
HUMAN CHECKPOINT CP2 (Corrective Addendum) — Requirements Baseline, Sourcing Decision & Change Requests CR-001..CR-002
Decision needed: Approve | Approve with changes | Reject

Summary (corrected figures matching the Stage 2 artifacts and Gate G2-r4)
- Requirements Catalog (A10, workbook/02-analysis/requirements.md & requirements.csv): 89 atomic, testable requirements — 66 functional (REQ-F-001–REQ-F-066: 42 Must in R1, 16 Should in R2, 8 Could in R3) and 23 non-functional with numerical targets (REQ-N-001–REQ-N-023: 17 Must, 4 Should, 2 Could; 59 Must, 20 Should, 10 Could overall) — plus 4 user decision points (UDP-01–UDP-04 from seed §10) and 9 out-of-scope items (SC-X01–SC-X09). Of the 59 Must requirements, 54 (42 REQ-F core items + 12 user-stated REQ-N items) are user-stated Must requirements and 5 (REQ-N-001, 002, 003, 006, 017, plus the metric-logging sub-clauses of REQ-F-001, 023, 026, 040, 042) are CP2 proposals.
- 14 Requirements marked **(Proposal for CP2)** (DEC-016, A10 §2–§3): 7 functional proposals — REQ-F-001 (LaTeXiT equation recovery from PDF objects), REQ-F-023 (ImportBatch logging of module, lectures, counts and timestamp for SM-1), REQ-F-026 (CardReviewLog.state_before logging for SM-2 trailing 30-day true retention), REQ-F-040 (DailyPlanItem.completed_at timestamp logging for SM-4b ≥5/7 days consistency), REQ-F-042 (structured wrong | unclear report reason for SM-3 <2% reported wrong), REQ-F-048 (GradingCallLog token logging and Settings.token_rates_json for SM-6 monthly API spend), and REQ-F-052 (per-thread tutor conversation retention until deleted by the student) — and 7 non-functional proposals — REQ-N-001–REQ-N-006 (latency/runtime targets) and REQ-N-017 (on-demand cleanup of intermediate pipeline round files via clean-rounds).
- Sourcing Decision (A22, workbook/02-analysis/sourcing.md, DEC-015): evaluated 4 options over the 36-month horizon against the 54 user-stated Must requirements (42 REQ-F + 12 REQ-N, §2.1–§2.2), 18 user-stated Should items (§2.3), 14 CP2 proposals (§2.4), and seed §10 guardrails (§2.5):
  - Option 1 (Custom Build — Pipeline + Integrated Study App, recommended): $72–$1,800 base 36-month TCO ($72–$5,400 with subscription upgrade contingency), 15–40 h active student build time (most likely 25 h, ASM-055; 118.97 h agent session time across A05), 54/54 user-stated Musts met natively (42/42 REQ-F, 12/12 REQ-N) and 14/14 CP2 proposals met natively.
  - Option 2 (Hybrid — Custom Pipeline + Anki Desktop/AnkiMobile + smaller companion app): $72–$1,824.99 base 36-month TCO ($72–$5,424.99 with contingency, including $24.99 one-time for AnkiMobile on iOS per ASM-065), 14–38 h active student time (most likely 23.5 h; Anki replaces only slice SL-07 Flashcard Review = PERT ET 2.17 h of 56.95 h = 3.8% of Stage 4 slice effort in A05/A06 while 36.95 h remains across the other 15 study-app slices), 24 Met / 4 Partial / 14 Gap across the 42 user-stated Must REQ-F items natively (and 8/12 user-stated Must REQ-N natively), plus dual-database split between Anki SQLite and companion-app SQLite.
  - Option 3 (SaaS — RemNote Pro with AI): $648–$720 over 36 months ($18–$20/month billed annually per ASM-065), 4 Met / 7 Partial / 31 Gap across the 42 user-stated Must REQ-F items, ruled out by uploading copyrighted HKUST slides to a third-party cloud outside Anthropic (violating seed §7/§10 and DEC-008) and lacking multi-agent review, concept-level FSRS, and multi-variant rotation.
  - Option 4 (Obsidian + Community Plugins): $0 local or $144–$288 over 36 months with Obsidian Sync ($4–$8/month per ASM-065), 1 Met / 18 Workaround / 23 Gap across the 42 user-stated Must REQ-F items, requiring 30–90 min/lecture of manual card/question creation (ASM-056, 20–156 h/semester across the 4 in-scope modules × 10–26 lectures/module = 40–104 lectures/semester per ASM-012, DEC-007, ASM-051, and A02 §1.3) and failing REQ-N-006 (≤15 min/lecture pipeline run) and SM-1 (≥7 days before each assessment).

Assumptions that need your confirmation (corrected exact statements from A00)
- ASM-037 (M/M, CP2): The performance targets in A10 §3 and A20 §5 are: REQ-N-001 <=100 ms card flip/rating persistence p95; REQ-N-002 <=300 ms next-card/next-quiz selection p95; REQ-N-003 <=1,000 ms Today view load p95; REQ-N-004 <=10.0 s Claude written-answer marking p90; REQ-N-005 <=3.0 s tutor first streamed token p90; and REQ-N-006 <=15 min per-lecture pipeline run (Stage A + Stage B) — if wrong: we adjust the numerical thresholds in A10 §3 and A20 §5.
- ASM-058 (H/H, verified 2026-10-21 in A22 §3 & A00): Running your personal generation pipeline interactively inside the official Claude Code CLI on your individual subscription using native subagent definitions (.claude/agents/) is within Anthropic's Consumer Terms, while OAuth token extraction for unattended background services or embedded web-app calls (R2 marking/tutor) is prohibited (REQ-N-022, BR-006, BR-043) — if wrong: pipeline runs move to API billing with your prior approval (UDP-01, RSK-021).
- ASM-059 (M/L, verified 2026-10-21 in A22 §3 & A00): Anthropic API pricing used for the $2–$40/month ($72–$1,440 over 36 months) R2 app estimate is Haiku 5.5 at $0.10 input and $0.50 output per MTok (prompts <=100K tokens), Sonnet 5.5 at $2 input and $10 output per MTok, and cache reads at 5–10% of input — if wrong: we update Settings.token_rates_json in REQ-F-048 and the TCO range in A02/A22.
- ASM-062 (M/M, verified 2026-10-21 in A22 §3 & A00): Official Claude subscription tiers are Pro ($20/mo), Max 5x ($100/mo, +$80/mo step), and Max 20x ($200/mo, +$100/mo step) — if wrong: we update the $0–$100/mo upgrade contingency in A02/A22.
- ASM-065 (L/M, CP2, verified 2026-10-21 in A22 §1–§3 & A00): Third-party product prices used in A22 are: Anki $0 on desktop/AnkiWeb/Android and $24.99 one-time for AnkiMobile on iOS; RemNote Pro with AI $18–$20/month billed annually ($648–$720 over 36 months); and Obsidian $0 local with optional Obsidian Sync at $4–$8/month ($144–$288 over 36 months) — if wrong: we update the third-party TCO rows in A22 §3.
- ASM-023 (L/M, CP2): Tutor conversations are kept until you delete them, one thread at a time, via a one-click Delete Thread action (REQ-F-052, BR-040) — if wrong: we can auto-purge threads at semester end or after N days.
- ASM-024 (L/M, CP2): Pipeline intermediate files (cards.round*.json, review.round*.json) are kept outside this public repository until the module ends and cleaned up on demand via clean-rounds while preserving *.final.json, flagged.json, and run-summary.json (REQ-N-017) — if wrong: we retain all intermediate round files indefinitely.
- ASM-027 (L/M, CP2): When R3 adds phone access (REQ-F-059–REQ-F-061), target mobile browsers are current iOS Safari and Android Chrome down to a 375 px viewport width (REQ-N-019, REQ-N-021, A20 §2) — if wrong: we narrow mobile testing to your specific phone browser/OS.
- ASM-044 (H/L, carried from CP1): Your Claude subscription's rolling and weekly limits sustain the CS lecture-processing pace between SL-05 and 30 Nov — if wrong: batch across windows, upgrade one plan step (+$80–$100/mo), or switch to API billing with your approval (measured first in SL-01).

Questions and decisions needed at this checkpoint
- DEC-015 (Sourcing decision, A22 §4): Confirm Option 1 (Custom Build — Pipeline + Integrated Study App) over Options 2–4.
- DEC-016 (14 Proposed requirements, A10 §2–§3): Confirm all 14 requirements marked **(Proposal for CP2)** (7 functional: REQ-F-001, 023, 026, 040, 042, 048, 052; 7 non-functional: REQ-N-001–006, 017).
- CR-001 and CR-002 (Changes to baselined artifacts, A00): Confirm CR-001 and CR-002 below.

Changes to baselined artifacts since CP1
- CR-001 (A01–A07 on stage-1/initiation, reviewed in G1-CR001.md): aligned post-CP1 status wording to DEC-010/DEC-012/DEC-013; prefixed scope item IDs as SC-P01–SC-P11, SC-A01–SC-A16, and SC-X01–SC-X09; aligned A05 WBS group headers (4-R1–4-R3, 5-R1–5-R3, 6) and moved hosted A63 entries into SL-18 so 5.6 has one deliverable (A61); and made schedule_calc.py atomic via os.replace. Zero change to PERT estimates, critical path (116.27 h), or dates.
- CR-002 (A07 §4, A09, A10 & requirements.csv, A12, A14, A18, A20, A22, traceability-matrix.md & .csv on stage-2/requirements, reviewed in G2-r3.md & G2-r4.md): added the Stage 2 A20 Master Test Plan summary to A07 §4 as planned at CP1; corrected the A10 §1 summary table REQ-N priority counts to 17 Must / 4 Should / 2 Could (59 Must / 20 Should / 10 Could = 89 total) to match A10 §3 and requirements.csv; added DEC-014 (Q-16 fallback) to REQ-F-012's source tag; aligned A10 §5 out-of-scope IDs to SC-X01–SC-X09; aligned A10, A18, and A22 status headers with DEC-015/DEC-016; removed personal local file paths from A09 and A20; aligned A12/A14 prose on "marking" (A18 §2); and cited ASM-065 and A05 effort derivations in A22 while aligning Opt 2/3/4 Met/Partial/Gap summary counts (24/4/14, 4/7/31, 1/18/23) with §2.1–§2.2.

Risks you are being asked to accept
- None as unmitigated residual risks at CP2; all 22 risks in A03 remain mitigated, with RSK-002, RSK-004, and RSK-018 scheduled for empirical validation in SL-01 immediately after Stage 3.

On approval, these artifacts and change requests are confirmed as the Stage 1–2 baseline: A01–A07 (with CR-001 and CR-002), A09 (with 02-analysis/sources/), A10 (with requirements.csv), A11–A20, A22, and traceability-matrix.md (with traceability-matrix.csv).
Full detail: workbook/README.md
```

### User reply to CP2 Corrective Addendum (verbatim, 2026-10-23)

```text
approve
```

---

## CP3 — Design Baseline (2026-10-21, ADVISORY)

Status: **Original CP3 (`2026-10-21`) Approved** `[USER CP3]`; **CP3 Corrective Addendum (`2026-10-25`, ADVISORY) — Pending user reply** (proceeding on stated assumptions per `DEC-005` and protocol §7). Baseline set: `A30` (`ADR-001`–`ADR-007`), `A31`, `A32`, `A33` (with `schema.sql`), `A34` (with `openapi.yaml` and `schemas/pipeline-contracts.schema.json`), `A35`, `A36`, `A37`, `A38`, `A39` (with `test-cases.csv`), `A40`, `A41`, `A42`, plus `CR-003` (Stage 2 post-CP2 decomposition) and `CR-004` updates to `A03` and `traceability-matrix.md`/`.csv` (pending user confirmation on the `CP3 Corrective Addendum`).

```text
HUMAN CHECKPOINT CP3 — Design Baseline
Decision needed: Approve | Approve with changes | Reject (ADVISORY — continuing on stated assumptions unless you request changes)

Summary
- Produced and reviewed all Stage 3 architecture and design artifacts (A30–A42, plus CR-001 updates to A03 and traceability-matrix.md/.csv) on branch stage-3/design; Gate G3 passed at r2 (48 PASS / 0 FAIL / 0 N/A, workbook/00-governance/reviews/G3-r2.md) after resolving all 12 G3-r1 findings and all observations (workbook/00-governance/dispositions.md).
- Architecture Decision Records (A30, workbook/03-design/adr/README.md, ADR-001–ADR-007, DEC-016–DEC-022): adopted TypeScript 5.6 + React 18 + Vite 5 + Tailwind CSS + Hono 4 on Node.js 22 LTS + ts-fsrs v5 + better-sqlite3 + KaTeX + marked + DOMPurify + Ajv + @anthropic-ai/sdk + Vitest + Playwright (ADR-001); SQLite 3 WAL mode + external non-git JSON workspace (ADR-002); 3-tier modular monolith with single-location rule enforcement and justified DB/UI backstops (ADR-003); Claude Code subagents + deterministic pipeline-cli context isolation (ADR-004); allowlisted read-only HKUST Canvas REST sync + local PDF/LaTeXiT fallback (ADR-005); localhost bypass in R1–R2 and Fly.io Hong Kong (hkg) container with Argon2id owner auth in R3 (ADR-006); and 3NF relational normalization with 5 justified JSON columns (ADR-007).
- Architecture Overview (A31, workbook/03-design/architecture.md): 12 modules (M01–M08 in the study app, M09–M12 in the generation pipeline) with an acyclic dependency DAG (ARCH-01), sequence diagrams across UC-01–UC-21, single-module assignment for all 45 business rules (BR-001–BR-045) and 6 decision tables (DR-01–DR-06 / DT-01–DT-06) (ARCH-02), and 4 automated architectural fitness tests (ARCH-01–ARCH-04).
- Logical & Physical Data Design (A32, A33, workbook/03-design/db/logical-model.md, physical-design.md & schema.sql): 34 3NF SQLite STRICT tables (R01–R34), 3 derived read views (V01–V03), and 15 secondary indexes (IDX-01–IDX-15) verified in live SQLite 3 execution with explicit ON DELETE rules, full A18 attribute/CHECK parity, and verified online VACUUM INTO backups before every import and restore.
- Interface Contracts (A34, workbook/03-design/api/interfaces.md, openapi.yaml & schemas/pipeline-contracts.schema.json): 38 REST/SSE operations across 36 paths in OpenAPI 3.1.0 with RFC 9457 ProblemDetails error envelopes, 7 deterministic CLI commands (CLI-01–CLI-07), 5 external/file contracts (INT-01–INT-05), and 20 JSON Schema Draft 2020-12 definitions covering all 6 module export files, feedback.json, and workspace files (E23–E27).
- UI & Dialogue Design and Reports (A35, A41, workbook/03-design/ui.md & reports.md): 11 screens (SCR-01–SCR-11) with full dialogue navigation graph, wireframes, 28 input validation rules (FLD-01–FLD-28), Anki keyboard shortcuts (Space, 1–4, r, f, s, e, a, Esc), WCAG 2.2 AA contrast and non-colour urgency badges; plus 9 operational/analytical reports and exports (RPT-01–RPT-09).
- Security, Privacy & Observability (A36, A37, A38, workbook/03-design/security.md, privacy.md & observability.md): STRIDE threat model across all 5 trust boundaries (TB-01–TB-05) and full 38×4 + 7×4 authorization matrix; attribute-level privacy data map with zero IP storage, zero staff PII, and Anthropic-only course material transmission; and 9 SLOs (SLO-01–SLO-09), redacted NDJSON logging, 5 metrics (MET-01–MET-05), and 6 alerts (ALT-01–ALT-06).
- Test Design & Data/Model Quality Plan (A39, A42, workbook/03-design/test-design.md, test-cases.csv & data-model-quality.md): 286 Integration and System test cases (TC-I-001–TC-I-255, TC-I-N10/12/17/20, TC-S-001–TC-S-027) with 100% coverage of operations, FLD rules, DT rules, REQ-Fs, and REQ-Ns; end-to-end lineage matrix, 15 automated data-quality rules (DQR-01–DQR-15) with Halt/Quarantine/Alert actions, 9 AI/model component specs (AI-01–AI-09), and 6 held-out evaluation datasets (EVAL-01–EVAL-06) with numeric thresholds.
- Slice Plan (A40, workbook/03-design/slice-plan.md): 21 vertical slices (SL-01–SL-21) ordered risk-first (starting with SL-01-walking-skeleton across slide/LaTeXiT extraction -> Card Creator -> isolated Card Reviewer -> SQLite WAL import -> FSRS review UI), confirming the A05 WBS (CR-001) and assigning all 286 test cases.

Assumptions that need your confirmation (high impact, low or medium confidence, or marked for this checkpoint)
- ASM-028 & ASM-060 (resolved by ADR-006 / DEC-021 for R3): When R3 adds remote phone access, deploying a single Docker container with a 1 GB persistent volume on Fly.io (Hong Kong region, ~$2.10–$5.00/mo, or Tailscale Serve at $0/mo) is acceptable — if wrong: we can target another host or keep Tailscale-only in R3.
- ASM-044 (H/L, carried to SL-01): Your Claude subscription's rolling and weekly limits sustain single-lecture and batch processing in Claude Code — empirically tested in SL-01 (`TC-S-006`).
- ASM-046 (H/M, carried to SL-01): 150 DPI slide PNGs + extracted text + recovered LaTeXiT equations give Creators and Reviewers sufficient fidelity on visual/math slides — empirically tested in SL-01 (`TC-S-016`).

Questions and observations raised since the last checkpoint
- None open (all 12 G3-r1 findings and 4 G3-r1/r2 observations resolved in workbook/00-governance/dispositions.md).

Changes to baselined artifacts since the last checkpoint
- CR-001 (workbook/00-governance/assumptions-decisions.md): Added accepted out-of-scope failure-class risks RSK-023 and RSK-024 to A03 (risk-register.md), confirmed A05 WBS slices SL-01–SL-21 unchanged, and populated Stage 3 design and test columns in traceability-matrix.md/.csv.

Risks you are being asked to accept
- RSK-023 (L/M, A03 & A39 §4.2): Out-of-band manual editing or corruption of study.db or pipeline export JSON files outside the app/CLI — mitigation: SQLite application_id header check, PRAGMA quick_check on startup, Ajv schema gate on import, and automatic pre-import VACUUM INTO backups.
- RSK-024 (L/H, A03 & A39 §4.2): Local OS user-account compromise or malware on the student's laptop in R1–R2 — mitigation: bind server strictly to 127.0.0.1, chmod 0600 on study.db and .env, and never expose API keys to browser or git.
- Operational/external residual risks already in A03 (`A39 §4.2`): RSK-004 (Claude subscription rolling/weekly rate limits -> pause/resume per lecture), RSK-014 (Canvas token revocation/rate-limit -> automatic fallback to local files), and RSK-008 (student sharing the R3 owner password -> Argon2id + 30-day revocable sessions).

On approval, these artifacts become the baseline: A30 (ADR-001–ADR-007), A31, A32, A33 (with schema.sql), A34 (with openapi.yaml and pipeline-contracts.schema.json), A35, A36, A37, A38, A39 (with test-cases.csv), A40, A41, A42, plus CR-001 updates to A03 and traceability-matrix.md/.csv
Full detail: workbook/README.md
```

### User reply (verbatim, 2026-10-21)

```text
Approve
```

### CP3 Corrective Addendum (2026-10-25, ADVISORY — Pending Gate G3-r4 re-review & user reply)

Following the `stage-2/requirements` rebase and `CR-003` integration on `main` (`3ca0121`), this corrective addendum aligns the `CP3` summary with the rebased Stage 2 baseline (`117` atomic requirements, `141` acceptance scenarios, `263` data dictionary attributes, `DEC-015`/`DEC-016` numbering, `ASM-069`/`ASM-070`, `CR-003`, and `CR-004`). The original `CP3` message and reply (`2026-10-21`) and `reviews/G3-r1.md` / `reviews/G3-r2.md` / `reviews/G3-r3.md` are preserved unedited (`R1`; see `Questions and observations raised since the last checkpoint` below for the provenance and gate-conformance disclosure), while this addendum is prepared for the `G3-r4` gate re-review (`2026-10-25`) and remains **pending user reply** under `DEC-005` (`ADVISORY` checkpoint mode, protocol §7).

```text
HUMAN CHECKPOINT CP3 (Corrective Addendum) — Design Baseline, CR-003 & CR-004
Decision needed: Approve | Approve with changes | Reject (ADVISORY — continuing on stated assumptions unless you request changes)

Summary (aligned with rebased Stage 2 baseline on main; pending Gate G3-r4 re-review on 2026-10-25)
- Stage 3 architecture and design artifacts (A30–A42) and CR-004 updates to A03, A13, A18, and the 117-row traceability-matrix.md/.csv on branch stage-3/design are prepared for Gate G3 cycle r4 (2026-10-25; see workbook/README.md and workbook/00-governance/assumptions-decisions.md for full details).
- Architecture Decision Records (A30, ADR-001–ADR-007, DEC-017–DEC-023): TypeScript 5.6 + React 18 + Vite 5 + Tailwind CSS + Workbox + Hono 4 on Node.js 22 LTS + ts-fsrs v5 (`v5.4.2`, FSRS-6 21-weight vector + 17/19 legacy migration, ASM-066(a)) + better-sqlite3 + KaTeX + marked + DOMPurify + Ajv + ical-generator + @anthropic-ai/sdk + Vitest + Playwright + Python 3 (`pypdf` + `poppler-utils` `pdftoppm` for CLI-02, verified in SL-01, ASM-066(b)) (ADR-001, DEC-017); SQLite 3 WAL mode + external non-git JSON workspace (ADR-002, DEC-018); 3-tier modular monolith with single-location rule enforcement and justified DB/UI backstops (ADR-003, DEC-019); Claude Code subagents + deterministic pipeline-cli context isolation (ADR-004, DEC-020); allowlisted 6-endpoint read-only HKUST Canvas REST sync + local fallback (ADR-005, DEC-021, resolving ASM-048); localhost bypass in R1–R2 and Fly.io Hong Kong (hkg) container with Argon2id owner auth, 14-day revocable `__Host-study_session` cookies, startup bind-address guard (`0.0.0.0` only on Fly.io; `127.0.0.1` loopback under local Tailscale Serve), and trusted-proxy per-IP login rate limiting in R3 (ADR-006, DEC-022, ASM-028, ASM-060, ASM-069); and 3NF relational normalization across 34 tables with 5 justified JSON columns (ADR-007, DEC-023).
- Architecture, Data, API, UI, Security, Privacy, Observability, Reports & Quality (A31–A38, A41, A42): 12 modules (M01–M12) enforcing BR-001–BR-045 and DR-01–DR-06; 34 3NF SQLite STRICT tables (R01–R34) synchronised 1-for-1 with all 263 A18 attributes (Settings.id = 'default' seeded row, daily_budget_min 15..720 DEFAULT 120, minutes_per_page 0.5..15.0 DEFAULT 2.5, monthly_spend_cap_mode IN ('block', 'warn') DEFAULT 'block' per ASM-067, fsrs_weights_json NULL or 17/19/21-float array, v_concept_mastery V02 with SM-5 = mastered + strong per ASM-066(d), and R29 seeding `claude-haiku-5-5` / `claude-sonnet-5-5` defaults per ASM-059 while pre-seeding 5.5 and 4.x rates in token_rates_json per ASM-059/ASM-070); 38 REST/SSE operations in OpenAPI 3.1.0 (`additionalProperties: false` on all 22 request-body schemas) + 7 CLI commands + 20 JSON Schemas; 11 screens (SCR-01–SCR-11, "Last 7d" consistency without streak counters) and 30 field validation rules (FLD-01–FLD-30); STRIDE threat model & 38×4 + 7×4 authorization matrix; privacy data map; 9 SLOs; 9 reports (RPT-01–RPT-09); and 15 data-quality rules (DQR-01–DQR-15), 9 AI specs (AI-01–AI-09), and 6 evaluation sets (EVAL-01–EVAL-06).
- Test Design & Slice Plan (A39, A40): 293 Integration and System test cases (TC-I-001–TC-I-262, TC-I-N10/12/17/20, TC-S-001–TC-S-027) and 21 vertical slices (SL-01–SL-21) covering all 117 atomic requirements and 141 acceptance scenarios (AT-001–AT-141), with entry gates on SL-12 (ASM-070) and SL-18 (ASM-028).

Questions and observations raised since the last checkpoint
- None open (all 6 observations and review errata across `G3-r1.md`, `G3-r2.md`, and `G3-r3.md` are dispositioned as Fixed in `workbook/00-governance/dispositions.md` rows 50–55):
  1. `G3-r1.md` (`37e8142`) & `G3-r2.md` (`c68dc01`, `b5f96b2`) provenance & checklist conformance: predate the rebase onto `main` `3ca0121` (unreachable git objects) and used non-protocol `G3.1`–`G3.16` checklists citing non-existent IDs (`BR-047`, `DR-008`, `FLD-29`, `Q-24`, `UC-19`) — preserved unedited per protocol §4.2, with this snapshot prepared for full Gate G3 re-review in cycle `r4` (`dispositions.md` row 55; default if you don't answer: rely on the `G3-r4` review of record once completed).
  2. `G3-r3.md` (`181b625`) `OBS-G3-r3-01` (`ADR-007 §3` line 55 said `22 instead of 29` tables instead of `34`) — Fixed in `ADR-007:55` (`22 instead of 34`) and `dispositions.md` row 54 (default if you don't answer: keep `34` tables across `A32`/`A33`/`ADR-007`).
  3. `G3-r3.md` (`181b625`) evidence errata (`G3-r1` commit/date, `G3.12` Option 1 mis-cited as Option 2, `A42.2`/`A42.3` `DQR-01`–`15` & `AI-01`–`09` IDs, and `ASM-059` cost figures) — Fixed in `dispositions.md` row 55 and prepared for re-verification in cycle `r4` (default if you don't answer: accept the corrected citations in `G3-r4`).

Ask-first items (AGENTS.md §3, [SEED §10])
1. ASM-070 (H/M, open — default marking & tutor models before R2 / SL-12): Please confirm whether to keep the seeded `claude-haiku-5-5` ($0.10/$0.50/$0.01 per MTok) and `claude-sonnet-5-5` ($2.00/$10.00/$0.20 per MTok) defaults on the `ASM-059` cost basis ($2.3–$18/mo marking + tutor, within $2–$40/mo in A02/A22) or switch to `claude-haiku-4-5` ($1.00/$5.00/$0.10 per MTok) and `claude-sonnet-4-6` ($3.00/$15.00/$0.30 per MTok; $6–$35.5/mo on the same volumes, also pre-seeded in `Settings.token_rates_json`). Default if unanswered when `SL-12` starts (`DEC-005`): `SL-12` proceeds on the seeded `claude-haiku-5-5` / `claude-sonnet-5-5` defaults and migrates `id='default'` to `4.x` only if a verbatim reply from you in `checkpoints.md` selects `4.x`.
2. ASM-028 & A37 §3 (M/M, open — third-party cloud hosting of course-derived `study.db` before R3 / SL-18): Please confirm before `R3` (`SL-18`) whether you approve deploying `study.db` (which contains flashcards, quiz questions, and glossary terms derived from HKUST course material; raw PDFs never leave your laptop) to a Fly.io Hong Kong (`hkg`) volume (~$2.35–$5.00/mo per `ASM-069`) or prefer local Tailscale Serve ($0/mo, zero third-party cloud storage). Default if unanswered or declined when `SL-18` starts: `SL-18` uses local Tailscale Serve bound strictly to `127.0.0.1` (`R1`–`R2` slices `SL-01`–`SL-17` run strictly on `127.0.0.1`).

Assumptions that need your confirmation (high impact, low or medium confidence, or marked for this checkpoint)
- ASM-058 (H/M, open — downgrade disclosure from CP2 addendum): Running the personal generation pipeline interactively in Claude Code CLI on your subscription is within Anthropic's Consumer Terms; `CR-003` lowered its status from `H/confirmed` in the CP2 addendum back to `M/open` pending pre-`SL-01` clause verification (`RSK-021`) — if wrong: pipeline runs move to API billing with your prior approval (`UDP-01`).
- ASM-067 (H/M, open): `Settings.monthly_spend_cap_mode` defaults to `'block'` (hard-stopping new Claude calls at 100% of the monthly cap in `Settings.timezone` [default `Asia/Hong_Kong`, `ASM-022`] while preserving self-marking fallback, `RSK-008`), with `'warn'` as an opt-in setting — if wrong: change default mode to `'warn'`.
- ASM-068 (H/M, open): `>= 95.0%` (`95.0–100.0%`) notation compliance and source citation accuracy benchmark threshold in `REQ-N-012` / `AT-126` / `EVAL-02` validated in `SL-02` — if wrong: adjust threshold in `REQ-N-012` and `EVAL-02`.
- ASM-028 (M/M, open), ASM-060 (L/M, open until SL-18) & ASM-069 (L/M, open until SL-18): Fly.io `hkg` container + 1 GB volume (~$2.35–$5.00/mo per `ASM-069` on 2026-10-23, within `ASM-060` $0–$10/mo; original CP3 quoted ~$2.10–$5.00/mo as `DEC-021`, now `DEC-022`) or Tailscale Serve ($0/mo).
- ASM-059 (M/L, open) & ASM-070 (H/M, open until SL-12): `Settings.token_rates_json` pre-seeds both `5.5` (`ASM-059`, default) and `4.x` (`ASM-070`) rates and dynamically enforces positive rate entries for any configured `grading_model` / `tutor_model` (`TC-I-256`).
- ASM-066 (M/M, open): Adopted Node.js 22 LTS, TypeScript 5.6, SQLite 3 WAL, `ts-fsrs v5.4.2` (FSRS-6), KaTeX 0.16, Python 3 (`pypdf` + `poppler-utils`) (`ADR-001` / `DEC-017`), `Asia/Hong_Kong`/`UTC`/`Europe/London` timezone test fixtures (`A20 §2`, `A39`), `v_concept_mastery` (`V02`) with `SM-5 = mastered + strong`, and singleton `Settings.id = 'default'`.
- ASM-048 (M/L, open, SL-03), ASM-044 (H/L, open, SL-01) & ASM-046 (H/M, open, SL-01): Empirically tested in `SL-01` (`TC-S-006`, `TC-S-016`) and `SL-03` (`RSK-014`).

Changes to baselined artifacts since the last checkpoint
- CR-003 (Stage 2 artifacts `A00`, `A07 §4`, `A10`, `A12`–`A14`, `A16`–`A20`, `A22`, `traceability-matrix.md`/`.csv`; full detail in `assumptions-decisions.md`): split 26 compound `REQ-F` rows into 54 atomic rows (`117` requirements total: `94 REQ-F` + `23 REQ-N`; `67` user-stated Must in `A22 §2` alongside `DEC-015`), added `Settings.monthly_spend_cap_mode` (`263` attributes in `A16`/`A18`), tagged `REQ-N-012` `>= 95%` to `ASM-068`, and added `UC-12 ext 2b`, `UC-13 ext 4b`, and `AT-138`–`AT-141` (`141` scenarios).
- CR-004 (Stage 1/2/3 artifacts `A00`, `A03`, `A13`, `A18`, `A30`–`A42`, `traceability-matrix.md`/`.csv`, `dispositions.md`, `AGENTS.md §4`; full detail in `assumptions-decisions.md`): added `RSK-023`–`024` and aligned `A03` status/assumption mappings; aligned `Settings.id = 'default'`, `daily_budget_min = 120` (`15..720`), `minutes_per_page = 2.5` (`0.5..15.0`), `monthly_spend_cap_micro_usd > 0`, `fsrs_weights_json` (`17/19/21` floats), `V01`/`V02`, and `R01`–`R29` `CHECK` constraints across `A13`, `A18`, `ADR-007` (`34` tables), `A32`–`A35`, and `A39`; seeded `5.5` model defaults (`ASM-059`) with `4.x` rates (`ASM-070`) and gated `SL-12` (`ASM-070`) and `SL-18` (`ASM-028`); set `additionalProperties: false` on all 22 OpenAPI request schemas; added `FLD-29`–`30` (`30` field rules) and `TC-I-256`–`262` (`293` test cases); and populated all `117` rows of `traceability-matrix.md`/`.csv`.

Risks you are being asked to accept
- RSK-023 (L/M, A03 & A39 §4.2): Out-of-band manual editing or corruption of `study.db` or pipeline export JSON files outside the app/CLI.
- RSK-024 (L/H, A03 & A39 §4.2): Local OS user-account compromise or malware on the student's laptop in `R1`–`R2`.
- Operational/external residual risks in A03 (A39 §4.2): `RSK-004` (Claude subscription rate limits), `RSK-014` (Canvas token revocation/rate-limit -> local fallback), and `RSK-008` (student sharing the `R3` owner password; mitigated by Argon2id, 14-day revocable `__Host-study_session` cookie [correcting the original 2026-10-21 CP3 summary's "30-day" text to match `ADR-006 §3.2` and `A36 §4.1`], `127.0.0.1` loopback bind under Tailscale Serve, trusted-proxy per-IP login rate limit, and default `'block'` spend cap per `ASM-067`).

On approval, these artifacts and change requests are confirmed as the Stage 3 baseline: A30 (ADR-001–ADR-007), A31, A32, A33 (with schema.sql), A34 (with openapi.yaml and pipeline-contracts.schema.json), A35, A36, A37, A38, A39 (with test-cases.csv), A40, A41, A42, plus CR-003 and CR-004 updates to A03, A13, A18, and traceability-matrix.md/.csv.
Full detail: workbook/README.md
```

### User reply to CP3 Corrective Addendum

_Pending Gate G3-r4 re-review (`2026-10-25`) and user reply (ADVISORY checkpoint per `DEC-005` and protocol §7: the build proceeds on the stated assumptions in `ASM-058`–`ASM-060` and `ASM-066`–`ASM-070`, `DEC-017`–`DEC-023`, `CR-003`, and `CR-004`, and this addendum remains marked pending in `workbook/README.md` until the user replies)._

