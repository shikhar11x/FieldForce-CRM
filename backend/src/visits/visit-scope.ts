import type { AuthUser } from '../auth/auth.types.js';
import type { Prisma } from '../generated/prisma/client.js';

/** Admin: sab. Manager: apne + apni team ke visits. Employee: sirf apne. */
export function visitScope(actor: AuthUser): Prisma.VisitWhereInput {
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