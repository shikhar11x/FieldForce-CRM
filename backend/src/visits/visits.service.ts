import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../auth/auth.types.js';
import { distanceMeters } from '../common/geo.js';
import { customerScope } from '../customers/customer-scope.js';
import { Prisma } from '../generated/prisma/client.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { QrService } from '../qr/qr.service.js';
import {
  detectImage,
  formatBytes,
  type UploadedImage,
} from '../storage/image-type.js';
import { StorageService } from '../storage/storage.service.js';
import { visitScope } from './visit-scope.js';
import type { CreateVisitDto, ScanQrDto } from './visits.dto.js';

/** Customer se is doori ke andar hi verify hota hai. */
const GEOFENCE_METERS = 100;
/** GPS reading isse kharab (zyada meters) ho to reject. */
const MAX_ACCURACY_METERS = 75;
const MAX_PHOTOS_PER_VISIT = 10;

type ScanStatus =
  | 'VERIFIED'
  | 'LOCATION_MISMATCH'
  | 'LOW_ACCURACY'
  | 'CUSTOMER_NOT_LOCATED'
  | 'NO_VISIT'
  | 'INVALID_CODE';

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
    select: {
      id: true,
      name: true,
      kind: true,
      size: true,
      uploadedAt: true,
      storageKey: true,
    },
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
      // storageKey kabhi bahar nahi jaata, sirf ye batata hai ki file hai ya nahi.
      hasFile: a.storageKey !== null,
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
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
    private readonly qr: QrService,
  ) {}

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

  async addPhoto(actor: AuthUser, id: string, file: UploadedImage | undefined) {
    const visit = await this.loadAsAssignee(actor, id);
    if (visit.status !== 'STARTED') {
      throw new BadRequestException('Start the visit before adding photos.');
    }
    if (!file || file.size === 0) {
      throw new BadRequestException('Attach a photo in the "file" field.');
    }

    // Type file ke bytes se pehchanta hai, client ke bataye naam se nahi.
    const image = detectImage(file.buffer);
    if (!image) {
      throw new BadRequestException('Only JPEG, PNG or WebP images are allowed.');
    }

    const count = await this.prisma.visitAttachment.count({
      where: { visitId: id },
    });
    if (count >= MAX_PHOTOS_PER_VISIT) {
      throw new BadRequestException(
        `A visit can have at most ${MAX_PHOTOS_PER_VISIT} photos.`,
      );
    }

    const key = this.storage.newKey(`visits/${id}`, image.ext);
    await this.storage.save(key, file.buffer);

    try {
      await this.prisma.$transaction([
        this.prisma.visitAttachment.create({
          data: {
            visitId: id,
            name: `Visit photo ${count + 1}.${image.ext}`,
            kind: 'Photo',
            size: formatBytes(file.size),
            storageKey: key,
            mimeType: image.mime,
            sizeBytes: file.size,
          },
        }),
        this.prisma.visitEvent.create({
          data: { visitId: id, type: 'PHOTO', title: 'Photo uploaded' },
        }),
      ]);
    } catch (error) {
      // Database fail ho to disk par bachi file saaf kar do.
      await this.storage.remove(key);
      throw error;
    }
    return this.findOne(actor, id);
  }

  async getPhoto(actor: AuthUser, id: string, photoId: string) {
    const attachment = await this.prisma.visitAttachment.findFirst({
      where: { id: photoId, visit: { ...visitScope(actor), id } },
      select: { storageKey: true, mimeType: true },
    });
    if (!attachment?.storageKey || !attachment.mimeType) {
      throw new NotFoundException('Photo not found.');
    }

    const file = await this.storage.open(attachment.storageKey);
    return { ...file, mime: attachment.mimeType };
  }

  /**
   * Customer ka signed QR + device ki GPS location. Server khud code check
   * karta hai, visit dhundta hai aur doori nikalta hai. Business ke nateeje
   * (galat code, door, visit nahi...) 200 ke saath `status` me aate hain.
   */
  async scanQr(actor: AuthUser, dto: ScanQrDto) {
    const accuracy = Math.round(dto.accuracyMeters);
    const result = (
      status: ScanStatus,
      extra: Record<string, unknown> = {},
    ) => ({
      status,
      geofenceMeters: GEOFENCE_METERS,
      accuracyMeters: accuracy,
      ...extra,
    });

    const customerId = this.qr.parse(dto.qrPayload);
    if (!customerId) return result('INVALID_CODE');

    const customer = await this.prisma.customer.findFirst({
      where: { id: customerId, organizationId: actor.organizationId },
      select: { id: true, company: true, address: true, latitude: true, longitude: true },
    });
    if (!customer) return result('INVALID_CODE');

    // Sirf actor ke apne active visits, chahe customer ab kisi aur ko assigned ho.
    const visits = await this.prisma.visit.findMany({
      where: {
        organizationId: actor.organizationId,
        assignedToId: actor.id,
        customerId,
        status: { in: ['SCHEDULED', 'STARTED'] },
      },
      orderBy: { scheduledAt: 'asc' },
      select: {
        id: true,
        status: true,
        purpose: true,
        scheduledAt: true,
        qrVerified: true,
      },
    });

    const customerInfo = {
      customerName: customer.company,
      address: customer.address,
    };
    const visit = visits.find((v) => v.status === 'STARTED') ?? visits[0];
    if (!visit) return result('NO_VISIT', customerInfo);

    const visitInfo = {
      ...customerInfo,
      visitId: visit.id,
      visitPurpose: visit.purpose,
      visitScheduledAt: visit.scheduledAt.toISOString(),
    };

    if (visit.qrVerified) return result('VERIFIED', visitInfo);
    if (customer.latitude === null || customer.longitude === null) {
      return result('CUSTOMER_NOT_LOCATED', visitInfo);
    }
    if (accuracy > MAX_ACCURACY_METERS) return result('LOW_ACCURACY', visitInfo);

    const distance = Math.round(
      distanceMeters(
        dto.latitude,
        dto.longitude,
        customer.latitude,
        customer.longitude,
      ),
    );
    if (distance > GEOFENCE_METERS) {
      return result('LOCATION_MISMATCH', { ...visitInfo, distanceMeters: distance });
    }

    await this.prisma.$transaction([
      this.prisma.visit.update({
        where: { id: visit.id },
        data: {
          qrVerified: true,
          qrVerifiedAt: new Date(),
          verifyDistanceM: distance,
          verifyAccuracyM: accuracy,
          verifyLatitude: dto.latitude,
          verifyLongitude: dto.longitude,
        },
      }),
      this.prisma.visitEvent.create({
        data: {
          visitId: visit.id,
          type: 'QR_VERIFIED',
          title: 'QR code verified',
        },
      }),
    ]);
    return result('VERIFIED', { ...visitInfo, distanceMeters: distance });
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
      throw new ForbiddenException('Only the assigned employee can do this.');
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