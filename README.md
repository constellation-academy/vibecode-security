# vibecode-security

A Claude Code skill that reviews vibe-coded apps for security before they go live. It runs a secrets scan, an OWASP Top 10 code review, and a GDPR checklist — and issues a hard PASS or FAIL verdict.

Every app reviewed is assumed to be **fully internet-facing** (no VPN, no private network), so the review is strict: a PASS is earned, not given.

---

## Before you start

When Claude runs the security scan, it will ask for your permission to execute a script. **Click Allow** — this is expected and required for the scan to work.

---

## Install (recommended) — as a plugin

This is the easiest way to install and manage the skill. Works in **Claude Code Desktop and the CLI**.

Paste these two lines into the Claude Code prompt, one after the other:

```
/plugin marketplace add https://github.com/constellation-academy/vibecode-security.git
```

```
/plugin install vibecode-security@constellation-academy-agent-skills
```

Then restart Claude Code. Done. (You only need **git** installed — the HTTPS link above clones anonymously, so no GitHub account or SSH keys are required.)

**Prefer clicking?** On Desktop, after the first command you can also install from the UI: click the **+** button next to the prompt box → **Plugins** → **Add plugin**, then pick **vibecode-security** from the browser.

**Stay on the latest version.** This is a security tool, so you want the newest checks — but third-party plugins don't auto-update by default. Turn it on once: run `/plugin`, open the **Marketplaces** tab, select **constellation-academy-agent-skills**, and choose **Enable auto-update**. After that you get updates automatically at startup, no reinstall.

(Prefer to update by hand? Run `/plugin marketplace update constellation-academy-agent-skills` then `/reload-plugins` whenever you want the latest.)

---

## Install (alternative) — single skill file

If you'd rather not use the plugin system, install just the skill file. Works on Desktop and CLI.

**Desktop:** paste this into the chat and press Enter (the `!` runs it as a command):

```
! mkdir -p ~/.claude/skills/vibecode-security && curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/skills/vibecode-security/SKILL.md -o ~/.claude/skills/vibecode-security/SKILL.md
```

**CLI:** run the same command in your terminal (without the leading `!`):

```bash
mkdir -p ~/.claude/skills/vibecode-security && curl -fsSL https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/skills/vibecode-security/SKILL.md -o ~/.claude/skills/vibecode-security/SKILL.md
```

Then restart Claude Code. (This method self-updates each time you run the skill.)

---

## Check it worked

After restarting, open any project and type **"check my app"** (or **"kann ich das veröffentlichen?"**). Claude should recognise it and offer to run the security review. If it does, you're set.

---

## Usage

Say things like **"check my app"**, **"can I go live?"**, **"is this safe to share?"**, **"Freigabe"**, or **"kann ich das veröffentlichen?"** — in English or German.

Claude will confirm the project path, run the scan, review the code, and issue a PASS or FAIL verdict.

---

## Author

[Sascha Ringert](https://constellation-academy.com) · [Constellation Academy](https://constellation-academy.com)
