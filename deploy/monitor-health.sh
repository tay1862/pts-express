#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${ROOT_DIR:-/opt/pts-express}"
LOG_FILE="${MONITOR_LOG_FILE:-/var/log/pts-express-monitor.log}"

cd "$ROOT_DIR"
set -a
. ./.env.production
set +a

COMPOSE_ARGS=(-f docker-compose.prod.yml --env-file .env.production)
if [ "${USE_NPM_PROXY:-false}" = "true" ]; then
  COMPOSE_ARGS=(-f docker-compose.prod.yml -f docker-compose.npm.yml --env-file .env.production)
fi

HEALTH_URL="${HEALTH_URL:-${API_BASE_URL%/}/health}"
STAMP="$(date -Is)"

notify() {
  local message="$1"
  printf '%s %s\n' "$STAMP" "$message" >>"$LOG_FILE"

  if [ -n "${ALERT_WEBHOOK_URL:-}" ]; then
    local escaped
    escaped="$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g')"
    curl -fsS --max-time 10 \
      -H 'Content-Type: application/json' \
      -d "{\"text\":\"PTS Express alert: ${escaped}\"}" \
      "$ALERT_WEBHOOK_URL" >/dev/null || true
  fi
}

if ! curl -fsS --max-time 10 "$HEALTH_URL" | grep -q '"ok":true'; then
  notify "healthcheck failed: $HEALTH_URL"
  exit 1
fi

compose_status="$(docker compose "${COMPOSE_ARGS[@]}" ps)"
if printf '%s\n' "$compose_status" | grep -Eiq 'unhealthy|restarting|exited|dead'; then
  notify "docker service status issue: $(printf '%s' "$compose_status" | tr '\n' ' ')"
  exit 1
fi

printf '%s ok\n' "$STAMP" >>"$LOG_FILE"
