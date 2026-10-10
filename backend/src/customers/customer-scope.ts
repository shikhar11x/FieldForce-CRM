import type { AuthUser } from '../auth/auth.types.js';
import type { Prisma } from '../generated/prisma/client.js';

/** Admin: sab. Manager: apne + apni team ke. Employee: sirf apne customers. */
export function customerScope(actor: AuthUser): Prisma.CustomerWhereInput {
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