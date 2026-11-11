const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/guide.js','utf8');
function node() {
  return {textContent:'',children:[],hidden:false,
    append(...items){this.children.push(...items);},
    replaceChildren(...items){this.children=items;},
    querySelectorAll(){return [];},
    querySelector(){return null;},
    get childElementCount(){return this.children.length;}
  };
}
const national={group:node(),title:node(),games:node(),gameCount:node()};
const section={section:node(),title:node(),gameCount:node(),status:node(),results:node(),national};
const ctx=vm.createContext({
  sections:new Map([['nba',section]]),followedTeams:new Map(),zone:'America/Denver',
  stampFormat:{format:date=>date.toISOString()},matchupSizes:{unobserve(){}},
  element:()=>node(),gameRow:()=>node(),isNationalBroadcast:()=>false,
  updateHighlightHeadings(){},resetSummary(value){value.group.hidden=true;value.games.replaceChildren();},
  updateSourceStatus(id,node,state,text){node.textContent=text;node.state=state;},
  URLSearchParams,fetchSchedule:undefined
});
vm.runInContext(source.slice(source.indexOf('const rememberedSchedules'),source.indexOf('async function loadDay')),ctx);
const snapshot={day:'2026-11-10',timeZone:'America/Denver',source:'Fixture',fetchedAt:'2026-11-10T10:00:00Z',
 games:[{broadcasts:[],awayCode:'BOS',homeCode:'PHI'}]};
(async()=>{
 const signal=new AbortController().signal;
 ctx.fetchSchedule=async(p,s,show)=>{const value={snapshot,saved:false};show(value);return value;};
 await ctx.loadLeague('nba',snapshot.day,signal);
 assert.equal(section.gameCount.textContent,'1 game');
 ctx.fetchSchedule=async()=>{throw new Error('offline');};
 await ctx.loadLeague('nba',snapshot.day,signal);
 assert.equal(section.gameCount.textContent,'1 game');
 assert.match(section.status.textContent,/Saved listings 2026-11-10T10:00:00.000Z/);
 assert.match(section.status.textContent,/Refresh failed/);
 assert.doesNotMatch(section.status.textContent,/Refreshing/);
 await ctx.loadLeague('nba','2026-11-11',signal);
 assert.equal(section.status.state,'unavailable');
 assert.equal(section.gameCount.textContent,'');
 ctx.fetchSchedule=async(p,s,show)=>{show({snapshot:{...snapshot,games:null},saved:false});};
 await ctx.loadLeague('nba',snapshot.day,signal);
 assert.equal(section.gameCount.textContent,'1 game');
 ctx.fetchSchedule=async(p,s,show)=>{show({snapshot:{...snapshot,fetchedAt:'2026-11-10T11:00:00Z',games:[]},saved:false});return {snapshot};};
 await ctx.loadLeague('nba',snapshot.day,signal);
 assert.equal(section.gameCount.textContent,'0 games');
 assert.match(section.status.textContent,/11:00:00/);
 console.log('5 retained-schedule scenarios passed: initial, offline, isolated date, malformed, fresh replacement');
})().catch(error=>{console.error(error);process.exitCode=1;});
