# ADR-001 · Language, Web Stack, and Core Domain Libraries

- **Artifact ID:** `A30` (`ADR-001`)
- **Stage:** Stage 3 — Architecture & Design
- **Date:** `2026-10-21`
- **Status:** Accepted
- **Deciders:** System Architect (confirmed via `DEC-014` at `CP2`)
- **Drivers:** `[SEED §8]`, `DEC-014` (`A22 §5`), `ASM-005`, `REQ-F-023`–`034`, `REQ-F-043`–`048`, `REQ-F-057`, `REQ-F-060`, `REQ-N-001`–`005`, `REQ-N-010`, `REQ-N-018`–`021`, `RSK-003`

---

## 1. Context and Forces

The Study App and Generation Pipeline must be built, tested, and maintained by an AI agent with pull-request reviews by a single university student (`DEC-004`, `ASM-031`, `ASM-055`). The technology stack must satisfy the following forces:
1. **Seed preference (`[SEED §8]`):** The seed recommends React + TypeScript with `ts-fsrs` for the web frontend and Node.js + TypeScript with SQLite and the Claude TypeScript SDK (`@anthropic-ai/sdk`) for the backend.
2. **Mathematical FSRS fidelity (`REQ-N-010`, `RSK-003`):** Both flashcard scheduling (`CardState`) and concept-level quiz scheduling (`ConceptState`) must match reference FSRS v4/v5 calculations (`100%` parity) without custom memory-math bugs.
3. **Sub-100 ms local interactivity & offline PWA (`REQ-N-001`–`003`, `REQ-N-009`, `REQ-F-060`):** Card flips/ratings (`<= 100 ms` p95), next-item selection (`<= 300 ms` p95), and Today checklist rendering (`<= 1,000 ms` p95) must be fast on laptop and mobile browsers and work offline in `R3`.
4. **Heavy mathematical & diagram content (`[USER Q-08]`, `REQ-F-024`, `REQ-N-014`):** Four in-scope modules (Theory of Computation, Machine Learning, LLMs, Macroeconomics) require fast, XSS-safe client-side LaTeX equation rendering and Markdown formatting.
5. **Verified build environment (`ASM-005`):** The repository workspace provides Node.js `v22.22.1`, `npm 9.2.0`, and Python `3.x` with `pypdf` and `poppler-utils` (`pdftoppm`, `pdfinfo`).

---

## 2. Decision

We adopt an end-to-end **TypeScript 5.x (strict mode)** stack running on **Node.js 22 LTS**, organised as an npm workspace monorepo with a small Python PDF/LaTeXiT extraction helper:

1. **Frontend (`packages/web`):** **React 18** + **Vite 5** + **Tailwind CSS 3**, with **Workbox** (`vite-plugin-pwa`) for `R3` offline Service Worker caching and IndexedDB offline mutation queueing (`idb`).
2. **Backend HTTP Server (`packages/server`):** **Hono** (running on `@hono/node-server` in Node.js 22 LTS), providing lightweight, strictly typed REST + Server-Sent Events (SSE) endpoints and serving the static React build in `R3`.
3. **Shared Contracts & Domain Types (`packages/shared`):** Shared TypeScript interfaces, **Ajv v8** (JSON Schema Draft 2020-12) validators, and RFC 9457 `ProblemDetails` error models used by both the pipeline CLI, backend server, and frontend.
4. **Core Reusable Libraries (`DEC-014`, `A22 §5`):**
   - `ts-fsrs` (`v4.x`): sole scheduling engine for both `CardState` and `ConceptState` (`REQ-N-010`, `BR-024`, `BR-032`).
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
  - Zero network overhead on local API calls (`<= 5 ms` SQLite query + Hono serialization, well within `REQ-N-001`'s `<= 100 ms` budget).
  - Offline PWA (`R3`) can run `ts-fsrs` locally in the browser for offline flashcard and MCQ reviews (`REQ-F-060`) with `100%` mathematical parity (`REQ-N-010`).
- **Negative / Trade-offs:**
  - `better-sqlite3` uses a native Node addon, requiring standard prebuilt binaries for Node 22 LTS on Linux (`x64`) in dev/CI and in the `R3` Docker image (`ADR-006`).
