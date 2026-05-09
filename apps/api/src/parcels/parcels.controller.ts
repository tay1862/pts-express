import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import type { RequestUser as RequestUserType } from '../common/types/request-user';
import {
  AddParcelPhotoDto,
  AdminOverrideDto,
  AdvanceParcelDto,
  ReceiveParcelDto,
} from './dto/parcel-write.dto';
import { SearchParcelsDto } from './dto/search-parcels.dto';
import { ParcelsService } from './parcels.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('parcels')
export class ParcelsController {
  constructor(private readonly parcels: ParcelsService) {}

  @Get()
  search(@Query() query: SearchParcelsDto) {
    return this.parcels.search(query);
  }

  @Get(':id')
  findById(@Param('id') id: string) {
    return this.parcels.findById(id);
  }

  @Post('receive')
  receive(
    @Body() dto: ReceiveParcelDto,
    @CurrentUser() actor: RequestUserType,
  ) {
    return this.parcels.receive(dto, actor);
  }

  @Post(':code/arrive')
  arrive(
    @Param('code') code: string,
    @Body() dto: AdvanceParcelDto,
    @CurrentUser() actor: RequestUserType,
  ) {
    return this.parcels.arrive(code, dto, actor);
  }

  @Post(':code/pickup')
  pickup(
    @Param('code') code: string,
    @Body() dto: AdvanceParcelDto,
    @CurrentUser() actor: RequestUserType,
  ) {
    return this.parcels.pickup(code, dto, actor);
  }

  @Post(':id/override')
  @Roles(UserRole.OWNER, UserRole.ADMIN)
  override(
    @Param('id') id: string,
    @Body() dto: AdminOverrideDto,
    @CurrentUser() actor: RequestUserType,
  ) {
    return this.parcels.override(id, dto, actor);
  }

  @Post(':id/photos')
  addPhoto(
    @Param('id') id: string,
    @Body() dto: AddParcelPhotoDto,
    @CurrentUser() actor: RequestUserType,
  ) {
    return this.parcels.addPhoto(id, dto, actor);
  }
}
