export const ROLES = ['ADMIN', 'MANAGER', 'EMPLOYEE'] as const;
export type AppRole = (typeof ROLES)[number];

/** Request pe guard ke baad yahi attach hota hai. */
export interface AuthUser {
  id: string;
  role: AppRole;
  organizationId: string;
}