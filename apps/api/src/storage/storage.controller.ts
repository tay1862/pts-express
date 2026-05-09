import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Res,
  UseGuards,
} from '@nestjs/common';
import type { Response } from 'express';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { PresignUploadDto } from './dto/presign-upload.dto';
import { StorageService } from './storage.service';

@Controller('storage')
export class StorageController {
  constructor(private readonly storage: StorageService) {}

  @Post('presign')
  @UseGuards(JwtAuthGuard)
  presignUpload(@Body() dto: PresignUploadDto) {
    return this.storage.presignUpload(dto);
  }

  @Get('proxy')
  async proxyPublicImage(@Query('url') url: string, @Res() res: Response) {
    const image = await this.storage.fetchPublicImage(url);
    res.setHeader('Content-Type', image.contentType);
    res.setHeader('Cache-Control', 'public, max-age=86400');
    res.send(image.body);
  }
}
