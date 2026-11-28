import {planForward,executeForward} from './mobile-forward-01-policy.mjs';
// Isolated lab adapter. No production IDs, SDK, credentials or network calls.
const id=n=>'00000000-0000-4000-8000-'+String(n).padStart(12,'0');
const roomA=id(1),roomB=id(2),roomC=id(3);
const rooms=[{id:roomA,name:'Nguồn mẫu A'},{id:roomB,name:'Báo giá mẫu'},{id:roomC,name:'Hội thoại mẫu B'}];
const hash=n=>n.toString(16).padStart(64,'0');
const base=Date.parse('2026-11-28T08:00:00+07:00');
const image=(n,h,room,at)=>({assetId:id(n+1000),messageId:id(n+2000),roomId:room,kind:'image',sha256:hash(h),sizeBytes:1000,at,sortIndex:0});
const records=new Map([[roomA,Array.from({length:54},(_,i)=>image(i+1,i===53?1:i+1,roomA,base+(i+1)*1000))],[roomB,Array.from({length:9},(_,i)=>image(100+i,i+2,roomB,base))],[roomC,[]]]);
const el=id=>document.getElementById(id);
const source=el('source'),destination=el('destination'),from=el('from'),to=el('to'),status=el('status'),send=el('send'),stop=el('stop'),review=el('review'),progress=el('progress');
const fields=[source,destination,from,to,el('preview')];
for(const s of [source,destination])for(const room of rooms){const opt=document.createElement('option');opt.value=room.id;opt.textContent=room.name;s.append(opt)}
destination.value=roomB;
let preview=null,request=null,running=false,cancelled=false,serial=0,nextId=5000;
const setStatus=t=>{status.textContent=t};
const parseVN=s=>{if(!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(s))throw Error('invalid_window');const ms=Date.parse(s+':00+07:00');if(!Number.isSafeInteger(ms))throw Error('invalid_window');return ms};
const options=()=>({sourceRoom:source.value,destinationRoom:destination.value,fromMs:parseVN(from.value),toMs:parseVN(to.value)});
const inventory=opts=>({...opts,sourceComplete:true,destinationComplete:true,source:[...(records.get(opts.sourceRoom)||[])],destination:[...(records.get(opts.destinationRoom)||[])]});
function invalidate(){if(running)return;serial++;preview=null;request=null;review.hidden=true;send.disabled=true;setStatus('Cần kiểm tra lại trước khi gửi.')}
for(const f of [source,destination,from,to])f.addEventListener('change',invalidate);
el('form').addEventListener('submit',e=>{
 e.preventDefault();if(running)return;invalidate();
 try{request=options();preview=planForward(inventory(request));const p=preview;el('total').textContent=p.items.length+p.skipped.length;el('skip').textContent=p.skipped.length;el('count').textContent=p.items.length;el('route').textContent=source.selectedOptions[0].textContent+' → '+destination.selectedOptions[0].textContent;
 const list=el('items');list.replaceChildren();
 for(const [i,item] of p.items.entries()){const li=document.createElement('li');li.dataset.assetId=item.assetId;li.textContent='Ảnh mẫu '+(Number(item.assetId.slice(-12))-1000);list.append(li)}
 progress.max=Math.max(p.items.length,1);progress.value=0;review.hidden=false;send.disabled=!p.items.length;setStatus(p.items.length?'Đã lọc trùng. Xác nhận để gửi thử.':'Không có ảnh mới.');}catch{setStatus('Không thể lập danh sách. Kiểm tra nguồn, đích và thời gian.')}
});
stop.addEventListener('click',()=>{cancelled=true;stop.disabled=true;setStatus('Đang dừng sau ảnh đang xử lý…')});
send.addEventListener('click',async()=>{
 if(running||!preview||!request)return;const p=preview,opts=request,epoch=++serial;
 running=true;cancelled=false;send.disabled=true;stop.disabled=false;for(const f of fields)f.disabled=true;
 setStatus('Đang gửi thử ảnh mẫu…');
 try{const result=await executeForward({preview:p,readInventory:async()=>inventory(opts),isCurrent:()=>!cancelled&&serial===epoch,sendOfficialImage:async item=>{
 await new Promise(r=>setTimeout(r,35));const messageId=id(nextId++);records.get(item.destinationRoom).push({assetId:id(nextId++),messageId,roomId:item.destinationRoom,kind:'image',sha256:item.sha256,sizeBytes:item.sizeBytes,at:base+100000,sortIndex:0});
 return {clientId:item.clientId,destinationRoom:item.destinationRoom,sha256:item.sha256,messageId};
 },onProgress:({confirmed,total})=>{progress.value=confirmed;setStatus('Đã xác nhận mô phỏng '+confirmed+'/'+total+' ảnh')}});
 progress.value=result.confirmed;setStatus(result.state==='confirmed'?'Hoàn tất mô phỏng '+result.confirmed+' ảnh. Không gửi ảnh thật.':'Đã dừng. '+result.confirmed+' ảnh mẫu xác nhận. Kiểm tra lại trước khi tiếp tục.');
 }catch{setStatus('Danh sách đã đổi hoặc phiên không còn hợp lệ. Kiểm tra lại.')}
 finally{running=false;stop.disabled=true;for(const f of fields)f.disabled=false;preview=null;request=null;send.disabled=true}
});
