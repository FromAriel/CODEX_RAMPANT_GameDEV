#!/usr/bin/env bash
set -euo pipefail

TIMEOUT_SEC=20
LOG_FILE="/tmp/gdformat.log"
GD_ARGS=(--use-spaces=4)

files=()
for f in "$@"; do
    [[ $f == *.gd ]] && files+=("$f")
done

[[ ${#files[@]} -eq 0 ]] && exit 0

> "$LOG_FILE"
if ! timeout "${TIMEOUT_SEC}s" gdformat "${GD_ARGS[@]}" "${files[@]}" &> "$LOG_FILE"; then
    echo "⚠️  gdformat failed or exceeded ${TIMEOUT_SEC}s." >&2
    echo "    Commit or task aborted. See detailed logs below." >&2
    echo "CODEX: ❌ gdformat failed or timed out after ${TIMEOUT_SEC}s"
    echo "CODEX: 📄 log available at $LOG_FILE"
    echo "──── gdformat log excerpt ────"
    tail -n 10 "$LOG_FILE"
    echo "──── (full log in $LOG_FILE) ────"
    exit 1
fi
