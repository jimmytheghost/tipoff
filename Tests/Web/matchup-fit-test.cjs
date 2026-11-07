const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/guide.js', 'utf8');
const context = vm.createContext({getComputedStyle: () => ({columnGap: '8px'})});
vm.runInContext(source.slice(source.indexOf('function fitMatchupNames('), source.indexOf('const matchupSizes')), context);
const rect = width => ({getBoundingClientRect: () => ({width})});
let width = 300;
const logos = [Object.assign(rect(22), {complete:true, naturalWidth:500}), Object.assign(rect(22), {complete:true, naturalWidth:500})];
const teams = [0,1].map(i => ({querySelector: selector => selector === '.tipoff-team-logo' ? logos[i] : rect(selector === '.tipoff-team-full' ? 80 + i*10 : 40 + i*5)}));
const classes = new Set();
const row = {isConnected:true, getBoundingClientRect:()=>({width}), querySelectorAll:()=>teams,
 querySelector: selector=>rect(selector === '.tipoff-matchup-separator' ? 14 : 0),
 classList:{toggle:(name,on)=>on?classes.add(name):classes.delete(name)}};
let count=0;
function expect(short, icons) {context.fitMatchupNames(row); assert.equal(classes.has('tipoff-matchup-short'),short);assert.equal(classes.has('tipoff-matchup-logos'),icons);count++;}
expect(false,false);
width=200;expect(true,false);
width=150;expect(true,true);
width=300;expect(false,false);
width=150;logos[0].complete=false;expect(true,false);
logos[0].complete=true;logos[0].naturalWidth=0;expect(true,false);
logos[0].naturalWidth=500;expect(true,true);
logos[0]=null;expect(true,false);
context.fitMatchupNames(null);
console.log(`${count} matchup sizing/resize/logo fallback cases passed`);
