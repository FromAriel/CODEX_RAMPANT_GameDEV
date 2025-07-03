#!/usr/bin/env bash
set -e
for f in $(git diff --name-only --cached); do
    if [ -f "$f" ]; then
        mime=$(file -b --mime-type "$f")
        case "$mime" in
            text/*) ;;
            */xml) ;;
            *) echo "Binary file staged: $f"; exit 1;;
        esac
    fi
done
exit 0
