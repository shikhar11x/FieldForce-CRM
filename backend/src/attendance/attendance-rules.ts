/** Check-in is time ke baad ho to Late (office timezone, minutes since midnight). */
export const LATE_AFTER_MINUTES = 10 * 60;
/** Check-out ke baad is se kam kaam ho to Half day. */
export const HALF_DAY_UNDER_MINUTES = 4 * 60;

export type DayStatus = 'PRESENT' | 'LATE' | 'HALF_DAY' | 'ABSENT' | 'WEEK_OFF';

export interface DayEntry {
  /** YYYY-MM-DD */
  date: string;
  status: DayStatus;
  checkInAt: Date | null;
  checkOutAt: Date | null;
}

export interface AttendanceRow {
  date: Date;
  checkInAt: Date;
  checkOutAt: Date | null;
}

const formatters = new Map<string, Intl.DateTimeFormat>();

function formatter(timeZone: string): Intl.DateTimeFormat {
  let f = formatters.get(timeZone);
  if (!f) {
    f = new Intl.DateTimeFormat('en-GB', {
      timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      hourCycle: 'h23',
    });
    formatters.set(timeZone, f);
  }
  return f;
}

/** Office timezone me is waqt ka din (YYYY-MM-DD) aur din ke minutes. */
export function localTime(date: Date, timeZone: string) {
  const parts = formatter(timeZone).formatToParts(date);
  const get = (type: string) =>
    parts.find((p) => p.type === type)?.value ?? '00';
  return {
    day: `${get('year')}-${get('month')}-${get('day')}`,
    minutes: Number(get('hour')) * 60 + Number(get('minute')),
  };
}

/** `@db.Date` value ko YYYY-MM-DD me badalta hai. */
export const dateKey = (date: Date) => date.toISOString().slice(0, 10);

const pad = (n: number) => String(n).padStart(2, '0');

export function isSunday(key: string): boolean {
  return new Date(`${key}T00:00:00Z`).getUTCDay() === 0;
}

/** Ek din ka status, sirf check-in aur check-out ke times se. */
export function statusFor(
  record: { checkInAt: Date; checkOutAt: Date | null },
  timeZone: string,
): DayStatus {
  if (record.checkOutAt) {
    const worked =
      (record.checkOutAt.getTime() - record.checkInAt.getTime()) / 60_000;
    if (worked < HALF_DAY_UNDER_MINUTES) return 'HALF_DAY';
  }
  return localTime(record.checkInAt, timeZone).minutes > LATE_AFTER_MINUTES
    ? 'LATE'
    : 'PRESENT';
}

/**
 * Mahine ke har din ka status, [today] tak. Record nahi hai to: Sunday =
 * week off, purana din = absent, aaj = abhi kuch nahi (check-in baaki hai).
 * [fromKey] (joining date) se pehle ke din count nahi hote.
 */
export function buildMonth(
  year: number,
  month: number,
  rows: AttendanceRow[],
  today: string,
  timeZone: string,
  fromKey: string,
): DayEntry[] {
  const byDate = new Map(rows.map((r) => [dateKey(r.date), r]));
  const daysInMonth = new Date(Date.UTC(year, month, 0)).getUTCDate();
  const entries: DayEntry[] = [];

  for (let d = 1; d <= daysInMonth; d++) {
    const key = `${year}-${pad(month)}-${pad(d)}`;
    if (key > today) break;
    if (key < fromKey) continue;

    const row = byDate.get(key);
    if (row) {
      entries.push({
        date: key,
        status: statusFor(row, timeZone),
        checkInAt: row.checkInAt,
        checkOutAt: row.checkOutAt,
      });
    } else if (isSunday(key)) {
      entries.push({ date: key, status: 'WEEK_OFF', checkInAt: null, checkOutAt: null });
    } else if (key < today) {
      entries.push({ date: key, status: 'ABSENT', checkInAt: null, checkOutAt: null });
    }
  }
  return entries;
}

export function summarize(entries: DayEntry[]) {
  let presentDays = 0;
  let lateDays = 0;
  let halfDays = 0;
  let absentDays = 0;
  let workedMinutes = 0;

  for (const e of entries) {
    if (e.status === 'PRESENT') presentDays++;
    else if (e.status === 'LATE') lateDays++;
    else if (e.status === 'HALF_DAY') halfDays++;
    else if (e.status === 'ABSENT') absentDays++;

    if (e.checkInAt && e.checkOutAt) {
      workedMinutes += Math.max(
        0,
        Math.round((e.checkOutAt.getTime() - e.checkInAt.getTime()) / 60_000),
      );
    }
  }
  return { presentDays, lateDays, halfDays, absentDays, workedMinutes };
}