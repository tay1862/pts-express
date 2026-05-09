#!/usr/bin/env bash
set -euo pipefail

USE_NPM_PROXY_VALUE="${USE_NPM_PROXY:-false}"

cat >/etc/cron.d/pts-express-monitor <<'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EOF
cat >>/etc/cron.d/pts-express-monitor <<EOF
*/5 * * * * root ROOT_DIR=/opt/pts-express USE_NPM_PROXY=${USE_NPM_PROXY_VALUE} /opt/pts-express/deploy/monitor-health.sh >/dev/null 2>&1
EOF

chmod 0644 /etc/cron.d/pts-express-monitor
systemctl restart cron
