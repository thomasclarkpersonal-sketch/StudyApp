# Project Seed Specification (System Service Request)

> **How to fill this in:** answer what you know and write **Unknown** where you're unsure — the agent will ask you, or record an assumption you can confirm later. Replace the bracketed examples. Sections marked ★ matter most; the rest can be brief.

## 1. Project Overview ★
* **App name:** [e.g. ExpenseFlow]
* **Problem / opportunity:** [1–3 sentences on the "why": what problem this solves or what opportunity it captures]
* **Primary goal:** [The #1 outcome when the app is working]
* **Success metrics:** [How you'll know it worked — measurable where possible. e.g. "Expense approval time drops from 5 days to 1 day within 3 months of launch."]

## 2. Users & Stakeholders ★

| Role | Who they are | Approx. number | Tech comfort (low / medium / high) | Accessibility or device needs |
| :-- | :-- | :-- | :-- | :-- |
| [Primary user] | [e.g. Employees submitting expenses] | [e.g. 200] | [medium] | [mostly on phones] |
| [Admin / secondary user] | [e.g. Finance team] | [e.g. 5] | [high] | |

* **Other stakeholders:** [People who approve, pay for, or are affected by the app without using it daily]

## 3. Core Features (Story Cards) ★
*List what users must be able to do. Priority tells the agent what to plan and build first.*

| # | As a… | I want to… | So that… | Priority (Must / Should / Could) |
| :-- | :-- | :-- | :-- | :-- |
| 1 | [employee] | [submit an expense with a receipt photo and amount] | [I get reimbursed] | [Must] |
| 2 | [manager] | [approve or reject submitted expenses] | [spending stays within policy] | [Must] |
| 3 | [user] | [see a dashboard of my open items] | [I know what needs action] | [Should] |

* **Reports & outputs:** [Reports, dashboards, exports, or notifications people need — who reads each and how often. e.g. "Monthly spend by department for the finance director."]

## 4. Key Data
* **Main things to track (nouns):** [e.g. Users, Expenses, Receipts, Approval Logs]
* **Sensitive data:** [Personal data? Financial? Health? Children's data? List what applies, or "None"]
* **Expected volume:** [e.g. ~2,000 expenses/month; 5 years of history]
* **Retention / deletion rules:** [e.g. keep receipts 7 years for tax; delete leavers' accounts after 90 days]

## 5. External Systems & Integrations

| System | What's exchanged | Direction (in / out / both) | How (API, file, email, manual) | Who owns it |
| :-- | :-- | :-- | :-- | :-- |
| [e.g. Accounting system] | [approved expenses] | [out] | [API] | [Finance] |

*Write "None" if the app stands alone.*

## 6. Existing System & Data Migration
* **What's used today:** [Spreadsheets, paper, a legacy app, nothing]
* **Data to bring across:** [What, roughly how much, and how clean it is]
* **Must the old system keep running during the transition?** [Yes / No / Unknown]
* **Documents to attach:** [Please attach whatever exists — the agent skims them before its first questions: written procedures, paper or PDF forms, the spreadsheets you use now, current reports, screenshots of current systems. The agent can't interview your users, so these are how it learns how work really happens.]
* **What will change for people:** [Whose daily work changes, and how keen they are on the change]

## 7. Quality Requirements (Non-Functional)
* **Performance:** [e.g. pages load in under 2 seconds for typical use]
* **Scale:** [Peak concurrent users; expected growth]
* **Availability:** [e.g. business hours only / 99.9% / 24×7 with zero-downtime updates]
* **Security & access:** [Login method (email, SSO, social), roles and what each may do]
* **Misuse to guard against:** [Who might misuse the system or its data, and how far the agent should go testing it — e.g. "honest mistakes only", "a curious colleague", "a determined attacker". The agent turns this into a review scope you approve at the design checkpoint.]
* **Privacy & compliance:** [e.g. GDPR, UK GDPR, HIPAA, PCI DSS, SOC 2, sector rules, or "None known"]
* **Accessibility:** [Web and mobile: WCAG 2.2 AA by default — change if needed. Command-line or voice tools: describe the needs, e.g. plain text a screen reader can follow, no meaning carried by colour alone.]
* **Languages, regions, time zones:**
* **Devices & browsers:**

## 8. Technical Preferences & Constraints
* **Target platform:** [Web app, iOS/Android, desktop, CLI, API]
* **Preferred tech stack:** [e.g. Next.js, Python/FastAPI, PostgreSQL — or "Agent to recommend"]
* **Hosting / cloud:** [e.g. AWS, Azure, GCP, Vercel, self-hosted, Docker]
* **Existing infrastructure, accounts, or licences to reuse:**
* **Technologies to avoid:**
* **Open to buying instead of building?** [Yes — compare off-the-shelf, SaaS, and open-source options / No — must be custom-built (say why) / Unknown]
* **Products already considered:** [e.g. "Tried Expensify, too expensive for 200 users"]
* **AI / machine-learning features:** [e.g. receipt reading, recommendations, a chat assistant — or "None"]

## 9. Project Constraints ★
* **Budget:** [Build budget and monthly running budget, or "Unknown"]
* **Deadline / key dates:**
* **Who will build it:** [The agent in BUILD mode / an in-house team (size and skills) / contractors]
* **Who will run and maintain it after launch:**

## 10. Agent Run Settings
* **Mode:** [**PLAN** — specifications and plans only (default) / **BUILD** — the agent also writes tests and code; requires a code repository, runtime, and test runner]
* **Tier:** [**Auto** (default) / S / M / L — override the agent's sizing of the project]
* **Project type:** [**Auto** (default) / Business information system / Developer tool, library, or API / Data, analytics, or ML system / Real-time, game, or embedded — more than one is fine]
* **Checkpoint mode:** [**STRICT** — the agent waits for your approval at every checkpoint (default) / **ADVISORY** — the agent waits at the scope and requirements checkpoints, then continues on stated assumptions]
* **Review depth:** [**Standard** (default) — independent review scales with the project's size; on a small project each gate gets one full review, then re-checks of what failed / **Thorough** — every re-review covers the whole affected gate, whatever the size. Costs more time and tokens]
* **Output location:** [Default: `./workbook/`]
* **Decisions the agent must always ask you about:** [e.g. anything that adds a paid service — the agent treats these as checkpoint decisions (protocol R6)]

## 11. Non-Goals (Out of Scope for v1.0)
*What should the agent explicitly ignore for now?*
* [e.g. No direct bank account syncing in v1; manual CSV upload only.]

## 12. Known Assumptions, Risks & Open Questions
* **Assumptions you're making:**
* **Risks you already see:**
* **Questions you haven't answered yet:**
