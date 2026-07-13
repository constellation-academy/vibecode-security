# Admin setup — org-wide rollout

This is for the **org admin** (Sascha), not for end users. Do it once. After this, every
Constellation Academy user gets the security check auto-installed — Desktop, terminal, and
VS Code — with **zero steps on their end**.

## Why this instead of `/plugin`

The `/plugin` command only works in the **terminal**, not the Desktop app, which is what our
non-technical users run. And the Desktop UI can't add a new marketplace by URL — it only lists
plugins from marketplaces that are *already* registered. So there is no click-only self-serve
path on Desktop. Org-managed settings solve this: they register the marketplace **and** install
the plugin for everyone, automatically.

## Steps (server-managed, no files, no MDM) — this is what's deployed

1. Go to **https://claude.ai/admin-settings/claude-code**
   (You need the **Owner** / Primary Owner role on the Teams/Enterprise plan.)
2. Under **Managed settings (settings.json)**, click **Manage**.
3. Paste (or **Upload settings.json**) this exact config, then click **Add settings** /
   **Update settings**:

   ```json
   {
     "extraKnownMarketplaces": {
       "vibecode-agent-skills": {
         "source": {
           "source": "github",
           "repo": "constellation-academy/vibecode-agent-skills"
         }
       }
     },
     "enabledPlugins": {
       "vibecode-security@vibecode-agent-skills": true
     }
   }
   ```

That's it. Users pick it up at their next login (or within the hourly refresh). They may need to
restart the Claude Code Desktop app once.

- Managed settings **outrank** user settings, so this is on for everyone and can't be toggled off
  by users (fine for a security gate; loosen via the Plugins UI's "Installed by default" if you
  ever want it user-removable — that path needs a private repo).
- The schema deliberately omits `autoUpdate` (not in the documented `extraKnownMarketplaces`
  shape); managed marketplaces still refresh from the repo.
- **Careful:** this editor replaces the *entire* managed `settings.json`. If you add other org
  settings later, keep these two keys in the same JSON — don't overwrite them away.

## Alternative: MDM file (only if you prefer file distribution)

If you'd rather push a file via Jamf / Intune / group policy instead of the admin console, drop the
**same JSON** at:

- **macOS:** `/Library/Application Support/ClaudeCode/managed-settings.json`
- **Windows:** `C:\Program Files\ClaudeCode\managed-settings.json`
- **Linux/WSL:** `/etc/claude-code/managed-settings.json`

## Users outside managed settings

Anyone not covered by the org account (personal login, contractor) won't get the auto-install.
For them, the one-time manual path is a single terminal command:

```
/plugin marketplace add https://github.com/constellation-academy/vibecode-agent-skills.git
/plugin install vibecode-security@vibecode-agent-skills
```

...or, if they only use Desktop, commit a `.claude/settings.json` with the same JSON as above into
their app repo — it auto-registers when they open that folder.
