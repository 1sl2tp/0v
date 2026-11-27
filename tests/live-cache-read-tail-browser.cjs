// Integrated synthetic SDK test of actual room entry, image cache and read-through. No production traffic.
const {chromium,webkit}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs');
const origin='https://1sl2tp.github.io/0v/';
const html=fs.readFileSync('index.html','utf8');
const admin='00000000-0000-4000-8000-000000000001',peer='00000000-0000-4000-8000-000000000002',room='30000000-0000-4000-8000-000000000001';
const ids=[1,2,3,4].map(i=>'40000000-0000-4000-8000-00000000000'+i);
const sdk='('+function(admin,peer,room,ids){
 const at=i=>new Date(Date.UTC(2026,10,27,2,i)).toISOString();
 const messages=ids.map((id,i)=>({id,conversation_id:room,sender_account_id:i===3?admin:peer,created_at:at(i+1),body:i===0?'Nội dung cũ '.repeat(180):i===3?'Đã nhận hàng':''}));
 const assets=[1,2].map(i=>({id:'50000000-0000-4000-8000-00000000000'+i,message_id:ids[i],kind:'image',mime_type:'image/png',storage_key:'fixture/image'+i+'.png',width_px:48,height_px:96,sort_index:0}));
 const f=window.fixture={seen:[],downloads:0,bytes:0,metadata:0,batches:0,confirmed:false};
 window.supabase={createClient:()=>({auth:{onAuthStateChange(){},async getSession(){return {data:{session:{user:{id:admin}}}}},mfa:{async getAuthenticatorAssuranceLevel(){return {data:{currentLevel:'aal2',nextLevel:'aal2'}}},async listFactors(){return {data:{totp:[{id:'fixture',status:'verified'}]}}}}},channel(){return {on(){return this},subscribe(){return this}}},removeChannel(){},storage:{from(bucket){if(bucket!=='v21-media')throw Error('wrong bucket');return {async info(key){if(!assets.some(a=>a.storage_key===key))throw Error('wrong image');f.metadata++;return {data:{metadata:{eTag:'fixture-'+key}}}},async download(key){if(!assets.some(a=>a.storage_key===key))throw Error('wrong image');f.downloads++;const canvas=document.createElement('canvas');canvas.width=48;canvas.height=96;canvas.getContext('2d').fillRect(0,0,48,96);const data=await new Promise(resolve=>canvas.toBlob(resolve,'image/png'));f.bytes+=data.size;return {data}}}}},async rpc(name,args){
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
 const contact=page.locator('#contacts').getByText('Hội thoại cache mẫu',{exact:true});
 await contact.waitFor({state:'visible'});
 await page.waitForFunction(()=>window.crmCacheStats?.().ram.prepareCalls===2&&window.fixture?.downloads===2,{},{timeout:20000});
 await page.waitForFunction(()=>window.crmCacheStats?.().ram.bytes>0&&window.fixture?.bytes>0);
 const warm=await page.evaluate(()=>({downloads:fixture.downloads,bytes:fixture.bytes,stats:crmCacheStats(),srcs:[...document.querySelectorAll('#messages [data-image-state=ready] img')].map(x=>x.src)}));
 await contact.click();
 await page.locator('#messages [data-live-message-id="'+ids[3]+'"]').waitFor({state:'attached'});
 await page.waitForFunction(()=>document.querySelectorAll('#messages [data-image-state=ready]').length===2,{},{timeout:10000});
 const opened=await page.evaluate(()=>({downloads:fixture.downloads,bytes:fixture.bytes,stats:crmCacheStats(),srcs:[...document.querySelectorAll('#messages [data-image-state=ready] img')].map(x=>x.src)}));
 assert.equal(opened.downloads,warm.downloads);assert.equal(opened.bytes,warm.bytes);
 await page.waitForFunction(()=>typeof window.fixtureReleaseSeen==='function',{},{timeout:15000});
 assert.deepEqual((await page.evaluate(()=>fixture.seen.at(-1))).sort(),ids.slice(0,3).sort());
 assert.equal(await page.locator('.contact[data-id="'+peer+'"] .unread-count').textContent(),'3');
 await page.evaluate(()=>window.fixtureReleaseSeen());
 await page.waitForFunction(()=>!document.querySelector('.contact .unread-count'));
 await page.locator('.conversation .panel-head [data-go=contacts]').evaluate(e=>e.click());
 await contact.click();
 await page.waitForFunction(()=>document.querySelectorAll('#messages [data-image-state=ready]').length===2,{},{timeout:10000});
 const reopened=await page.evaluate(()=>({downloads:fixture.downloads,bytes:fixture.bytes,stats:crmCacheStats(),srcs:[...document.querySelectorAll('#messages [data-image-state=ready] img')].map(x=>x.src)}));
 assert.equal(reopened.downloads,opened.downloads);assert.equal(reopened.bytes,opened.bytes);assert.deepEqual(reopened.srcs,opened.srcs);assert.equal(reopened.stats.ram.prepareCalls,opened.stats.ram.prepareCalls);assert.equal(reopened.stats.ram.displayCreated,2);assert(reopened.stats.ram.decodedBytes<=24*1024*1024);console.log('CACHE-RESOLVE-03 '+engine.name()+' stable URL/reuse',JSON.stringify({displayCreated:reopened.stats.ram.displayCreated,displayReuse:reopened.stats.ram.displayReuse,decodedBytes:reopened.stats.ram.decodedBytes}));
 await page.waitForFunction(()=>crmCacheStats().durableWrites===2&&crmCacheStats().displayReadyCount>=2,{},{timeout:15000});
 await page.reload();await page.waitForFunction(()=>document.querySelectorAll('#messages [data-image-state=ready]').length===2&&window.crmCacheStats?.().displayReadyCount>=2,{},{timeout:20000});
 const restored=await page.evaluate(()=>({stats:crmCacheStats(),downloads:fixture.downloads,batches:fixture.batches,metadata:fixture.metadata}));
 assert.equal(restored.downloads,0);assert.equal(restored.batches,1);assert.equal(restored.metadata,0);assert.equal(restored.stats.batchHits,2);assert.equal(restored.stats.ram.decodeCount,2);assert(restored.stats.displayReadyCount>=2);
 console.log('CACHE-ROOM '+engine.name()+' real HTML F5 two groups',JSON.stringify({batches:restored.batches,metadata:restored.metadata,downloads:restored.downloads,batchMs:restored.stats.batchMs,decodeMs:restored.stats.ram.decodeMs,prepareMs:restored.stats.ram.prepareMs,displayReadyMs:restored.stats.displayReadyMs,displayRequestMs:restored.stats.displayRequestMs,displayReadyCount:restored.stats.displayReadyCount}));
 console.log('CACHE/NOTIFY '+engine.name()+' synthetic prewarm/open/reopen',JSON.stringify({coldDownloads:warm.downloads,coldBytes:warm.bytes,openExtra:opened.downloads-warm.downloads,reopenExtra:reopened.downloads-opened.downloads,reopenExtraBytes:reopened.bytes-opened.bytes,readAck:true}));
 }finally{await browser.close()}}})().catch(e=>{console.error(e);process.exitCode=1});
