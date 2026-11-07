const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/guide.js', 'utf8');
const code = source.slice(source.indexOf('function dayKey('), source.indexOf('function leagueHeader('));
const originalZone = process.env.TZ;
let count = 0;
try {
  for (const zone of ['America/Denver', 'Pacific/Auckland']) {
    process.env.TZ = zone;
    const context = vm.createContext({});
    vm.runInContext(code, context);
    for (const [month, first, last] of [
      ['2026-11-07', '2026-11-01', '2026-12-12'],
      ['2026-03-08', '2026-03-01', '2026-04-11'],
      ['2028-02-29', '2028-01-30', '2028-03-11'],
      ['2026-12-31', '2026-11-29', '2027-01-09'],
    ]) {
      const days = context.calendarDaysForMonth(context.dateFromDayKey(month));
      assert.equal(days.length, 42);
      assert.equal(context.dayKey(days[0]), first);
      assert.equal(context.dayKey(days[41]), last);
      assert.equal(days[0].getDay(), 0);
      assert.equal(new Set(days.map(context.dayKey)).size, 42);
      for (let i = 0; i < days.length; i++) {
        assert.equal(days[i].getHours(), 12);
        assert.equal(days[i].getDay(), i % 7);
      }
      count++;
    }
    for (const [day, offset, expected] of [
      ['2026-01-31', 1, '2026-02-28'],
      ['2028-01-31', 1, '2028-02-29'],
      ['2028-02-29', 12, '2029-02-28'],
      ['2026-08-31', 1, '2026-09-30'],
      ['2026-01-31', -1, '2025-12-31'],
    ]) {
      const result = context.shiftCalendarMonth(context.dateFromDayKey(day), offset);
      assert.equal(context.dayKey(result), expected);
      assert.equal(result.getHours(), 12);
      count++;
    }
  }
} finally {
  if (originalZone === undefined) delete process.env.TZ;
  else process.env.TZ = originalZone;
}
console.log(`${count} calendar grid/month navigation cases passed across two time zones`);
