#!/usr/bin/env bash
# PreToolUse hook — blocks reading/editing of sensitive files inside the sandbox.
# Triggered for Read, Edit, and Bash tools before execution.

INPUT=$(cat)

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

SENSITIVE_PATTERN='(^|/)\.env(\.|$)|\.pem$|\.key$|\.p12$|\.pfx$|(^|/)id_rsa|id_ed25519|credentials\.json$|\.netrc$|\.npmrc$'

if [[ -n "$FILE" ]]; then
  if echo "$FILE" | grep -qE "$SENSITIVE_PATTERN"; then
    echo '{"decision":"block","reason":"Access to sensitive file blocked by sandbox policy."}'
    exit 0
  fi
fi

echo '{"decision":"approve"}'
