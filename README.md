# Vibecode Security

Security gate for vibecoded apps before going live. Includes a scan script and a Claude Code skill.

## Installation (3 steps)

**Step 1 — Clone the repo** (einmalig):
```bash
git clone https://github.com/constellation-academy/vibecode-security ~/vibecode-security
```

**Step 2 — Run the install script**:
```bash
bash ~/vibecode-security/install.sh
```

**Step 3 — Restart Claude Code** (komplett schließen und neu öffnen).

Done. Trigger it by saying: **"Freigabe"**, **"security check"**, or **"ich will meine App veröffentlichen"**.

---

## Manual scan (without Claude Code)

```bash
bash ~/vibecode-security/scan.sh /path/to/your-repo
```

Fix any findings, re-run until clean, then ask a tech reviewer to sign off.

## Requirements

- bash
- git
- Node.js + npm (for JS projects)
- Python + `pip install pip-audit` (for Python projects)

## Updating

```bash
cd ~/vibecode-security && git pull
```

No reinstall needed — the skill symlinks to the cloned folder.
