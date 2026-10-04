import { createHash, randomBytes } from 'node:crypto';
import {
    BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { compare,hash, hashSync } from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service.js';
import type { AppRole } from './auth.types.js';

// Unknown email pe bhi ek bcrypt compare chalta hai, taaki response time
// se pata na chale ki email exist karta hai.
const DUMMY_HASH = hashSync('not-a-real-password', 12);

interface UserRecord {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: AppRole;
  organizationId: string;
  employeeId: string;
  department: string;
  designation: string;
  joiningDate: Date;
  organization: { name: string };
}

const sha256 = (value: string) =>
  createHash('sha256').update(value).digest('hex');

function toProfile(user: UserRecord) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    organization: user.organization.name,
    employeeId: user.employeeId,
    department: user.department,
    designation: user.designation,
    joiningDate: user.joiningDate.toISOString().slice(0, 10),
  };
}

@Injectable()
export class AuthService {
  private readonly accessTtlSeconds: number;
  private readonly refreshTtlMs: number;

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    config: ConfigService,
  ) {
    this.accessTtlSeconds = Number(config.get('JWT_ACCESS_TTL_SECONDS') ?? 900);
    this.refreshTtlMs =
      Number(config.get('REFRESH_TOKEN_TTL_DAYS') ?? 30) * 24 * 60 * 60 * 1000;
  }

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: { email: email.trim().toLowerCase() },
      include: { organization: { select: { name: true } } },
    });

    const passwordOk = await compare(password, user?.passwordHash ?? DUMMY_HASH);
    if (!user || !passwordOk) {
      throw new UnauthorizedException('Invalid email or password.');
    }
    if (!user.isActive) {
      throw new ForbiddenException('Your account has been deactivated.');
    }

    return this.issueTokens(user);
  }

  async refresh(refreshToken: string) {
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash: sha256(refreshToken) },
      include: {
        user: { include: { organization: { select: { name: true } } } },
      },
    });
    if (!stored) throw new UnauthorizedException('Invalid refresh token.');

    // Revoked token dobara aaya: token chori hua ho sakta hai, to is user
    // ke saare sessions band kar do.
    if (stored.revokedAt) {
      await this.prisma.refreshToken.updateMany({
        where: { userId: stored.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException('Session is no longer valid.');
    }

    if (stored.expiresAt <= new Date()) {
      throw new UnauthorizedException('Refresh token expired.');
    }
    if (!stored.user.isActive) {
      throw new ForbiddenException('Your account has been deactivated.');
    }

    // Rotation: purana token ek hi baar use ho sakta hai.
    const claimed = await this.prisma.refreshToken.updateMany({
      where: { id: stored.id, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    if (claimed.count === 0) {
      throw new UnauthorizedException('Session is no longer valid.');
    }

    return this.issueTokens(stored.user);
  }

  async logout(refreshToken: string): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: { tokenHash: sha256(refreshToken), revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { organization: { select: { name: true } } },
    });
    if (!user) throw new UnauthorizedException('Account is not available.');
    return toProfile(user);
  }
    async updateProfile(userId: string, email: string, phone: string) {
    const normalized = email.trim().toLowerCase();

    const taken = await this.prisma.user.findFirst({
      where: { email: normalized, NOT: { id: userId } },
      select: { id: true },
    });
    if (taken) throw new ConflictException('That email is already in use.');

    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { email: normalized, phone: phone.trim() },
      include: { organization: { select: { name: true } } },
    });
    return toProfile(user);
  }

  /** Password badalne pe baaki sab sessions band, is device ko naye tokens. */
  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string,
  ) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { organization: { select: { name: true } } },
    });
    if (!user) throw new UnauthorizedException('Account is not available.');

    if (!(await compare(currentPassword, user.passwordHash))) {
      throw new BadRequestException('Your current password is incorrect.');
    }
    if (currentPassword === newPassword) {
      throw new BadRequestException('Choose a different password.');
    }

    const passwordHash = await hash(newPassword, 12);
    await this.prisma.$transaction([
      this.prisma.user.update({ where: { id: userId }, data: { passwordHash } }),
      this.prisma.refreshToken.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: new Date() },
      }),
    ]);

    return this.issueTokens(user);
  }

  private async issueTokens(user: UserRecord) {
    const accessToken = await this.jwt.signAsync({
      sub: user.id,
      role: user.role,
      org: user.organizationId,
    });

    const refreshToken = randomBytes(48).toString('base64url');
    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: sha256(refreshToken),
        expiresAt: new Date(Date.now() + this.refreshTtlMs),
      },
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: this.accessTtlSeconds,
      user: toProfile(user),
    };
  }
}