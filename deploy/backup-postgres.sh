#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${ROOT_DIR:-/opt/pts-express}"
BACKUP_DIR="${BACKUP_DIR:-/opt/pts-express-backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"

cd "$ROOT_DIR"
set -a
. ./.env.production
set +a

COMPOSE_ARGS=(-f docker-compose.prod.yml --env-file .env.production)
if [ "${USE_NPM_PROXY:-false}" = "true" ]; then
  COMPOSE_ARGS=(-f docker-compose.prod.yml -f docker-compose.npm.yml --env-file .env.production)
fi

mkdir -p "$BACKUP_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
FILE="$BACKUP_DIR/pts-express-$STAMP.sql.gz"

docker compose "${COMPOSE_ARGS[@]}" exec -T postgres \
  pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip >"$FILE"

find "$BACKUP_DIR" -type f -name 'pts-express-*.sql.gz' -mtime +"$RETENTION_DAYS" -delete

if [ -n "${BACKUP_HEALTHCHECK_URL:-}" ]; then
  curl -fsS --retry 3 "$BACKUP_HEALTHCHECK_URL" >/dev/null
fi

echo "$FILE"
