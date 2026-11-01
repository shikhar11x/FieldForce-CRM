import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client.js';

const prisma = new PrismaClient({
    adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
});

// Pichle do mahine ka history, taaki calendar aur reports me data dikhe.
const DAYS_BACK = 70;

const pad = (n: number) => String(n).padStart(2, '0');

async function main() {
    if ((await prisma.attendance.count()) > 0) {
        console.log('Attendance already has data. Skipping.');
        return;
    }

    const employees = await prisma.user.findMany({
        where: { role: 'EMPLOYEE', isActive: true },
        select: { id: true, name: true, organizationId: true, joiningDate: true },
    });

    const now = new Date();
    let created = 0;

    for (const e of employees) {
        const seed = [...e.name].reduce((sum, c) => sum + c.charCodeAt(0), 0);
        const rows = [];

        // Aaj ko chhod ke: employee aaj ka check-in app se khud karega.
        for (let back = 1; back <= DAYS_BACK; back++) {
            const day = new Date(now.getFullYear(), now.getMonth(), now.getDate() - back);
            if (day.getDay() === 0) continue; // Sunday = week off

            const key = `${day.getFullYear()}-${pad(day.getMonth() + 1)}-${pad(day.getDate())}`;
            const date = new Date(key);
            if (date < e.joiningDate) continue;

            const roll = (seed + day.getDate() * 7 + (day.getMonth() + 1) * 3) % 20;
            if (roll === 0) continue; // absent: koi record nahi

            const jitter = (seed + day.getDate() * 11) % 30;
            const at = (hour: number, minute: number) =>
                new Date(day.getFullYear(), day.getMonth(), day.getDate(), hour, minute);

            let checkInAt: Date;
            let checkOutAt: Date;
            if (roll <= 2) {
                checkInAt = at(10, 15 + (jitter % 30)); // late
                checkOutAt = at(18, 30 + (jitter % 25));
            } else if (roll === 3) {
                checkInAt = at(9, 30); // half day
                checkOutAt = at(13, 0);
            } else {
                checkInAt = at(9, jitter);
                checkOutAt = at(18, (seed + day.getDate() * 5) % 40);
            }

            rows.push({
                organizationId: e.organizationId,
                userId: e.id,
                date,
                checkInAt,
                checkInLatitude: 28.9,
                checkInLongitude: 76.6,
                checkInAccuracyM: 12,
                checkOutAt,
                checkOutLatitude: 28.9,
                checkOutLongitude: 76.6,
                checkOutAccuracyM: 12,
            });
        }

        await prisma.attendance.createMany({ data: rows });
        created += rows.length;
    }

    console.log(`Seeded ${created} attendance records for ${employees.length} employees.`);
}

main()
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })
    .finally(() => prisma.$disconnect());