# PTS Express MVP

Monorepo for the PTS Express Thailand to Laos MVP.

## Apps

- `apps/api`: NestJS REST API, Prisma, PostgreSQL, JWT auth, RBAC, sync, public tracking.
- `apps/mobile`: Flutter Android/Web app for staff/admin/public tracking surfaces.

## Local API

```bash
cd apps/api
cp .env.example .env
npm run prisma:generate
npm run prisma:migrate -- --name init
npm run prisma:seed
npm run start:dev
```

Default seeded login: `admin` / `admin1234` unless changed in `.env`.

## VPS

Production uses `docker-compose.prod.yml`, Caddy HTTPS, PostgreSQL, API, and Flutter Web.

Required before deployment:

- DNS `A` record for `DOMAIN` points to the VPS IP.
- Cloudflare R2 bucket, S3 API token, and public/custom domain are ready.
- `.env.production` exists on the VPS and is never committed.

Basic flow:

```bash
sudo ./deploy/setup-vps.sh
git clone https://github.com/tay1862/pts-express.git /opt/pts-express
cd /opt/pts-express
cp .env.production.example .env.production
# Fill DOMAIN, DATABASE_URL/JWT/admin secrets, and real R2 values.
docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build
docker compose -f docker-compose.prod.yml exec api npm run prisma:seed
sudo ./deploy/install-backup-cron.sh
./deploy/backup-postgres.sh
./deploy/restore-postgres.sh /opt/pts-express-backups/<backup-file>.sql.gz
```

For load testing concurrent staff writes:

```bash
API_BASE_URL=https://your-domain/api STAFF_USERNAME=owner STAFF_PASSWORD='<password>' STAFF_COUNT=8 PARCELS_PER_STAFF=10 node deploy/load-test-staff.mjs
```

## Flutter builds

```bash
cd apps/mobile
dart run build_runner build
dart compile js web/drift_worker.dart -O2 -o web/drift_worker.js
flutter build web --dart-define=API_BASE_URL=https://api.example.com/api
flutter build apk --dart-define=API_BASE_URL=https://api.example.com/api
```
