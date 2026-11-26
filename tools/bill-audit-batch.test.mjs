import assert from 'node:assert/strict';
import {auditBatch} from './bill-audit-batch.mjs';
const rows=Array.from({length:12},(_,i)=>({id:String(i).padStart(2,'0'),assetId:'a'+i,hash:i.toString(16).padStart(64,'0'),status:i===11?'review':'received'}));
const map=new Map(),links=new Map(),seen=[];
const opts={rows,version:'fixture-v1',checkpoint:async k=>map.get(k),save:async x=>{assert(['done','terminal','retry'].includes(x.state));map.set(x.key,x)},link:async x=>{assert(['linked','linked_terminal'].includes(x.state));links.set(JSON.stringify([x.key,x.id,x.assetId]),x)},read:async x=>{seen.push(x.id);return {originalVerified:true,fields:{amount:null}}}};
assert.equal((await auditBatch(opts)).calls,10);
assert.equal(seen[0],'11');
assert.equal((await auditBatch(opts)).calls,2);
assert.equal((await auditBatch(opts)).calls,0);
const duplicate={...rows[0],id:'duplicate',assetId:'other'};
assert.equal((await auditBatch({...opts,rows:[duplicate]})).calls,0);
const quota=await auditBatch({...opts,version:'quota',now:100,read:async()=>{throw Object.assign(Error(),{status:429,retryAfterMs:120000})}});
assert.equal(quota.calls,1);assert.equal(quota.blockedUntil,120100);
assert.equal((await auditBatch({...opts,version:'quota',now:101})).calls,0);


const bad=await auditBatch({...opts,rows:[{id:'bad',assetId:'a',hash:'bad'}]});assert.equal(bad.invalid,1);assert.equal(bad.calls,0);
const denied=await auditBatch({...opts,version:'denied',rows:[rows[0]],read:async()=>({originalVerified:false})});assert.equal(denied.calls,1);
assert.equal((await auditBatch({...opts,version:'denied',rows:[rows[0]]})).terminal,1);
assert.equal((await auditBatch({...opts,version:'denied',rows:[duplicate]})).calls,0);
assert.equal((await auditBatch({...opts,version:'denied',rows:[rows[0],duplicate]})).calls,0);
assert.equal(map.get(JSON.stringify(['denied',rows[0].hash])).state,'terminal');
assert.equal(links.get(JSON.stringify([JSON.stringify(['denied',rows[0].hash]),duplicate.id,duplicate.assetId])).state,'linked_terminal');
assert.equal(map.get(JSON.stringify(['fixture-v1',rows[0].hash])).state,'done');

let writes=0;await assert.rejects(auditBatch({...opts,version:'disk-failure',save:async()=>{writes++;throw Error('disk');}}),/checkpoint_write_failed/);assert.equal(writes,1);

console.log('synthetic audit batch checks passed');
