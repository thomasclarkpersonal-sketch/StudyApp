# ADR-005 · HKUST Canvas Read-Only REST API Integration with Local Folder Fallback

- **Artifact ID:** `A30` (`ADR-005`)
- **Stage:** Stage 3 — Architecture & Design
- **Date:** `2026-10-21`
- **Status:** Accepted
- **Deciders:** System Architect & Student (`[USER Q-17]`, `DEC-009`, `CP1`)
- **Drivers:** `[USER Q-17]`, `DEC-009`, `ASM-048`–`050`, `ASM-061`, `REQ-F-002`, `REQ-N-013`, `REQ-N-014`, `REQ-N-016`, `BR-001`, `BR-002`, `BR-003`, `RSK-010`, `RSK-013`, `RSK-014`

---

## 1. Context and Forces

In `Q-17` (`DEC-009`), the student chose to allow the pipeline to read course material, announcements, assignments, and syllabi directly from **HKUST Canvas** (`https://canvas.ust.hk`) rather than manually downloading every file, because the COMP 4901B syllabus (`SRC-05`) leaves coursework dates and weekly schedules as *"to be announced on Canvas"* (`ASM-047`).
This integration is governed by strict security and privacy constraints:
1. **Read-only & scope-restricted (`ASM-049`, `ASM-061`, `BR-001`, `REQ-N-016`):** Access must be strictly `GET`/`HEAD` (read-only), restricted to the explicit `canvas_course_id` values in `pipeline.config.json`, and limited to course syllabus, modules, files, pages, assignments, and announcements — never reading discussion forums, class rosters, or other students' submissions, and never scraping other university portals.
2. **Secret protection (`ASM-050`, `REQ-N-013`, `RSK-013`):** The Canvas credential must be stored outside the repository and browser, never logged, and never committed.
3. **Graceful fallback (`ASM-048`, `REQ-F-002`, `UC-03 ext 2a`, `RSK-014`):** If HKUST terms disallow automated token access, if the token expires, or if Canvas is unreachable, the pipeline must fall back cleanly to reading local files in `courses/<module>/source/`.

---

## 2. Decision

We implement Canvas ingestion in `pipeline-cli sync-canvas` (`packages/pipeline/src/canvas/CanvasClient.ts`) using **Read-Only Canvas REST API v1 Calls with a Personal Access Token and Automatic Local Folder Fallback**:

1. **Authentication & Secret Storage (`REQ-N-013`):**
   - Uses a standard Canvas Personal Access Token (`Authorization: Bearer <CANVAS_API_TOKEN>`) read exclusively from an environment variable or `~/.config/studyapp/credentials.env` (mode `0600`, outside the git repository).
2. **Hardcoded Method & Endpoint Allowlist (`BR-001`, `REQ-N-016`):**
   - `CanvasClient` only implements `GET` requests against five allowlisted path patterns for a configured `:course_id`:
     - `GET /api/v1/courses/:course_id?include[]=syllabus_body`
     - `GET /api/v1/courses/:course_id/modules?include[]=items&per_page=100`
     - `GET /api/v1/courses/:course_id/files?per_page=100` (plus file download URLs for `.pdf`, `.pptx`, `.docx`, `.md`)
     - `GET /api/v1/courses/:course_id/pages/:url`
     - `GET /api/v1/courses/:course_id/assignments?per_page=100`
     - `GET /api/v1/courses/:course_id/discussion_topics?only_announcements=true&per_page=100`
   - Any attempt to call `POST`, `PUT`, `PATCH`, `DELETE`, or any non-allowlisted endpoint (such as `/users`, `/enrollments`, `/submissions`, or non-announcement `/discussion_topics`) throws an immediate `CanvasPolicyViolationError` before any network socket is opened (`TC-I-170`).
3. **PII Stripping & Untrusted-Data Encapsulation (`BR-002`, `BR-003`, `REQ-N-014`, `REQ-N-016`):**
   - Response JSON is stripped of author/instructor metadata (`author`, `user_name`, `email`, `avatar_image_url`, `grader_id`) at the client boundary so third-party staff PII never enters the staging workspace (`DEC-008`, `BR-003`).
   - All text fields (`syllabus_body`, assignment `description`, announcement `message`, page `body`) have HTML tags sanitised to plain text/Markdown and are wrapped in `<untrusted_course_material source="canvas">...</untrusted_course_material>`.
4. **Timeouts, Retries, and Local Folder Fallback (`A34`, `UC-03 ext 2a`):**
   - Per-request timeout: `10,000 ms`; retry policy: up to `2` retries with exponential backoff (`1 s`, `3 s`) on `429 Too Many Requests` or `502`/`503`/`504`, honouring `Retry-After`.
   - On `401`/`403`, network failure, or `--offline` flag, `pipeline-cli` logs a clear warning and continues extraction from local files in `<workspace>/source/` (`REQ-F-002`).

---

## 3. Alternatives Considered

### Alternative A: Headless Browser Scraping (Playwright / Puppeteer with CAS/SAML Session Cookies)
- **Pros:** Works even if the Canvas UI disables API token generation.
- **Why rejected:** Brittle against HKUST Duo 2FA prompts and HTML layout changes, carries higher risk of violating institutional portal-scraping rules (`ASM-048`, `ASM-061`), and exposes full browser session cookies rather than a revocable scoped API token.

### Alternative B: Direct Canvas Calls from the Study App Web Server
- **Pros:** Clicking "Sync Canvas" inside the web UI.
- **Why rejected:** Canvas content must pass through the Extractor and Reviewer pipeline before entering the Study App (`DEC-002`, `WF-01`), and keeping `CANVAS_API_TOKEN` out of the web server reduces the `R3` hosted attack surface (`ADR-006`, `RSK-008`, `RSK-013`).

---

## 4. Consequences

- **Positive:**
  - Enforces `BR-001`–`BR-003` (`read-only`, `in-scope courses only`, `zero staff/student PII`, `untrusted data tags`) in deterministic, unit-tested TypeScript code (`CanvasClient`).
  - Zero lock-in to Canvas availability: local folder drop-in (`courses/<module>/source/`) always works identically.
- **Negative / Trade-offs:**
  - The student generates a personal access token once in Canvas (`Account → Settings → Approved Integrations → New Access Token`) and places it in their local `.env`.
