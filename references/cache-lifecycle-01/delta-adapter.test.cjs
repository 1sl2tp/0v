const assert=require('node:assert/strict');
const {test}=require('node:test');
const fs=require('node:fs');
const html=fs.readFileSync('index.html','utf8');
const policy=fs.readFileSync('references/cache-lifecycle-01/delta-policy.cjs','utf8');
const src=policy.slice(policy.indexOf('const revOK='),policy.indexOf('module.exports='));
assert(html.includes(src),'Runtime uses exact tested policy');
const a=html.indexOf(' function deltaSerialize('),b=html.indexOf(' function liveSnapshotKey(',a);
assert(a>=0&&b>a);
const accountId='00000000-0000-4000-8000-000000000003',room='00000000-0000-4000-8000-000000000001';
function fixture(){
 const owner={accountId},calls=[],state={scope:owner,cached:null,missing:false,deny:false,legacy:0};const rev='a'.repeat(64);
 const create=new Function('state','calls','owner','room','rev',src+';const ThreadDeltaPolicy={apply,known,nextLimit};'+
 'let deltaEnabled=true,deltaUnavailable=false;const deltaStates=new Map(),deltaLimits=new Map(),deltaFlights=new Map();const ThreadBillAutoPolicy={uuid:()=>true};let scope=owner;function getLiveSnapshot(){return state.cached}'+
 'async function rpc(name,args){calls.push(args);if(state.missing)throw Object.assign(Error("missing"),{code:"PGRST202"});if(state.deny)throw Object.assign(Error("denied"),{code:"42501"});const all=Array.from({length:Math.min(50,args.p_limit)},(_,i)=>({id:"m"+i,conversation_id:room,body:"fixture",sender_account_id:owner.accountId,created_at:"2026-01-01T00:00:00Z"}));return {account_id:owner.accountId,room,limit:args.p_limit,available:50,messages:{revisions:Object.fromEntries(all.map(x=>[x.id,rev])),upserts:all.filter(x=>args.p_known_messages[x.id]!==rev).map(row=>({id:row.id,rev,row}))},assets:{revisions:{},upserts:[]}}}'+html.slice(a,b)+
 ';return {read:()=>readDeltaThread(owner,room,async()=>{state.legacy++;return {messages:[{id:"legacy"}]}}),save:()=>deltaSerialize(deltaStates.get(room)),limits:deltaLimits,assets:msgs=>deltaAssets(room,msgs),reset:()=>deltaStates.clear()}');
 return {state,calls,api:create(state,calls,owner,room,rev)};
}
test('integrated read adapter coalesces, reuses revisions on F5 and grows history',async()=>{const f=fixture();const [first,joined]=await Promise.all([f.api.read(),f.api.read()]);assert.equal(first.length,30);assert.deepEqual(joined,first);assert.equal(f.calls.length,1);assert.deepEqual(f.api.assets(first),[]);f.state.cached={msgs:first,delta:f.api.save()};f.api.reset();const restored=await f.api.read();assert.equal(restored.length,30);assert.equal(Object.keys(f.calls[1].p_known_messages).length,30);f.api.limits.set(room,50);assert.equal((await f.api.read()).length,50);assert.equal(f.calls[2].p_limit,50)});
test('missing RPC falls back once; authorization errors never fall back',async()=>{const f=fixture();f.state.missing=true;assert.equal((await f.api.read())[0].id,'legacy');assert.equal((await f.api.read())[0].id,'legacy');assert.equal(f.calls.length,1);assert.equal(f.state.legacy,2);const d=fixture();d.state.deny=true;await assert.rejects(d.api.read(),/denied/);assert.equal(d.state.legacy,0)});
