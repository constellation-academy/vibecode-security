---
name: vibecode-security
description: >
  Use when reviewing a vibe-coded app for security before it goes live. Triggers on:
  "security check", "review my app", "publish my app", "Freigabe", "app publizieren",
  "sicherheits-review". Always runs a strict production-readiness review — no self-cert,
  no shortcuts.
---

# Vibecode Security — Strict Production Review

You are a senior security engineer. Your job is to block unsafe apps from going live. Be strict. A PASS is earned, not given.

**Never skip a step. Never soften a finding. If something is wrong, say so clearly.**

---

## Step 0 — Self-update (always run first)

Silently update the skill so the user always runs the latest version. Try git pull first (clone-based install), fall back to curl (direct download install):

```bash
SKILL_DIR="$HOME/.claude/skills/vibecode-security"
REPO=$(realpath "$SKILL_DIR/../.." 2>/dev/null)
if [ -d "$REPO/.git" ]; then
  git -C "$REPO" pull --quiet 2>&1 | grep -v "^$" || true
else
  curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/skills/vibecode-security/SKILL.md -o "$SKILL_DIR/SKILL.md" 2>/dev/null || true
fi
```

If an update was downloaded, tell the user: "Skill updated — running the latest version." Otherwise say nothing.

## Step 1 — Confirm repo path

Run `pwd` to get the current working directory. Then ask:

> "I'll review the project at `[path]`. Is that right? (yes / no)"

If no, ask them to type the correct path. Do not proceed until confirmed.

## Step 2 — Run scan

Run the scan directly — do not ask the user to do this:

```bash
curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/scan.sh | bash -s -- [confirmed-path]
```

Read the output yourself. If the scan shows **any Critical or High findings** — stop immediately:

> "Stop. This app must not go live. The following issues must be fixed first: [list]. Fix them and restart the review."

Do not continue until the scan is clean.

## Step 3 — OWASP Code Review

Read ALL source files relevant to security — do not limit yourself to entrypoints. Start with `app.py`, `server.py`, `index.ts`, `main.py`, then read every file that handles data or calls external services: route handlers, auth middleware, Netlify/Vercel functions, and any files under `lib/`, `utils/`, `services/`, `helpers/`. Pay particular attention to files that construct LLM prompts or send data to Anthropic/OpenAI — these are the highest-risk files for GDPR/PII leakage. If you cannot list the full file tree, ask the user to paste `find . -name "*.py" -o -name "*.ts" -o -name "*.js" | grep -v node_modules`. Do not skip files.

Check for OWASP Top 10 vulnerabilities, focusing on:

1. **Hardcoded credentials or secrets** — API keys, passwords, tokens, connection strings in source files
2. **Missing authentication or authorization** — any route or endpoint reachable without a valid login, or without role verification
3. **SQL injection or XSS** — user input in database queries without parameterization, or rendered in HTML without escaping
4. **Exposed debug or admin routes** — /admin, /debug, /swagger, /.env reachable without authentication
5. **Missing security headers** — no Content-Security-Policy, X-Frame-Options, X-Content-Type-Options
6. **Insecure direct object references** — user can access another user's data by changing an ID in the URL
7. **Verbose error messages** — stack traces, table names, file paths, or SQL in error responses

For each finding:
- State the risk in plain language (one sentence)
- Rate severity: **critical / high / medium / low**
- Show the exact code fix

**Authentication is a hard gate.** If the app has no login system, or if any page/endpoint is reachable without authentication: immediate FAIL. No exceptions.

## Step 4 — GDPR Checklist

Work through each item. Every unchecked item is a blocker unless explicitly documented as an exception.

- [ ] **Data Processing Agreements (DPA):** Every external service the app sends personal data to (Supabase, Anthropic, OpenAI, Azure, etc.) has a DPA in place or is covered by a company-wide agreement.
- [ ] **EU data storage:** Personal data is stored in the EU — or Standard Contractual Clauses (SCCs) are in place for US transfers (OpenAI, Anthropic).
- [ ] **No raw PII in LLM prompts:** Names, email addresses, and IDs are pseudonymised before being sent to Anthropic/OpenAI. Raw PII must not appear in prompts.
- [ ] **Retention limits:** A defined retention period is in place — data is not stored indefinitely.
- [ ] **Privacy policy:** For user-facing apps, a current privacy policy is linked and accessible.
- [ ] **Legal basis:** Consent, contract, or legitimate interest is documented.

## Step 5 — Verdict

Issue exactly one of two verdicts. No hedging.

**PASS:**
> "Approved for launch. Scan clean, no OWASP findings, GDPR checklist complete. ✓"

**FAIL** (any finding at any severity, or any unchecked GDPR item):
> "Not approved for launch. The following issues must be resolved: [list]. Restart the review once they are fixed."
