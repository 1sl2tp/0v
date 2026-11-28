import test from 'node:test';
import assert from 'node:assert/strict';
import {planForward,executeForward} from '../references/mobile-forward-01-policy.mjs';
const id=n=>'00000000-0000-4000-8000-'+String(n).padStart(12,'0');
const sourceRoom=id(1),destinationRoom=id(2),hash=n=>String(n).padStart(64,'0');
const image=(n,h=n,at=n,roomId=sourceRoom)=>({assetId:id(n+100),messageId:id(n+200),kind:'image',sha256:hash(h),sizeBytes:100,at,sortIndex:0,roomId});
const input=(extra={})=>({sourceRoom,destinationRoom,fromMs:0,toMs:1000,sourceComplete:true,destinationComplete:true,source:[image(3),image(1),image(2,1),image(4)],destination:[image(9,3,9,destinationRoom)],...extra});
const ack=(x,n=88)=>({clientId:x.clientId,destinationRoom:x.destinationRoom,messageId:id(n),sha256:x.sha256,sizeBytes:x.sizeBytes,state:'committed'});
test('sort and skip exact SHA-256/size duplicates in source and destination',()=>{
 const p=planForward(input());assert.deepEqual(p.items.map(x=>x.assetId),[id(101),id(104)]);assert.deepEqual(p.skipped,[id(102),id(103)]);assert(Object.isFrozen(p.items));
});
test('same time sorts by message, media sort index, asset; filter outside window and non-images',()=>{
 const a={...image(6,6,10),messageId:id(501),sortIndex:2},b={...image(5,5,10),messageId:id(501),sortIndex:1};
 const p=planForward(input({fromMs:5,toMs:10,destination:[],source:[a,b,image(7,7,4),{...image(8,8,7),kind:'file'},{...image(9,9,8),deleted:true}]}));
 assert.deepEqual(p.items.map(x=>x.assetId),[b.assetId,a.assetId]);
});
test('refuse incomplete inventory, unverified hash, wrong room, same room',()=>{
 for(const extra of [{sourceComplete:false},{destinationComplete:false},{source:[{...image(1),sha256:null}]},{destination:[image(1)]},{destinationRoom:sourceRoom},{source:[image(1,1,1,destinationRoom)]}])assert.throws(()=>planForward(input(extra)));
});
test('sequential official sends, stable keys, confirmed progress only',async()=>{
 const data=input(),preview=planForward(data),sent=[],progress=[];
 const result=await executeForward({preview,readInventory:async()=>data,isCurrent:()=>true,sendOfficialImage:async x=>{sent.push(x.assetId);return ack(x)},onProgress:x=>progress.push(x.confirmed)});
 assert.deepEqual(sent,preview.items.map(x=>x.assetId));assert.deepEqual(progress,[1,2]);assert.deepEqual(result,{state:'confirmed',confirmed:2,skippedDuringSend:0});
 assert.equal(planForward(data).items[0].clientId,preview.items[0].clientId);
});
test('changed preview requires new review before any write',async()=>{
 const data=input();let calls=0;
 await assert.rejects(executeForward({preview:planForward(data),readInventory:async()=>input({destination:[]}),isCurrent:()=>true,sendOfficialImage:async()=>{calls++}}),/preview_changed/);assert.equal(calls,0);
});
test('uncertain ACK stops immediately and never blindly retries',async()=>{
 const data=input(),preview=planForward(data);let calls=0;
 const result=await executeForward({preview,readInventory:async()=>data,isCurrent:()=>true,sendOfficialImage:async()=>{calls++;throw Error('network')}});
 assert.equal(calls,1);assert.deepEqual(result,{state:'reconcile_required',confirmed:0,skippedDuringSend:0,uncertainClientId:preview.items[0].clientId});
});
test('malformed ACK is not a success; account change stops later sends',async()=>{
 const data=input(),preview=planForward(data);let live=true,calls=0;
 const wrong=await executeForward({preview,readInventory:async()=>data,isCurrent:()=>true,sendOfficialImage:async()=>({})});assert.equal(wrong.state,'reconcile_required');
 const stopped=await executeForward({preview,readInventory:async()=>data,isCurrent:()=>live,sendOfficialImage:async x=>{calls++;live=false;return ack(x)}});
 assert.equal(calls,1);assert.deepEqual(stopped,{state:'stopped',confirmed:1,skippedDuringSend:0,reason:'session_changed'});
});

test('concurrent already-present receipt is skipped, never counted as newly sent',async()=>{
 const data=input(),preview=planForward(data);let calls=0;const progress=[];
 const result=await executeForward({preview,readInventory:async()=>data,isCurrent:()=>true,sendOfficialImage:async x=>++calls===1?{...ack(x),state:'already_present',messageId:null}:ack(x),onProgress:x=>progress.push([x.confirmed,x.skippedDuringSend])});
 assert.deepEqual(result,{state:'confirmed',confirmed:1,skippedDuringSend:1});assert.deepEqual(progress,[[0,1],[1,1]]);
});
test('reject mismatched byte count, missing committed state, and duplicate receipt with message id',async()=>{
 const data=input(),preview=planForward(data);
 for(const patch of [{sizeBytes:999},{state:undefined},{state:'already_present'}]){
  let calls=0;const result=await executeForward({preview,readInventory:async()=>data,isCurrent:()=>true,sendOfficialImage:async x=>{calls++;return {...ack(x),...patch}}});
  assert.equal(result.state,'reconcile_required');assert.equal(result.confirmed,0);assert.equal(calls,1);
 }
});
