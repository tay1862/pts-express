#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# PTS Express — Restore PostgreSQL from local file or Google Drive
#
# Usage:
#   ./deploy/restore-postgres.sh <backup.sql.gz>          # local file
#   ./deploy/restore-postgres.sh --gdrive [filename]      # from Google Drive
#     If filename is omitted, the latest backup is used.
# ──────────────────────────────────────────────────────────
set -euo pipefail

ROOT_DIR="${ROOT_DIR:-/opt/pts-express}"
BACKUP_DIR="${BACKUP_DIR:-/opt/pts-express-backups}"
GDRIVE_REMOTE="${GDRIVE_REMOTE:-gdrive}"
GDRIVE_FOLDER="${GDRIVE_FOLDER:-pts-express-backups}"

cd "$ROOT_DIR"
set -a
. ./.env.production
set +a

COMPOSE_ARGS=(-f docker-compose.prod.yml --env-file .env.production)
if [ "${USE_NPM_PROXY:-false}" = "true" ]; then
  COMPOSE_ARGS=(-f docker-compose.prod.yml -f docker-compose.npm.yml --env-file .env.production)
fi

# ── Resolve backup file ───────────────────────────────────
if [ "${1:-}" = "--gdrive" ]; then
  GDRIVE_FILE="${2:-}"
  if [ -z "$GDRIVE_FILE" ]; then
    echo "[restore] Finding latest backup on Google Drive…"
    GDRIVE_FILE=$(rclone lsf "${GDRIVE_REMOTE}:${GDRIVE_FOLDER}/" \
      --include "pts-express-*.sql.gz" | sort | tail -1)
    if [ -z "$GDRIVE_FILE" ]; then
      echo "[restore] ERROR: No backups found on Google Drive." >&2
      exit 1
    fi
  fi
  mkdir -p "$BACKUP_DIR"
  BACKUP_FILE="$BACKUP_DIR/$GDRIVE_FILE"
  echo "[restore] Downloading ${GDRIVE_FILE} from Google Drive…"
  rclone copyto "${GDRIVE_REMOTE}:${GDRIVE_FOLDER}/${GDRIVE_FILE}" "$BACKUP_FILE" --progress
else
  BACKUP_FILE="${1:?Usage: ./deploy/restore-postgres.sh <backup.sql.gz>  or  --gdrive [filename]}"
fi

test -f "$BACKUP_FILE" || { echo "[restore] ERROR: File not found: $BACKUP_FILE" >&2; exit 1; }
echo "[restore] Restoring from $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))…"
echo "[restore] WARNING: This will DROP and recreate the database."
read -r -p "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "[restore] Aborted."; exit 0; }

# ── Restore ────────────────────────────────────────────────
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

echo "[restore] Done. All services restarted."
