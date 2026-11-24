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
  await page.waitForFunction(()=>window.apiProof);
  const inspect=selector=>page.locator(selector).first().evaluate(el=>window.apiProof.describe(el));
  const fonts=async list=>{for(const [sel,size,line,weight] of list){const x=await inspect(sel);assert.equal(x.computed.size,size,sel);assert.equal(x.computed.line,line,sel);assert.equal(x.computed.weight,weight,sel);assert.equal(x.fontOK,true,sel)}};
  const read=()=>page.evaluate(()=>window.apiProof.report());
  await fonts([['.directory .panel-head strong',17,22,600],['.directory .label-version',10,16,400],['.contact .identity b',15,20,600],['.contact .identity small',12,16,400],['.contact .time',12,16,400]]);
  const dir=await read();assert(dir.family.total>0);console.log('Family directory',width,JSON.stringify(dir.family.counts),JSON.stringify(dir.family.issues.slice(0,12)));assert.equal(dir.button.visible,dir.button.registered);assert.equal(dir.icon.visible,dir.icon.registered);assert.equal(dir.layout.contactGeometry.length,4);assert(dir.layout.contactGeometry.every(x=>x.inside<=1&&x.overlap<=1));
  await page.locator('#addContact').evaluate(el=>el.click());
  await page.waitForSelector('dialog[open]');
  assert.equal((await read()).popup.profiles[0],'form');console.log('Family popup',width,JSON.stringify((await read()).family.counts));
  await fonts([['dialog[open] h3',17,22,600],['dialog[open] p',13,18,400]]);
  await page.locator('dialog[open] button').last().click();
  await page.waitForSelector('dialog[open]',{state:'detached'});
  await page.locator('.contact[data-id=nv]').evaluate(el=>el.click());
  await page.waitForFunction(()=>document.querySelector('#app').dataset.screen==='chat');
  await fonts([['#currentName',17,22,600],['#currentRole',12,16,400],['#messages .bubble',17,26,400],['#messages .meta',12,16,400],['#draft',17,22,400]]);
  assert.equal((await inspect('#draft')).input,'chat');console.log('Family chat',width,JSON.stringify((await read()).family.counts));
  const sizes=await page.evaluate(()=>{const root=document.documentElement,s=root.style,old=s.getPropertyValue('--type-chat'),priority=s.getPropertyPriority('--type-chat'),get=()=>[...document.querySelectorAll('#messages .bubble')].map(e=>parseFloat(getComputedStyle(e).fontSize));const before=get();let during,after;try{s.setProperty('--type-chat','20px');during=get()}finally{old?s.setProperty('--type-chat',old,priority):s.removeProperty('--type-chat');after=get()}return {before,during,after}});
  assert(sizes.before.length>=2);assert(sizes.before.every(n=>n===17));assert(sizes.during.every(n=>n===20));assert.deepEqual(sizes.after,sizes.before);
  // Reload checks first paint roles persist; no synthetic keyboard is represented as native.
  await page.reload();await page.waitForFunction(()=>window.apiProof);
  await fonts([['.directory .label-version',10,16,400],['.contact .identity b',15,20,600]]);
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
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
