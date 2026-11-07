const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/guide.js', 'utf8');
const context = vm.createContext({});
vm.runInContext(source.slice(source.indexOf('const logoAliases'), source.indexOf('const networkLogos')), context);
let count = 0;
for (const [code, league, slug] of [
  ['GSW', 'nba', 'gs'], ['UTA', 'nba', 'utah'], ['JAC', 'nfl', 'jax'],
  ['NYL', 'wnba', 'ny'], ['TBL', 'nhl', 'tb'], ['COL', 'mlb', 'col'],
  ['WSN', 'mlb', 'wsh'], ['col', 'mlb', 'col'],
]) {
  assert.deepEqual(Array.from(context.teamLogoSources(code, league)), [
    `https://a.espncdn.com/i/teamlogos/${league}/500-dark/${slug}.png`,
    `https://a.espncdn.com/i/teamlogos/${league}/500/${slug}.png`,
  ]);
  count++;
}
for (const [id, slug] of [['115', 'col'], ['147', 'nyy'], ['120', 'wsh']]) {
  assert.deepEqual(Array.from(context.teamLogoSources(id, 'mlb')), [
    `https://a.espncdn.com/i/teamlogos/mlb/500-dark/${slug}.png`,
    `https://a.espncdn.com/i/teamlogos/mlb/500/${slug}.png`,
    `https://www.mlbstatic.com/team-logos/${id}.svg`,
  ]);
  count++;
}
assert.deepEqual(Array.from(context.teamLogoSources('999', 'mlb')), ['https://www.mlbstatic.com/team-logos/999.svg']);
count++;
for (const [code, league] of [['../COL', 'mlb'], ['COL', 'unknown'], [115, 'mlb']]) {
  assert.deepEqual(Array.from(context.teamLogoSources(code, league)), []);
  count++;
}
context.element = () => ({
  handlers: {}, removed: false,
  addEventListener(name, callback) { this.handlers[name] = callback; },
  remove() { this.removed = true; },
});
vm.runInContext(source.slice(source.indexOf('function mark('), source.indexOf('const teamLocations')), context);
const fallbacks = ['default.png', 'original.svg'];
const image = context.mark('dark.png', 'tipoff-team-logo', fallbacks);
assert.equal(image.src, 'dark.png');
image.handlers.error(); assert.equal(image.src, 'default.png'); assert.equal(image.removed, false);
image.handlers.error(); assert.equal(image.src, 'original.svg'); assert.equal(image.removed, false);
image.handlers.error(); assert.equal(image.removed, true);
assert.deepEqual(fallbacks, ['default.png', 'original.svg']);
count++;
const network = context.mark('network.svg', 'tipoff-network-logo');
network.handlers.error(); assert.equal(network.removed, true);
count++;
console.log(`${count} team-logo routing and fallback cases passed`);
