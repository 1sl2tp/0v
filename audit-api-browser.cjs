const {chromium}=require('playwright');
const {pathToFileURL}=require('node:url');
const assert=require('node:assert/strict');
const url=pathToFileURL(process.cwd()+'/index.html').href;
(async()=>{
 const browser=await chromium.launch({headless:true});
 try{
 for(const width of [320,375,390,430,768,1280]){
  const page=await browser.newPage({viewport:{width,height:900}}),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(url+'?apicheck=1');
  await page.waitForFunction(()=>window.apiProof);assert.equal(await page.locator('#app').getAttribute('data-main-source'),'api');assert.equal(await page.locator('.contact').count(),4);
  const inspect=selector=>page.locator(selector).first().evaluate(el=>window.apiProof.describe(el));
  const fonts=async list=>{for(const [sel,size,line,weight] of list){const x=await inspect(sel);assert.equal(x.computed.size,size,sel);assert.equal(x.computed.line,line,sel);assert.equal(x.computed.weight,weight,sel);assert.equal(x.fontOK,true,sel)}};
  const read=()=>page.evaluate(()=>window.apiProof.report());
  await fonts([['.directory .panel-head strong',18,24,600],['.directory .label-version',10,16,400],['.contact .identity b',16,22,600],['.contact .identity small',13,18,400],['.contact .time',13,18,400]]);
  assert.equal(await page.locator('.contact').first().getAttribute('data-layout-profile'),'contact-row');assert.equal(await page.locator('.filters button').first().evaluate(el=>parseFloat(getComputedStyle(el).fontSize)),14);const dir=await read();assert.equal(dir.family.issues.length,0);const owners=await page.evaluate(()=>window.ownerAudit());assert(owners.parents.includes('KeyboardController'));assert(owners.parents.includes('Avatar'));assert(owners.parents.includes('Surface'));assert.equal(owners.report.issues.length,0);const gap=await page.locator('.contact').first().evaluate(el=>{const s=document.documentElement.style,old=s.getPropertyValue('--row-gap'),priority=s.getPropertyPriority('--row-gap'),read=()=>parseFloat(getComputedStyle(el).columnGap);const before=read();let during;try{s.setProperty('--row-gap',(before+4)+'px');during=read()}finally{old?s.setProperty('--row-gap',old,priority):s.removeProperty('--row-gap')}return {before,during,after:read()}});assert.equal(gap.during,gap.before+4);assert.equal(gap.after,gap.before);assert(dir.family.total>0);console.log('Family directory',width,JSON.stringify(dir.family.counts),JSON.stringify(dir.family.issues.slice(0,12)));assert.equal(dir.button.visible,dir.button.registered);assert.equal(dir.icon.visible,dir.icon.registered);assert.equal(dir.layout.contactGeometry.length,4);assert(dir.layout.contactGeometry.every(x=>x.inside<=1&&x.overlap<=1));
  // Verify every item, not the first item or the sample text.
  const rows=await page.locator('.contact').evaluateAll(nodes=>{
   const root=document.documentElement,s=root.style,props={'--avatar-size':'44px','--type-body':'17px','--row-gap':'12px'},old=Object.keys(props).map(k=>[k,s.getPropertyValue(k),s.getPropertyPriority(k)]);
   const read=()=>nodes.map(row=>{const a=row.querySelector('.avatar'),name=row.querySelector('.identity b'),preview=row.querySelector('.identity small'),time=row.querySelector('.time'),box=a.getBoundingClientRect();return {id:row.dataset.id,label:a.textContent,owner:a.dataset.parentApi,status:a.dataset.familyStatus,profile:a.dataset.avatarSize,shape:a.dataset.avatarShape,w:box.width,h:box.height,name:parseFloat(getComputedStyle(name).fontSize),nameWeight:getComputedStyle(name).fontWeight,preview:parseFloat(getComputedStyle(preview).fontSize),time:parseFloat(getComputedStyle(time).fontSize),gap:parseFloat(getComputedStyle(row).columnGap),content:name.textContent}});
   const before=read();let during;try{for(const [k,v] of Object.entries(props))s.setProperty(k,v);during=read()}finally{for(const [k,v,p] of old)v?s.setProperty(k,v,p):s.removeProperty(k)}return {before,during,after:read()};
  });
  assert.deepEqual(rows.before.map(x=>x.id),['kh','ncc','nv','nhom']);assert.deepEqual(rows.before.map(x=>x.label),['KH','NCC','NV','NH']);
  for(let i=0;i<4;i++){const b=rows.before[i],d=rows.during[i];assert.equal(b.owner,'Avatar',b.id);assert.equal(b.status,'DECLARED',b.id);assert.equal(b.profile,'directory',b.id);assert.equal(b.w,b.h,b.id);assert.equal(b.name,16,b.id);assert.equal(b.nameWeight,'600',b.id);assert.equal(b.preview,13,b.id);assert.equal(b.time,13,b.id);assert.equal(d.w,44,b.id);assert.equal(d.h,44,b.id);assert.equal(d.name,17,b.id);assert.equal(d.gap,12,b.id);assert.equal(d.content,b.content,b.id);}
  assert.deepEqual(rows.after,rows.before);console.log('All contact rows',width,JSON.stringify(rows.before.map(x=>({id:x.id,size:x.w,owner:x.owner,name:x.name,gap:x.gap}))));
  for(const [filter,id,avatar] of [['KH','kh','KH'],['NCC','ncc','NCC'],['NV','nv','NV'],['Nhóm','nhom','NH']]){
   await page.locator('[data-go=contacts]').first().evaluate(el=>el.click());await page.locator('[data-filter="'+filter+'"]').evaluate(el=>el.click());
   assert.deepEqual(await page.locator('.contact:not([hidden])').evaluateAll(es=>es.map(e=>e.dataset.id)),[id]);
   await page.locator('.contact[data-id="'+id+'"]').evaluate(el=>el.click());const av=await page.locator('#currentAvatar').evaluate(el=>({text:el.textContent,owner:el.dataset.parentApi,profile:el.dataset.avatarSize,w:el.getBoundingClientRect().width,h:el.getBoundingClientRect().height}));assert.equal(av.text,avatar,id);assert.equal(av.owner,'Avatar',id);assert.equal(av.profile,'header',id);assert.equal(av.w,av.h,id);
  }
  await page.locator('[data-go=contacts]').first().evaluate(el=>el.click());await page.locator('[data-filter="Tất cả"]').evaluate(el=>el.click());
  assert.equal(await page.locator('.contact:not([hidden])').count(),4);
  await page.locator('#addContact').evaluate(el=>el.click());
  await page.waitForSelector('dialog[open]');
  assert.equal((await read()).popup.profiles[0],'form');assert.equal(await page.locator('dialog[open]').getAttribute('data-surface-owner'),'Surface');console.log('Family popup',width,JSON.stringify((await read()).family.counts));
  await fonts([['dialog[open] h3',18,24,600],['dialog[open] p',14,20,400]]);
  await page.locator('dialog[open] button').last().click();
  await page.waitForSelector('dialog[open]',{state:'detached'});
  await page.locator('.contact[data-id=nv]').evaluate(el=>el.click());
  await page.waitForFunction(()=>document.querySelector('#app').dataset.screen==='chat');
  await fonts([['#currentName',18,24,600],['#currentRole',13,18,400],['#messages .bubble',18,27,400],['#messages .meta',13,18,400],['#draft',17,22,400]]);
  assert.equal((await inspect('#draft')).input,'chat');assert.equal(await page.locator('#messages .message').first().getAttribute('data-layout-profile'),'message');assert.equal((await read()).family.issues.length,0);console.log('Family chat',width,JSON.stringify((await read()).family.counts));
  const sizes=await page.evaluate(()=>{const root=document.documentElement,s=root.style,old=s.getPropertyValue('--type-chat'),priority=s.getPropertyPriority('--type-chat'),get=()=>[...document.querySelectorAll('#messages .bubble')].map(e=>parseFloat(getComputedStyle(e).fontSize));const before=get();let during,after;try{s.setProperty('--type-chat','21px');during=get()}finally{old?s.setProperty('--type-chat',old,priority):s.removeProperty('--type-chat');after=get()}return {before,during,after}});
  assert(sizes.before.length>=2);assert(sizes.before.every(n=>n===18));assert(sizes.during.every(n=>n===21));assert.deepEqual(sizes.after,sizes.before);
  // Negative control: a declared child with a fake parent must be detected.
  const bad=await page.evaluate(()=>{const e=document.createElement('span');Object.assign(e.dataset,{family:'Typography',parentApi:'Fake',familyStatus:'DECLARED',typeRole:'body'});document.querySelector('#app').append(e);try{return window.familyAudit().issues.some(x=>x.status==='WRONG-PARENT')}finally{e.remove()}});assert(bad);
  // Reload checks first paint roles persist; no synthetic keyboard is represented as native.
  await page.reload();await page.waitForFunction(()=>window.apiProof);
  await fonts([['.directory .label-version',10,16,400],['.contact .identity b',16,22,600]]);
  assert.deepEqual(errors,[]);
  console.log(width+'px: directory/chat/input/popup/font propagation/registration/contact geometry/F5 passed');
  await page.close();
 }
 // Layout and Typography lab coverage is separate from the normal UI.
 const page=await browser.newPage({viewport:{width:390,height:844}});await page.goto(url+'?geolab=1');
 await page.locator('.contact[data-id=nv]').evaluate(el=>el.click());
 await page.locator('.conversation .panel-head button[data-go=crm]').evaluate(el=>el.click());
 await page.waitForSelector('.geo-lab [data-geo-layout]');
 assert(await page.locator('.geo-lab [data-geo-layout]').count()>1);
 await page.close();
 const surf=await browser.newPage({viewport:{width:390,height:844}});await surf.goto(url+'?surfacelab=1');
 await surf.locator('.contact[data-id=nv]').evaluate(el=>el.click());
 await surf.locator('.conversation .panel-head button[data-go=crm]').evaluate(el=>el.click());
 await surf.waitForSelector('[data-surface-variant=plain]');
 const styles=await surf.locator('#moduleContent [data-surface-variant]').evaluateAll(nodes=>nodes.map(el=>{const s=getComputedStyle(el);return {variant:el.dataset.surfaceVariant,border:s.borderTopWidth,edge:s.borderTopColor,bg:s.backgroundColor,shadow:s.boxShadow,radius:s.borderRadius,width:el.getBoundingClientRect().width,height:el.getBoundingClientRect().height}}));
 console.log('Surface computed styles',JSON.stringify(styles));assert.equal(styles.length,5);assert(styles.every(s=>s.border==='1px'&&s.width===styles[0].width&&s.height===styles[0].height&&s.radius===styles[0].radius));assert.notEqual(styles[1].bg,styles[0].bg,'subtle background');assert.notEqual(styles[2].edge,styles[0].edge,'outlined edge');assert.notEqual(styles[3].shadow,'none','raised shadow');assert.notEqual(styles[4].bg,styles[0].bg,'selected background');
 const colors=await surf.locator('[data-surface-variant=subtle]').evaluate(el=>{const root=document.documentElement,s=root.style,old=s.getPropertyValue('--surface-subtle-face'),priority=s.getPropertyPriority('--surface-subtle-face'),get=()=>getComputedStyle(el).backgroundColor;const before=get();let during;try{s.setProperty('--surface-subtle-face','rgb(1, 2, 3)');during=get()}finally{old?s.setProperty('--surface-subtle-face',old,priority):s.removeProperty('--surface-subtle-face')}return {before,during,after:get()}});
 assert.equal(colors.during,'rgb(1, 2, 3)');assert.equal(colors.after,colors.before);console.log('Surface API 5 variants, equal geometry, parent token propagation passed');await surf.close();
 const avlab=await browser.newPage({viewport:{width:390,height:844}});await avlab.goto(url+'?avatarlab=1');
 await avlab.locator('.contact[data-id=nv]').evaluate(el=>el.click());await avlab.locator('.conversation .panel-head button[data-go=crm]').evaluate(el=>el.click());
 await avlab.waitForSelector('#moduleContent [data-avatar-state=image]');await avlab.waitForSelector('#moduleContent [data-avatar-state=error]');
 const avatars=await avlab.locator('#moduleContent [data-avatar-profile]').evaluateAll(es=>es.map(e=>({size:e.getBoundingClientRect().width,height:e.getBoundingClientRect().height,shape:e.dataset.avatarShape,state:e.dataset.avatarState,text:e.textContent,radius:getComputedStyle(e).borderRadius,fit:e.querySelector('img')?getComputedStyle(e.querySelector('img')).objectFit:null})));
 assert.equal(avatars.length,7);assert(avatars.every(x=>x.size===x.height));assert.equal(avatars[0].size,24);assert.equal(avatars[4].size,56);assert.equal(avatars[3].radius,'0px');assert.equal(avatars[4].fit,'cover');assert.equal(avatars[5].text,'B');assert.equal(avatars[6].text,'NV');console.log('Avatar lab 7 cases',JSON.stringify(avatars));await avlab.close();
 const media=await browser.newPage({viewport:{width:390,height:844}});await media.goto(url+'?medialab=1');
 await media.locator('.contact[data-id=nv]').evaluate(el=>el.click());await media.locator('.conversation .panel-head button[data-go=crm]').evaluate(el=>el.click());
 const grids=media.locator('#moduleContent [data-media-parent=true]');assert.equal(await grids.count(),4);
 for(let i=0;i<4;i++){const tiles=grids.nth(i).locator('.media-tile');assert.equal(await tiles.count(),i+1);const styles=await tiles.evaluateAll(es=>es.map(e=>({fit:getComputedStyle(e.querySelector('img')).objectFit,w:e.getBoundingClientRect().width,h:e.getBoundingClientRect().height})));console.log('Media grid',i+1,JSON.stringify(styles));assert(styles.every(x=>x.fit===(i===0?'contain':'cover')&&x.w>0&&x.h>0));}
 const lastTile=grids.nth(3).locator('.media-tile').last();await lastTile.scrollIntoViewIfNeeded();await lastTile.locator('img').evaluate(img=>img.decode());await lastTile.click();await media.waitForSelector('dialog[open] [data-media-viewer-stage]');const stage=media.locator('[data-media-viewer-stage]');await media.waitForFunction(()=>document.querySelector('[data-media-viewer-stage]').dataset.mediaZoom==='1');
 const fitted=await stage.locator('img').evaluate(el=>el.getBoundingClientRect().width);await media.getByRole('button',{name:'Phóng to',exact:true}).click();assert.equal(await stage.getAttribute('data-media-zoom'),'1.5');assert(Math.abs(await stage.locator('img').evaluate(el=>el.getBoundingClientRect().width)-fitted*1.5)<1);await media.getByRole('button',{name:'Vừa khung',exact:true}).click();assert.equal(await stage.getAttribute('data-media-zoom'),'1');
 // Simulated pointer events: logic only, not a physical iOS touch certification.
 const gesture=await stage.evaluate(el=>{
  const b=el.getBoundingClientRect(),cx=b.left+b.width/2,cy=b.top+b.height/2;
  const emit=(type,id,x,y)=>el.dispatchEvent(new PointerEvent(type,{pointerId:id,pointerType:'touch',clientX:x,clientY:y,bubbles:true,cancelable:true,button:0}));
  emit('pointerdown',1,cx-30,cy);emit('pointerdown',2,cx+30,cy);emit('pointermove',1,cx-60,cy);emit('pointermove',2,cx+60,cy);
  const pinch=Number(el.dataset.mediaZoom);emit('pointermove',1,cx-300,cy);emit('pointermove',2,cx+300,cy);const max=Number(el.dataset.mediaZoom);
  emit('pointerup',2,cx+300,cy);const pan=el.dataset.mediaGesture;el.scrollLeft=0;emit('pointerup',1,cx-300,cy);emit('pointerdown',3,cx,cy);emit('pointermove',3,cx-40,cy);const dragged=el.scrollLeft;emit('pointercancel',3,cx-40,cy);return {pinch,max,pan,dragged,end:el.dataset.mediaGesture}
 });
 assert.equal(gesture.pinch,2);assert.equal(gesture.max,4);assert.equal(gesture.pan,'pan');assert(gesture.dragged>0);assert.equal(gesture.end,'idle');
 await media.getByRole('button',{name:'Vừa khung',exact:true}).click();assert.equal(await stage.getAttribute('data-media-zoom'),'1');console.log('Media gestures simulated',JSON.stringify(gesture));
 await media.getByRole('button',{name:'Xoay 90°',exact:true}).click();assert.equal(await stage.locator('img').getAttribute('width'),'360');assert.equal(await stage.locator('img').getAttribute('height'),'640');assert.equal(await grids.nth(3).locator('.media-tile').last().locator('img').getAttribute('width'),'640');
 await media.locator('dialog[open] button').last().click();await media.waitForSelector('dialog[open]',{state:'detached'});console.log('Media: all 10 tiles, fit, zoom, rotate and close passed');await media.close();
 const systems=await browser.newPage({viewport:{width:390,height:844},reducedMotion:'reduce'});await systems.goto(url+'?systemslab=1');await systems.locator('.contact[data-id=nv]').evaluate(e=>e.click());await systems.locator('.conversation .panel-head button[data-go=crm]').evaluate(e=>e.click());
 const lessons=systems.locator('[data-system-lesson]');assert.equal(await lessons.count(),8);
 const mediaLesson=systems.locator('[data-system-lesson="10 Media"]');const first=mediaLesson.locator('.media-tile').first();await first.scrollIntoViewIfNeeded();await first.locator('img').evaluate(e=>e.decode());await first.click();await systems.getByRole('button',{name:'Ảnh tiếp',exact:true}).click();assert.equal(await systems.locator('[data-media-viewer-stage]').getAttribute('data-media-index'),'1');await systems.getByRole('button',{name:'Ảnh tiếp',exact:true}).click();assert.equal(await systems.locator('[data-media-viewer-stage]').getAttribute('data-media-index'),'2');assert(await systems.getByRole('button',{name:'Ảnh tiếp',exact:true}).isDisabled());await systems.getByRole('button',{name:'Ảnh trước',exact:true}).click();assert.equal(await systems.locator('[data-media-viewer-stage]').getAttribute('data-media-index'),'1');await systems.locator('dialog[open] button').last().click();
 assert(await mediaLesson.locator('video').evaluate(e=>e.controls&&e.playsInline&&!e.autoplay));await mediaLesson.getByRole('button',{name:'Dừng và giải phóng video'}).click();
 assert.equal(await systems.locator('[data-system-lesson="11 Card"] [data-surface-variant]').count(),3);
 const density=await systems.locator('[data-system-lesson="12 Table"] [data-table-density]').evaluateAll(es=>es.map(e=>({density:e.dataset.tableDensity,rows:e.querySelectorAll('tbody tr').length,cells:[...e.querySelectorAll('tbody tr')].map(r=>r.children.length),pad:parseFloat(getComputedStyle(e.querySelector('td')).paddingTop)})));assert.equal(density.length,3);assert(density.every(x=>x.rows===3&&x.cells.every(n=>n===5)));console.log('Table density',JSON.stringify(density));assert.deepEqual(density.map(x=>x.pad),[4,6,12]);
 const scroll=systems.locator('[data-scroll-lab]');assert(await scroll.evaluate(e=>e.scrollHeight-e.clientHeight>48),'scroll sample must overflow');await scroll.evaluate(e=>e.scrollTop=0);await systems.getByRole('button',{name:'Thêm dòng',exact:true}).evaluate(e=>e.click());assert.equal(await scroll.evaluate(e=>e.scrollTop),0);await scroll.evaluate(e=>e.scrollTop=e.scrollHeight);await systems.getByRole('button',{name:'Thêm dòng',exact:true}).evaluate(e=>e.click());assert(await scroll.evaluate(e=>e.scrollHeight-e.clientHeight-e.scrollTop<2));
 await systems.getByRole('button',{name:'Chạy chuyển động'}).evaluate(e=>e.click());assert.equal(await systems.locator('[data-motion-profile]').getAttribute('data-motion-reduced'),'true');
 assert.equal(await systems.locator('[data-responsive-profile=cards]>section').count(),4);
 const toggle=systems.getByRole('button',{name:'Chọn mẫu',exact:true});await toggle.evaluate(e=>e.click());assert.equal(await toggle.getAttribute('aria-pressed'),'true');await systems.getByRole('button',{name:'Đổi trạng thái bận'}).evaluate(e=>e.click());assert.equal(await toggle.getAttribute('aria-busy'),'true');assert.equal(await toggle.getAttribute('aria-pressed'),'true');
 await systems.getByRole('button',{name:'dark',exact:true}).evaluate(e=>e.click());assert.equal(await systems.locator('[data-theme-profile]').evaluate(e=>getComputedStyle(e).backgroundColor),'rgb(32, 33, 36)');await systems.getByRole('button',{name:'light',exact:true}).evaluate(e=>e.click());assert.equal(await systems.locator('[data-theme-profile]').evaluate(e=>getComputedStyle(e).backgroundColor),'rgb(255, 255, 255)');
 console.log('Systems lab: 8 lessons, 3 rows x 3 tables, scroll anchor, reduced motion, state/theme and gallery navigation passed');await systems.close();

 // Verify actual browser updater without network access.
 const releaseHtml=require('fs').readFileSync('index.html','utf8'),current=JSON.parse(require('fs').readFileSync('version.json','utf8')).version,[major,minor]=current.slice(1).split('.').map(Number),future='v'+major+'.'+(minor+1),futureQuery=future.slice(1),futureHtml=releaseHtml.replaceAll(current,future),origin='https://1sl2tp.github.io/0v/';
 async function checkRelease(mode){
  const p=await browser.newPage({viewport:{width:390,height:844}});let entryReady=mode!=='stale',manifestReady=!['dirty','resume','readonly','mutation'].includes(mode);
  try{
   await p.route(origin+'**',route=>{const u=new URL(route.request().url());if(u.pathname.endsWith('/version.json')){const version=manifestReady?future:current;return route.fulfill({json:{version,entry:'index.html',snapshot:'release-'+version+'.html',gitBlobSha:'a'.repeat(40)}})}if(u.pathname.endsWith('/index.html'))return route.fulfill({contentType:'text/html',body:entryReady?futureHtml:releaseHtml});if(u.searchParams.get('v')===futureQuery)return route.fulfill({contentType:'text/html',body:futureHtml});return route.fulfill({contentType:'text/html',body:releaseHtml})});
   await p.goto(origin+(mode==='lab'?'?systemslab=1':mode==='resume'?'?floating=1&v='+current.slice(1)+'&r='+Date.now():''));await p.bringToFront();await p.waitForFunction(()=>!document.hidden&&!!window.releaseStatus);
   if(mode==='dirty'){
    await p.locator('.contact[data-id=nv]').evaluate(e=>e.click());await p.locator('#draft').fill('Bản nháp cần giữ');
    assert.equal(await p.locator('#draft').inputValue(),'Bản nháp cần giữ');manifestReady=true;
    await p.evaluate(()=>window.dispatchEvent(new Event('focus')));
    await p.waitForFunction(v=>window.releaseStatus?.().state==='deferred'&&window.releaseStatus?.().pending===v,future);
    assert.equal(await p.locator('#draft').inputValue(),'Bản nháp cần giữ');assert.notEqual(new URL(p.url()).searchParams.get('v'),futureQuery);
    // Save the draft on switching away, then clear it after returning. The current editor is authoritative.
    await p.locator('[data-go=contacts]').first().evaluate(e=>e.click());await p.locator('.contact[data-id=ncc]').evaluate(e=>e.click());await p.locator('[data-go=contacts]').first().evaluate(e=>e.click());await p.locator('.contact[data-id=nv]').evaluate(e=>e.click());assert.equal(await p.locator('#draft').inputValue(),'Bản nháp cần giữ');await p.locator('#draft').fill('');await p.locator('#draft').blur();await p.waitForURL(u=>u.searchParams.get('v')===futureQuery,{timeout:25000});assert((await p.title()).endsWith(future));
   }else if(mode==='readonly'){
    await p.locator('#addContact').evaluate(e=>e.click());await p.getByRole('dialog').getByRole('button',{name:'Đóng',exact:true}).click();assert.equal(await p.evaluate(()=>window.releaseStatus().dirty),false);manifestReady=true;await p.evaluate(()=>window.dispatchEvent(new Event('online')));await p.waitForURL(u=>u.searchParams.get('v')===futureQuery,{timeout:20000});assert((await p.title()).endsWith(future));
   }else if(mode==='resume'){
    await p.waitForFunction(()=>window.releaseStatus().state==='current');manifestReady=true;await p.evaluate(()=>window.dispatchEvent(new Event('pageshow')));await p.waitForURL(u=>u.searchParams.get('v')===futureQuery,{timeout:10000});assert((await p.title()).endsWith(future));assert.equal(new URL(p.url()).searchParams.get('floating'),'1');
   }else if(mode==='mutation'){
    await p.locator('.contact[data-id=nv]').evaluate(e=>e.click());await p.locator('#draft').fill('Tin mẫu chưa lưu');await p.locator('#composer').evaluate(e=>e.requestSubmit());await p.locator('#draft').blur();manifestReady=true;await p.evaluate(()=>window.dispatchEvent(new Event('online')));await p.waitForFunction(()=>window.releaseStatus().state==='deferred'&&window.releaseStatus().blockers.includes('unsaved-demo'));assert.notEqual(new URL(p.url()).searchParams.get('v'),futureQuery);assert(await p.getByText('Tin mẫu chưa lưu',{exact:true}).count());
   }else if(mode==='stale'){
    await p.waitForFunction(()=>window.releaseStatus?.().state==='waiting-pages');
    assert.notEqual(new URL(p.url()).searchParams.get('v'),futureQuery);entryReady=true;await p.evaluate(()=>window.dispatchEvent(new Event('focus')));await p.waitForURL(u=>u.searchParams.get('v')===futureQuery,{timeout:25000});assert((await p.title()).endsWith(future));
   }else{
    await p.waitForURL(u=>u.searchParams.get('v')===futureQuery,{timeout:mode==='clean'?8000:25000});assert((await p.title()).endsWith(future));if(mode==='lab')assert(new URL(p.url()).searchParams.get('systemslab')==='1');
   }
   console.log('ReleaseUpdater case passed',mode,p.url());
  }catch(e){console.error('ReleaseUpdater failure',mode,p.url(),await p.evaluate(()=>({status:window.releaseStatus?.(),hidden:document.hidden,active:document.activeElement?.id,draft:document.querySelector('#draft')?.value})).catch(()=>null));throw e}
  finally{await p.close()}
 }
 for(const mode of ['clean','dirty','stale','lab','readonly','resume','mutation'])await checkRelease(mode);
 console.log('ReleaseUpdater clean, dirty, stale entry and lab navigation passed');

 const collection=await browser.newPage({viewport:{width:390,height:844}});await collection.goto(url+'?collectionlab=1');await collection.locator('.contact[data-id=nv]').evaluate(e=>e.click());await collection.locator('.conversation .panel-head button[data-go=crm]').evaluate(e=>e.click());
 const rows=collection.locator('[data-collection-key]'),visible=collection.locator('[data-collection-key]:not([hidden])'),status=collection.locator('[data-collection-status]');
 assert.equal(await rows.count(),8);assert.equal(await visible.count(),8);
 assert(await collection.locator('[data-collection-key=a3]').isDisabled());
 await collection.locator('[data-collection-key=a1]').evaluate(e=>e.click());assert.equal(await status.getAttribute('data-selected-count'),'1');
 await collection.locator('[data-collection-filter="Bánh"]').evaluate(e=>e.click());assert.equal(await visible.count(),3);
 await collection.getByRole('button',{name:'Chọn tất cả kết quả',exact:true}).evaluate(e=>e.click());assert.equal(await status.getAttribute('data-selected-count'),'4');assert.equal(await status.getAttribute('data-visible-selected'),'3');
 await collection.getByRole('button',{name:'Sắp xếp tên',exact:true}).evaluate(e=>e.click());assert.deepEqual(await visible.evaluateAll(es=>es.map(e=>e.dataset.collectionKey)),['b3','b2','b1']);
 await collection.getByRole('button',{name:'Bỏ chọn kết quả',exact:true}).evaluate(e=>e.click());assert.equal(await status.getAttribute('data-selected-count'),'1');
 await collection.locator('[data-collection-filter=all]').evaluate(e=>e.click());assert.equal(await visible.count(),8);assert.equal(await collection.locator('[data-collection-key=a1]').getAttribute('aria-pressed'),'true');
 const search=collection.getByRole('searchbox',{name:'Tìm hàng mẫu'});await search.fill('sua');assert.equal(await visible.count(),3);assert.deepEqual((await visible.evaluateAll(es=>es.map(e=>e.dataset.collectionKey))).sort(),['a1','a2','a3']);await search.fill('SỮA');assert.equal(await visible.count(),3);await search.fill('dac');assert.equal(await visible.count(),1);assert.equal(await visible.first().getAttribute('data-collection-key'),'a3');await search.fill('nuoc');assert.equal(await visible.count(),2);await search.fill('zzzz');assert.equal(await visible.count(),0);assert(await collection.getByRole('button',{name:'Chọn tất cả kết quả',exact:true}).isDisabled());assert.equal(await status.getAttribute('data-selected-count'),'1');await search.fill('');
 await collection.getByRole('button',{name:'Chọn tất cả kết quả',exact:true}).evaluate(e=>e.click());assert.equal(await status.getAttribute('data-selected-count'),'7');assert.equal(await collection.locator('[data-collection-key=a3]').getAttribute('aria-pressed'),'false');
 await collection.locator('[data-collection-filter="Bánh"]').evaluate(e=>e.click());await collection.getByRole('button',{name:'Bỏ chọn tất cả',exact:true}).evaluate(e=>e.click());assert.equal(await status.getAttribute('data-selected-count'),'0');assert((await rows.evaluateAll(es=>es.map(e=>e.getAttribute('aria-pressed')))).every(s=>s==='false'));console.log('Collection: 8 rows, stable ID, disabled, filtered selection, hidden selection, sort and empty results passed');await collection.close();

 const virt=await browser.newPage({viewport:{width:390,height:844}});await virt.goto(url+'?virtuallab=1');await virt.locator('.contact[data-id=nv]').evaluate(e=>e.click());await virt.locator('.conversation .panel-head button[data-go=crm]').evaluate(e=>e.click());
 const viewport=virt.locator('[data-virtual-viewport]'),vrows=virt.locator('[data-virtual-key]');
 await virt.waitForFunction(()=>document.querySelector('[data-virtual-viewport]')?.dataset.virtualCount==='10000');
 async function inspectVirtual(){return viewport.evaluate(el=>({count:+el.dataset.virtualCount,mounted:el.querySelectorAll('[data-virtual-key]').length,first:+el.dataset.virtualFirst,last:+el.dataset.virtualLast,height:el.clientHeight,scrollHeight:el.scrollHeight,rows:[...el.querySelectorAll('[data-virtual-key]')].map(e=>({key:e.dataset.virtualKey,i:+e.dataset.virtualIndex,h:e.getBoundingClientRect().height,pos:+e.getAttribute('aria-posinset'),size:+e.getAttribute('aria-setsize')}))}))}
 function verifyVirtual(s){assert(s.mounted<=Math.ceil(s.height/44)+9);assert.equal(s.scrollHeight,Math.max(s.height,s.count*44));assert.equal(new Set(s.rows.map(r=>r.key)).size,s.mounted);assert(s.rows.every((r,i)=>r.h===44&&r.pos===r.i+1&&r.size===s.count&&(i===0||r.i===s.rows[i-1].i+1)));if(s.count){assert(s.rows[0].i<=s.first);assert(s.rows.at(-1).i>=s.last-1)}}
 let vs=await inspectVirtual();verifyVirtual(vs);assert.equal(vs.count,10000);assert.equal(vs.first,0);assert.equal(vs.mounted,11);console.log('Virtual initial',JSON.stringify(vs));
 await viewport.evaluate(el=>{el.focus({preventScroll:true});el.querySelector('[data-virtual-key=v5]').dataset.reuseProof='yes';el.scrollTop=44});await virt.waitForFunction(()=>document.querySelector('[data-virtual-viewport]')?.dataset.virtualFirst==='1');assert.equal(await virt.locator('[data-virtual-key=v5]').getAttribute('data-reuse-proof'),'yes');assert(await viewport.evaluate(el=>document.activeElement===el));verifyVirtual(await inspectVirtual());
 await virt.getByRole('button',{name:'Giữa danh sách',exact:true}).evaluate(e=>e.click());vs=await inspectVirtual();verifyVirtual(vs);assert.equal(vs.first,5000);
 await virt.getByRole('button',{name:'Cuối danh sách',exact:true}).evaluate(e=>e.click());vs=await inspectVirtual();verifyVirtual(vs);assert.equal(vs.last,10000);assert.equal(vs.rows.at(-1).key,'v10000');console.log('Virtual end',JSON.stringify(vs));
 await virt.getByRole('button',{name:'Đầu danh sách',exact:true}).evaluate(e=>e.click());await viewport.evaluate(el=>el.scrollTop=88);await virt.waitForFunction(()=>document.querySelector('[data-virtual-viewport]')?.dataset.virtualFirst==='2');
 const vsearch=virt.getByRole('searchbox',{name:'Tìm trong 10.000 hàng'});await vsearch.fill('sua');vs=await inspectVirtual();verifyVirtual(vs);assert.equal(vs.count,5000);assert.equal(vs.first,1);assert.equal(vs.rows.find(r=>r.i===vs.first).key,'v3');
 await vsearch.fill('zzzz');vs=await inspectVirtual();verifyVirtual(vs);assert.equal(vs.count,0);assert.equal(vs.mounted,0);
 await vsearch.fill('');await viewport.evaluate(el=>el.style.height='440px');await virt.waitForFunction(()=>+document.querySelector('[data-virtual-viewport]')?.dataset.virtualLast===10);vs=await inspectVirtual();verifyVirtual(vs);assert.equal(vs.mounted,14);
 const oldViewport=await viewport.elementHandle();await virt.locator('#modules button').first().evaluate(e=>e.click());assert(await oldViewport.evaluate(el=>el.dataset.virtualDisposed==='true'&&!el.isConnected&&el.querySelectorAll('[data-virtual-key]').length===0));await oldViewport.dispose();console.log('Virtualizer: 10000 rows, bounded DOM, end, keyed reuse, anchor, search, resize, disposal passed');await virt.close();

 const dyn=await browser.newPage({viewport:{width:390,height:844}});await dyn.goto(url+'?dynamiclab=1');await dyn.locator('.contact[data-id=nv]').evaluate(e=>e.click());await dyn.locator('.conversation .panel-head button[data-go=crm]').evaluate(e=>e.click());const dv=dyn.locator('[data-virtual-viewport]');
 await dyn.waitForFunction(()=>document.querySelector('[data-virtual-viewport]')?.dataset.virtualCount==='1000');
 async function snapDyn(){return dv.evaluate(el=>{const first=Number(el.dataset.virtualFirst),row=el.querySelector('[data-virtual-index="'+first+'"]'),bounds=el.getBoundingClientRect();return {first,key:row?.dataset.virtualKey,offset:row?row.getBoundingClientRect().top-bounds.top:null,total:el.scrollHeight,top:el.scrollTop,bottom:el.scrollHeight-el.clientHeight-el.scrollTop,mounted:el.querySelectorAll('[data-virtual-key]').length,heights:[...el.querySelectorAll('[data-virtual-key]')].map(r=>r.getBoundingClientRect().height)}})}
 await dyn.waitForFunction(()=>new Set([...document.querySelectorAll('[data-virtual-key]')].map(e=>e.getBoundingClientRect().height)).size>=3);
 let ds=await snapDyn();assert(ds.mounted<24);assert(new Set(ds.heights).size>=3);
 await dyn.getByRole('button',{name:'Giữa mẫu',exact:true}).evaluate(e=>e.click());await dyn.waitForFunction(()=>+document.querySelector('[data-virtual-viewport]').dataset.virtualFirst>=495);await dyn.waitForTimeout(150);const before=await snapDyn();
 await dyn.getByRole('button',{name:'Nở dòng phía trên',exact:true}).evaluate(e=>e.click());await dyn.waitForFunction(total=>document.querySelector('[data-virtual-viewport]').scrollHeight>total,before.total);await dyn.waitForTimeout(100);const after=await snapDyn();assert.equal(after.key,before.key);assert(Math.abs(after.offset-before.offset)<=2);assert(after.top>before.top);
 await dyn.getByRole('button',{name:'Nở dòng đang đọc',exact:true}).evaluate(e=>e.click());await dyn.waitForFunction(total=>document.querySelector('[data-virtual-viewport]').scrollHeight>total,after.total);await dyn.waitForTimeout(100);const own=await snapDyn();assert.equal(own.key,after.key);assert(Math.abs(own.top-after.top)<=2);
 await dyn.getByRole('button',{name:'Cuối mẫu',exact:true}).evaluate(e=>e.click());await dyn.waitForTimeout(150);await dyn.getByRole('button',{name:'Cuối mẫu',exact:true}).evaluate(e=>e.click());const end=await snapDyn();assert(end.bottom<=2);await dyn.getByRole('button',{name:'Nở dòng cuối',exact:true}).evaluate(e=>e.click());await dyn.waitForFunction(total=>document.querySelector('[data-virtual-viewport]').scrollHeight>total,end.total);await dyn.waitForTimeout(100);const grownEnd=await snapDyn();assert(grownEnd.bottom<=2,JSON.stringify({end,grownEnd}));
 await dv.evaluate(el=>{el.querySelector('[data-virtual-key="d1000"] [data-dynamic-extra]').hidden=true});await dyn.waitForFunction(total=>document.querySelector('[data-virtual-viewport]').scrollHeight<total,grownEnd.total);await dyn.waitForTimeout(100);const shrunkEnd=await snapDyn();assert(shrunkEnd.bottom<=2,JSON.stringify({grownEnd,shrunkEnd}));
 await dv.evaluate(el=>el.scrollTop-=80);await dyn.waitForTimeout(100);const away=await snapDyn();assert(away.bottom>2);await dv.evaluate(el=>{el.querySelector('[data-virtual-key="d1000"] [data-dynamic-extra]').hidden=false});await dyn.waitForFunction(total=>document.querySelector('[data-virtual-viewport]').scrollHeight>total,away.total);await dyn.waitForTimeout(100);const awayAfter=await snapDyn();assert.equal(awayAfter.key,away.key);assert(Math.abs(awayAfter.offset-away.offset)<=2);assert(awayAfter.bottom>2);
 const dh=await dv.elementHandle();await dyn.locator('#modules button').first().evaluate(e=>e.click());assert(await dh.evaluate(e=>e.dataset.virtualDisposed==='true'&&!e.isConnected));await dh.dispose();console.log('Dynamic Virtualizer anchor and edge proof',JSON.stringify({before,after,own,end}));await dyn.close();
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
