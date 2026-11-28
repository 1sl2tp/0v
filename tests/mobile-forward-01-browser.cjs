const {chromium,webkit}=require('playwright');
const assert=require('node:assert/strict');
const http=require('node:http'),fs=require('node:fs'),path=require('node:path');
const base=path.join(process.cwd(),'references'),files=new Set(['mobile-forward-01-lab.html','mobile-forward-01-lab.mjs','mobile-forward-01-policy.mjs']);
(async()=>{
const server=http.createServer((req,res)=>{const name=req.url.slice(1);if(!files.has(name)){res.writeHead(404).end();return}res.setHeader('Content-Type',name.endsWith('.mjs')?'text/javascript':'text/html; charset=utf-8');res.end(fs.readFileSync(path.join(base,name)))});
await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
const url='http://127.0.0.1:'+server.address().port+'/mobile-forward-01-lab.html';
try{for(const engine of [chromium,webkit]){const b=await engine.launch();try{for(const width of [320,375,390,430]){
 const p=await b.newPage({viewport:{width,height:844},isMobile:true,hasTouch:true});const errors=[];p.on('pageerror',e=>errors.push(e.message));await p.route('**/*',r=>r.request().url().startsWith(url.slice(0,url.lastIndexOf('/')+1))?r.continue():r.abort());await p.goto(url);
 await p.locator('#preview').click();await p.waitForFunction(()=>!document.querySelector('#review').hidden);
 assert.equal(await p.locator('#total').textContent(),'54');assert.equal(await p.locator('#skip').textContent(),'10');assert.equal(await p.locator('#count').textContent(),'44');assert.equal(await p.locator('#items li').count(),44);
 assert.equal(await p.locator('#items li').first().textContent(),'Ảnh mẫu 1');assert.equal(await p.locator('#items li').nth(1).textContent(),'Ảnh mẫu 11');assert(await p.locator('#realSend').isDisabled());
 assert(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
 await p.locator('#send').click();await p.waitForFunction(()=>document.querySelector('#status').textContent.includes('Hoàn tất mô phỏng 44'));
 await p.locator('#preview').click();assert.equal(await p.locator('#count').textContent(),'0');assert(await p.locator('#send').isDisabled());
 await p.locator('#destination').selectOption({index:2});assert(await p.locator('#review').isHidden());await p.locator('#preview').click();assert.equal(await p.locator('#count').textContent(),'53');await p.locator('#send').click();await p.locator('#stop').click();await p.waitForFunction(()=>document.querySelector('#status').textContent.startsWith('Đã dừng.'));assert(await p.locator('#send').isDisabled());assert(await p.locator('#realSend').isDisabled());
 assert.deepEqual(errors,[]);console.log(engine.name(),width,'PASS');await p.close();
 }}finally{await b.close()}}}finally{server.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
