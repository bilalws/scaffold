# Django + Nuxt.js Scaffold

Monorepo scaffold for Django (backend) + Nuxt.js (frontend) projects.

**Stack:** Django · DRF · django-rq · Redis · Gunicorn · Nuxt.js · Nginx · Certbot

---

## Starting a New Project

1. Create a new repo on GitLab and clone it locally
2. Run init:

```bash
chmod +x scripts/init.sh scripts/rename.sh
./scripts/init.sh
```

The init script will:
- Pull all scaffold files from GitHub
- Rename all `__PROJECT_NAME__` placeholders to your repo name
- Generate Django project with `config/` settings split (base / dev / prod)
- Move `shared/` utilities into place
- Set up RQ + Redis task queue config

3. Init Nuxt.js frontend manually:

```bash
npx nuxi@latest init frontend --template minimal
cd frontend && npm install
```

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
│   ├── shared/          ← shared utilities, exceptions, middleware
│   ├── runtimes/        ← logs, media, static (gitignored)
│   ├── scripts/         ← one-off backend scripts
│   ├── locale/          ← i18n translations
│   ├── gunicorn.conf.py
│   └── requirements.txt
├── frontend/            ← Nuxt.js app
├── devops/
│   ├── nginx/           ← nginx.conf + location.conf
│   ├── systemd/         ← gunicorn + rq worker services
│   ├── scripts/         ← deploy, backup, restore, setup-server
│   └── cron/            ← crontab example
├── scripts/
│   ├── init.sh          ← run once after cloning
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
| `make collectstatic` | Collect static files |
| `make deploy` | Deploy backend + frontend |
| `make deploy-be` | Deploy backend only |
| `make deploy-fe` | Deploy frontend only |
| `make backup` | Backup database |
| `make restore FILE=path` | Restore database |
| `make setup-server DOMAIN=x` | First-time server setup |

---

## First Deploy

```bash
# 1. On server — prepare project directory
sudo mkdir -p /opt/projects
sudo chown -R ubuntu:ubuntu /opt/projects

# 2. Clone project
cd /opt/projects
git config --global credential.helper store
git clone https://deploy-user:token@gitlab.com/your-username/project.git
cd project

# 3. Run server setup
bash devops/scripts/setup-server.sh yourdomain.com
```

After `setup-server.sh` completes, follow the printed next steps:

```bash
# Timezone
sudo timedatectl set-timezone Asia/Seoul

# Firewall
sudo ufw allow 80/tcp && sudo ufw allow 443/tcp

# MySQL — create user and database
sudo mysql
  CREATE USER 'ubuntu'@'localhost';
  GRANT ALL PRIVILEGES ON *.* TO 'ubuntu'@'localhost';
  CREATE DATABASE `your-project` DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;

# Environment
cp .env.example .env  # fill in your values

# Python setup
python3 -m venv backend/venv
pip install -r backend/requirements.txt

# Django
make migrate
make createsuperuser
make collectstatic

# Start services
sudo systemctl start your-project your-project-worker1 your-project-worker2

# Frontend
cd frontend && npm run build
pm2 start .output/server/index.mjs --name your-project-frontend
```