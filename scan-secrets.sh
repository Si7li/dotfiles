#!/bin/bash
# Fails (exit 1) if any file in the given paths looks like it contains a secret.
# Prints file:line only, never the value.
cd "$(dirname "$(readlink -f "$0")")"
PATTERNS='sk-[A-Za-z0-9_-]{20,}|sk-proj-[A-Za-z0-9_-]{10,}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(api[_-]?key|secret|token|passw(or)?d)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9_/+=.-]{16,}'
hits=$(grep -HrnIiEo "$PATTERNS" "${@:-home system}" 2>/dev/null | cut -d: -f1,2 | sort -u)
if [ -n "$hits" ]; then
  echo "!! Possible secrets found — not committing. Remove them (or move to a non-tracked file):" >&2
  echo "$hits" | sed 's/^/   /' >&2
  exit 1
fi
