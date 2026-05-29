# vibecode-security

A Claude Code skill that blocks unsafe vibe-coded apps from going live. It runs a secrets scan, an OWASP Top 10 code review, and a GDPR checklist — and issues a hard PASS or FAIL verdict.

**Trigger phrases:** `security check` · `review my app` · `publish my app` · `Freigabe`

---

## Install

### Mac / Linux

Paste this into your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/install.sh | bash
```

Then **restart Claude Code** (quit and reopen).

---

### Windows

Paste this into PowerShell:

```powershell
irm https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/install.ps1 | iex
```

Then **restart Claude Code** (quit and reopen).

---

### Claude Code Desktop (Mac)

1. Open Claude Code Desktop
2. Open a terminal window inside the app (`Ctrl+`` ` or via the menu)
3. Paste the Mac install command:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/install.sh | bash
   ```
4. **Quit and reopen** Claude Code Desktop

---

## Usage

In any Claude Code session, say:

> **"security check"** or **"review my app"** or **"Freigabe"**

The skill will ask for your repo path, run the scan, review your code, and issue a PASS or FAIL verdict.

---

## Manual scan (without Claude Code)

**Mac / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/scan.sh | bash -s -- /path/to/your-repo
```

**Windows (Git Bash or WSL):**
```bash
curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/scan.sh | bash -s -- /path/to/your-repo
```

Fix all findings, re-run until clean, then trigger the full Claude Code review.

---

## Updating

The skill auto-updates every time it runs (pulls the latest version silently).

---

## Requirements

- Claude Code (CLI or Desktop app)
- Node.js + npm (for JS/TS projects)
- Python + `pip install pip-audit` (for Python projects)

---

## Author

[Sascha Ringert](https://constellation-academy.com) · [Constellation Academy](https://constellation-academy.com)
