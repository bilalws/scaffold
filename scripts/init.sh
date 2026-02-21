#!/usr/bin/env bash
set -e

SCAFFOLD_REPO="https://github.com/bilalws/scaffold"

echo "▶ Pulling scaffold files..."
git remote remove scaffold 2>/dev/null || true
git remote add scaffold "$SCAFFOLD_REPO"
git fetch scaffold
git checkout scaffold/main -- .
git remote remove scaffold


BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RESET="\033[0m"

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

# Run startproject with config as name, output into a temp dir then move
django-admin startproject config backend/

# django-admin startproject config backend/ creates:
#   backend/manage.py
#   backend/config/   ← the inner module (settings, urls, wsgi, asgi)
# That's already what we want, no restructuring needed.

# Split settings
mkdir -p backend/config/settings
touch backend/config/settings/__init__.py

# Read the generated SECRET_KEY from settings.py to reuse
GENERATED_KEY=$(grep "^SECRET_KEY" backend/config/settings.py | cut -d"'" -f2)

# base.py
cat > backend/config/settings/base.py << EOF
from pathlib import Path
import environ

env = environ.Env()

BASE_DIR = Path(__file__).resolve().parent.parent.parent

environ.Env.read_env(BASE_DIR / '.env')

SECRET_KEY = env('SECRET_KEY', default='${GENERATED_KEY}')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # third party
    'rest_framework',
    'corsheaders',
    'django_rq',
    # local
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'
ASGI_APPLICATION = 'config.asgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': env('DB_NAME'),
        'USER': env('DB_USER'),
        'PASSWORD': env('DB_PASSWORD'),
        'HOST': env('DB_HOST', default='localhost'),
        'PORT': env('DB_PORT', default='5432'),
    }
}

RQ_QUEUES = {
    'default': {
        'USE_REDIS_CACHE': 'default',
    },
    'priority': {
        'USE_REDIS_CACHE': 'default',
    },
}

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/0'),
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'runtimes' / 'static'
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'runtimes' / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

LOCALE_PATHS = [BASE_DIR / 'locale']
EOF

# dev.py
cat > backend/config/settings/dev.py << 'EOF'
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

CORS_ALLOW_ALL_ORIGINS = True
EOF

# prod.py
cat > backend/config/settings/prod.py << 'EOF'
from .base import *

DEBUG = False

ALLOWED_HOSTS = env.list('ALLOWED_HOSTS')

CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS')

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
EOF

# Remove original flat settings.py
rm backend/config/settings.py

# Update manage.py, wsgi.py, asgi.py to point to settings.dev
sed -i "s/config.settings/config.settings.dev/" backend/manage.py
sed -i "s/config.settings/config.settings.dev/" backend/config/wsgi.py
sed -i "s/config.settings/config.settings.dev/" backend/config/asgi.py

# Add RQ urls to urls.py
cat >> backend/config/urls.py << 'EOF'

# RQ Dashboard (dev only — protect in prod)
from django.urls import include
urlpatterns += [path('django-rq/', include('django_rq.urls'))]
EOF

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
