const assert=require('node:assert/strict');
const {test}=require('node:test');
const fs=require('node:fs');
const html=fs.readFileSync('index.html','utf8');
const src=html.slice(html.indexOf('const ScrollController={'),html.indexOf('function appShellActive(){'));
function fixture(){
 const messages={scrollHeight:1500,clientHeight:800,scrollTop:0},app={hidden:false,dataset:{screen:'chat'}},document={hidden:false};
 let scheduled=0,writes=0,restores=0,blocked=false,paint=0;
 const trace=[];
 const S=new Function('messages','app','document','scheduleJump','syncJump',src+';return ScrollController')(messages,app,document,()=>scheduled++,()=>{});
 S.following=()=>!!S.tail;S.interacting=()=>false;S.trace=(k,d)=>trace.push([k,d]);S.stopFollowing=()=>{S.tail=null};
 S.tail={target:null,attempts:0,jump:true};S.flushProjection=()=>{S.finishProjection({room:'r',epoch:1,follow:false,top:0},messages)};
 S.restoreReadingAnchor=()=>restores++;
 S.drainImagePaint=()=>{paint++;return true};
 S.end=()=>{writes++;if(!blocked)messages.scrollTop=messages.scrollHeight-messages.clientHeight};
 // Actual controller reads scope globals; construct fixture with scope from closure instead of mutating production.
 const body=src+';return ScrollController';
 const controller=new Function('messages','app','document','scheduleJump','syncJump','isLive','navigationPending','active','navigationEpoch',body)(messages,app,document,()=>scheduled++,()=>{},true,false,'r',1);
 for(const k of ['following','interacting','trace','stopFollowing','tail','restoreReadingAnchor','drainImagePaint','end'])controller[k]=S[k];
 // Rebind following, stop and pending projection to actual controller.
 controller.following=()=>!!controller.tail;controller.stopFollowing=()=>{controller.tail=null};
 controller.flushProjection=()=>controller.finishProjection({room:'r',epoch:1,follow:false,top:0},messages);
 return {controller,messages,trace,counts:()=>({scheduled,writes,restores,paint}),block:v=>{blocked=v}};
}
test('one frame, one physical target; stale history projection cannot fight explicit arrow',()=>{
 const f=fixture(),S=f.controller;S.flushTailFrame();assert.equal(f.messages.scrollTop,700);assert.equal(f.counts().writes,1);assert.equal(f.counts().restores,0);
 S.flushTailFrame();assert.equal(f.counts().writes,1);
 f.messages.scrollHeight=1540;S.flushTailFrame();assert.equal(f.messages.scrollTop,740);assert.equal(f.counts().writes,2);
 S.flushTailFrame();assert.equal(f.counts().writes,2);
});
test('unchanged physical target cannot be retried indefinitely after native displacement',()=>{
 const f=fixture(),S=f.controller;f.block(true);for(let i=0;i<20;i++)S.flushTailFrame();
 assert.equal(f.counts().writes,2);assert.equal(S.tail,null);assert.equal(f.trace.filter(x=>x[0]==='tail-conflict').length,1);
});
test('observer and follow projection must not directly reconcile tail',()=>{
 assert(!src.includes("this.reconcileTail('content-resize')"));assert(!src.includes("this.reconcileTail('projection-tail')"));assert(html.includes('ScrollController.flushTailFrame()'));
});
