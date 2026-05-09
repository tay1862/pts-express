import { Controller, Get, Param } from '@nestjs/common';
import { ParcelsService } from './parcels.service';

@Controller('track')
export class PublicTrackController {
  constructor(private readonly parcels: ParcelsService) {}

  @Get(':trackingCode')
  track(@Param('trackingCode') trackingCode: string) {
    return this.parcels.publicTrack(trackingCode);
  }
}
