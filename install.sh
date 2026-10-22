#!/bin/bash
# Installs the status line into ~/.claude and enables it in settings.json.
set -e
command -v jq >/dev/null || { echo "jq is required (brew install jq / apt install jq)"; exit 1; }
mkdir -p "$HOME/.claude"
cp "$(dirname "$0")/statusline.sh" "$HOME/.claude/statusline.sh"
chmod +x "$HOME/.claude/statusline.sh"
S="$HOME/.claude/settings.json"; [ -f "$S" ] || echo '{}' > "$S"
jq '.statusLine = {type: "command", command: "~/.claude/statusline.sh", padding: 0}' "$S" > "$S.tmp" && mv "$S.tmp" "$S"
echo "Installed. Send a message in Claude Code (or restart it) to see the status line."
