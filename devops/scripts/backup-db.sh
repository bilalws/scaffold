#!/usr/bin/env bash
set -e

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
source "/var/www/${PROJECT_NAME}/.env"

BACKUP_DIR="/var/backups/${PROJECT_NAME}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${BACKUP_DIR}/db_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "▶ Backing up database..."

# PostgreSQL
PGPASSWORD="$DB_PASSWORD" pg_dump -U "$DB_USER" -h "$DB_HOST" "$DB_NAME" | gzip > "$FILENAME"

# MySQL (uncomment if using MySQL instead)
# mysqldump -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" "$DB_NAME" | gzip > "$FILENAME"

echo "✔ Backup saved: $FILENAME"

# Keep only last 30 backups
ls -t "${BACKUP_DIR}"/db_*.sql.gz | tail -n +31 | xargs -r rm
