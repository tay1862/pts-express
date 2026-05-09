import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma.service';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwt: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { username: dto.username },
    });
    const valid = user
      ? await bcrypt.compare(dto.password, user.passwordHash)
      : false;
    if (!user?.isActive || !valid) {
      throw new UnauthorizedException('Invalid username or password');
    }

    const expiresIn = dto.rememberMe ? '30d' : '12h';
    const accessToken = await this.jwt.signAsync(
      { sub: user.id, username: user.username },
      { expiresIn },
    );

    await this.prisma.auditLog.create({
      data: {
        action: 'auth.login',
        entityType: 'user',
        entityId: user.id,
        actorId: user.id,
        metadata: { rememberMe: !!dto.rememberMe },
      },
    });

    return {
      accessToken,
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        role: user.role,
      },
    };
  }
}
