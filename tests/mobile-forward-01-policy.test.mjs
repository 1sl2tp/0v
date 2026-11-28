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

test('isolated canonical client identity vectors agree with MEDIA-SEND-02; lab key stays correlation only',async()=>{
 // Test-only RFC 9562 UUIDv5 computation; no application adapter or network.
 const {createHash}=await import('node:crypto');
 const ns=Buffer.from('ab9e85c7a8f14b8496aad3aa7ce5b4d8','hex');
 function v5(name){const b=createHash('sha1').update(ns).update(name,'utf8').digest().subarray(0,16);b[6]=(b[6]&15)|80;b[8]=(b[8]&63)|128;const h=b.toString('hex');return [h.slice(0,8),h.slice(8,12),h.slice(12,16),h.slice(16,20),h.slice(20)].join('-')}
 const vectors=[
 [21,2,1,100,'ec41e4fd-a38d-5b22-8d13-43faa6813c5d','def7d78f-c874-52e7-9486-e00e1aa7f087'],
 [22,2,1,100,'767036da-c7ec-5d60-ba81-adfc645078ea','6f93e758-e55a-5fda-8e40-33045e30458d'],
 [21,3,1,100,'1c970cae-454b-55e4-9c86-28fec25498c7','d97bd0e2-b054-5da5-b686-a7a33c64ed38'],
 [21,2,4,100,'2d8c1415-b022-5e0f-8a4f-aaf15a7c194d','a4354c8d-657f-50ea-97a7-bd5bd8bbfb08'],
 [21,2,1,101,'aee147fc-8f40-5e66-87ca-393cf09be055','f24dc62c-cf7a-5685-80a1-a3294ca2262e']];
 for(const [actor,room,h,size,client,asset] of vectors){
  const name=[id(actor),id(room),hash(h),size].join(':');
  assert.equal('0v:'+v5('client:'+name),'0v:'+client);
  assert.equal(v5('asset:'+name),asset);
 }
 const item=planForward(input()).items[0];
 assert.equal(item.sha256,hash(1));
 assert.equal(item.sizeBytes,100);
 assert.notEqual(item.clientId,'0v:'+vectors[0][4]);
 // The lab correlation key must never be mistaken for a canonical receipt key.
 assert.match(item.clientId,/^0v:forward:/);
});
