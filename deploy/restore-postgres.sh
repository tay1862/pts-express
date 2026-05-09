#!/usr/bin/env bash
set -euo pipefail

BACKUP_FILE="${1:?Usage: ./deploy/restore-postgres.sh <backup.sql.gz>}"
ROOT_DIR="${ROOT_DIR:-/opt/pts-express}"

cd "$ROOT_DIR"
set -a
. ./.env.production
set +a

COMPOSE_ARGS=(-f docker-compose.prod.yml --env-file .env.production)
if [ "${USE_NPM_PROXY:-false}" = "true" ]; then
  COMPOSE_ARGS=(-f docker-compose.prod.yml -f docker-compose.npm.yml --env-file .env.production)
fi

test -f "$BACKUP_FILE"

docker compose "${COMPOSE_ARGS[@]}" stop api web caddy
docker compose "${COMPOSE_ARGS[@]}" exec -T postgres \
  psql -U "$POSTGRES_USER" -d postgres \
  -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${POSTGRES_DB}' AND pid <> pg_backend_pid();"
docker compose "${COMPOSE_ARGS[@]}" exec -T postgres \
  dropdb -U "$POSTGRES_USER" --if-exists "$POSTGRES_DB"
docker compose "${COMPOSE_ARGS[@]}" exec -T postgres \
  createdb -U "$POSTGRES_USER" "$POSTGRES_DB"
gzip -dc "$BACKUP_FILE" | docker compose "${COMPOSE_ARGS[@]}" exec -T postgres \
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
docker compose "${COMPOSE_ARGS[@]}" up -d
