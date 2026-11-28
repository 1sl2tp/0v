// MOBILE-FORWARD-01: isolated reference contract. No network, DOM, or credentials.
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const digest=/^[0-9a-f]{64}$/i;
const validId=x=>typeof x==='string'&&uuid.test(x);
const validHash=x=>typeof x==='string'&&digest.test(x);
const fail=reason=>{throw new Error(reason)};
const identity=x=>x.sha256.toLowerCase()+':'+x.sizeBytes;
const eligible=x=>x&&x.kind==='image'&&!x.deleted;
const verified=x=>validId(x.assetId)&&validHash(x.sha256)&&Number.isSafeInteger(x.sizeBytes)&&x.sizeBytes>0;
const order=(a,b)=>a.at-b.at||a.messageId.localeCompare(b.messageId)||a.sortIndex-b.sortIndex||a.assetId.localeCompare(b.assetId);
export function planForward({sourceRoom,destinationRoom,fromMs,toMs,source,destination,sourceComplete,destinationComplete}={}){
 if(!validId(sourceRoom)||!validId(destinationRoom)||sourceRoom===destinationRoom)fail('invalid_room');
 if(!Number.isSafeInteger(fromMs)||!Number.isSafeInteger(toMs)||fromMs>toMs)fail('invalid_window');
 if(sourceComplete!==true||destinationComplete!==true||!Array.isArray(source)||!Array.isArray(destination))fail('incomplete_inventory');
 const src=[],seen=new Set(),items=[],skipped=[];
 for(const a of source){
  if(!eligible(a))continue;
  if(a.roomId!==sourceRoom||!Number.isSafeInteger(a.at))fail('invalid_source_scope');
  if(a.at<fromMs||a.at>toMs)continue;
  if(!verified(a)||!validId(a.messageId)||!Number.isSafeInteger(a.sortIndex)||a.sortIndex<0)fail('unverified_source_image');
  src.push(a);
 }
 for(const a of destination){
  if(!eligible(a))continue;
  if(a.roomId!==destinationRoom||!verified(a))fail('unverified_destination_image');
  seen.add(identity(a));
 }
 for(const a of src.sort(order)){
  const key=identity(a);
  if(seen.has(key)){skipped.push(a.assetId);continue}
  seen.add(key);
  items.push(Object.freeze({assetId:a.assetId,sourceMessageId:a.messageId,sha256:a.sha256.toLowerCase(),sizeBytes:a.sizeBytes,clientId:'0v:forward:'+destinationRoom+':'+a.assetId}));
 }
 return Object.freeze({sourceRoom,destinationRoom,fromMs,toMs,items:Object.freeze(items),skipped:Object.freeze(skipped)});
}
const signature=p=>JSON.stringify([p.sourceRoom,p.destinationRoom,p.fromMs,p.toMs,p.items,p.skipped]);
// The adapter must use the authenticated official media owner, not a direct insert.
// A rejected/uncertain send halts the batch. Reconcile server state before a new preview.
export async function executeForward({preview,readInventory,sendOfficialImage,isCurrent,onProgress=()=>{}}={}){
 if(!preview||typeof readInventory!=='function'||typeof sendOfficialImage!=='function'||typeof isCurrent!=='function')fail('official_adapter_required');
 if(!isCurrent())fail('session_changed');
 const current=planForward(await readInventory());
 if(!isCurrent())fail('session_changed');
 if(signature(preview)!==signature(current))fail('preview_changed');
 let confirmed=0,skippedDuringSend=0;
 for(const item of current.items){
  if(!isCurrent())return {state:'stopped',confirmed,skippedDuringSend,reason:'session_changed'};
  try{
   const ack=await sendOfficialImage(Object.freeze({...item,sourceRoom:current.sourceRoom,destinationRoom:current.destinationRoom}));
   if(!ack||ack.clientId!==item.clientId||ack.destinationRoom!==current.destinationRoom||ack.sha256!==item.sha256||ack.sizeBytes!==item.sizeBytes)fail('unverified_ack');
   if(ack.state==='already_present'){
    // Authorized canonical duplicate receipt, never a new send ACK.
    if(ack.messageId!=null)fail('unexpected_duplicate_message');
    skippedDuringSend++;
   }else if(ack.state==='committed'&&validId(ack.messageId)){confirmed++}
   else fail('unverified_ack');
  }catch{return {state:'reconcile_required',confirmed,skippedDuringSend,uncertainClientId:item.clientId}}
  if(!isCurrent())return {state:'stopped',confirmed,skippedDuringSend,reason:'session_changed'};
  try{onProgress({confirmed,skippedDuringSend,total:current.items.length})}catch{/* UI callback cannot cause replay */}
 }
 return {state:'confirmed',confirmed,skippedDuringSend};
}
