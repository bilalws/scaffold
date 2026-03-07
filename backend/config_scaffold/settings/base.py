from pathlib import Path
import environ
from datetime import timedelta

env = environ.Env()

BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent  # project root
BACKEND_DIR = Path(__file__).resolve().parent.parent.parent      # backend/

environ.Env.read_env(BASE_DIR / '.env')

ENVIRONMENT = env('ENVIRONMENT', default='development')
SECRET_KEY = env('SECRET_KEY')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.humanize',
    # third party
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'whitenoise',
    'django_rq',
    'django_htmx',
    # local
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.middleware.locale.LocaleMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'shared.middleware.ip.IPAddressMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
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

# Database — uncomment your choice
# PostgreSQL
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.postgresql',
#         'NAME': env('DB_NAME'),
#         'USER': env('DB_USER'),
#         'PASSWORD': env('DB_PASSWORD'),
#         'HOST': env('DB_HOST', default='localhost'),
#         'PORT': env('DB_PORT', default='5432'),
#     }
# }

# MySQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': env('DB_NAME'),
        'USER': env('DB_USER'),
        'PASSWORD': env('DB_PASSWORD'),
        'HOST': env('DB_HOST', default='localhost'),
        'PORT': env('DB_PORT', default='3306'),
        'OPTIONS': {
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'charset': 'utf8mb4',
        }
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Email
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_USE_TLS = True
EMAIL_USE_SSL = False
EMAIL_HOST = env('EMAIL_HOST', default='smtp.gmail.com')
EMAIL_PORT = env('EMAIL_PORT', default='587')
EMAIL_HOST_USER = env('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = env('EMAIL_HOST_PASSWORD', default='')
DEFAULT_FROM_EMAIL = env('EMAIL_HOST_USER', default='')

# i18n
LANGUAGE_CODE = 'en'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True
LOCALE_PATHS = [BACKEND_DIR / 'locale']

# Static & Media
STATIC_URL = '/static/'
MEDIA_URL = '/media/'
STATIC_ROOT = BACKEND_DIR / 'runtimes' / 'static'
STATICFILES_DIRS = []
MEDIA_ROOT = BACKEND_DIR / 'runtimes' / 'media'
REPORT_DIR = BACKEND_DIR / 'runtimes' / 'reports'

ADMIN_LOGIN_URL = '/management/auth/login/'
LOGIN_REDIRECT_URL = '/management'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Django REST Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'EXCEPTION_HANDLER': 'shared.exception_handler.base_exception_handler',
}

# JWT settings
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=2),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
}

# Redis Cache
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/0'),
    }
}

# RQ Queues
_REDIS_URL = env('REDIS_URL', default='redis://localhost:6379/0')

RQ_QUEUES = {
    'default': {
        'URL': _REDIS_URL,
        'DEFAULT_TIMEOUT': 360,
    },
    'priority': {
        'URL': _REDIS_URL,
        'DEFAULT_TIMEOUT': 360,
    },
    'long': {
        'URL': _REDIS_URL,
        'DEFAULT_TIMEOUT': 600,
    },
}

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'file': {
            'format': '[%(asctime)s][%(levelname)s] %(message)s'
        }
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
        'info': {
            'level': 'INFO',
            'class': 'logging.handlers.TimedRotatingFileHandler',
            'when': 'midnight',
            'backupCount': 5,
            'formatter': 'file',
            'filename': str(BACKEND_DIR / 'runtimes' / 'logs' / 'info.log'),
        },
        'debug': {
            'level': 'DEBUG',
            'class': 'logging.handlers.TimedRotatingFileHandler',
            'when': 'midnight',
            'backupCount': 3,
            'formatter': 'file',
            'filename': str(BACKEND_DIR / 'runtimes' / 'logs' / 'debug.log'),
        },
        'transaction': {
            'level': 'INFO',
            'class': 'logging.handlers.TimedRotatingFileHandler',
            'when': 'midnight',
            'backupCount': 3,
            'formatter': 'file',
            'filename': str(BACKEND_DIR / 'runtimes' / 'logs' / 'transaction.log'),
        },
        'admin': {
            'level': 'INFO',
            'class': 'logging.handlers.TimedRotatingFileHandler',
            'when': 'midnight',
            'backupCount': 5,
            'formatter': 'file',
            'filename': str(BACKEND_DIR / 'runtimes' / 'logs' / 'admin.log'),
        },
    },
    'loggers': {
        'info': {
            'handlers': ['info'],
            'level': 'INFO',
            'propagate': True,
        },
        'debug': {
            'handlers': ['debug'],
            'level': 'DEBUG',
            'propagate': True,
        },
        'transaction': {
            'handlers': ['transaction'],
            'level': 'INFO',
            'propagate': True,
        },
        'gunicorn.access': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'admin': {
            'handlers': ['admin'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
