const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/guide.js', 'utf8');
const context = vm.createContext({});
vm.runInContext(source.slice(source.indexOf('function scheduleStatusText('), source.indexOf('function updateSourceStatus(')), context);
const stamp = 'Nov 7, 2026, 2:30 PM';
const cases = [
  [[], '0 loaded - 5 loading'],
  [['saved', 'loading'], '1 loaded - 4 loading'],
  [Array(5).fill('updated'), `All schedules loaded ${stamp}`],
  [Array(5).fill('saved'), `All schedules loaded ${stamp}`],
  [['saved', 'updated', 'saved', 'updated', 'unavailable'], '4 loaded - 1 error'],
  [['unavailable', 'unavailable', 'updated', 'loading', 'loading'], '1 loaded - 2 errors - 2 loading'],
  [Array(5).fill('unavailable'), '0 loaded - 5 errors'],
];
for (const [states, expected] of cases) assert.equal(context.scheduleStatusText(states, stamp), expected);
assert.match(fs.readFileSync('web/index.html', 'utf8'), /<details class="tipoff-schedule-status">/);
console.log('7 schedule-status summary cases and collapsed-default markup check passed');

const alertCases = [
  [[['nba', 'updated'], ['nfl', 'loading']], ''],
  [[['nba', 'saved'], ['nfl', 'saved']], 'Saved listings: NBA, NFL'],
  [[['nba', 'saved'], ['wnba', 'unavailable']], 'Unavailable: WNBA · Saved listings: NBA'],
];
for (const [states, expected] of alertCases) assert.equal(context.scheduleAlertText(new Map(states)), expected);
console.log('3 schedule notice cases passed');
