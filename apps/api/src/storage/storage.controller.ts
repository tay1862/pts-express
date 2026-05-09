import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { PresignUploadDto } from './dto/presign-upload.dto';
import { StorageService } from './storage.service';

@UseGuards(JwtAuthGuard)
@Controller('storage')
export class StorageController {
  constructor(private readonly storage: StorageService) {}

  @Post('presign')
  presignUpload(@Body() dto: PresignUploadDto) {
    return this.storage.presignUpload(dto);
  }
}
