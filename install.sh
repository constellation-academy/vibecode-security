#!/bin/bash
set -e

SKILL_SRC="$(cd "$(dirname "$0")/skills/vibecode-security" && pwd)"
SKILL_DEST="$HOME/.claude/skills/vibecode-security"

mkdir -p "$HOME/.claude/skills"

if [ -L "$SKILL_DEST" ]; then
  rm "$SKILL_DEST"
fi

ln -sf "$SKILL_SRC" "$SKILL_DEST"
echo "✓ vibecode-security skill installed."
echo "  Restart Claude Code, then say: 'Freigabe' or 'security check'"
