const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/guide.js', 'utf8');
const context = vm.createContext({});
vm.runInContext(source.slice(source.indexOf('const teamLocations'), source.indexOf('function team(')), context);
const cases = [
  ['NBA nickname receives location', 'Nuggets', 'nba', 'Denver Nuggets'],
  ['Multiword nickname receives location', 'Trail Blazers', 'nba', 'Portland Trail Blazers'],
  ['Existing full source name is preserved', 'Los Angeles Clippers', 'nba', 'Los Angeles Clippers'],
  ['Unknown source name is preserved', 'Future Club', 'nba', 'Future Club'],
  ['Lookup is scoped to NBA', 'Kings', 'nhl', 'Kings'],
  ['Whitespace and case in a known nickname', '  nuggets ', 'nba', 'Denver Nuggets'],
];
for (const [label, name, league, expected] of cases) {
  assert.equal(context.fullTeamName(name, league), expected, label);
  console.log(`PASS ${label}`);
}
console.log(`${cases.length} team display-name cases passed`);
