#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# PTS Express — Daily PostgreSQL backup with Google Drive upload
# Prerequisites: rclone configured with a remote named "gdrive"
#   sudo apt install rclone
#   rclone config   →  name: gdrive, type: drive, scope: drive
# ──────────────────────────────────────────────────────────
set -euo pipefail

ROOT_DIR="${ROOT_DIR:-/opt/pts-express}"
BACKUP_DIR="${BACKUP_DIR:-/opt/pts-express-backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"
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

# ── 1. Dump database ───────────────────────────────────────
mkdir -p "$BACKUP_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
FILE="$BACKUP_DIR/pts-express-$STAMP.sql.gz"

echo "[backup] Dumping database…"
docker compose "${COMPOSE_ARGS[@]}" exec -T postgres \
  pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip >"$FILE"
echo "[backup] Created $FILE ($(du -h "$FILE" | cut -f1))"

# ── 2. Upload to Google Drive ──────────────────────────────
if command -v rclone &>/dev/null; then
  echo "[backup] Uploading to ${GDRIVE_REMOTE}:${GDRIVE_FOLDER}/…"
  rclone mkdir "${GDRIVE_REMOTE}:${GDRIVE_FOLDER}" 2>/dev/null || true
  rclone copyto "$FILE" "${GDRIVE_REMOTE}:${GDRIVE_FOLDER}/$(basename "$FILE")" \
    --progress --transfers 1
  echo "[backup] Upload complete."

  # Prune old backups on Google Drive
  rclone delete "${GDRIVE_REMOTE}:${GDRIVE_FOLDER}" \
    --min-age "${RETENTION_DAYS}d" \
    --include "pts-express-*.sql.gz" 2>/dev/null || true
else
  echo "[backup] rclone not found — skipping Google Drive upload."
  echo "         Install: sudo apt install rclone && rclone config"
fi

# ── 3. Prune local backups ─────────────────────────────────
find "$BACKUP_DIR" -type f -name 'pts-express-*.sql.gz' -mtime +"$RETENTION_DAYS" -delete

# ── 4. Health check ────────────────────────────────────────
if [ -n "${BACKUP_HEALTHCHECK_URL:-}" ]; then
  curl -fsS --retry 3 "$BACKUP_HEALTHCHECK_URL" >/dev/null
fi

echo "[backup] Done: $FILE"
