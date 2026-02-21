#!/usr/bin/env bash
set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RESET="\033[0m"

SCAFFOLD_REPO="https://github.com/bilalws/scaffold"

echo "▶ Pulling scaffold files..."
git remote remove scaffold 2>/dev/null || true
git remote add scaffold "$SCAFFOLD_REPO"
git fetch scaffold
git checkout scaffold/main -- .
git remote remove scaffold

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║      Project Init (Django + Nuxt)    ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════╝${RESET}"
echo ""

# ─── 1. Rename placeholders ───────────────
bash scripts/rename.sh

# ─── 2. Django setup ──────────────────────
echo -e "${CYAN}▶ Setting up Django backend...${RESET}"

python3 -m venv backend/.venv
source backend/.venv/bin/activate
pip install --quiet django django-environ djangorestframework django-cors-headers django-rq

# Generate Django project — no conflict since config_scaffold/ != config/
django-admin startproject config backend/

# Replace generated settings.py with scaffold settings
rm backend/config/settings.py
mv backend/config_scaffold/settings backend/config/settings
rm -rf backend/config_scaffold

# Point manage.py, wsgi, asgi to settings.dev
sed -i "s/config.settings/config.settings.dev/" backend/manage.py
sed -i "s/config.settings/config.settings.dev/" backend/config/wsgi.py
sed -i "s/config.settings/config.settings.dev/" backend/config/asgi.py

deactivate
echo -e "${GREEN}✔ Django backend ready${RESET}"

# ─── 3. Nuxt setup ────────────────────────
echo -e "${CYAN}▶ Setting up Nuxt.js frontend...${RESET}"
npx nuxi@latest init frontend --no-install --git-init false --packageManager npm
cd frontend && npm install --silent && cd ..
echo -e "${GREEN}✔ Nuxt.js frontend ready${RESET}"

# ─── Done ─────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║            Init complete! 🎉             ║${RESET}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  Next steps:"
echo -e "  1. cp .env.example .env  →  fill in your values"
echo -e "  2. make migrate          →  run DB migrations"
echo -e "  3. make dev              →  start backend + frontend + worker"
echo ""
