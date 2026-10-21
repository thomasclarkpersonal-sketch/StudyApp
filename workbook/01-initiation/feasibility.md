# A02 · Feasibility Assessment

Owner: Strategic Planner. Stage 1, written 2026-10-21. Tier M: economic feasibility as a three-year total cost of ownership with simple payback.

**Figures.** Every figure has a source tag. Estimates without a source are ranges, with their basis in the assumption register. Prices come from a web search on 2026-10-21 and are re-verified in A22 (`ASM-059`, `ASM-062`). Amounts are in US dollars, the currency Anthropic prices in; the student gave no currency [USER Q-06].

## 1. Economic

### 1.1 Three-year total cost of ownership

Horizon: 36 months from R1, the catalog's tier-M horizon (`ASM-054`).

| Cost item | Kind | Per month | 36 months | Basis |
| :-- | :-- | :-- | :-- | :-- |
| Building the system: the agent's sessions | One-time | — | Not known to the agent; excluded, for the student to add | The agent cannot see what its own sessions cost the student [ASM-030] |
| Building the system: the student's time (checkpoints, pull-request reviews, setup) | One-time | — | 15–40 hours of student time | [ASM-055] |
| Claude subscription for the pipeline | Recurring | $0 extra: the student already holds Pro or Max | $0 | [USER Q-15]; marginal cost only if the limits run out (`ASM-044`) |
| Contingency: upgrading Pro to Max 5x if the pipeline exhausts the limits | Recurring, if needed | $0–$80 | $0–$2,880 | Pro $20/month, Max 5x $100/month [ASM-062]; needed only if `ASM-044` fails. Raising spend needs the student's approval [SEED §10] |
| Claude API for app features: marking and tutor (R2) | Recurring | $2–$40 | $72–$1,440 | Token volumes and per-token prices in [ASM-059]. 36 months is used for simplicity, although R2 starts after R1, so the range is an upper bound |
| Hosting for phone access (R3) | Recurring | $0–$10 | $0–$360 | [ASM-060]; host chosen by ADR in Stage 3 (`ASM-028`) |
| Libraries (`ts-fsrs`, KaTeX, React and others) and Canvas access | — | $0 | $0 | Open-source licences checked in A22; Canvas access uses the student's existing account [DEC-009] |
| **Total cash, base case** | | **$2–$50** | **$72–$1,800** | Sum of the rows above, without the contingency |
| **Total cash, with the upgrade contingency** | | **$2–$130** | **$72–$4,680** | Base case plus the contingency row |

Arithmetic: low end 2 × 36 = 72; high end 40 × 36 = 1,440, 10 × 36 = 360, 80 × 36 = 2,880; 1,440 + 360 = 1,800; 1,800 + 2,880 = 4,680; per month 40 + 10 = 50 and 50 + 80 = 130.

### 1.2 Benefits

**Tangible, in student time.** The student would otherwise make cards by hand. With the pipeline, the student spends time only on the human review step [SEED §1 Problem] [SEED §3 story 5].

| Quantity | Optimistic | Most likely | Pessimistic | Basis |
| :-- | --: | --: | --: | :-- |
| Making cards by hand, per lecture (avoided) | 90 min | 60 min | 30 min | [ASM-056] |
| Human review step, per lecture (incurred) | 10 min | 15 min | 25 min | [ASM-057] |
| Net time saved per lecture | 80 min | 45 min | 5 min | Row 1 − row 2 |
| Student time to build | 15 h | 25 h | 40 h | [ASM-055] |
| Lectures per semester in the in-scope modules | 104 | — | 40 | 4 modules × 10–26 lectures [USER Q-08] [USER Q-13] [ASM-051] |

**Intangible:** one daily plan instead of scattered sources; better retention through FSRS; questions that test understanding in the assessment's format; deadlines not missed; cards that match the course rather than general knowledge [SEED §1] [SEED §3].

### 1.3 Simple payback

The benefits are student time and learning, not money, so payback is measured in **lectures processed** before the student's build time is recovered. Payback counts are rounded up to whole lectures.

| Case | Calculation | Payback |
| :-- | :-- | :-- |
| Optimistic | 15 h × 60 / 80 min | about 12 lectures: within this semester |
| Most likely | 25 h × 60 / 45 min | about 34 lectures: within one semester of the in-scope modules (40–104 lectures) |
| Pessimistic | 40 h × 60 / 5 min | 480 lectures: about 4.6–12 semesters, so possibly beyond the 36-month horizon |

The cash cost is small next to the time at stake, and nothing is spent before R2 (`ASM-043`). Payback depends mainly on keeping the human review step well below the time needed to make cards by hand.

**Verdict: Feasible with conditions.** Conditions: the subscription limits cover pipeline runs (`ASM-044` → `RSK-004`); the human review step stays well under the time needed to make cards by hand (→ `RSK-019`).

## 2. Technical

**Project size:** small. One builder, 65 work packages with a total expected time of about 103 hours (A05), one user.

**Requirement structure:**
- **App:** high. The source documents specify features, data model, scheduling logic, screens and API [DOC study-app-spec.md §1–§5].
- **Pipeline:** medium. Roles, rules, rubrics, prompts and schemas are specified [DOC flashcard-pipeline.md §3–§12], but slide reading (`ASM-046`) and Canvas access (`DEC-009`) are new and open.

**Familiarity:**
- **App:** high. The recommended stack is mainstream (TypeScript, React, Node, SQLite), and FSRS comes as a library [SEED §8].
- **Pipeline:** low. It combines multi-agent orchestration in Claude Code on a subscription, reading slide images at scale, Canvas access, and evaluating LLM outputs.

**Technical risk rating (catalog B2):**

| Part | Familiarity | Size | Structure | Rating |
| :-- | :-- | :-- | :-- | :-- |
| Study app | High | Small | High | Very low |
| Generation pipeline | Low | Small | High (rules) to low (slide reading, Canvas) | Medium-low to high |
| **Overall** | | | | **Medium**, driven by the pipeline |

**Key technical unknowns:**
1. **Reading slide images.** Whether page images plus extracted text and recovered LaTeX give the Creators and Reviewers the full content, at what usage. The sample lecture has 25 image-led content slides [DOC COMP4901b_Sept24_RL.pdf whole file]. (`ASM-046` → `RSK-002`)
2. **Subscription limits.** Whether the Claude subscription's limits allow the Computer Science lectures to be processed at the needed pace. Anthropic does not publish exact limits; they apply in rolling windows and weekly caps (`ASM-044`, `ASM-062` → `RSK-004`).
3. **Reviewer independence in Claude Code.** Each Reviewer must be a fresh instance that never sees the Creator's reasoning [DOC flashcard-pipeline.md §3.1] (→ `RSK-018`).
4. **Canvas access.** Whether to use a Canvas API token or the student's browser session, and whether automated access is allowed (`ASM-048` → `RSK-014`).
5. **Prompt injection.** Defending against instructions hidden in course material or Canvas pages [SEED §7 Misuse] (→ `RSK-010`).
6. **Testing generated content.** Checking cards and questions against an evaluation set with numeric thresholds (A42).

**Verdict: Feasible with conditions.** The walking skeleton, `SL-01`, runs the sample lecture through the pipeline, including slide images, into the app first. That retires unknowns 1–3 before the rest is built (A06). Risks: `RSK-002`, `RSK-004`, `RSK-010`, `RSK-014`, `RSK-018`.

## 3. Operational

- **Fit:** the student initiated the project, is keen on the change, and is the only person affected [SEED §6 What will change for people]. The daily checklist replaces scattered sources [SEED §1].
- **Phone habit:** the student reviews and quizzes mostly on a phone [SEED §2], but the MVP is laptop only until story 17 (R3) [USER Q-04]. Use of R1 may be lower than intended (→ `RSK-020`).
- **Ongoing work:** each lecture needs the human review step [SEED §3 story 5]. If it takes nearly as long as making cards by hand, the benefit shrinks (→ `RSK-019`). Daily load could build up (→ `RSK-009`).
- **Maintenance:** the student runs and maintains the system after launch [SEED §9]. The pipeline is re-run every semester, so it needs clear run instructions (A63) and a maintenance path (A71).

**Verdict: Feasible with conditions.** Risks: `RSK-009`, `RSK-019`, `RSK-020`.

## 4. Schedule

From A06, at 3 hours of work per day (`ASM-053`), with a roughly 95% band from 4 h/day at ET − 2SD to 2 h/day at ET + 2SD:

| Target | Date needed | Derived date (range) | Assessment |
| :-- | :-- | :-- | :-- |
| MVP before the first midterm | within 2 weeks of 2026-10-20 [USER Q-02] | R1: 16 Nov (8 Nov – 3 Dec) | **Not achievable.** The student accepted this and chose the full MVP for later assessments [USER Q-11] |
| Pipeline ready to process real lectures | early enough to process the Computer Science lectures by 30 Nov (proposed SM-1) | SL-05: 9 Nov (3–21 Nov) | Achievable at the most likely pacing; tight in the slow case |
| Computer Science lectures processed at least 7 days before the finals | by 30 Nov 2026 (exam period 7–19 Dec [DOC ug_course_syllabus_template_doc_COMP4901B.docx.pdf p.2]) | Processing starts when SL-05 is done | Processing 30–78 Computer Science lectures (3 modules × 10–26 [ASM-051]) takes about 7.5–19.5 h of pipeline time at the seed's 15 minutes per lecture [SEED §7 Performance] [ASM-037], plus 5–32.5 h of human review at 10–25 minutes each [ASM-057]. At the most likely pacing this fits between 9 and 30 Nov; in the slow case it does not |
| R1 in use before the exam period | 7 Dec 2026 | R1: 16 Nov (8 Nov – 3 Dec) | Achievable, even in the slow case |
| R2 and R3 | none set by the student | 23 Nov and 27 Nov at 3 h/day, up to 13 Dec and 20 Dec in the slow case | They may overlap the exam period, when the student has less time. This is a choice for CP1 |

Arithmetic for the processing load: 30 × 15 = 450 min = 7.5 h; 78 × 15 = 1,170 min = 19.5 h; 30 × 10 = 300 min = 5 h; 78 × 25 = 1,950 min = 32.5 h.

**Verdict: Feasible with conditions.** Conditions: the student sustains about 3 hours of work a day (`ASM-053`); processing starts as soon as SL-05 is done. Risks: `RSK-001`, `RSK-015`.

## 5. Legal and contractual

| Topic | Finding | Source |
| :-- | :-- | :-- |
| Sending course material to Claude | Allowed by the university | [USER Q-01] |
| Course AI policy (COMP 4901B) | AI may help with coding and debugging; AI-generated text may not be copied into submitted work. The tutor must not write or rewrite assessed work (scope X6) | [DOC ug_course_syllabus_template_doc_COMP4901B.docx.pdf p.3] [SEED §11]; → `RSK-022` |
| Other modules' course policies | Not seen | Covered at university level by [USER Q-01] |
| Copyright of course material | Personal study use only; never published; never committed to this public repository; referenced where the student keeps it | [SEED §7] [DEC-008]; → `RSK-012` |
| Automated Canvas access | HKUST's terms on reading Canvas with a personal token or session are not known; the fallback is manual download | [ASM-048]; → `RSK-014` |
| Claude Code on a subscription for a personal pipeline | Assumed to be within Anthropic's terms for personal use; checked in A22 | [ASM-058]; → `RSK-021` |
| Personal data | Only the student's own study history and tutor conversations, stored locally in R1; no data about other people | [SEED §4 Sensitive data] [ASM-049]; mapped in A37 |
| Open-source licences | Checked for each adopted library in A22 | — |

**Verdict: Feasible with conditions.** Risks: `RSK-012`, `RSK-014`, `RSK-021`, `RSK-022`.

## 6. Political and organisational

**N/A.** At tier M this dimension is required only when stakeholder groups have conflicting interests. Here the only user is the person who commissioned and maintains the system. The lecturers' and university's interests are covered under legal (§5).

## Summary

| Dimension | Verdict | Risks raised |
| :-- | :-- | :-- |
| Economic | Feasible with conditions | RSK-004, RSK-019 |
| Technical | Feasible with conditions | RSK-002, RSK-004, RSK-010, RSK-014, RSK-018 |
| Operational | Feasible with conditions | RSK-009, RSK-019, RSK-020 |
| Schedule | Feasible with conditions | RSK-001, RSK-015 |
| Legal and contractual | Feasible with conditions | RSK-012, RSK-014, RSK-021, RSK-022 |
| Political and organisational | N/A (single stakeholder) | — |
