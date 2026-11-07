const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/guide.js', 'utf8');
const code = source.slice(source.indexOf('function dayKey('), source.indexOf('function leagueHeader('));
const valid = ['2026-11-17', '2026-03-08', '2026-11-01', '2026-12-31', '2028-02-29'];
const invalid = ['', '2026-02-29', '2026-13-01', '2026-11-31', '17/11/2026'];
const originalZone = process.env.TZ;
let count = 0;
try {
  for (const zone of ['America/Denver', 'Pacific/Auckland']) {
    process.env.TZ = zone;
    const context = vm.createContext({});
    vm.runInContext(code, context);
    for (const value of valid) {
      const result = context.dateFromDayKey(value);
      assert.equal(context.dayKey(result), value, `${zone}: local day ${value}`);
      assert.equal(result.getHours(), 12, `${zone}: local noon ${value}`);
      count++;
    }
    for (const value of invalid) {
      assert.equal(context.dateFromDayKey(value), null, `${zone}: reject ${value}`);
      count++;
    }
  }
} finally {
  if (originalZone === undefined) delete process.env.TZ;
  else process.env.TZ = originalZone;
}
console.log(`${count} date picker cases passed across two time zones`);
