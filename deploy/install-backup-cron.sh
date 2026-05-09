#!/usr/bin/env bash
set -euo pipefail

cat >/etc/cron.d/pts-express-backup <<'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
15 2 * * * root ROOT_DIR=/opt/pts-express BACKUP_DIR=/opt/pts-express-backups /opt/pts-express/deploy/backup-postgres.sh >> /var/log/pts-express-backup.log 2>&1
EOF

chmod 0644 /etc/cron.d/pts-express-backup
systemctl restart cron
