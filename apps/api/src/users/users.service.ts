import { Injectable } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { RequestUser } from '../common/types/request-user';
import { PrismaService } from '../prisma.service';
import { CreateUserDto, UpdateUserDto } from './dto/user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  list() {
    return this.prisma.user.findMany({
      select: this.safeUserSelect(),
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(dto: CreateUserDto, actor: RequestUser) {
    const user = await this.prisma.user.create({
      data: {
        username: dto.username,
        passwordHash: await bcrypt.hash(dto.password, 12),
        displayName: dto.displayName,
        role: dto.role,
      },
      select: this.safeUserSelect(),
    });
    await this.audit('user.create', user.id, actor, { role: dto.role });
    return user;
  }

  async update(id: string, dto: UpdateUserDto, actor: RequestUser) {
    const user = await this.prisma.user.update({
      where: { id },
      data: {
        displayName: dto.displayName,
        passwordHash: dto.password
          ? await bcrypt.hash(dto.password, 12)
          : undefined,
        role: dto.role,
        isActive: dto.isActive,
      },
      select: this.safeUserSelect(),
    });
    await this.audit('user.update', id, actor, {
      role: dto.role,
      isActive: dto.isActive,
      passwordChanged: !!dto.password,
    });
    return user;
  }

  private safeUserSelect() {
    return {
      id: true,
      username: true,
      displayName: true,
      role: true,
      isActive: true,
      createdAt: true,
      updatedAt: true,
    };
  }

  private async audit(
    action: string,
    entityId: string,
    actor: RequestUser,
    metadata: {
      role?: UserRole;
      isActive?: boolean;
      passwordChanged?: boolean;
    },
  ) {
    await this.prisma.auditLog.create({
      data: {
        action,
        entityType: 'user',
        entityId,
        actorId: actor.id,
        metadata,
      },
    });
  }
}
