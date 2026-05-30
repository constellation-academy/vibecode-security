# vibecode-security

A Claude Code skill that reviews vibe-coded apps for security before they go live. It runs a secrets scan, an OWASP Top 10 code review, and a GDPR checklist — and issues a hard PASS or FAIL verdict.

---

## Before you start

When Claude runs the security scan, it will ask for your permission to execute a script. **Click Allow** — this is expected and required for the scan to work.

---

## Install — Claude Code Desktop

1. Open Claude Code Desktop
2. Paste this into the chat and press Enter:

```
! mkdir -p ~/.claude/skills/vibecode-security && curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/skills/vibecode-security/SKILL.md -o ~/.claude/skills/vibecode-security/SKILL.md
```

3. Quit and reopen Claude Code Desktop

Done.

---

## Install — Claude Code CLI

Run this in your terminal:

```bash
mkdir -p ~/.claude/skills/vibecode-security && curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/skills/vibecode-security/SKILL.md -o ~/.claude/skills/vibecode-security/SKILL.md
```

Then restart Claude Code.

---

## Usage

Say things like **"check my app"**, **"can I go live?"**, **"is this safe to share?"**, **"Freigabe"**, or **"kann ich das veröffentlichen?"** — in English or German.

Claude will confirm the project path, run the scan, review the code, and issue a PASS or FAIL verdict.

---

## Author

[Sascha Ringert](https://constellation-academy.com) · [Constellation Academy](https://constellation-academy.com)
