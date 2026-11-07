const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/guide.js', 'utf8');
const context = vm.createContext({});
vm.runInContext(source.slice(source.indexOf('const nonFeaturedNetworks'), source.indexOf('function gameRow')), context);
const b = (name, category = 'Regional') => ({ name, category });
const cases = [
  ['national networks take priority', 'nba', [b('Altitude', 'Altitude guide'), b('ESPN', 'National'), b('ABC', 'National')], ['ESPN', 'ABC']],
  ['matched Altitude guide takes priority', 'nba', [b('ALT'), b('Altitude 2', 'Altitude guide'), b('Altitude+', 'Altitude guide'), b('KTVD-20^')], ['Altitude 2']],
  ['NBA TV alone does not displace Altitude', 'nba', [b('NBA TV', 'National'), b('Altitude', 'Altitude guide')], ['Altitude']],
  ['NHL Altitude precedes other regional feeds', 'nhl', [b('DSN'), b('ALT')], ['ALT']],
  ['footnotes are retained', 'nba', [b('Altitude^', 'Altitude guide'), b('Altitude+')], ['Altitude^']],
  ['radio is excluded', 'mlb', [b('Radio Station', 'Radio'), b('Local TV')], ['Local TV']],
  ['unknown source names remain intact', 'mlb', [b('Unfamiliar TV'), b('Another TV')], ['Unfamiliar TV']],
  ['empty inventory stays empty', 'nba', [], []],
  ['radio-only inventory stays empty', 'nfl', [b('Radio Station', 'Radio')], []],
  ['composite names are not interpreted', 'nba', [b('KUSA-TV (9NEWS)'), b('ALT2/KTVD')], ['KUSA-TV (9NEWS)']],
];
for (const [name, league, broadcasts, expected] of cases) {
  const before = JSON.stringify(broadcasts);
  const actual = context.compactBroadcasts(broadcasts, league);
  assert.deepEqual(Array.from(actual, item => item.name), expected, name);
  assert.equal(JSON.stringify(broadcasts), before, `${name}: source unchanged`);
  console.log(`PASS ${name}`);
}
console.log(`${cases.length} compact Following cases passed`);
