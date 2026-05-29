# vibecode-security

A Claude Code skill that reviews vibe-coded apps for security before they go live. It runs a secrets scan, an OWASP Top 10 code review, and a GDPR checklist — and issues a hard PASS or FAIL verdict.

---

## Install — Claude Code Desktop

1. Open Claude Code Desktop
2. Type the following into the chat and press Enter:

```
! curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/install.sh | bash
```

3. Quit and reopen Claude Code Desktop

That's it. From now on, just say **"security check"** or **"review my app"** in any session.

---

## Install — Claude Code CLI

```bash
curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/install.sh | bash
```

---

## Usage

Say **"security check"**, **"review my app"**, or **"Freigabe"** in any Claude Code session.

Claude will confirm the project path, run the scan, review the code, and issue a PASS or FAIL verdict.

---

## Requirements

- Node.js + npm (for JS/TS projects)
- Python + `pip install pip-audit` (for Python projects)

---

## Author

[Sascha Ringert](https://constellation-academy.com) · [Constellation Academy](https://constellation-academy.com)
