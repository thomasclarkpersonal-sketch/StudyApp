# ADR-001 · Language, Web Stack, and Core Domain Libraries

- **Artifact ID:** `A30` (`ADR-001`)
- **Stage:** Stage 3 — Architecture & Design
- **Date:** `2026-10-21`
- **Status:** Accepted
- **Deciders:** System Architect (confirmed via `DEC-015` at `CP2` and `DEC-017` at `CP3`)
- **Drivers:** `[SEED §8]`, `DEC-015` (`A22 §5`), `DEC-017`, `ASM-005`, `ASM-066`, `REQ-F-023`–`034`, `REQ-F-043`–`048`, `REQ-F-057`, `REQ-F-060`, `REQ-N-001`–`005`, `REQ-N-010`, `REQ-N-018`–`021`, `RSK-003`

---

## 1. Context and Forces

The Study App and Generation Pipeline must be built, tested, and maintained by an AI agent with pull-request reviews by a single university student (`DEC-004`, `ASM-031`, `ASM-055`). The technology stack must satisfy the following forces:
1. **Seed preference (`[SEED §8]`):** The seed recommends React + TypeScript with `ts-fsrs` for the web frontend and Node.js + TypeScript with SQLite and the Claude TypeScript SDK (`@anthropic-ai/sdk`) for the backend.
2. **Mathematical FSRS fidelity (`REQ-N-010`, `RSK-003`):** Both flashcard scheduling (`CardState`) and concept-level quiz scheduling (`ConceptState`), including real-time `retrievability` calculations (`TC-I-022`, `TC-I-N10`), must match reference `ts-fsrs` v5 (which implements FSRS-6 with a `21`-weight parameter vector and migrates legacy `17`-/`19`-weight vectors, `ASM-066`) calculations (`100%` parity) without custom or duplicate SQL memory-math bugs.
3. **Sub-100 ms local interactivity & offline PWA (`REQ-N-001`–`003`, `REQ-N-009`, `REQ-F-060`):** Card flips/ratings (`<= 100 ms` p95), next-item selection (`<= 300 ms` p95), and Today checklist rendering (`<= 1,000 ms` p95) must be fast on laptop and mobile browsers and work offline in `R3`.
4. **Heavy mathematical & diagram content (`[USER Q-08]`, `REQ-F-024`, `REQ-N-014`):** Four in-scope modules (Theory of Computation, Machine Learning, LLMs, Macroeconomics) require fast, XSS-safe client-side LaTeX equation rendering and Markdown formatting.
5. **Build environment (`ASM-005`, `ASM-066`):** The repository workspace is verified on Linux `x86_64` with Node.js `v22.22.1` and `npm 9.2.0` (`ASM-005`) and `ts-fsrs` `v5.4.2` (`FSRSVersion: "v5.4.2 using FSRS-6.0"`, `default_w.length = 21`, `ASM-066(a)`), while the Python 3 + `pypdf` + `poppler-utils` (`pdftoppm`) PDF/LaTeXiT extraction helper (`CLI-02`) is adopted under `ASM-066(b)` with its installation and workspace verification scheduled in `SL-01`.

---

## 2. Decision

We adopt an end-to-end **TypeScript 5.6 (strict mode)** stack running on **Node.js 22 LTS** (`ASM-005`), organised as an npm workspace monorepo with a small Python 3 (`pypdf` + `poppler-utils` `pdftoppm`) PDF/LaTeXiT extraction helper (`CLI-02`, `ASM-066(b)`, installed and verified in `SL-01`):

1. **Frontend (`packages/web`):** **React 18** + **Vite 5** + **Tailwind CSS**, with **Workbox** (`vite-plugin-pwa`) for `R3` offline Service Worker caching and IndexedDB offline mutation queueing (`idb`).
2. **Backend HTTP Server (`packages/server`):** **Hono 4** (running on `@hono/node-server` in Node.js 22 LTS), providing lightweight, strictly typed REST + Server-Sent Events (SSE) endpoints and serving the static React build in `R3`.
3. **Shared Contracts & Domain Types (`packages/shared`):** Shared TypeScript interfaces, **Ajv v8** (JSON Schema Draft 2020-12) validators, and RFC 9457 `ProblemDetails` error models used by both the pipeline CLI, backend server, and frontend.
4. **Core Reusable Libraries (`DEC-015`, `DEC-017`, `A22 §5`):**
   - `ts-fsrs` v5 (`v5.4.2`, `FSRS-6.0`): sole FSRS-6 (`21`-weight, with `17`/`19`-weight legacy parameter migration via `migrateParameters`, `ASM-066`) scheduling and `retrievability` engine for both `CardState` and `ConceptState` (`REQ-N-010`, `BR-024`, `BR-032`, `TC-I-022`, `TC-I-N10`).
   - `better-sqlite3`: synchronous, low-overhead C++ SQLite binding for Node.js (`ADR-002`).
   - `katex` + `marked` + `dompurify`: client-side LaTeX and sanitised Markdown rendering (`REQ-F-024`, `REQ-N-014`).
   - `@anthropic-ai/sdk`: server-side Claude API client with prompt caching (`cache_control: { type: "ephemeral" }`) and SSE streaming for `R2` written-answer marking and the grounded tutor (`REQ-F-043`–`048`).
   - `ical-generator`: RFC 5545 `.ics` calendar feed generation (`REQ-F-057`).
5. **Testing & Quality Tooling (`A20`, `A39`):** **Vitest** for unit, integration, contract, and benchmark tests; **Playwright** + `@axe-core/playwright` for browser E2E, offline PWA, multi-viewport (`REQ-N-021`), and WCAG 2.2 AA accessibility tests (`REQ-N-018`); **ESLint** + `typescript-eslint` for static analysis and layering enforcement (`ADR-003`).

---

## 3. Alternatives Considered

### Alternative A: Next.js (App Router / SSR Full-Stack Framework)
- **Pros:** Combines React UI and API routes in one framework.
- **Why rejected:** Next.js App Router introduces React Server Components complexity, heavier build times, and awkward offline PWA Service Worker integration (`REQ-F-060`, `REQ-N-009`), whereas a SPA (Vite + React) backed by a clean REST/SSE API (`Hono`) maps directly to `A34` OpenAPI contracts, runs effortlessly offline via Service Worker + IndexedDB, and keeps presentation and business layers strictly separated (`G3.1`).

### Alternative B: Python Backend (FastAPI + SQLite) with TypeScript/React Frontend
- **Pros:** Direct in-process access to Python PDF libraries (`pypdf`) on the backend.
- **Why rejected:** Splits the domain across two languages (Python and TypeScript), preventing shared JSON Schema/type definitions and preventing the server and offline PWA client from sharing the exact same `ts-fsrs` TypeScript library (`REQ-N-010`). Since PDF extraction runs only in the offline pipeline CLI (`ADR-004`), keeping the web app and API 100% TypeScript is simpler to maintain (`ASM-055`).

### Alternative C: Electron or Tauri Desktop Application
- **Pros:** Native local file system access on the laptop.
- **Why rejected:** Cannot be deployed to a cloud host for phone browser/PWA access in `R3` (`REQ-F-059`–`061`, `[USER Q-04]`) without maintaining a separate web build.

---

## 4. Consequences

- **Positive:**
  - Single language (`TypeScript`) and shared `ts-fsrs` / `Ajv` validation across frontend, backend, and pipeline helper CLI.
  - Zero network overhead on local API calls (in-process SQLite query + Hono serialization, designed to fit within `REQ-N-001`'s `<= 100 ms` p95 target; empirically measured in `SL-01` and `SL-07`).
  - Offline PWA (`R3`) can run `ts-fsrs` locally in the browser for offline flashcard and MCQ reviews (`REQ-F-060`) with `100%` mathematical parity (`REQ-N-010`).
- **Negative / Trade-offs:**
  - `better-sqlite3` uses a native Node addon, requiring standard prebuilt binaries for Node 22 LTS on Linux (`x64`) in dev/CI and in the `R3` Docker image (`ADR-006`).
  - The `CLI-02` PDF/LaTeXiT extraction helper requires Python 3, `pypdf`, and `poppler-utils` (`pdftoppm`), whose installation and workspace verification are scheduled in `SL-01` (`ASM-066(b)`, `RSK-002`).
