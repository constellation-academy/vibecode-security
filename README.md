# vibecode-security

A Claude Code skill that blocks unsafe vibe-coded apps from going live. It runs a secrets scan, an OWASP Top 10 code review, and a GDPR checklist — and issues a hard PASS or FAIL verdict.

**Trigger phrases:** `security check` · `review my app` · `publish my app` · `Freigabe`

---

## Install

### Mac / Linux — Claude Code CLI or VS Code

Paste this into your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/install.sh | bash
```

Then **restart Claude Code** (quit and reopen).

---

### Windows — Claude Code CLI or VS Code

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

### VS Code

1. Open the integrated terminal in VS Code (`Ctrl+`` ` / `Cmd+`` `)
2. Run the install command for your OS (see Mac/Linux or Windows above)
3. **Restart VS Code** — the skill is picked up on next launch

---

## Usage

In any Claude Code session, say:

> **"security check"** or **"review my app"** or **"Freigabe"**

The skill will ask for your repo path, run the scan, review your code, and issue a PASS or FAIL verdict.

---

## Manual scan (without Claude Code)

**Mac / Linux:**
```bash
bash ~/vibecode-security/scan.sh /path/to/your-repo
```

**Windows (Git Bash or WSL):**
```bash
bash ~/vibecode-security/scan.sh /path/to/your-repo
```

Fix all findings, re-run until clean, then trigger the full Claude Code review.

---

## Updating

The skill auto-updates on Mac/Linux every time it runs (it pulls the latest version silently).

On Windows, re-run the PowerShell install command to get the latest version.

---

## Requirements

- Claude Code (CLI, VS Code extension, or Desktop app)
- bash + git (Mac/Linux; Windows: Git Bash or WSL for the manual scan)
- Node.js + npm (for JS/TS projects)
- Python + `pip install pip-audit` (for Python projects)

---

## Author

[Sascha Ringert](https://constellation-academy.com) · [Constellation Academy](https://constellation-academy.com)
