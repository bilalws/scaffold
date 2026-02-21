#!/usr/bin/env bash
set -e

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
source "/opt/projects/${PROJECT_NAME}/.env"

FILE="$1"
if [ -z "$FILE" ]; then
    echo "Usage: restore-db.sh <backup-file.sql.gz>"
    exit 1
fi

echo "▶ Restoring database from $FILE..."

# PostgreSQL
#gunzip -c "$FILE" | PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h "$DB_HOST" "$DB_NAME"

# MySQL (uncomment if using MySQL instead)
gunzip -c "$FILE" | mysql -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" "$DB_NAME"

echo "✔ Restore complete."
