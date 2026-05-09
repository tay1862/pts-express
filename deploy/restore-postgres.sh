#!/usr/bin/env bash
set -euo pipefail

BACKUP_FILE="${1:?Usage: ./deploy/restore-postgres.sh <backup.sql.gz>}"
ROOT_DIR="${ROOT_DIR:-/opt/pts-express}"

cd "$ROOT_DIR"
set -a
. ./.env.production
set +a

test -f "$BACKUP_FILE"

docker compose -f docker-compose.prod.yml stop api web caddy
docker compose -f docker-compose.prod.yml exec -T postgres \
  psql -U "$POSTGRES_USER" -d postgres \
  -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${POSTGRES_DB}' AND pid <> pg_backend_pid();"
docker compose -f docker-compose.prod.yml exec -T postgres \
  dropdb -U "$POSTGRES_USER" --if-exists "$POSTGRES_DB"
docker compose -f docker-compose.prod.yml exec -T postgres \
  createdb -U "$POSTGRES_USER" "$POSTGRES_DB"
gzip -dc "$BACKUP_FILE" | docker compose -f docker-compose.prod.yml exec -T postgres \
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
docker compose -f docker-compose.prod.yml up -d
