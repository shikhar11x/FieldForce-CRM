import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { hash } from 'bcryptjs';
import { PrismaClient } from '../src/generated/prisma/client.js';

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
});

type Role = 'ADMIN' | 'MANAGER' | 'EMPLOYEE';

interface SeedUser {
  employeeId: string;
  name: string;
  email: string;
  phone: string;
  role: Role;
  designation: string;
  department: string;
  team?: string;
  managerEmail?: string;
  joiningDate: string;
  isActive?: boolean;
}

const TEAMS = ['Sales North', 'Sales South', 'Service'];

// Managers pehle, taaki employees unse link ho sakein.
const USERS: SeedUser[] = [
  { employeeId: 'FF-0001', name: 'Aarav Mehta', email: 'admin@fieldforce.com', phone: '+91 98765 43210', role: 'ADMIN', designation: 'Administrator', department: 'Administration', joiningDate: '2019-04-01' },
  { employeeId: 'FF-0102', name: 'Priya Sharma', email: 'manager@fieldforce.com', phone: '+91 98765 43211', role: 'MANAGER', designation: 'Regional Sales Manager', department: 'Regional Sales', joiningDate: '2021-06-14' },
  { employeeId: 'FF-0108', name: 'Rahul Bose', email: 'rahul.bose@fieldforce.com', phone: '+91 98765 43220', role: 'MANAGER', designation: 'Operations Manager', department: 'Operations', joiningDate: '2022-01-10' },
  { employeeId: 'FF-0457', name: 'Rohan Verma', email: 'employee@fieldforce.com', phone: '+91 98765 43212', role: 'EMPLOYEE', designation: 'Senior Sales Executive', department: 'Field Sales', team: 'Sales North', managerEmail: 'manager@fieldforce.com', joiningDate: '2023-02-06' },
  { employeeId: 'FF-0461', name: 'Sneha Reddy', email: 'sneha.reddy@fieldforce.com', phone: '+91 98765 43213', role: 'EMPLOYEE', designation: 'Sales Executive', department: 'Field Sales', team: 'Sales South', managerEmail: 'manager@fieldforce.com', joiningDate: '2023-05-15' },
  { employeeId: 'FF-0470', name: 'Arjun Nair', email: 'arjun.nair@fieldforce.com', phone: '+91 98765 43214', role: 'EMPLOYEE', designation: 'Service Agent', department: 'Field Service', team: 'Service', managerEmail: 'manager@fieldforce.com', joiningDate: '2023-08-21' },
  { employeeId: 'FF-0482', name: 'Kavya Iyer', email: 'kavya.iyer@fieldforce.com', phone: '+91 98765 43215', role: 'EMPLOYEE', designation: 'Sales Executive', department: 'Field Sales', team: 'Sales South', managerEmail: 'manager@fieldforce.com', joiningDate: '2024-01-08' },
  { employeeId: 'FF-0493', name: 'Imran Khan', email: 'imran.khan@fieldforce.com', phone: '+91 98765 43216', role: 'EMPLOYEE', designation: 'Service Agent', department: 'Field Service', team: 'Service', managerEmail: 'manager@fieldforce.com', joiningDate: '2024-03-18' },
  { employeeId: 'FF-0510', name: 'Neha Kapoor', email: 'neha.kapoor@fieldforce.com', phone: '+91 98765 43217', role: 'EMPLOYEE', designation: 'Field Executive', department: 'Field Sales', team: 'Sales North', managerEmail: 'manager@fieldforce.com', joiningDate: '2024-09-02' },
  { employeeId: 'FF-0431', name: 'Deepak Chauhan', email: 'deepak.chauhan@fieldforce.com', phone: '+91 98765 43218', role: 'EMPLOYEE', designation: 'Service Agent', department: 'Field Service', team: 'Service', managerEmail: 'manager@fieldforce.com', joiningDate: '2022-11-14', isActive: false },
];

async function main() {
  const passwordHash = await hash(process.env.SEED_PASSWORD ?? 'password123', 12);

  const organization =
    (await prisma.organization.findFirst({ where: { name: 'Northwind Logistics' } })) ??
    (await prisma.organization.create({ data: { name: 'Northwind Logistics' } }));

  const teamIds = new Map<string, string>();
  for (const name of TEAMS) {
    const team = await prisma.team.upsert({
      where: { organizationId_name: { organizationId: organization.id, name } },
      update: {},
      create: { organizationId: organization.id, name },
    });
    teamIds.set(name, team.id);
  }

  const userIds = new Map<string, string>();
  for (const u of USERS) {
    const data = {
      organizationId: organization.id,
      employeeId: u.employeeId,
      name: u.name,
      phone: u.phone,
      role: u.role,
      designation: u.designation,
      department: u.department,
      teamId: u.team ? (teamIds.get(u.team) ?? null) : null,
      managerId: u.managerEmail ? (userIds.get(u.managerEmail) ?? null) : null,
      joiningDate: new Date(u.joiningDate),
      isActive: u.isActive ?? true,
    };

    const user = await prisma.user.upsert({
      where: { email: u.email },
      update: data,
      create: { ...data, email: u.email, passwordHash },
    });
    userIds.set(u.email, user.id);
  }

  console.log(`Seeded ${USERS.length} users in "${organization.name}".`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());