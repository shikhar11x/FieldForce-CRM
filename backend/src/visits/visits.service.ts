
import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../auth/auth.types.js';
import { customerScope } from '../customers/customer-scope.js';
import { Prisma } from '../generated/prisma/client.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { visitScope } from './visit-scope.js';
import type { CreateVisitDto } from './visits.dto.js';

const GEOFENCE_METERS = 100;

const VISIT_SELECT = {
  id: true,
  customerId: true,
  assignedToId: true,
  scheduledAt: true,
  location: true,
  status: true,
  type: true,
  purpose: true,
  qrVerified: true,
  startedAt: true,
  completedAt: true,
  customer: { select: { company: true } },
  assignedTo: { select: { name: true } },
  notes: {
    select: {
      id: true,
      text: true,
      createdAt: true,
      author: { select: { name: true } },
    },
    orderBy: { createdAt: 'desc' },
  },
  attachments: {
    select: { id: true, name: true, kind: true, size: true, uploadedAt: true },
    orderBy: { uploadedAt: 'asc' },
  },
  events: {
    select: { type: true, title: true, createdAt: true },
    orderBy: { createdAt: 'asc' },
  },
} satisfies Prisma.VisitSelect;

type VisitRow = Prisma.VisitGetPayload<{ select: typeof VISIT_SELECT }>;

function toDto(v: VisitRow) {
  return {
    id: v.id,
    customerId: v.customerId,
    customer: v.customer.company,
    employeeId: v.assignedToId,
    employee: v.assignedTo.name,
    scheduledAt: v.scheduledAt.toISOString(),
    location: v.location,
    status: v.status,
    type: v.type,
    purpose: v.purpose,
    qrVerified: v.qrVerified,
    startedAt: v.startedAt?.toISOString() ?? null,
    completedAt: v.completedAt?.toISOString() ?? null,
    notes: v.notes.map((n) => ({
      id: n.id,
      author: n.author.name,
      text: n.text,
      timestamp: n.createdAt.toISOString(),
    })),
    attachments: v.attachments.map((a) => ({
      id: a.id,
      name: a.name,
      kind: a.kind,
      size: a.size,
      uploaded: a.uploadedAt.toISOString(),
    })),
    events: v.events.map((e) => ({
      type: e.type,
      title: e.title,
      timestamp: e.createdAt.toISOString(),
    })),
  };
}

@Injectable()
export class VisitsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(actor: AuthUser) {
    const rows = await this.prisma.visit.findMany({
      where: visitScope(actor),
      select: VISIT_SELECT,
      orderBy: { scheduledAt: 'asc' },
    });
    return rows.map(toDto);
  }

  async findOne(actor: AuthUser, id: string) {
    const visit = await this.prisma.visit.findFirst({
      where: { ...visitScope(actor), id },
      select: VISIT_SELECT,
    });
    // 403 ki jagah 404, taaki dusron ke visits ka pata na chale.
    if (!visit) throw new NotFoundException('Visit not found.');
    return toDto(visit);
  }

  async create(actor: AuthUser, dto: CreateVisitDto) {
    const customer = await this.prisma.customer.findFirst({
      where: { ...customerScope(actor), id: dto.customerId },
      select: { id: true, address: true },
    });
    if (!customer) {
      throw new BadRequestException('Select a customer you have access to.');
    }

    const assignedToId = await this.resolveAssignee(actor, dto.assigneeId);

    const visit = await this.prisma.visit.create({
      data: {
        organizationId: actor.organizationId,
        customerId: customer.id,
        assignedToId,
        createdById: actor.id,
        scheduledAt: new Date(dto.scheduledAt),
        location: dto.location || customer.address,
        type: dto.type,
        purpose: dto.purpose,
        events: { create: { type: 'SCHEDULED', title: 'Visit scheduled' } },
      },
      select: VISIT_SELECT,
    });
    return toDto(visit);
  }

  async start(actor: AuthUser, id: string) {
    await this.loadAsAssignee(actor, id);

    await this.prisma.$transaction(async (tx) => {
      const moved = await tx.visit.updateMany({
        where: { id, status: 'SCHEDULED' },
        data: { status: 'STARTED', startedAt: new Date() },
      });
      if (moved.count === 0) {
        throw new BadRequestException('Only scheduled visits can be started.');
      }
      await tx.visitEvent.create({
        data: { visitId: id, type: 'STARTED', title: 'Visit started' },
      });
    });
    return this.findOne(actor, id);
  }

  async complete(actor: AuthUser, id: string) {
    const visit = await this.loadAsAssignee(actor, id);

    await this.prisma.$transaction(async (tx) => {
      const now = new Date();
      const moved = await tx.visit.updateMany({
        where: { id, status: 'STARTED' },
        data: { status: 'COMPLETED', completedAt: now },
      });
      if (moved.count === 0) {
        throw new BadRequestException('Only started visits can be completed.');
      }
      await tx.visitEvent.create({
        data: { visitId: id, type: 'COMPLETED', title: 'Visit completed' },
      });
      await tx.customer.update({
        where: { id: visit.customerId },
        data: { lastVisitAt: now },
      });
    });
    return this.findOne(actor, id);
  }

  async cancel(actor: AuthUser, id: string) {
    await this.load(actor, id);

    await this.prisma.$transaction(async (tx) => {
      const moved = await tx.visit.updateMany({
        where: { id, status: 'SCHEDULED' },
        data: { status: 'CANCELLED' },
      });
      if (moved.count === 0) {
        throw new BadRequestException('Only scheduled visits can be cancelled.');
      }
      await tx.visitEvent.create({
        data: { visitId: id, type: 'CANCELLED', title: 'Visit cancelled' },
      });
    });
    return this.findOne(actor, id);
  }

  async addNote(actor: AuthUser, id: string, text: string) {
    const visit = await this.load(actor, id);
    if (visit.status === 'CANCELLED') {
      throw new BadRequestException('This visit is cancelled.');
    }

    await this.prisma.$transaction([
      this.prisma.visitNote.create({
        data: { visitId: id, authorId: actor.id, text },
      }),
      this.prisma.visitEvent.create({
        data: { visitId: id, type: 'NOTE', title: 'Note added' },
      }),
    ]);
    return this.findOne(actor, id);
  }

  /** Abhi sirf placeholder record. Asli file upload baad ke step me. */
  async addPhoto(actor: AuthUser, id: string) {
    const visit = await this.loadAsAssignee(actor, id);
    if (visit.status !== 'STARTED') {
      throw new BadRequestException('Start the visit before adding photos.');
    }

    const count = await this.prisma.visitAttachment.count({
      where: { visitId: id },
    });
    await this.prisma.$transaction([
      this.prisma.visitAttachment.create({
        data: {
          visitId: id,
          name: `Visit photo ${count + 1}.jpg`,
          kind: 'Photo',
          size: '1.9 MB',
        },
      }),
      this.prisma.visitEvent.create({
        data: { visitId: id, type: 'PHOTO', title: 'Photo uploaded' },
      }),
    ]);
    return this.findOne(actor, id);
  }

  /**
   * TEMPORARY: server sirf assignee aur app se aayi distance check karta hai.
   * Asli QR (signed customer code) aur GPS verification Step 22 me aayega.
   */
  async verifyQr(actor: AuthUser, id: string, distanceMeters: number) {
    const visit = await this.loadAsAssignee(actor, id);
    if (visit.status !== 'SCHEDULED' && visit.status !== 'STARTED') {
      throw new BadRequestException('This visit is no longer active.');
    }
    if (visit.qrVerified) return this.findOne(actor, id);

    if (distanceMeters > GEOFENCE_METERS) {
      throw new BadRequestException(
        `You are too far from the customer (${distanceMeters} m, limit ${GEOFENCE_METERS} m).`,
      );
    }

    await this.prisma.$transaction([
      this.prisma.visit.update({ where: { id }, data: { qrVerified: true } }),
      this.prisma.visitEvent.create({
        data: { visitId: id, type: 'QR_VERIFIED', title: 'QR code verified' },
      }),
    ]);
    return this.findOne(actor, id);
  }

  private async load(actor: AuthUser, id: string) {
    const visit = await this.prisma.visit.findFirst({
      where: { ...visitScope(actor), id },
      select: {
        id: true,
        status: true,
        assignedToId: true,
        customerId: true,
        qrVerified: true,
      },
    });
    if (!visit) throw new NotFoundException('Visit not found.');
    return visit;
  }

  private async loadAsAssignee(actor: AuthUser, id: string) {
    const visit = await this.load(actor, id);
    if (visit.assignedToId !== actor.id) {
      throw new ForbiddenException(
        'Only the assigned employee can do this.',
      );
    }
    return visit;
  }

  private async resolveAssignee(
    actor: AuthUser,
    requested?: string,
  ): Promise<string> {
    if (actor.role === 'EMPLOYEE') {
      if (requested !== undefined && requested !== actor.id) {
        throw new ForbiddenException(
          'Employees can only schedule visits for themselves.',
        );
      }
      return actor.id;
    }

    if (requested === undefined) {
      if (actor.role === 'MANAGER') return actor.id;
      throw new BadRequestException('Select an assignee.');
    }

    const assignee = await this.prisma.user.findFirst({
      where: {
        id: requested,
        organizationId: actor.organizationId,
        isActive: true,
        role: { in: ['EMPLOYEE', 'MANAGER'] },
      },
      select: { id: true, managerId: true },
    });
    if (!assignee) {
      throw new BadRequestException(
        'The assignee must be an active employee or manager.',
      );
    }
    if (
      actor.role === 'MANAGER' &&
      assignee.id !== actor.id &&
      assignee.managerId !== actor.id
    ) {
      throw new ForbiddenException(
        'You can only assign visits to yourself or your team.',
      );
    }
    return assignee.id;
  }
}