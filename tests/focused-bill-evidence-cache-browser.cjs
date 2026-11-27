// Integrated synthetic SDK test of actual room entry, image cache and read-through. No production traffic.
const {chromium,webkit}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs');
const origin='https://1sl2tp.github.io/0v/';
const sourceHTML=fs.readFileSync('index.html','utf8'),fixtureBoundary='function appShellActive(){';
assert.equal(sourceHTML.split(fixtureBoundary).length,2);
// Only the intercepted synthetic HTML exposes internal owners. No production global.
const html=sourceHTML.replace(fixtureBoundary,'window.__fixtureOwners=()=>({Message,ContentAPI,MediaController,ScrollController,Geometry,FamilyRegistry,auditGeometry,readOwnerRuntime:()=>Object.keys(OwnerRuntime)});\n'+fixtureBoundary);
const admin='00000000-0000-4000-8000-000000000001',peer='00000000-0000-4000-8000-000000000002',room='30000000-0000-4000-8000-000000000001';
const ids=[1,2,3,4].map(i=>'40000000-0000-4000-8000-00000000000'+i);
const sdk='('+function(admin,peer,room,ids){
 const at=i=>new Date(Date.UTC(2026,10,27,2,i)).toISOString();
 const messages=ids.map((id,i)=>({id,conversation_id:room,sender_account_id:i===3?admin:peer,created_at:at(i+1),body:i===0?'Nội dung cũ '.repeat(180):i===3?'Đã nhận hàng':''}));
 const assets=[1,2].map(i=>({id:'50000000-0000-4000-8000-00000000000'+i,message_id:ids[i],kind:'image',mime_type:'image/png',storage_key:'fixture/image'+i+'.png',width_px:48,height_px:96,sort_index:0}));
 const f=window.fixture={seen:[],downloads:0,bytes:0,metadata:0,batches:0,confirmed:true};
 const receipt={asset_id:assets[1].id,message_id:assets[1].message_id,status:'received',has_ledger:true,amount_vnd:'26000',date_vn:'25/11/2026',time_vn:null,receiving_account:'290118199999',receiving_name:'BUI XUAN TUNG',transfer_content:'fixture memo',bank_clock:{source:'independent_agribank_credit_notification',date:'2026-11-25',time:'21:52'}};
 assets[1].bill_receipt={...receipt,...(sessionStorage.getItem('fixture-proof')==='1'?{ocr_rechecked_account:'2901181999999'}:{})};
 f.proof=()=>{sessionStorage.setItem('fixture-proof','1');assets[1].bill_receipt={...receipt,ocr_rechecked_account:'2901181999999'};window.dispatchEvent(new Event('online'))};
 window.supabase={createClient:()=>({auth:{onAuthStateChange(){},async getSession(){return {data:{session:{user:{id:admin}}}}},mfa:{async getAuthenticatorAssuranceLevel(){return {data:{currentLevel:'aal2',nextLevel:'aal2'}}},async listFactors(){return {data:{totp:[{id:'fixture',status:'verified'}]}}}}},channel(){return {on(){return this},subscribe(){return this}}},removeChannel(){},storage:{from(bucket){if(bucket!=='v21-media')throw Error('wrong bucket');return {async info(key){if(!assets.some(a=>a.storage_key===key))throw Error('wrong image');f.metadata++;if(f.parityMode==='deny')return {error:{statusCode:'403'}};if(f.parityMode==='missing')return {data:{}};if(f.parityMode==='hold')await new Promise(resolve=>window.fixtureReleaseParity=resolve);return {data:{metadata:{eTag:(f.parityMode==='mismatch'?'different-':'fixture-')+key}}}},async download(key){if(!assets.some(a=>a.storage_key===key))throw Error('wrong image');f.downloads++;const canvas=document.createElement('canvas');canvas.width=48;canvas.height=96;canvas.getContext('2d').fillRect(0,0,48,96);const data=await new Promise(resolve=>canvas.toBlob(resolve,'image/png'));f.bytes+=data.size;return {data}}}}},async rpc(name,args){
 if(name==='platform_account_context')return {data:{allowed:true,account_class:'admin',account_id:admin}};
 if(name==='v0_admin_read'){if(args.p_kind==='session')return {data:{account_id:admin,role:'admin'}};if(args.p_kind==='directory')return {data:{account_id:admin,contacts:[{id:peer,display_name:'Hội thoại cache mẫu',conversation_id:room,contact_group:'other',preview_text:'Đã nhận hàng',latest_at:at(4),read_ack_supported:true,last_read_at:f.confirmed?at(3):at(0),unread_count:f.confirmed?0:3,has_unread:!f.confirmed}]}};if(args.p_kind==='thread'&&args.p_conversation_id===room)return {data:{account_id:admin,messages}}}
 if(name==='v0_admin_media'&&args.p_conversation_id===room)return {data:{account_id:admin,assets}};
 if(name==='v0_admin_media_revisions'){if(args.p_conversation_id!==room)throw Error('wrong room');f.batches++;return {data:{account_id:admin,room,revisions:args.p_keys.filter(k=>assets.some(a=>a.storage_key===k)).map(path=>({path,etag:'fixture-'+path,version:''}))}}}
 if(name==='v0_admin_mark_seen'){if(args.p_conversation_id!==room)throw Error('wrong room');f.seen.push(args.p_message_ids);if(!ids.slice(0,3).every(id=>args.p_message_ids.includes(id)))return {data:{account_id:admin,conversation_id:room,last_read_at:at(0),unread_count:3}};await new Promise(resolve=>window.fixtureReleaseSeen=resolve);f.confirmed=true;return {data:{account_id:admin,conversation_id:room,last_read_at:at(3),unread_count:0}}}
 throw Error('unexpected RPC '+name)
 }})};
}.toString()+')('+[admin,peer,room,ids].map(JSON.stringify).join(',')+');';

(async()=>{for(const engine of [chromium,webkit]){const browser=await engine.launch();try{
 const page=await browser.newPage({viewport:{width:390,height:844},isMobile:true,hasTouch:true});
 await page.route('**/*',r=>['blob:','data:'].includes(new URL(r.request().url()).protocol)?r.continue():r.abort());
 await page.route('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.57.4/dist/umd/supabase.min.js',r=>r.fulfill({contentType:'application/javascript',body:sdk}));
 await page.route(/^https:\/\/1sl2tp\.github\.io\/0v\/(?:\?.*)?$/,r=>r.fulfill({contentType:'text/html; charset=utf-8',body:html}));
 await page.goto(origin+'?live=1&cachecheck=1&metabatch=1');
 await page.locator('#contacts').getByText('Hội thoại cache mẫu',{exact:true}).click();
 const bill=page.locator('#messages [data-live-bill-pair]');
 await bill.waitFor({state:'attached'});
 await page.waitForFunction(()=>document.querySelector('#messages [data-live-bill-pair] [data-image-state=ready] img')?.naturalWidth>0,{},{timeout:20000});
 assert.match(await bill.textContent(),/STK chưa đủ bằng chứng/);
 const before=await page.evaluate(()=>{const img=document.querySelector('#messages [data-live-bill-pair] img');window.fixtureBillImage=img;return {src:img.src,downloads:fixture.downloads,bytes:fixture.bytes,prepare:crmCacheStats().ram.prepareCalls}});
 await page.evaluate(()=>fixture.proof());
 await page.waitForFunction(()=>{const b=document.querySelector('#messages [data-live-bill-pair]');return b?.textContent.includes('2901181999999')&&b.textContent.includes('Giờ Agribank')&&!b.textContent.includes('STK chưa đủ bằng chứng')},{},{timeout:20000});
 const after=await page.evaluate(()=>{const img=document.querySelector('#messages [data-live-bill-pair] img');return {same:img===window.fixtureBillImage,src:img.src,downloads:fixture.downloads,bytes:fixture.bytes,prepare:crmCacheStats().ram.prepareCalls}});
 assert.equal(after.same,true);assert.equal(after.src,before.src);assert.equal(after.downloads,before.downloads);assert.equal(after.bytes,before.bytes);assert.equal(after.prepare,before.prepare);
 assert.match(await bill.textContent(),/Đã ghi thu/);assert.match(await bill.textContent(),/Giờ trên ảnh/);assert.match(await bill.textContent(),/21:52/);
 console.log('LIVE-BILL-FOCUSED cache '+engine.name()+' same image DOM, same URL, zero extra downloads/bytes/decode preparation, separate bank clock passed');
 }finally{await browser.close()}}})().catch(e=>{console.error(e);process.exitCode=1});
