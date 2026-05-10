import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import type { RequestUser } from '../common/types/request-user';
import { CreateUserDto, ResetPasswordDto, UpdateUserDto } from './dto/user.dto';
import { UsersService } from './users.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.OWNER, UserRole.ADMIN)
@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  list() {
    return this.users.list();
  }

  @Get(':id')
  findById(@Param('id') id: string) {
    return this.users.findById(id);
  }

  @Post()
  create(@Body() dto: CreateUserDto, @CurrentUser() actor: RequestUser) {
    return this.users.create(dto, actor);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateUserDto,
    @CurrentUser() actor: RequestUser,
  ) {
    return this.users.update(id, dto, actor);
  }

  @Post(':id/reset-password')
  resetPassword(
    @Param('id') id: string,
    @Body() dto: ResetPasswordDto,
    @CurrentUser() actor: RequestUser,
  ) {
    return this.users.resetPassword(id, dto, actor);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() actor: RequestUser) {
    return this.users.remove(id, actor);
  }
}
