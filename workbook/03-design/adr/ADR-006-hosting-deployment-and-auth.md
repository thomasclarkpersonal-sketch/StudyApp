# ADR-006 · Hosting, Deployment Model (`B9`), and Single-User Authentication

- **Artifact ID:** `A30` (`ADR-006`)
- **Stage:** Stage 3 — Architecture & Design
- **Date:** `2026-10-21`
- **Status:** Accepted
- **Deciders:** System Architect (resolving `ASM-028` and evaluating `ASM-060` with `ASM-069` pricing sources, presented at `CP3`)
- **Drivers:** `[USER Q-04]`, `[SEED §7, §8]`, `ASM-008`, `ASM-028`, `ASM-060`, `ASM-069`, `REQ-F-059`–`062`, `REQ-F-094`, `REQ-N-008`, `REQ-N-009`, `REQ-N-013`, `REQ-N-015`, `RSK-008`, `RSK-020`, Catalog Appendix `B9`

---

## 1. Context and Forces

Per `[USER Q-04]` (`ASM-008`) and `DEC-010`:
- **Releases `R1` and `R2`:** The Study App runs locally on the student's laptop (`127.0.0.1:3000`). In `R1`, it makes zero external network calls (`REQ-N-008`). In `R2`, the local server calls `https://api.anthropic.com` for written-answer marking and the tutor (`REQ-F-043`–`048`).
- **Release `R3` (`SL-18`, Story 17):** The Study App is deployed so the student can study on their phone (and laptop) from anywhere with offline PWA support (`REQ-F-060`, `REQ-F-061`), protected behind a single owner password (`REQ-F-059`, `REQ-N-015`, `RSK-008`), within an operating budget of **`$0–$10/month`** (`ASM-060`, `A02 §1.1`).

Per Catalog Appendix `B9`, the hosting choice must be evaluated across service model, deployment model, availability/reliability, scalability, provider viability, security/compliance, openness/portability, and cost (including data egress and operations time).

---

## 2. Evaluation of Hosting Options (`Appendix B9`)

| Criterion (`B9`) | Option 1: Fly.io PaaS (Single Container + 1 GB NVMe Volume in `hkg`) | Option 2: Tailscale Serve / Cloudflare Tunnel to Student's Laptop | Option 3: Serverless Functions + Managed Cloud DB (Vercel + Turso/Supabase) | Option 4: AWS EC2 / Lightsail IaaS VM (`ap-east-1` Hong Kong) |
| :-- | :-- | :-- | :-- | :-- |
| **Service & deployment model** | Public Cloud PaaS (Docker container + persistent NVMe block volume) | Hybrid / Private Mesh VPN (`Tailscale`) to local laptop | Public Serverless FaaS + Managed DB-as-a-Service | Public Cloud IaaS VM |
| **Availability & reliability** | Always-on (24/7 even when laptop is asleep in backpack); auto-restarts container on crash | Fails whenever the student's laptop is closed/asleep (which is common when commuting and studying on a phone!) | Always-on (`99.9%`) | Always-on, but student must patch Linux OS & manage systemd/TLS |
| **Scalability** | Vertical scale (`256 MB`–`1 GB` RAM, `1 GB`–`10 GB` NVMe) easily exceeds `REQ-N-007` (`500k` rows < `150 MB` SQLite) | Limited to laptop uptime | High, but adds network hop between FaaS and remote DB (`REQ-N-001` `<= 100 ms` at risk) | High |
| **Provider viability** | High (established developer PaaS with Hong Kong `hkg` edge region) | High | High | High |
| **Security & compliance** | Automatic Let's Encrypt TLS (`HTTPS` 1.3), private env secrets (`fly secrets`), single-tenant volume | Encrypted WireGuard tunnel (`Tailscale`), zero public internet exposure | Shared multi-tenant cloud DB; extra third-party data processor (`UDP-03`) | Manual firewall / TLS configuration required |
| **Openness & exit cost** | Standard `Dockerfile` + single `study.db` SQLite file (`scp`/`sftp` exit in `< 1 min`, zero lock-in) | Zero lock-in (`study.db` stays on laptop) | High lock-in: requires adapting `better-sqlite3` synchronous transactions to HTTP libSQL/Postgres | Low lock-in (standard Linux VM), higher ops effort |
| **Monthly cost (`ASM-060`, `ASM-069`)** | **`~$2.35–$5.00/month`** (`shared-cpu-1x` `256 MB` `$1.94–$2.19/mo` base / `~$2.19–$4.50/mo` in `hkg` + `1 GB` NVMe volume `$0.15/mo` + Asia-Pacific egress `$0.04/GB`, `< $0.05/mo` for `< 1 GB/mo` single-user traffic; `fly.io/docs/about/pricing/` verified `2026-10-23` `[ASM-060, ASM-069]`) | **`$0/month`** (Tailscale Personal free tier for personal non-commercial use; `tailscale.com/pricing` verified `2026-10-23` `[ASM-069]`) | `$0/month` Hobby free tier, **`$20/month` per seat** on Vercel Pro if Hobby limits exceeded (`vercel.com/pricing` verified `2026-10-23` `[ASM-069]`) | **`$3.50–$10.00/month`** (`ap-east-1` Lightsail Linux `$3.50/mo` IPv6-only `512 MB` to `$5.00–$10.00/mo` dual-stack IPv4 `512 MB`–`1 GB`; `aws.amazon.com/lightsail/pricing/` verified `2026-10-23` `[ASM-069]`) |
| **Operations time** | `< 5 min/release` (`fly deploy`) | `0 min` deploy, but requires keeping laptop awake | Medium (managing two cloud vendors) | High (OS patching, Caddy/Nginx TLS, cron backups) |

---

## 3. Decision

### 3.1 Deployment Model across Releases (`ASM-028`, `ASM-060`, `ASM-069`)
1. **`R1` and `R2` (Local Mode, `APP_MODE=local`):**
   - The Hono server binds strictly to loopback (`127.0.0.1:3000`, never `0.0.0.0`) so no other device on university Wi-Fi can reach it.
   - Authentication is bypassed in `local` mode (`REQ-F-059`, `BR-044`), while `Origin` / `Sec-Fetch-Site` headers are checked on all state-changing requests (`POST`, `PUT`, `PATCH`, `DELETE`) to prevent cross-site request forgery from other browser tabs.
2. **`R3` (Hosted Mode, `APP_MODE=hosted`):**
   - Primary target: **Single Docker container on Fly.io (`hkg` Hong Kong region)** mounting a persistent `1 GB` NVMe volume at `/data/study.db` (`~$2.35–$5.00/month` per `ASM-069`, within `ASM-060`'s `$0–$10/month` range; `ASM-060` remains `open` until verified at `SL-18` deployment).
   - Because the deployment artifact is a standard OCI `Dockerfile` listening on `PORT=3000` with `/data/study.db`, the student can also run it at `$0/month` (`[ASM-069]`) over **Tailscale Serve** on their laptop or on any other container host (`Railway`, `Render`, VPS) without changing a single line of code.

### 3.2 Single-User Password Authentication in `R3` (`REQ-F-059`, `REQ-N-015`, `BR-045`)
When `APP_MODE=hosted`:
1. **Startup guard:** The server refuses to start if `STUDY_APP_PASSWORD_HASH` or `SESSION_SECRET` (`>= 32` random bytes) is missing from the environment (`TC-S-015` [alias `TC-S-N15`]).
2. **Password hashing:** The student's password is stored as an **Argon2id** hash (`m=65536, t=3, p=4`, or Node `crypto.scrypt` with `N=16384, r=8, p=1` + 16-byte random salt and constant-time `crypto.timingSafeEqual`) in `STUDY_APP_PASSWORD_HASH`. Plaintext passwords are never stored anywhere.
3. **Session token & cookie:** On `POST /api/auth/login`, the server issues a cryptographically random 32-byte session token (storing only `SHA-256(token)` in the `auth_session` SQLite table `R33` with `issued_at` and `expires_at` 14-day TTL so `POST /api/auth/logout` or password rotation immediately revokes active sessions) in an `HttpOnly; Secure; SameSite=Strict; Path=/` cookie (`__Host-study_session`).
4. **Global auth middleware, trusted client-IP resolution & rate limiting (`REQ-N-015`, `TC-I-006`, `TC-I-257`):** Every HTTP route except `GET /api/health` and `POST /api/auth/login` (plus static login assets) runs the auth middleware **before** reading request bodies, touching SQLite, or calling the Claude API. Failed login attempts on `POST /api/auth/login` are rate-limited in memory to **`<= 5` attempts per 60 seconds per client IP** (`429 Too Many Requests` with `Retry-After: 60`), where the client IP is resolved according to `TRUSTED_PROXY_MODE` (`'fly' | 'tailscale' | 'none'`, default `'fly'` when `FLY_APP_NAME` is set in `APP_MODE=hosted`, else `'none'`):
   - **`TRUSTED_PROXY_MODE='fly'` (Fly.io `R3` deployment):** uses the single-value **`Fly-Client-IP`** header set and overwritten at the Fly.io edge proxy, and **ignores** raw client-supplied `X-Forwarded-For`, `X-Real-IP`, or `Forwarded` headers so an attacker cannot bypass the rate limit by rotating spoofed forwarding headers (`TC-I-257`).
   - **`TRUSTED_PROXY_MODE='tailscale'` (Tailscale Serve `R3` deployment):** accepts the single-hop forwarding header from `tailscaled` **only** when the direct TCP socket peer (`remoteAddress`) is loopback (`127.0.0.1` or `::1`).
   - **`TRUSTED_PROXY_MODE='none'` or missing/malformed platform header (fallback):** keys the per-IP bucket on the **direct TCP socket peer address (`remoteAddress`)** paired with a global failed-login circuit breaker (`<= 20` failed attempts per 60 s across all sources), while requests carrying an already-valid `__Host-study_session` cookie bypass the login endpoint entirely so a stranger's failed login attempts cannot lock out an already-authenticated owner device.

---

## 4. Consequences

- **Positive:**
  - Resolves the `ASM-028` host choice and grounds `ASM-060` in verified vendor pricing (`~$2.35–$5.00/month <= $10/month` `[ASM-060, ASM-069]`), with low regional latency via the same-city Hong Kong (`hkg`) edge region.
  - Preserves the exact same `better-sqlite3` engine and `VACUUM INTO` backup architecture across `R1`, `R2`, and `R3`.
  - Protects Claude API spend and personal study data in `R3` (`RSK-008`, `REQ-N-015`).
- **Negative / Trade-offs:**
  - Because `study.db` lives on the Fly.io volume in `R3` while the pipeline runs locally in Claude Code on the student's laptop, importing a newly generated module in `R3` uploads the 6 JSON export files (`~200 KB`–`2 MB`) through the authenticated `POST /api/import/preview` and `POST /api/import/apply` web endpoints (which works identically in both local and hosted modes!).
