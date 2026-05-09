import 'dotenv/config';
import { PrismaClient, UserRole, WarehouseCode } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import * as bcrypt from 'bcrypt';

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is missing');
}

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
});

async function main() {
  await prisma.warehouse.upsert({
    where: { code: WarehouseCode.TH },
    update: {},
    create: {
      code: WarehouseCode.TH,
      name: 'Thailand Warehouse',
      country: 'Thailand',
    },
  });

  await prisma.warehouse.upsert({
    where: { code: WarehouseCode.LA },
    update: {},
    create: { code: WarehouseCode.LA, name: 'Laos Warehouse', country: 'Laos' },
  });

  const passwordHash = await bcrypt.hash(
    process.env.SEED_ADMIN_PASSWORD ?? 'admin1234',
    12,
  );
  await prisma.user.upsert({
    where: { username: process.env.SEED_ADMIN_USERNAME ?? 'admin' },
    update: {},
    create: {
      username: process.env.SEED_ADMIN_USERNAME ?? 'admin',
      passwordHash,
      displayName: 'PTS Admin',
      role: UserRole.OWNER,
    },
  });
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
