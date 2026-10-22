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

interface SeedCustomer {
  company: string;
  contactName: string;
  phone: string;
  email: string;
  address: string;
  status: 'ACTIVE' | 'INACTIVE' | 'NEW';
  assignee: string; // employee ka email
  highPriority?: boolean;
  lastVisitDays?: number;
  nextVisitDays?: number;
}

const CUSTOMERS: SeedCustomer[] = [
  { company: 'Metro Hardware', contactName: 'Vikram Malhotra', phone: '+91 98100 11001', email: 'vikram@metrohardware.in', address: '12, Sector 14 Market Road', status: 'ACTIVE', assignee: 'employee@fieldforce.com', highPriority: true, lastVisitDays: -1, nextVisitDays: 6 },
  { company: 'Sunrise Traders', contactName: 'Anita Desai', phone: '+91 98100 11002', email: 'anita@sunrisetraders.in', address: '45, Sector 9 Main Bazaar', status: 'ACTIVE', assignee: 'arjun.nair@fieldforce.com', lastVisitDays: -3, nextVisitDays: 4 },
  { company: 'Greenfield Foods', contactName: 'Sanjay Gupta', phone: '+91 98100 11003', email: 'sanjay@greenfieldfoods.in', address: 'Plot 8, Industrial Area Phase 2', status: 'ACTIVE', assignee: 'employee@fieldforce.com', highPriority: true, lastVisitDays: 0, nextVisitDays: 2 },
  { company: 'Apex Pharma', contactName: 'Dr. Meera Joshi', phone: '+91 98100 11004', email: 'meera@apexpharma.in', address: '3, Civil Lines Road', status: 'ACTIVE', assignee: 'sneha.reddy@fieldforce.com', lastVisitDays: -6, nextVisitDays: 1 },
  { company: 'Bright Electricals', contactName: 'Rajesh Kumar', phone: '+91 98100 11005', email: 'rajesh@brightelectricals.in', address: '21, Model Town Chowk', status: 'ACTIVE', assignee: 'employee@fieldforce.com', lastVisitDays: -9, nextVisitDays: 5 },
  { company: 'Lotus Stationers', contactName: 'Pooja Bansal', phone: '+91 98100 11006', email: 'pooja@lotusstationers.in', address: '7, Old Market Lane', status: 'INACTIVE', assignee: 'kavya.iyer@fieldforce.com', lastVisitDays: -75 },
  { company: 'Kisan Agro Supplies', contactName: 'Harpreet Singh', phone: '+91 98100 11007', email: 'harpreet@kisanagro.in', address: '88, Mandi Road', status: 'NEW', assignee: 'imran.khan@fieldforce.com', nextVisitDays: 1 },
  { company: 'Ocean Logistics', contactName: 'Farhan Sheikh', phone: '+91 98100 11008', email: 'farhan@oceanlogistics.in', address: 'Warehouse 4, Transport Nagar', status: 'ACTIVE', assignee: 'neha.kapoor@fieldforce.com', highPriority: true, lastVisitDays: -2, nextVisitDays: 3 },
  { company: 'Silverline Textiles', contactName: 'Deepa Nair', phone: '+91 98100 11009', email: 'deepa@silverlinetextiles.in', address: '16, Weavers Colony', status: 'INACTIVE', assignee: 'arjun.nair@fieldforce.com', lastVisitDays: -120 },
  { company: 'Urban Cafe Chain', contactName: 'Tanya Arora', phone: '+91 98100 11010', email: 'tanya@urbancafe.in', address: '2, City Centre Mall', status: 'NEW', assignee: 'sneha.reddy@fieldforce.com', highPriority: true, nextVisitDays: 2 },
];

function daysFromNow(days: number, hour = 11): Date {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate() + days, hour, 0);
}

interface SeedTask {
  title: string;
  description: string;
  customer: string;
  assignee: string; // employee ka email
  days: number;
  hour: number;
  minute?: number;
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
  status: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
  location: string;
}

const TASKS: SeedTask[] = [
  { title: 'Collect signed contract', description: 'Pick up the signed annual supply contract and confirm the revised payment terms with the owner.', customer: 'Sunrise Traders', assignee: 'employee@fieldforce.com', days: 0, hour: 14, priority: 'HIGH', status: 'PENDING', location: 'Sector 9 Main Bazaar' },
  { title: 'Product demo for new range', description: 'Demonstrate the new packaging range to the purchase team. Carry the sample kit and the printed brochure.', customer: 'Greenfield Foods', assignee: 'employee@fieldforce.com', days: 0, hour: 15, minute: 30, priority: 'URGENT', status: 'IN_PROGRESS', location: 'Industrial Area Phase 2' },
  { title: 'Payment follow-up', description: 'Follow up on the invoice due this week.', customer: 'Metro Hardware', assignee: 'employee@fieldforce.com', days: 0, hour: 17, priority: 'MEDIUM', status: 'PENDING', location: 'Sector 14 Market Road' },
  { title: 'Deliver product samples', description: '', customer: 'Apex Pharma', assignee: 'employee@fieldforce.com', days: 1, hour: 11, priority: 'LOW', status: 'PENDING', location: 'Civil Lines Road' },
  { title: 'Share revised price list', description: 'Email and WhatsApp the Q4 price list to the owner.', customer: 'Bright Electricals', assignee: 'employee@fieldforce.com', days: -2, hour: 17, priority: 'HIGH', status: 'PENDING', location: 'Model Town Chowk' },
  { title: 'Quarterly stock audit', description: 'Verify shelf stock against the last delivery challan.', customer: 'Metro Hardware', assignee: 'employee@fieldforce.com', days: -3, hour: 12, priority: 'MEDIUM', status: 'COMPLETED', location: 'Sector 14 Market Road' },
  { title: 'Onboarding kit handover', description: 'Hand over the welcome kit and walk through the app.', customer: 'Kisan Agro Supplies', assignee: 'imran.khan@fieldforce.com', days: 1, hour: 10, minute: 30, priority: 'HIGH', status: 'PENDING', location: 'Mandi Road' },
  { title: 'Renewal discussion', description: 'Discuss the annual contract renewal and volume pricing.', customer: 'Ocean Logistics', assignee: 'neha.kapoor@fieldforce.com', days: 2, hour: 13, priority: 'URGENT', status: 'IN_PROGRESS', location: 'Transport Nagar' },
  { title: 'Menu pricing proposal', description: 'Prepare a bulk pricing proposal for 12 outlets.', customer: 'Urban Cafe Chain', assignee: 'sneha.reddy@fieldforce.com', days: 2, hour: 12, priority: 'HIGH', status: 'PENDING', location: 'City Centre Mall' },
  { title: 'Re-activation call', description: 'Check why orders stopped and offer a returning discount.', customer: 'Lotus Stationers', assignee: 'kavya.iyer@fieldforce.com', days: -1, hour: 16, priority: 'LOW', status: 'PENDING', location: 'Old Market Lane' },
  { title: 'Warranty claim inspection', description: 'Inspection no longer needed. Customer closed the claim.', customer: 'Silverline Textiles', assignee: 'arjun.nair@fieldforce.com', days: 3, hour: 11, priority: 'MEDIUM', status: 'CANCELLED', location: 'Weavers Colony' },
  { title: 'Install demo display unit', description: 'Set up the counter display and brief the store staff.', customer: 'Apex Pharma', assignee: 'sneha.reddy@fieldforce.com', days: -5, hour: 10, priority: 'HIGH', status: 'COMPLETED', location: 'Civil Lines Road' },
  { title: 'Collect feedback survey', description: '', customer: 'Sunrise Traders', assignee: 'arjun.nair@fieldforce.com', days: 4, hour: 15, priority: 'LOW', status: 'PENDING', location: 'Sector 9 Main Bazaar' },
];

function taskTime(days: number, hour: number, minute = 0): Date {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate() + days, hour, minute);
}

type VisitStatus = 'SCHEDULED' | 'STARTED' | 'COMPLETED' | 'CANCELLED';
type VisitType = 'SALES' | 'SERVICE' | 'FOLLOW_UP' | 'DELIVERY' | 'DEMO';
type VisitEventType =
  | 'SCHEDULED'
  | 'STARTED'
  | 'QR_VERIFIED'
  | 'NOTE'
  | 'PHOTO'
  | 'COMPLETED'
  | 'CANCELLED';

interface SeedVisit {
  customer: string;
  assignee: string; // employee ka email
  days: number;
  hour: number;
  minute?: number;
  status: VisitStatus;
  type: VisitType;
  purpose: string;
  startOffsetMin?: number; // schedule ke kitne minute baad start hua
  durationMin?: number;
  qrVerified?: boolean;
  note?: string;
  photo?: string;
}

const VISITS: SeedVisit[] = [
  { customer: 'Metro Hardware', assignee: 'employee@fieldforce.com', days: 0, hour: 9, minute: 30, status: 'COMPLETED', type: 'SALES', purpose: 'Order follow-up and stock check', durationMin: 65, qrVerified: true, note: 'Stock levels are healthy. Owner wants revised pricing on the cement range.', photo: 'Shelf photo.jpg' },
  { customer: 'Sunrise Traders', assignee: 'employee@fieldforce.com', days: 0, hour: 11, status: 'COMPLETED', type: 'SALES', purpose: 'Contract renewal paperwork', durationMin: 45, qrVerified: true, note: 'Signed contract copy collected from the owner.' },
  { customer: 'Greenfield Foods', assignee: 'employee@fieldforce.com', days: 0, hour: 13, minute: 30, status: 'STARTED', type: 'DEMO', purpose: 'Product demo for the new packaging range', qrVerified: true },
  { customer: 'Apex Pharma', assignee: 'employee@fieldforce.com', days: 0, hour: 15, status: 'SCHEDULED', type: 'FOLLOW_UP', purpose: 'Follow up on sample feedback' },
  { customer: 'Bright Electricals', assignee: 'employee@fieldforce.com', days: 0, hour: 16, minute: 30, status: 'SCHEDULED', type: 'DELIVERY', purpose: 'Deliver the Q4 display kit' },
  { customer: 'Metro Hardware', assignee: 'employee@fieldforce.com', days: -1, hour: 15, minute: 30, status: 'COMPLETED', type: 'SERVICE', purpose: 'Service check on the display unit', durationMin: 40, qrVerified: true, note: 'Replaced the faulty LED strip. Unit working normally.' },
  { customer: 'Greenfield Foods', assignee: 'employee@fieldforce.com', days: 2, hour: 10, status: 'SCHEDULED', type: 'SALES', purpose: 'Annual contract renewal discussion' },
  { customer: 'Ocean Logistics', assignee: 'neha.kapoor@fieldforce.com', days: 3, hour: 11, minute: 30, status: 'SCHEDULED', type: 'SALES', purpose: 'Volume pricing negotiation' },
  { customer: 'Kisan Agro Supplies', assignee: 'imran.khan@fieldforce.com', days: 1, hour: 10, status: 'SCHEDULED', type: 'DEMO', purpose: 'Onboarding and product walkthrough' },
  { customer: 'Urban Cafe Chain', assignee: 'sneha.reddy@fieldforce.com', days: 2, hour: 12, status: 'SCHEDULED', type: 'SALES', purpose: 'Bulk pricing proposal for 12 outlets' },
  { customer: 'Silverline Textiles', assignee: 'arjun.nair@fieldforce.com', days: -10, hour: 12, status: 'CANCELLED', type: 'FOLLOW_UP', purpose: 'Dormant account check-in' },
  { customer: 'Lotus Stationers', assignee: 'kavya.iyer@fieldforce.com', days: -75, hour: 11, status: 'COMPLETED', type: 'FOLLOW_UP', purpose: 'Check why orders have slowed', durationMin: 35 },
  { customer: 'Apex Pharma', assignee: 'sneha.reddy@fieldforce.com', days: -6, hour: 11, status: 'COMPLETED', type: 'SERVICE', purpose: 'Install the counter display unit', startOffsetMin: 10, durationMin: 55, qrVerified: true },
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

  // Customers sirf tab seed hote hain jab abhi koi customer nahi hai.
  const customerCount = await prisma.customer.count({
    where: { organizationId: organization.id },
  });
  if (customerCount === 0) {
    const customerIds = new Map<string, string>();
    for (const c of CUSTOMERS) {
      const created = await prisma.customer.create({
        data: {
          organizationId: organization.id,
          company: c.company,
          contactName: c.contactName,
          phone: c.phone,
          email: c.email,
          address: c.address,
          status: c.status,
          highPriority: c.highPriority ?? false,
          assignedToId: userIds.get(c.assignee) ?? null,
          lastVisitAt: c.lastVisitDays === undefined ? null : daysFromNow(c.lastVisitDays),
          nextVisitAt: c.nextVisitDays === undefined ? null : daysFromNow(c.nextVisitDays),
        },
      });
      customerIds.set(c.company, created.id);
    }

    const notes = [
      { company: 'Metro Hardware', author: 'manager@fieldforce.com', text: 'Priority account this quarter. Keep pricing discussions with the manager.' },
      { company: 'Metro Hardware', author: 'employee@fieldforce.com', text: 'Prefers morning visits. Decision maker is Vikram Malhotra.' },
      { company: 'Greenfield Foods', author: 'employee@fieldforce.com', text: 'Interested in the new packaging range.' },
    ];
    for (const n of notes) {
      await prisma.customerNote.create({
        data: {
          customerId: customerIds.get(n.company)!,
          authorId: userIds.get(n.author)!,
          text: n.text,
        },
      });
    }
    console.log(`Seeded ${CUSTOMERS.length} customers.`);
  }

  // Tasks sirf tab seed hote hain jab abhi koi task nahi hai.
  const taskCount = await prisma.task.count({
    where: { organizationId: organization.id },
  });
  if (taskCount === 0) {
    const customers = await prisma.customer.findMany({
      where: { organizationId: organization.id },
      select: { id: true, company: true },
    });
    const byCompany = new Map(customers.map((c) => [c.company, c.id]));
    const creatorId = userIds.get('manager@fieldforce.com')!;

    let created = 0;
    for (const t of TASKS) {
      const customerId = byCompany.get(t.customer);
      const assignedToId = userIds.get(t.assignee);
      if (!customerId || !assignedToId) {
        console.warn(`Skipped task "${t.title}" (customer or assignee missing).`);
        continue;
      }
      await prisma.task.create({
        data: {
          organizationId: organization.id,
          title: t.title,
          description: t.description,
          customerId,
          assignedToId,
          createdById: creatorId,
          dueAt: taskTime(t.days, t.hour, t.minute),
          priority: t.priority,
          status: t.status,
          location: t.location,
          completedAt:
            t.status === 'COMPLETED' ? taskTime(t.days, t.hour, t.minute) : null,
        },
      });
      created++;
    }
    console.log(`Seeded ${created} tasks.`);
  }

  // Visits sirf tab seed hote hain jab abhi koi visit nahi hai.
  const visitCount = await prisma.visit.count({
    where: { organizationId: organization.id },
  });
  if (visitCount === 0) {
    const customers = await prisma.customer.findMany({
      where: { organizationId: organization.id },
      select: { id: true, company: true, address: true },
    });
    const byCompany = new Map(customers.map((c) => [c.company, c]));
    const creatorId = userIds.get('manager@fieldforce.com')!;

    let created = 0;
    for (const v of VISITS) {
      const customer = byCompany.get(v.customer);
      const assignedToId = userIds.get(v.assignee);
      if (!customer || !assignedToId) {
        console.warn(`Skipped visit "${v.purpose}" (customer or assignee missing).`);
        continue;
      }

      const scheduledAt = taskTime(v.days, v.hour, v.minute ?? 0);
      const at = (minutes: number) => new Date(scheduledAt.getTime() + minutes * 60_000);
      const startMin = v.startOffsetMin ?? 5;
      const endMin = startMin + (v.durationMin ?? 45);
      const hasStarted = v.status === 'STARTED' || v.status === 'COMPLETED';

      const events: { type: VisitEventType; title: string; createdAt: Date }[] = [
        { type: 'SCHEDULED', title: 'Visit scheduled', createdAt: new Date(scheduledAt.getTime() - 86_400_000) },
      ];
      if (hasStarted) events.push({ type: 'STARTED', title: 'Visit started', createdAt: at(startMin) });
      if (v.qrVerified) events.push({ type: 'QR_VERIFIED', title: 'QR code verified', createdAt: at(startMin + 1) });
      if (v.photo) events.push({ type: 'PHOTO', title: 'Photo uploaded', createdAt: at(startMin + 30) });
      if (v.note) events.push({ type: 'NOTE', title: 'Note added', createdAt: at(startMin + 35) });
      if (v.status === 'COMPLETED') events.push({ type: 'COMPLETED', title: 'Visit completed', createdAt: at(endMin) });
      if (v.status === 'CANCELLED') events.push({ type: 'CANCELLED', title: 'Visit cancelled', createdAt: at(-12 * 60) });

      await prisma.visit.create({
        data: {
          organizationId: organization.id,
          customerId: customer.id,
          assignedToId,
          createdById: creatorId,
          scheduledAt,
          location: customer.address,
          status: v.status,
          type: v.type,
          purpose: v.purpose,
          qrVerified: v.qrVerified ?? false,
          startedAt: hasStarted ? at(startMin) : null,
          completedAt: v.status === 'COMPLETED' ? at(endMin) : null,
          events: { create: events },
          notes: v.note
            ? { create: { authorId: assignedToId, text: v.note, createdAt: at(startMin + 35) } }
            : undefined,
          attachments: v.photo
            ? { create: { name: v.photo, kind: 'Photo', size: '2.1 MB', uploadedAt: at(startMin + 30) } }
            : undefined,
        },
      });
      created++;
    }
    console.log(`Seeded ${created} visits.`);
  }

  console.log(`Seeded ${USERS.length} users in "${organization.name}".`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());