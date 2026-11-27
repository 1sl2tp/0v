// Pure CALLBACK-01 policy. No transport, DOM, storage or production writes.
const sources=new Set(['zalo_missed_call','v21_call','guest_invite']);
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export const replyText='Em sẽ gọi lại ngay ạ.';
export function normalizePhone(value){
 const s=String(value??'').trim().replace(/[\s().-]/g,'');
 return /^\+?[0-9]{9,15}$/.test(s)?s:null;
}
export function callbackAction(phone,loaded){
 if(loaded!==true)return {kind:'wait'};
 const number=normalizePhone(phone);
 return number?{kind:'dial',href:'tel:'+number}:{kind:'add_phone'};
}
export function missedCallPolicy(event,context){
 // Adapter must construct this event from trusted, persisted server metadata;
 // never from arbitrary message body or an optimistic browser object.
 if(!event||!context||!sources.has(event.source)||event.kind!=='missed_call'||
 event.direction!=='incoming'||event.accepted!==false||!uuid.test(event.id??'')||
 event.conversationId!==context.conversationId||event.contactId!==context.contactId)
 return {visible:false,reply:null};
 const reply=context.group==='KH'&&context.serverEligible===true
 ?{clientId:'0v:'+event.id.toLowerCase(),body:replyText,contactId:event.contactId}:null;
 return {visible:true,reply};
}
