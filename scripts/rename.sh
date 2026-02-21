#!/usr/bin/env bash
set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
RESET="\033[0m"

# Use git root folder name as project name if not passed
if [ -n "$1" ]; then
    PROJECT_NAME="$1"
else
    PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
fi

PLACEHOLDER="__PROJECT_NAME__"

echo -e "${BOLD}▶ Renaming project to: ${PROJECT_NAME}${RESET}"

# Replace placeholder in all text files (excluding .git)
grep -rl "$PLACEHOLDER" . --exclude-dir=.git | while read -r file; do
    sed -i "s/${PLACEHOLDER}/${PROJECT_NAME}/g" "$file"
    echo "  updated: $file"
done

# Rename files that have the placeholder in their name
find . -name "*${PLACEHOLDER}*" ! -path "./.git/*" | while read -r f; do
    NEW="${f//$PLACEHOLDER/$PROJECT_NAME}"
    mv "$f" "$NEW"
    echo "  renamed: $f → $NEW"
done

echo -e "${GREEN}✔ Done${RESET}"
