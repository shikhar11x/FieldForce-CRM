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
import type { CreateTaskDto, UpdateTaskDto } from './tasks.dto.js';

const TASK_SELECT = {
  id: true,
  title: true,
  description: true,
  customerId: true,
  assignedToId: true,
  dueAt: true,
  priority: true,
  status: true,
  location: true,
  customer: { select: { company: true } },
  assignedTo: { select: { name: true } },
} satisfies Prisma.TaskSelect;

type TaskRow = Prisma.TaskGetPayload<{ select: typeof TASK_SELECT }>;

function toDto(t: TaskRow) {
  return {
    id: t.id,
    title: t.title,
    description: t.description,
    customerId: t.customerId,
    customer: t.customer.company,
    assigneeId: t.assignedToId,
    assignee: t.assignedTo.name,
    due: t.dueAt.toISOString(),
    priority: t.priority,
    status: t.status,
    location: t.location,
  };
}

@Injectable()
export class TasksService {
  constructor(private readonly prisma: PrismaService) {}

  /** Admin: sab. Manager: apne + team ke tasks. Employee: sirf apne. */
  private scope(actor: AuthUser): Prisma.TaskWhereInput {
    const base = { organizationId: actor.organizationId };
    switch (actor.role) {
      case 'ADMIN':
        return base;
      case 'MANAGER':
        return {
          ...base,
          OR: [
            { assignedToId: actor.id },
            { assignedTo: { is: { managerId: actor.id } } },
          ],
        };
      default:
        return { ...base, assignedToId: actor.id };
    }
  }

  async findAll(actor: AuthUser) {
    const rows = await this.prisma.task.findMany({
      where: this.scope(actor),
      select: TASK_SELECT,
      orderBy: { dueAt: 'asc' },
    });
    return rows.map(toDto);
  }

  async findOne(actor: AuthUser, id: string) {
    const task = await this.prisma.task.findFirst({
      where: { ...this.scope(actor), id },
      select: TASK_SELECT,
    });
    // 403 ki jagah 404, taaki dusron ke tasks ka pata na chale.
    if (!task) throw new NotFoundException('Task not found.');
    return toDto(task);
  }

  /** Form ke dropdowns: sirf wahi customers aur assignees jo actor ko allowed hain. */
  async options(actor: AuthUser) {
    const customers = await this.prisma.customer.findMany({
      where: customerScope(actor),
      select: { id: true, company: true },
      orderBy: { company: 'asc' },
    });

    const assigneeWhere: Prisma.UserWhereInput =
      actor.role === 'ADMIN'
        ? {
            organizationId: actor.organizationId,
            isActive: true,
            role: { in: ['EMPLOYEE', 'MANAGER'] },
          }
        : actor.role === 'MANAGER'
          ? {
              organizationId: actor.organizationId,
              isActive: true,
              OR: [{ id: actor.id }, { managerId: actor.id }],
            }
          : { id: actor.id };

    const assignees = await this.prisma.user.findMany({
      where: assigneeWhere,
      select: { id: true, name: true },
      orderBy: { name: 'asc' },
    });

    return {
      customers: customers.map((c) => ({ id: c.id, name: c.company })),
      assignees,
    };
  }

  async create(actor: AuthUser, dto: CreateTaskDto) {
    await this.assertCustomer(actor, dto.customerId);
    const assignedToId = await this.resolveAssignee(actor, dto.assigneeId);
    const status = dto.status ?? 'PENDING';

    const task = await this.prisma.task.create({
      data: {
        organizationId: actor.organizationId,
        title: dto.title,
        description: dto.description ?? '',
        customerId: dto.customerId,
        assignedToId,
        createdById: actor.id,
        dueAt: new Date(dto.due),
        priority: dto.priority ?? 'MEDIUM',
        status,
        location: dto.location ?? '',
        completedAt: status === 'COMPLETED' ? new Date() : null,
      },
      select: TASK_SELECT,
    });
    return toDto(task);
  }

  async update(actor: AuthUser, id: string, dto: UpdateTaskDto) {
    const existing = await this.prisma.task.findFirst({
      where: { ...this.scope(actor), id },
      select: { id: true, customerId: true, assignedToId: true, status: true },
    });
    if (!existing) throw new NotFoundException('Task not found.');

    const data: Prisma.TaskUncheckedUpdateInput = {};
    if (dto.title !== undefined) data.title = dto.title;
    if (dto.description !== undefined) data.description = dto.description;
    if (dto.due !== undefined) data.dueAt = new Date(dto.due);
    if (dto.priority !== undefined) data.priority = dto.priority;
    if (dto.location !== undefined) data.location = dto.location;

    // Customer aur assignee tabhi dobara check hote hain jab asal me badle hon,
    // taaki sirf status badalne par purani assignment ki wajah se na ruke.
    if (dto.customerId !== undefined && dto.customerId !== existing.customerId) {
      await this.assertCustomer(actor, dto.customerId);
      data.customerId = dto.customerId;
    }
    if (
      dto.assigneeId !== undefined &&
      dto.assigneeId !== existing.assignedToId
    ) {
      data.assignedToId = await this.resolveAssignee(actor, dto.assigneeId);
    }

    if (dto.status !== undefined && dto.status !== existing.status) {
      data.status = dto.status;
      data.completedAt = dto.status === 'COMPLETED' ? new Date() : null;
    }

    const updated = await this.prisma.task.update({
      where: { id },
      data,
      select: TASK_SELECT,
    });
    return toDto(updated);
  }

  private async assertCustomer(actor: AuthUser, customerId: string) {
    const customer = await this.prisma.customer.findFirst({
      where: { ...customerScope(actor), id: customerId },
      select: { id: true },
    });
    if (!customer) {
      throw new BadRequestException('Select a customer you have access to.');
    }
  }

  private async resolveAssignee(
    actor: AuthUser,
    requested?: string,
  ): Promise<string> {
    if (actor.role === 'EMPLOYEE') {
      if (requested !== undefined && requested !== actor.id) {
        throw new ForbiddenException(
          'Employees can only assign tasks to themselves.',
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
        'You can only assign tasks to yourself or your team.',
      );
    }
    return assignee.id;
  }
}