import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { AuthUser } from '../auth/auth.types.js';
import { Prisma } from '../generated/prisma/client.js';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  buildMonth,
  dateKey,
  localTime,
  statusFor,
  summarize,
  type DayEntry,
} from './attendance-rules.js';
import type { CheckDto, MonthQueryDto } from './attendance.dto.js';

function isUniqueViolation(error: unknown): boolean {
  return (
    error instanceof Prisma.PrismaClientKnownRequestError &&
    error.code === 'P2002'
  );
}

const dayDto = (e: DayEntry) => ({
  date: e.date,
  status: e.status,
  checkIn: e.checkInAt?.toISOString() ?? null,
  checkOut: e.checkOutAt?.toISOString() ?? null,
});

@Injectable()
export class AttendanceService {
  private readonly tz: string;

  constructor(
    private readonly prisma: PrismaService,
    config: ConfigService,
  ) {
    this.tz = config.get<string>('OFFICE_TIMEZONE') ?? 'Asia/Kolkata';
    // Galat timezone ho to startup par hi fail ho.
    localTime(new Date(), this.tz);
  }

  private todayKey(): string {
    return localTime(new Date(), this.tz).day;
  }

  private todayDto(
    key: string,
    row: { checkInAt: Date; checkOutAt: Date | null } | null,
  ) {
    return {
      date: key,
      status: row ? statusFor(row, this.tz) : null,
      checkIn: row?.checkInAt.toISOString() ?? null,
      checkOut: row?.checkOutAt?.toISOString() ?? null,
    };
  }

  async today(actor: AuthUser) {
    const key = this.todayKey();
    const row = await this.prisma.attendance.findUnique({
      where: { userId_date: { userId: actor.id, date: new Date(key) } },
    });
    return this.todayDto(key, row);
  }

  async checkIn(actor: AuthUser, dto: CheckDto) {
    const key = this.todayKey();
    try {
      const row = await this.prisma.attendance.create({
        data: {
          organizationId: actor.organizationId,
          userId: actor.id,
          date: new Date(key),
          checkInAt: new Date(),
          checkInLatitude: dto.latitude,
          checkInLongitude: dto.longitude,
          checkInAccuracyM: Math.round(dto.accuracyMeters),
        },
      });
      return this.todayDto(key, row);
    } catch (error) {
      if (isUniqueViolation(error)) {
        throw new BadRequestException('You have already checked in today.');
      }
      throw error;
    }
  }

  async checkOut(actor: AuthUser, dto: CheckDto) {
    const key = this.todayKey();
    const where = { userId: actor.id, date: new Date(key) };

    const moved = await this.prisma.attendance.updateMany({
      where: { ...where, checkOutAt: null },
      data: {
        checkOutAt: new Date(),
        checkOutLatitude: dto.latitude,
        checkOutLongitude: dto.longitude,
        checkOutAccuracyM: Math.round(dto.accuracyMeters),
      },
    });

    if (moved.count === 0) {
      const existing = await this.prisma.attendance.findFirst({ where });
      throw new BadRequestException(
        existing
          ? 'You have already checked out today.'
          : 'Check in before checking out.',
      );
    }
    return this.today(actor);
  }

  async month(actor: AuthUser, query: MonthQueryDto) {
    const target = await this.resolveTarget(actor, query.employeeId);
    const rows = await this.prisma.attendance.findMany({
      where: {
        userId: target.id,
        date: {
          gte: new Date(Date.UTC(query.year, query.month - 1, 1)),
          lte: new Date(Date.UTC(query.year, query.month, 0)),
        },
      },
      select: { date: true, checkInAt: true, checkOutAt: true },
    });

    return buildMonth(
      query.year,
      query.month,
      rows,
      this.todayKey(),
      this.tz,
      dateKey(target.joiningDate),
    ).map(dayDto);
  }

  /** Aaj ka status aur is mahine ka summary, har employee ke liye. */
  async team(actor: AuthUser) {
    const today = this.todayKey();
    const [year, month] = today.split('-').map(Number);

    const users = await this.prisma.user.findMany({
      where: {
        organizationId: actor.organizationId,
        role: 'EMPLOYEE',
        isActive: true,
        ...(actor.role === 'MANAGER' ? { managerId: actor.id } : {}),
      },
      select: { id: true, name: true, designation: true, joiningDate: true },
      orderBy: { name: 'asc' },
    });

    const rows = await this.prisma.attendance.findMany({
      where: {
        userId: { in: users.map((u) => u.id) },
        date: {
          gte: new Date(Date.UTC(year, month - 1, 1)),
          lte: new Date(Date.UTC(year, month, 0)),
        },
      },
      select: { userId: true, date: true, checkInAt: true, checkOutAt: true },
    });

    const byUser = new Map<string, typeof rows>();
    for (const row of rows) {
      const list = byUser.get(row.userId) ?? [];
      list.push(row);
      byUser.set(row.userId, list);
    }

    return users.map((u) => {
      const entries = buildMonth(
        year,
        month,
        byUser.get(u.id) ?? [],
        today,
        this.tz,
        dateKey(u.joiningDate),
      );
      const todayEntry = entries.find((e) => e.date === today);
      return {
        id: u.id,
        name: u.name,
        designation: u.designation,
        today: todayEntry ? dayDto(todayEntry) : null,
        summary: summarize(entries),
      };
    });
  }

  /** Employee: sirf apna. Manager: apni team. Admin: poori organization. */
  private async resolveTarget(actor: AuthUser, employeeId?: string) {
    if (actor.role === 'EMPLOYEE') {
      if (employeeId && employeeId !== actor.id) {
        throw new NotFoundException('Employee not found.');
      }
      const me = await this.prisma.user.findUnique({
        where: { id: actor.id },
        select: { id: true, joiningDate: true },
      });
      if (!me) throw new NotFoundException('Employee not found.');
      return me;
    }

    if (!employeeId) throw new BadRequestException('Select an employee.');

    const user = await this.prisma.user.findFirst({
      where: {
        id: employeeId,
        organizationId: actor.organizationId,
        role: 'EMPLOYEE',
        ...(actor.role === 'MANAGER' ? { managerId: actor.id } : {}),
      },
      select: { id: true, joiningDate: true },
    });
    // 403 ki jagah 404, taaki dusron ke employees ka pata na chale.
    if (!user) throw new NotFoundException('Employee not found.');
    return user;
  }
}