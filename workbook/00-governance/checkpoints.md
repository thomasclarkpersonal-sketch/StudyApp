# Checkpoints and Escalations

Protocol §7 and §8.1 step 8. Each checkpoint message and the user's reply is recorded here verbatim, as are escalation records.

## CP1 — Scope and Plan (2026-10-21, STRICT)

Status: **Pending user reply** (Stage 2 waits for this decision).

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

### User reply

_Pending._
