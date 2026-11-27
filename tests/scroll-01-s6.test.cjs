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

test('repeated grow and native clamp shrink reset budget only for changed geometry',()=>{
 const f=fixture(),S=f.controller,m=f.messages;S.flushTailFrame();
 for(let n=0;n<5;n++){m.scrollHeight=1540;S.flushTailFrame();assert.equal(m.scrollTop,740);assert(S.tail);m.scrollHeight=1500;m.scrollTop=700;S.flushTailFrame();assert(S.tail);assert.equal(S.tail.attempts,0)}
 assert.equal(f.counts().writes,6);assert.equal(f.trace.filter(x=>x[0]==='tail-conflict').length,0);
});
test('successful arrival alone does not replenish same geometry conflict budget',()=>{
 const f=fixture(),S=f.controller,m=f.messages;S.flushTailFrame();S.flushTailFrame();m.scrollTop=0;S.flushTailFrame();S.flushTailFrame();m.scrollTop=0;S.flushTailFrame();assert.equal(f.counts().writes,2);assert.equal(S.tail,null);
});

test('native shrink observation updates target before shared frame without a position write',()=>{
 const f=fixture(),S=f.controller,m=f.messages;S.flushTailFrame();
 for(let n=0;n<5;n++){m.scrollHeight=1540;S.flushTailFrame();assert.equal(m.scrollTop,740);const writes=f.counts().writes;m.scrollHeight=1500;m.scrollTop=700;S.userMoved();assert.equal(S.tail.target,'700:800');assert.equal(S.tail.attempts,0);assert.equal(f.counts().writes,writes)}
 assert.equal(f.counts().writes,6);assert(S.tail);
});


test('S8 arrow presentation only for a stationary reading state',()=>{
 const S=fixture().controller,base={near:false,visible:true,moving:false,following:false,ready:true};assert.equal(S.jumpVisible(base),true);for(const delta of [{near:true},{visible:false},{moving:true},{following:true},{ready:false}])assert.equal(S.jumpVisible({...base,...delta}),false);assert(html.includes("['touchend','touchcancel','scrollend']"));assert(!html.includes('ScrollController.captureMovingJump()'));
});
