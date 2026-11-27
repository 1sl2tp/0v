import test from 'node:test';
import assert from 'node:assert/strict';
import {callbackAction,missedCallPolicy,replyText} from '../references/callback-01-policy.mjs';
const e={id:'11111111-1111-4111-8111-111111111111',kind:'missed_call',source:'zalo_missed_call',direction:'incoming',accepted:false,conversationId:'room',contactId:'customer'};
const c={conversationId:'room',contactId:'customer',group:'KH',zaloLinked:true,serverEligible:true};
test('valid phone opens native tel; missing or invalid requests input; loading does not overwrite',()=>{
 assert.deepEqual(callbackAction('090 123 4567',true),{kind:'dial',href:'tel:0901234567'});
 assert.deepEqual(callbackAction('+84 901234567',true),{kind:'dial',href:'tel:+84901234567'});
 for(const p of ['',null,'123','tel:0901234567','0901234567;ext=1'])assert.equal(callbackAction(p,true).kind,'add_phone');
 assert.equal(callbackAction(null,false).kind,'wait');
});
test('only verified incoming missed event in correct room is visible',()=>{
 for(const v of [{...e,source:'text'},{...e,kind:'text',body:'Cuộc gọi nhỡ'},{...e,direction:'outgoing'},{...e,accepted:true},{...e,id:'bad'},{...e,contactId:'other'},{...e,conversationId:'other'}])assert.equal(missedCallPolicy(v,c).visible,false);
 assert.equal(missedCallPolicy(e,c).visible,true);
});
test('all linked Zalo users eligible regardless of group; repeated events generate same server dedupe key',()=>{
 const a=missedCallPolicy(e,c),b=missedCallPolicy({...e},{...c});
 assert.deepEqual(a,b);assert.equal(a.reply.body,replyText);
 assert.equal(a.reply.clientId,'0v:'+e.id);
 for(const group of ['KH','NCC','NV','CM','NHOM',null])assert.deepEqual(missedCallPolicy(e,{...c,group}).reply,a.reply);
 assert.equal(missedCallPolicy(e,{...c,zaloLinked:false}).reply,null);
 assert.equal(missedCallPolicy(e,{...c,zaloLinked:undefined}).reply,null);
 assert.equal(missedCallPolicy(e,{...c,serverEligible:false}).reply,null);
});
