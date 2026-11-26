// P05.1: offline audit orchestration only. No network, storage or finance adapter.
export async function auditBatch({rows,version,checkpoint,read,save,limit=10,now=Date.now()}) {
 if(!Number.isInteger(limit)||limit<1||limit>10||!version||!Array.isArray(rows)) throw Error('invalid scope');
 const priority=r=>r.status==='review'?0:r.missing?1:r.status==='received'?2:3;
 const sorted=[...rows].sort((a,b)=>priority(a)-priority(b)||a.id.localeCompare(b.id));
 let calls=0,linked=0,invalid=0,terminal=0,blockedUntil=null;
 for(const r of sorted){
  if(!r.id||!r.assetId||!r.hash||!/^[a-f0-9]{64}$/i.test(r.hash)){invalid++;continue;}
  const key=JSON.stringify([version,r.hash.toLowerCase()]);
  const prior=await checkpoint(key);
  if(prior?.state==='done'){await save({id:r.id,assetId:r.assetId,key,state:'linked',result:prior.result});linked++;continue}
  if(prior?.state==='terminal'){terminal++;await save({id:r.id,assetId:r.assetId,key,state:'linked_terminal',category:prior.category});continue;}
  if(prior?.retryAt>now){blockedUntil=prior.retryAt;break}
  if(calls>=limit)break;
  calls++;
  try{
   // Adapter must independently authorize and verify original bytes against hash.
   const result=await read({id:r.id,assetId:r.assetId,hash:r.hash});
   if(!result||result.originalVerified!==true)throw Object.assign(Error('unverified original'),{status:422});
   await save({id:r.id,assetId:r.assetId,key,state:'done',result});
  }catch(e){
   const attempts=(prior?.attempts??0)+1;
   const retry=e.status===429||e.status===503;
   const retryAt=now+Math.max(60000,Number.isFinite(e.retryAfterMs)?e.retryAfterMs:0)*2**(attempts-1);
   await save({id:r.id,assetId:r.assetId,key,state:retry&&attempts<3?'retry':'terminal',attempts,retryAt,category:e.status===429?'quota':'transport_or_access'});
   if(retry){blockedUntil=retryAt;break}
  }
 }
 return {calls,linked,invalid,terminal,blockedUntil,canPost:false};
}
