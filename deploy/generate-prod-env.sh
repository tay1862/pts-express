#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:?Usage: ./deploy/generate-prod-env.sh <domain>}"
R2_ENDPOINT="${R2_ENDPOINT:?R2_ENDPOINT is required}"
R2_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID:?R2_ACCESS_KEY_ID is required}"
R2_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY:?R2_SECRET_ACCESS_KEY is required}"
R2_BUCKET="${R2_BUCKET:?R2_BUCKET is required}"
R2_PUBLIC_BASE_URL="${R2_PUBLIC_BASE_URL:?R2_PUBLIC_BASE_URL is required}"

POSTGRES_PASSWORD="$(openssl rand -hex 32 | tr -d '\n')"
JWT_SECRET="$(openssl rand -base64 96 | tr -d '\n')"
SEED_ADMIN_PASSWORD="$(openssl rand -hex 18 | tr -d '\n')"

cat >.env.production <<EOF
DOMAIN=${DOMAIN}
API_BASE_URL=https://${DOMAIN}/api

POSTGRES_USER=pts
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=pts_express
DATABASE_URL=postgresql://pts:${POSTGRES_PASSWORD}@postgres:5432/pts_express?schema=public

JWT_SECRET=${JWT_SECRET}
PORT=3000
NODE_ENV=production

SEED_ADMIN_USERNAME=owner
SEED_ADMIN_PASSWORD=${SEED_ADMIN_PASSWORD}

REQUIRE_R2=true
R2_ENDPOINT=${R2_ENDPOINT}
R2_ACCESS_KEY_ID=${R2_ACCESS_KEY_ID}
R2_SECRET_ACCESS_KEY=${R2_SECRET_ACCESS_KEY}
R2_BUCKET=${R2_BUCKET}
R2_PUBLIC_BASE_URL=${R2_PUBLIC_BASE_URL}

BACKUP_RETENTION_DAYS=14
BACKUP_HEALTHCHECK_URL=${BACKUP_HEALTHCHECK_URL:-}
EOF

chmod 600 .env.production
echo "Created .env.production"
echo "Initial owner login: owner / ${SEED_ADMIN_PASSWORD}"
