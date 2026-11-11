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

  const seen = [];
  let attempts = 0;
  ctx = context(async () => ({status:200, ok:true, json:async()=>++attempts === 1
    ? {...cached, refreshing:true} : {snapshot:{day:'2026-11-06',fresh:true},saved:false,refreshing:false}}));
  ctx.schedulePause=async()=>{};
  const fresh = await ctx.fetchSchedule('',new AbortController().signal, value=>seen.push(value));
  assert.equal(seen.length,2);
  assert.equal(seen[0].saved,true);
  assert.equal(fresh.snapshot.fresh,true);
  attempts=0;
  ctx=context(async()=>{if (++attempts===2) throw new Error('offline');return {status:200,ok:true,json:async()=>({...cached,refreshing:true})};});
  ctx.schedulePause=async()=>{};
  let displayed;
  await assert.rejects(ctx.fetchSchedule('',new AbortController().signal,value=>displayed=value),/offline/);
  assert.equal(displayed.snapshot.day,'2026-11-06');
  console.log('6 client loading tests executed, 6 passed');
})().catch(error=>{console.error(error); process.exitCode=1;});
