import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { StorageModule } from '../storage/storage.module';
import { ParcelsController } from './parcels.controller';
import { ParcelsService } from './parcels.service';
import { PublicTrackController } from './public-track.controller';

@Module({
  imports: [StorageModule],
  controllers: [ParcelsController, PublicTrackController],
  providers: [ParcelsService, PrismaService],
  exports: [ParcelsService],
})
export class ParcelsModule {}
