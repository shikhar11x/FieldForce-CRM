import { customerScope } from './customer-scope.js';
import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../auth/auth.types.js';
import { Prisma } from '../generated/prisma/client.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { visitScope } from '../visits/visit-scope.js';
import type {
  CreateCustomerDto,
  UpdateCustomerDto,
} from './customers.dto.js';

const CUSTOMER_SELECT = {
  id: true,
  company: true,
  contactName: true,
  phone: true,
  email: true,
  address: true,
  status: true,
  highPriority: true,
  assignedToId: true,
  lastVisitAt: true,
  nextVisitAt: true,
  createdAt: true,
  assignedTo: { select: { name: true } },
} satisfies Prisma.CustomerSelect;

const NOTE_SELECT = {
  id: true,
  text: true,
  createdAt: true,
  author: { select: { name: true } },
} satisfies Prisma.CustomerNoteSelect;

type CustomerRow = Prisma.CustomerGetPayload<{ select: typeof CUSTOMER_SELECT }>;
type NoteRow = Prisma.CustomerNoteGetPayload<{ select: typeof NOTE_SELECT }>;

function toDto(c: CustomerRow) {
  return {
    id: c.id,
    company: c.company,
    contactName: c.contactName,
    phone: c.phone,
    email: c.email,
    address: c.address,
    status: c.status,
    highPriority: c.highPriority,
    assignedEmployeeId: c.assignedToId,
    assignedEmployee: c.assignedTo?.name ?? null,
    lastVisit: c.lastVisitAt?.toISOString() ?? null,
    nextVisit: c.nextVisitAt?.toISOString() ?? null,
    createdAt: c.createdAt.toISOString(),
  };
}

function toNoteDto(n: NoteRow) {
  return {
    id: n.id,
    author: n.author.name,
    text: n.text,
    timestamp: n.createdAt.toISOString(),
  };
}

@Injectable()
export class CustomersService {
  constructor(private readonly prisma: PrismaService) {}

  /** Admin: sab. Manager: apne + apni team ke. Employee: sirf apne. */
   private scope(actor: AuthUser): Prisma.CustomerWhereInput {
    return customerScope(actor);
  }

  async findAll(actor: AuthUser) {
    const rows = await this.prisma.customer.findMany({
      where: this.scope(actor),
      select: CUSTOMER_SELECT,
      orderBy: { company: 'asc' },
    });
    return rows.map(toDto);
  }

  async findOne(actor: AuthUser, id: string) {
    const customer = await this.prisma.customer.findFirst({
      where: { ...this.scope(actor), id },
      select: CUSTOMER_SELECT,
    });
    // 403 ki jagah 404, taaki dusron ke customers ka pata na chale.
    if (!customer) throw new NotFoundException('Customer not found.');

    const notes = await this.prisma.customerNote.findMany({
      where: { customerId: id },
      select: NOTE_SELECT,
      orderBy: { createdAt: 'desc' },
    });
    const visits = await this.prisma.visit.findMany({
      where: { ...visitScope(actor), customerId: id },
      select: {
        id: true,
        scheduledAt: true,
        purpose: true,
        status: true,
        assignedTo: { select: { name: true } },
      },
      orderBy: { scheduledAt: 'desc' },
    });

    return {
      customer: toDto(customer),
      notes: notes.map(toNoteDto),
      visits: visits.map((v) => ({
        id: v.id,
        date: v.scheduledAt.toISOString(),
        employee: v.assignedTo.name,
        purpose: v.purpose,
        status: v.status,
      })),
    };
  }

  async create(actor: AuthUser, dto: CreateCustomerDto) {
    this.assertManagedFields(actor, dto);
    const assignedToId = await this.resolveAssignee(actor, dto.assignedToId);

    const customer = await this.prisma.customer.create({
      data: {
        organizationId: actor.organizationId,
        company: dto.company,
        contactName: dto.contactName,
        phone: dto.phone,
        email: dto.email,
        address: dto.address,
        status: dto.status ?? 'NEW',
        highPriority: dto.highPriority ?? false,
        assignedToId,
      },
      select: CUSTOMER_SELECT,
    });
    return toDto(customer);
  }

  async update(actor: AuthUser, id: string, dto: UpdateCustomerDto) {
    const existing = await this.prisma.customer.findFirst({
      where: { ...this.scope(actor), id },
      select: { id: true },
    });
    if (!existing) throw new NotFoundException('Customer not found.');

    this.assertManagedFields(actor, dto);

    const data: Prisma.CustomerUncheckedUpdateInput = {};
    if (dto.company !== undefined) data.company = dto.company;
    if (dto.contactName !== undefined) data.contactName = dto.contactName;
    if (dto.phone !== undefined) data.phone = dto.phone;
    if (dto.email !== undefined) data.email = dto.email;
    if (dto.address !== undefined) data.address = dto.address;
    if (dto.status !== undefined) data.status = dto.status;
    if (dto.highPriority !== undefined) data.highPriority = dto.highPriority;
    if (dto.assignedToId !== undefined) {
      data.assignedToId = await this.resolveAssignee(actor, dto.assignedToId);
    }

    const updated = await this.prisma.customer.update({
      where: { id },
      data,
      select: CUSTOMER_SELECT,
    });
    return toDto(updated);
  }

  async addNote(actor: AuthUser, customerId: string, text: string) {
    const customer = await this.prisma.customer.findFirst({
      where: { ...this.scope(actor), id: customerId },
      select: { id: true },
    });
    if (!customer) throw new NotFoundException('Customer not found.');

    const note = await this.prisma.customerNote.create({
      data: { customerId, authorId: actor.id, text },
      select: NOTE_SELECT,
    });
    return toNoteDto(note);
  }

  /** Employee assignment, status aur priority nahi badal sakta. */
  private assertManagedFields(
    actor: AuthUser,
    dto: {
      assignedToId?: string;
      status?: string;
      highPriority?: boolean;
    },
  ) {
    if (
      actor.role === 'EMPLOYEE' &&
      (dto.assignedToId !== undefined ||
        dto.status !== undefined ||
        dto.highPriority !== undefined)
    ) {
      throw new ForbiddenException(
        'Only managers and admins can change assignment, status or priority.',
      );
    }
  }

  private async resolveAssignee(
    actor: AuthUser,
    requested?: string,
  ): Promise<string | null> {
    if (actor.role === 'EMPLOYEE') return actor.id;
    if (requested === undefined) {
      return actor.role === 'MANAGER' ? actor.id : null;
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
        'You can only assign customers to yourself or your team.',
      );
    }
    return assignee.id;
  }
}