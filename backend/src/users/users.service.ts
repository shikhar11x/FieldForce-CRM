import { randomBytes } from 'node:crypto';
import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { hash } from 'bcryptjs';
import type { AppRole, AuthUser } from '../auth/auth.types.js';
import { Prisma } from '../generated/prisma/client.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreateUserDto, UpdateUserDto } from './users.dto.js';

// passwordHash kabhi select nahi hota, isliye response me leak nahi ho sakta.
const USER_SELECT = {
  id: true,
  name: true,
  email: true,
  phone: true,
  role: true,
  designation: true,
  department: true,
  employeeId: true,
  joiningDate: true,
  isActive: true,
  managerId: true,
  team: { select: { name: true } },
  manager: { select: { name: true } },
} satisfies Prisma.UserSelect;

type UserRow = Prisma.UserGetPayload<{ select: typeof USER_SELECT }>;

function toDto(user: UserRow) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    designation: user.designation,
    department: user.department,
    team: user.team?.name ?? '',
    managerId: user.managerId,
    manager: user.manager?.name ?? '',
    employeeId: user.employeeId,
    joiningDate: user.joiningDate.toISOString().slice(0, 10),
    isActive: user.isActive,
  };
}

function isUniqueViolation(error: unknown): boolean {
  return (
    error instanceof Prisma.PrismaClientKnownRequestError &&
    error.code === 'P2002'
  );
}

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  /** Admin: poori organization. Manager: sirf direct reports. */
  private scope(actor: AuthUser): Prisma.UserWhereInput {
    if (actor.role === 'ADMIN') {
      return { organizationId: actor.organizationId };
    }
    if (actor.role === 'MANAGER') {
      return { organizationId: actor.organizationId, managerId: actor.id };
    }
    throw new ForbiddenException('You do not have access to this resource.');
  }

  async findAll(actor: AuthUser) {
    const users = await this.prisma.user.findMany({
      where: this.scope(actor),
      select: USER_SELECT,
      orderBy: { name: 'asc' },
    });
    return users.map(toDto);
  }

  async findOne(actor: AuthUser, id: string) {
    const user = await this.prisma.user.findFirst({
      where: { ...this.scope(actor), id },
      select: USER_SELECT,
    });
    // 403 ki jagah 404, taaki dusron ke users ka pata na chale.
    if (!user) throw new NotFoundException('User not found.');
    return toDto(user);
  }

  async create(actor: AuthUser, dto: CreateUserDto) {
    const taken = await this.prisma.user.findUnique({
      where: { email: dto.email },
      select: { id: true },
    });
    if (taken) {
      throw new ConflictException('A user with this email already exists.');
    }

    const { teamId, managerId } = await this.resolveRelations(
      actor.organizationId,
      dto.role,
      dto.team,
      dto.managerId,
    );

    const temporaryPassword = randomBytes(9).toString('base64url');
    const passwordHash = await hash(temporaryPassword, 12);
    const joiningDate = new Date(new Date().toISOString().slice(0, 10));

    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        const user = await this.prisma.user.create({
          data: {
            organizationId: actor.organizationId,
            employeeId: await this.nextEmployeeId(),
            name: dto.name,
            email: dto.email,
            phone: dto.phone,
            passwordHash,
            role: dto.role,
            designation: dto.designation,
            department: dto.department,
            teamId,
            managerId,
            joiningDate,
            isActive: dto.isActive ?? true,
          },
          select: USER_SELECT,
        });
        return { user: toDto(user), temporaryPassword };
      } catch (error) {
        if (!isUniqueViolation(error)) throw error;
        // Do admins ek saath create karein to employeeId takra sakta hai: retry.
      }
    }
    throw new ConflictException(
      'Could not create the user. Please try again.',
    );
  }

  async update(actor: AuthUser, id: string, dto: UpdateUserDto) {
    const target = await this.prisma.user.findFirst({
      where: { id, organizationId: actor.organizationId },
      select: USER_SELECT,
    });
    if (!target) throw new NotFoundException('User not found.');

    const isSelf = target.id === actor.id;
    if (isSelf && dto.role !== undefined && dto.role !== target.role) {
      throw new ForbiddenException('You cannot change your own role.');
    }
    if (isSelf && dto.isActive === false) {
      throw new ForbiddenException('You cannot deactivate your own account.');
    }

    const losingAdmin =
      target.role === 'ADMIN' &&
      ((dto.role !== undefined && dto.role !== 'ADMIN') ||
        dto.isActive === false);
    if (losingAdmin) {
      const otherAdmins = await this.prisma.user.count({
        where: {
          organizationId: actor.organizationId,
          role: 'ADMIN',
          isActive: true,
          NOT: { id },
        },
      });
      if (otherAdmins === 0) {
        throw new BadRequestException('At least one active admin is required.');
      }
    }

    if (
      target.role === 'MANAGER' &&
      dto.role !== undefined &&
      dto.role !== 'MANAGER'
    ) {
      const reports = await this.prisma.user.count({
        where: { managerId: id },
      });
      if (reports > 0) {
        throw new BadRequestException(
          "Reassign this manager's team members first.",
        );
      }
    }

    if (dto.email !== undefined && dto.email !== target.email) {
      const taken = await this.prisma.user.findUnique({
        where: { email: dto.email },
        select: { id: true },
      });
      if (taken) {
        throw new ConflictException('A user with this email already exists.');
      }
    }

    const data: Prisma.UserUncheckedUpdateInput = {};
    if (dto.name !== undefined) data.name = dto.name;
    if (dto.email !== undefined) data.email = dto.email;
    if (dto.phone !== undefined) data.phone = dto.phone;
    if (dto.designation !== undefined) data.designation = dto.designation;
    if (dto.department !== undefined) data.department = dto.department;
    if (dto.role !== undefined) data.role = dto.role;
    if (dto.isActive !== undefined) data.isActive = dto.isActive;

    // Relations tabhi dobara check hote hain jab asal me badle hon, taaki
    // sirf active/inactive toggle karne pe purane manager ki wajah se na ruke.
    const relationsChanged =
      (dto.role !== undefined && dto.role !== target.role) ||
      (dto.team !== undefined && dto.team !== (target.team?.name ?? '')) ||
      (dto.managerId !== undefined && dto.managerId !== target.managerId);

    if (relationsChanged) {
      const relations = await this.resolveRelations(
        actor.organizationId,
        dto.role ?? target.role,
        dto.team ?? target.team?.name,
        dto.managerId ?? target.managerId ?? undefined,
      );
      data.teamId = relations.teamId;
      data.managerId = relations.managerId;
    }

    try {
      const updated = await this.prisma.$transaction(async (tx) => {
        const row = await tx.user.update({
          where: { id },
          data,
          select: USER_SELECT,
        });
        // Deactivate hote hi saare refresh tokens band.
        if (dto.isActive === false) {
          await tx.refreshToken.updateMany({
            where: { userId: id, revokedAt: null },
            data: { revokedAt: new Date() },
          });
        }
        return row;
      });
      return toDto(updated);
    } catch (error) {
      if (isUniqueViolation(error)) {
        throw new ConflictException('A user with this email already exists.');
      }
      throw error;
    }
  }

  /** Sirf Employee ke team aur manager hote hain, aur dono zaroori hain. */
  private async resolveRelations(
    organizationId: string,
    role: AppRole,
    team?: string,
    managerId?: string,
  ) {
    if (role !== 'EMPLOYEE') return { teamId: null, managerId: null };
    if (!team || !managerId) {
      throw new BadRequestException('Employees need a team and a manager.');
    }

    const teamRow = await this.prisma.team.findUnique({
      where: { organizationId_name: { organizationId, name: team } },
      select: { id: true },
    });
    if (!teamRow) throw new BadRequestException('Unknown team.');

    const manager = await this.prisma.user.findFirst({
      where: { id: managerId, organizationId, role: 'MANAGER', isActive: true },
      select: { id: true },
    });
    if (!manager) {
      throw new BadRequestException(
        'The manager must be an active manager in your organization.',
      );
    }

    return { teamId: teamRow.id, managerId: manager.id };
  }

  private async nextEmployeeId(): Promise<string> {
    const rows = await this.prisma.user.findMany({
      select: { employeeId: true },
    });
    const highest = rows.reduce((max, row) => {
      const n = Number(row.employeeId.replace(/\D/g, ''));
      return Number.isFinite(n) ? Math.max(max, n) : max;
    }, 0);
    return `FF-${String(highest + 1).padStart(4, '0')}`;
  }
}