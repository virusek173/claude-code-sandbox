#!/usr/bin/env bash
# Entrypoint — ensures sandbox hooks are always active in settings.json,
# even when ~/.claude is mounted from the host and overwrites the image defaults.

set -euo pipefail

SETTINGS="/home/developer/.claude/settings.json"
HOOK='{"matcher":"Read|Edit","hooks":[{"type":"command","command":"block-sensitive-files"}]}'

mkdir -p "$(dirname "$SETTINGS")"

if [[ ! -f "$SETTINGS" ]]; then
    echo '{}' > "$SETTINGS"
fi

# Merge the hook into PreToolUse array, deduplicating by matcher+command
UPDATED=$(jq --argjson hook "$HOOK" '
  .hooks.PreToolUse //= [] |
  .hooks.PreToolUse |= (
    [.[] | select(.matcher != $hook.matcher)] + [$hook]
  )
' "$SETTINGS")

echo "$UPDATED" > "$SETTINGS"

exec claude "$@"
