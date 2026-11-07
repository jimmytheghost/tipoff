const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const source = fs.readFileSync('web/guide.js', 'utf8');
const code = source.slice(source.indexOf('function schedulePause'), source.indexOf('async function loadLeague'));
function context(fetch) {
  const ctx = vm.createContext({fetch, AbortController, DOMException, setTimeout, clearTimeout, Date});
  vm.runInContext(code, ctx);
  return ctx;
}
(async () => {
  let count = 0;
  const cached = {snapshot: {day: '2026-11-06'}, saved: true};
  let requested;
  let ctx = context(async url => {requested=url; count++; return {status:200, ok:true, json:async()=>cached};});
  assert.equal(await ctx.fetchSchedule('',new AbortController().signal),cached);
  assert.equal(count,1);
  assert.equal(requested,"/tipoff/schedule?");
  count=0;
  ctx = context(async () => ++count===1 ? {status:202,ok:true,json:async()=>({refreshing:true})} : {status:200,ok:true,json:async()=>cached});
  ctx.schedulePause=async()=>{};
  assert.equal(await ctx.fetchSchedule('',new AbortController().signal),cached);
  assert.equal(count,2);
  ctx=context(async()=>{});
  const controller = new AbortController();
  const pending=ctx.schedulePause(controller.signal);
  controller.abort();
  await assert.rejects(pending,{name:'AbortError'});
  ctx=context(async()=>({status:202,ok:true,json:async()=>({refreshing:true})}));
  ctx.schedulePause=async()=>{};
  let now=0; ctx.Date={now:()=>now+=100000};
  await assert.rejects(ctx.fetchSchedule('',new AbortController().signal),/timed out/);
  console.log('4 client loading tests executed, 4 passed');
})().catch(error=>{console.error(error); process.exitCode=1;});
