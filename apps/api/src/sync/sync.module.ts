import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { ParcelsModule } from '../parcels/parcels.module';
import { SyncController } from './sync.controller';
import { SyncService } from './sync.service';

@Module({
  imports: [ParcelsModule],
  controllers: [SyncController],
  providers: [SyncService, PrismaService],
})
export class SyncModule {}
