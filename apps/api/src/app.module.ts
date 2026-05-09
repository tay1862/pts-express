import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { ParcelsModule } from './parcels/parcels.module';
import { StorageModule } from './storage/storage.module';
import { SyncModule } from './sync/sync.module';
import { UsersModule } from './users/users.module';
import { HealthController } from './health.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    ParcelsModule,
    SyncModule,
    StorageModule,
    UsersModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
