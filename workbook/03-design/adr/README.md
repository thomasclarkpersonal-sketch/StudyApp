# A30 · Architecture Decision Records (Index)

- **Artifact ID:** `A30`
- **Stage:** Stage 3 — Architecture & Design
- **Owner:** System Architect
- **Date:** `2026-10-21`
- **Status:** Approved at `CP3` (`[USER CP3]`, `DEC-017`–`DEC-023`)

## ADR Inventory (`ADR-001`–`ADR-007`)

Every required architecture decision (`systems_analysis_and_design_project_framework.md` `A30`) and every protocol-mandated design justification (`G3.1`, `G3.2`, `G3.6`, `G3.8`, Appendix `B9`) is recorded in its own ADR file:

| ID | File | Title | Drivers (`REQ` / `ASM` / `RSK` / `DEC`) | Status |
| :-- | :-- | :-- | :-- | :-: |
| [`ADR-001`](ADR-001-language-and-framework.md) | `03-design/adr/ADR-001-language-and-framework.md` | Language, Web Stack, and Core Domain Libraries (TypeScript 5, React 18 + Vite, Hono/Node 22, `ts-fsrs`, `KaTeX`, `Ajv`, `@anthropic-ai/sdk`) | `[SEED §8]`, `DEC-015`, `DEC-017`, `ASM-005`, `ASM-066`, `REQ-N-001`–`005`, `REQ-N-010`, `REQ-N-018`–`021`, `RSK-003` | Accepted (`DEC-017`) |
| [`ADR-002`](ADR-002-data-store-and-dual-persistence.md) | `03-design/adr/ADR-002-data-store-and-dual-persistence.md` | Data Store and Dual Persistence Strategy (SQLite WAL via `better-sqlite3` for App State + Schema-Validated JSON Files for Pipeline) | `[SEED §5, §8, §10]`, `DEC-018`, `REQ-F-018`–`022`, `REQ-N-001`–`003`, `REQ-N-007`, `REQ-N-008`, `REQ-N-011`, `REQ-N-020`, `RSK-011` | Accepted (`DEC-018`) |
| [`ADR-003`](ADR-003-architecture-style-and-layering.md) | `03-design/adr/ADR-003-architecture-style-and-layering.md` | Architecture Style, Three-Tier Layering, Single-Writer Table Ownership, and Database Constraint Backstops | `G3.1`, `G3.6`, `A31`, `DEC-019`, `REQ-N-008`, `REQ-N-010`, `REQ-N-011`, `REQ-N-013`, `REQ-N-020` | Accepted (`DEC-019`) |
| [`ADR-004`](ADR-004-pipeline-runtime-and-subagent-isolation.md) | `03-design/adr/ADR-004-pipeline-runtime-and-subagent-isolation.md` | Pipeline Runtime in Claude Code CLI, Fresh-Context Subagent Isolation, and Multimodal + LaTeXiT Slide Ingestion | `[USER Q-05, Q-15]`, `DEC-020`, `ASM-044`, `ASM-046`, `ASM-058`, `REQ-F-001`–`020`, `REQ-F-067`–`075`, `REQ-N-006`, `REQ-N-012`, `REQ-N-014`, `REQ-N-022`, `RSK-002`, `RSK-004`, `RSK-018`, `RSK-021` | Accepted (`DEC-020`) |
| [`ADR-005`](ADR-005-canvas-integration-and-fallback.md) | `03-design/adr/ADR-005-canvas-integration-and-fallback.md` | HKUST Canvas Read-Only REST API Integration with Local Folder Fallback | `[USER Q-17]`, `DEC-009`, `DEC-021`, `ASM-048`–`050`, `ASM-061`, `REQ-F-002`, `REQ-F-068`, `REQ-N-013`, `REQ-N-014`, `REQ-N-016`, `RSK-010`, `RSK-013`, `RSK-014` | Accepted (`DEC-021`) |
| [`ADR-006`](ADR-006-hosting-deployment-and-auth.md) | `03-design/adr/ADR-006-hosting-deployment-and-auth.md` | Hosting, Deployment Model (`B9`), and Single-User Authentication (`Localhost` in `R1`–`R2`, Fly.io `hkg` + `Argon2id` Session Auth in `R3`) | `[USER Q-04]`, `DEC-022`, `ASM-008`, `ASM-028`, `ASM-060`, `ASM-069`, `REQ-F-059`–`062`, `REQ-F-094`, `REQ-N-008`, `REQ-N-009`, `REQ-N-013`, `REQ-N-015`, `RSK-008`, `RSK-020` | Accepted (`DEC-022`) |
| [`ADR-007`](ADR-007-normalization-and-json-audit-columns.md) | `03-design/adr/ADR-007-normalization-and-json-audit-columns.md` | Third Normal Form (`3NF`) Relational Schema and Controlled JSON Columns for Immutable Snapshots & Audit Logs | `G3.2`, `A32`, `A33`, `DEC-023`, `REQ-F-021`–`022`, `REQ-F-048`, `REQ-F-049`, `REQ-F-063`, `REQ-N-001`–`003`, `REQ-N-007` | Accepted (`DEC-023`) |
