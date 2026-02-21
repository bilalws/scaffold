#!/usr/bin/env bash
set -e

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
PROJECT_DIR="/opt/projects/${PROJECT_NAME}"
BRANCH="${1:-main}"

echo "▶ Pulling latest code ($BRANCH)..."
git pull origin "$BRANCH"

echo "▶ Backend: installing dependencies..."
cd "${PROJECT_DIR}/backend"
source .venv/bin/activate
pip install -r requirements.txt --quiet

echo "▶ Backend: running migrations..."
python manage.py migrate --settings=config.settings.prod

echo "▶ Backend: collecting static files..."
python manage.py collectstatic --noinput --settings=config.settings.prod

echo "▶ Frontend: installing & building..."
cd "${PROJECT_DIR}/frontend"
npm install --silent
npm run build

echo "▶ Restarting services..."
sudo systemctl restart "${PROJECT_NAME}"
sudo systemctl restart "${PROJECT_NAME}-worker1"
sudo systemctl restart "${PROJECT_NAME}-worker2"

echo "✔ Deploy complete."
