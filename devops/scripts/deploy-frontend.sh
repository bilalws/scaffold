#!/usr/bin/env bash
set -e

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
PROJECT_DIR="/opt/projects/${PROJECT_NAME}"
BRANCH="${1:-main}"

echo "▶ Pulling latest code ($BRANCH)..."
git pull origin "$BRANCH"

echo "▶ Frontend: installing & building..."
cd "${PROJECT_DIR}/frontend"
npm install --silent
npm run build
pm2 reload "${PROJECT_NAME}-frontend" || pm2 start .output/server/index.mjs --name "${PROJECT_NAME}-frontend"
