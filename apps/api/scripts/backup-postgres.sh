#!/usr/bin/env sh
set -eu

BACKUP_DIR="${BACKUP_DIR:-/backups/pts-express}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DATABASE_URL="${DATABASE_URL:?DATABASE_URL is required}"

mkdir -p "$BACKUP_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
pg_dump "$DATABASE_URL" | gzip > "$BACKUP_DIR/pts-express-$STAMP.sql.gz"
find "$BACKUP_DIR" -type f -name 'pts-express-*.sql.gz' -mtime +"$RETENTION_DAYS" -delete
