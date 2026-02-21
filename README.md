# Django + Nuxt.js Scaffold

Monorepo scaffold for Django (backend) + Nuxt.js (frontend) projects.

**Stack:** Django · DRF · django-rq · Redis · Gunicorn · Nuxt.js · Nginx · Certbot

---

## Starting a New Project

1. Use this repo as a GitHub template → create new repo
2. Clone your new repo
3. Run init:

```bash
chmod +x scripts/init.sh scripts/rename.sh
./scripts/init.sh
```

The init script will:
- Rename all `__PROJECT_NAME__` placeholders to your repo name
- Generate Django project with `config/` settings split (base / dev / prod)
- Generate Nuxt.js frontend
- Set up RQ + Redis task queue config

4. Copy and fill env:

```bash
cp .env.example .env
```

5. Start developing:

```bash
make dev
```

---

## Structure

```
├── backend/
│   ├── config/          ← Django settings, urls, wsgi, asgi
│   │   └── settings/
│   │       ├── base.py
│   │       ├── dev.py
│   │       └── prod.py
│   ├── apps/            ← your Django apps go here
│   ├── runtimes/        ← logs, media, static (gitignored)
│   ├── scripts/         ← one-off backend scripts
│   ├── locale/          ← i18n translations
│   ├── gunicorn.conf.py
│   └── requirements.txt
├── frontend/            ← Nuxt.js app
├── devops/
│   ├── nginx/           ← nginx config
│   ├── systemd/         ← gunicorn + rq worker services
│   ├── scripts/         ← deploy, backup, restore, setup-server
│   └── cron/            ← crontab example
├── scripts/
│   ├── init.sh          ← run once after cloning template
│   └── rename.sh        ← replaces __PROJECT_NAME__ placeholders
├── .env.example
└── Makefile
```

---

## Common Commands

| Command | Description |
|---|---|
| `make dev` | Start backend + frontend + rq worker |
| `make migrate` | Run Django migrations |
| `make makemigrations` | Create new migrations |
| `make shell` | Django shell |
| `make createsuperuser` | Create admin user |
| `make deploy` | Deploy to server |
| `make backup` | Backup database |
| `make restore FILE=path` | Restore database |
| `make setup-server DOMAIN=x` | First-time server setup |

---

## First Deploy

```bash
# 1. On server
sudo mkdir -p /opt/projects
sudo chown -R ubuntu:ubuntu /opt/projects

# 2. Clone
cd /opt/projects
git clone https://deploy-user:token@gitlab.com/bilalws/project.git

# 3. Run setup
cd project
bash devops/scripts/setup-server.sh yourdomain.com
```
