.PHONY: dev backend frontend migrate makemigrations shell collectstatic createsuperuser \
        worker1 worker2 lint-be lint-fe deploy backup restore setup-server

# ─── Development ──────────────────────────
dev:
	make -j3 backend frontend worker1

backend:
	cd backend && source venv/bin/activate && python manage.py runserver

frontend:
	cd frontend && npm run dev

worker1:
	cd backend && source venv/bin/activate && python manage.py rqworker default

worker2:
	cd backend && source venv/bin/activate && python manage.py rqworker priority

# ─── Django ───────────────────────────────
migrate:
	cd backend && source venv/bin/activate && python manage.py migrate

makemigrations:
	cd backend && source venv/bin/activate && python manage.py makemigrations

shell:
	cd backend && source venv/bin/activate && python manage.py shell

collectstatic:
	cd backend && source venv/bin/activate && python manage.py collectstatic --noinput

createsuperuser:
	cd backend && source venv/bin/activate && python manage.py createsuperuser

# ─── Code Quality ─────────────────────────
lint-be:
	cd backend && source venv/bin/activate && flake8 .

lint-fe:
	cd frontend && npm run lint

# ─── DevOps ───────────────────────────────
deploy:
	bash devops/scripts/deploy.sh

deploy-be:
	bash devops/scripts/deploy-backend.sh

deploy-fe:
	bash devops/scripts/deploy-frontend.sh

backup:
	bash devops/scripts/backup-db.sh

restore:
	bash devops/scripts/restore-db.sh $(FILE)

setup-server:
	bash devops/scripts/setup-server.sh $(DOMAIN)
