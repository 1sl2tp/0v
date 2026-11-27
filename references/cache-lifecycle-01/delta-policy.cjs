// Candidate transport policy. No DOM, storage, auth or keyboard side effects.
'use strict';
const revOK=x=>typeof x==='string'&&/^[a-f0-9]{64}$/.test(x);
function applyWindow(previous,section,max){
  if(!section||!section.revisions||Array.isArray(section.revisions)||typeof section.revisions!=='object'||!Array.isArray(section.upserts))throw Error('invalid delta');
  const ids=Object.keys(section.revisions);if(ids.length>max||section.upserts.length>ids.length)throw Error('invalid bounds');
  const next=new Map(),changed=new Map();
  for(const x of section.upserts){if(!x||typeof x.id!=='string'||changed.has(x.id)||x.row?.id!==x.id||!revOK(x.rev)||section.revisions[x.id]!==x.rev)throw Error('invalid upsert');changed.set(x.id,x)}
  for(const id of ids){const rev=section.revisions[id];if(!revOK(rev))throw Error('invalid revision');const item=changed.get(id)||previous.get(id);if(item?.rev!==rev||item.row?.id!==id)throw Error('missing delta row');next.set(id,item)}
  return next;
}
function apply(previous,response,{accountId,room,limit}){
  if(response?.account_id!==accountId||response.room!==room||response.limit!==limit||!Number.isInteger(limit)||limit<1||limit>100)throw Error('scope mismatch');
  if(previous&&(previous.accountId!==accountId||previous.room!==room))throw Error('previous scope mismatch');
  const messages=applyWindow(previous?.messages||new Map(),response.messages,limit);
  const assets=applyWindow(previous?.assets||new Map(),response.assets,500);
  for(const {row} of messages.values())if(row.conversation_id!==room)throw Error('message scope');
  for(const {row} of assets.values())if(!messages.has(row.message_id))throw Error('asset scope');
  return {accountId,room,limit,messages,assets};
}
function known(state){const revisions=m=>Object.fromEntries([...m].map(([id,x])=>[id,x.rev]));return {p_known_messages:revisions(state?.messages||new Map()),p_known_assets:revisions(state?.assets||new Map())}}
function nextLimit(limit){return Math.min(100,limit+20)}
module.exports={apply,known,nextLimit};
