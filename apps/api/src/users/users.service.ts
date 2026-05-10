import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { RequestUser } from '../common/types/request-user';
import { PrismaService } from '../prisma.service';
import {
  CreateUserDto,
  ResetPasswordDto,
  UpdateUserDto,
} from './dto/user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  list() {
    return this.prisma.user.findMany({
      select: this.safeUserSelect(),
      orderBy: { createdAt: 'desc' },
    });
  }

  async findById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: this.safeUserSelect(),
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async create(dto: CreateUserDto, actor: RequestUser) {
    try {
      const user = await this.prisma.user.create({
        data: {
          username: dto.username.trim(),
          passwordHash: await bcrypt.hash(dto.password, 12),
          displayName: dto.displayName.trim(),
          role: dto.role,
        },
        select: this.safeUserSelect(),
      });
      await this.audit('user.create', user.id, actor, { role: dto.role });
      return user;
    } catch (error) {
      this.handlePrismaError(error, 'create user');
    }
  }

  async update(id: string, dto: UpdateUserDto, actor: RequestUser) {
    const current = await this.findById(id);
    await this.assertCanModifyUser(current, actor, dto.isActive, dto.role);
    try {
      const user = await this.prisma.user.update({
        where: { id },
        data: {
          displayName: dto.displayName?.trim(),
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
    } catch (error) {
      this.handlePrismaError(error, 'update user');
    }
  }

  async resetPassword(id: string, dto: ResetPasswordDto, actor: RequestUser) {
    await this.findById(id);
    await this.prisma.user.update({
      where: { id },
      data: { passwordHash: await bcrypt.hash(dto.password.trim(), 12) },
      select: { id: true },
    });
    await this.audit('user.reset_password', id, actor, {});
    return this.findById(id);
  }

  async remove(id: string, actor: RequestUser) {
    const current = await this.findById(id);
    await this.assertCanModifyUser(current, actor, false, undefined);
    await this.prisma.user.update({
      where: { id },
      data: { isActive: false },
      select: { id: true },
    });
    await this.audit('user.remove', id, actor, {});
    return this.findById(id);
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

  private async assertCanModifyUser(
    target: { id: string; role: UserRole; isActive: boolean },
    actor: RequestUser,
    nextActive?: boolean,
    nextRole?: UserRole,
  ) {
    const nextIsActive = nextActive ?? target.isActive;
    const nextIsPrivileged =
      (nextRole ?? target.role) === UserRole.OWNER ||
      (nextRole ?? target.role) === UserRole.ADMIN;
    const targetIsPrivileged =
      target.role === UserRole.OWNER || target.role === UserRole.ADMIN;

    if (actor.id === target.id && nextActive === false) {
      throw new BadRequestException('You cannot deactivate yourself');
    }

    if (!nextIsActive && targetIsPrivileged) {
      await this.ensureNotLastPrivilegedUser(target.id);
    }

    if (targetIsPrivileged && !nextIsPrivileged) {
      await this.ensureNotLastPrivilegedUser(target.id);
    }
  }

  private async ensureNotLastPrivilegedUser(targetUserId: string) {
    const activePrivilegedCount = await this.prisma.user.count({
      where: {
        isActive: true,
        role: { in: [UserRole.OWNER, UserRole.ADMIN] },
        NOT: { id: targetUserId },
      },
    });
    if (activePrivilegedCount === 0) {
      throw new BadRequestException('At least one active OWNER or ADMIN is required');
    }
  }

  private handlePrismaError(error: unknown, context: string): never {
    if (this.isPrismaConflict(error)) {
      throw new ConflictException(`Unable to ${context}: duplicate value`);
    }
    throw error as never;
  }

  private isPrismaConflict(error: unknown) {
    return (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      (error as { code?: string }).code === 'P2002'
    );
  }
}
