// Static design audit. Run: node audit-design.cjs [--json]
// Reports cascade review candidates; does not prove computed-style equivalence.
function auditDesign(html,rules){
 const css=html.match(/<style\b[^>]*>([\s\S]*?)<\/style>/i)?.[1]||"";
 const version=html.match(/<title>[^<]*\b(v\d+\.\d+)<\/title>/i)?.[1]||null;
 const ids=[...rules.matchAll(/^- ([A-Z][A-Z0-9-]*-\d+):/gm)].map(m=>m[1]);
 const duplicates=[...new Set(ids.filter((x,i)=>ids.indexOf(x)!==i))];
 const tokens=[...new Set([...css.matchAll(/(--[\w-]+)\s*:/g)].map(m=>m[1]))];
 const unused=tokens.filter(k=>[...html.matchAll(new RegExp(k+"(?![\\w-])","g"))].length===1);
 const directFonts=[...css.matchAll(/font-size:\s*\d+(?:\.\d+)?px\b/g)].map(m=>m[0]);
 const rootDefinitions=new Map();for(const m of css.matchAll(/:root\s*\{([^{}]*)\}/g)){for(const t of m[1].matchAll(/(--[\w-]+)\s*:\s*([^;]+)/g)){if(!rootDefinitions.has(t[1]))rootDefinitions.set(t[1],[]);rootDefinitions.get(t[1]).push(t[2].trim())}}
 const repeatedRoot=[...rootDefinitions].filter(([,v])=>v.length>1).map(([token,values])=>({token,values}));
 const sameSelector=new Map();
 // A deliberately conservative scanner: strips comments, records exact selectors
 // within the same at-rule ancestry, and does not claim cross-selector cascade equivalence.
 const src=css.replace(/\/\*[\s\S]*?\*\//g,"");
 function scan(from,to,scope){
  let start=from,quote="",parens=0,brackets=0;
  for(let i=from;i<to;i++){const ch=src[i];if(quote){if(ch==="\\")i++;else if(ch===quote)quote="";continue}if(ch==="'"||ch==='"'){quote=ch;continue}
   if(ch==="(")parens++;else if(ch===")")parens--;else if(ch==="[")brackets++;else if(ch==="]")brackets--;
   if(parens||brackets)continue;if(ch===";"){start=i+1;continue}if(ch!=="{")continue;
   const selector=src.slice(start,i).trim().replace(/\s+/g," ");let depth=1,q="",end=i+1;
   for(;end<to;end++){const c=src[end];if(q){if(c==="\\")end++;else if(c===q)q="";continue}if(c==="'"||c==='"'){q=c;continue}if(c==="{")depth++;else if(c==="}"&&!--depth)break;}
   if(depth)break;
   if(/^@(media|supports|container|layer|keyframes|-webkit-keyframes)\b/.test(selector))scan(i+1,end,scope.concat(selector));
   else if(selector&&!selector.startsWith("@")){const body=src.slice(i+1,end);for(const m of body.matchAll(/(?:^|;)\s*([\w-]+)\s*:\s*([^;]+)/g)){const key=JSON.stringify([scope,selector,m[1]]);if(!sameSelector.has(key))sameSelector.set(key,[]);sameSelector.get(key).push(m[2].trim());}}
   i=end;start=end+1;
  }
 }
 scan(0,src.length,[]);
 const repeated=[...sameSelector].filter(([,v])=>v.length>1).map(([key,values])=>{const [scope,selector,property]=JSON.parse(key);return{scope,selector,property,values,kind:new Set(values).size===1?"identical":"review"}});
 let scripts=0,syntaxErrors=[];for(const m of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script>/gi)){if(/type=["']module/.test(m[1]))continue;try{new Function(m[2]);scripts++}catch(e){syntaxErrors.push(e.message)}}
 // VIEW-05: source-level guard. This is not an iOS performance test.
 const retired=/--chat-base|--keyboard-inset|--chat-visible-|inset-chat|keyboard-motion|data-kb-mode=native/.test(html);
 const shellFunction=html.match(/function visibleShellRect\([\s\S]*?\n\}/)?.[0];
 const viewportFunction=html.match(/function applyViewport\(\)\{[\s\S]*?\n\}/)?.[0]||"";
 const closeFunctions=html.slice(html.indexOf('function closingLayoutTarget('),html.indexOf('function supportsEarlyClose()'));
 let viewportCases=[],viewportError=null;
 try{
  const get=new Function(shellFunction+";return visibleShellRect")();
  const fallback={height:800,width:390};
  const cases=[
   [800,0,390,0],[700,0,390,0],[490,10,390,0],[490,10,390,0],
   [540,10,390,0],[670,0,390,0],[800,0,390,0],[375.5,4.2,640,3.5],
   [320,0,320,0],[800,0,390,0]
  ];
  viewportCases=cases.map(([height,top,width,left])=>{
   const r=get({height,width,offsetTop:top,offsetLeft:left},fallback);
   return {height,top,width,left,pass:r.height===height&&r.width===width&&r.top===top&&r.left===left};
  });
  const r=get(undefined,fallback);viewportCases.push({fallback:true,pass:r.height===800&&r.width===390&&r.top===0&&r.left===0});
  const stable=get({height:490,width:390,offsetTop:10,offsetLeft:0},fallback);
  const afterBlur=get({height:490,width:390,offsetTop:10,offsetLeft:0,focused:false},fallback);
  viewportCases.push({blurWithoutViewportChange:true,pass:JSON.stringify(stable)===JSON.stringify(afterBlur)});
 }catch(e){viewportError=e.message}
 const singleViewportOwner=!retired&&viewportFunction.includes("visibleShellRect(window.visualViewport")&&viewportFunction.includes("setProperty('--view-'+name")&&!/keyboardComposer\.style|draftForm\.style|\.style\.(bottom|transform|top)/.test(viewportFunction)&&css.includes("inset:auto 0 0;z-index:5");
 // KB-CORE-06: test the actual fast-path source with stubbed browser APIs.
 const fastPathNoLayout=!/getComputedStyle|getBoundingClientRect|scrollTop|scrollHeight|offsetHeight|clientHeight|nearBottom|classifyKeyboard|resizeDraft|setTimeout|watchViewport/.test(viewportFunction);
 let fastPathCases=[],fastPathQueued=0,fastPathError=null;
 try{
  const run=new Function(shellFunction+'\n'+closeFunctions+'\n'+viewportFunction+`
 let appliedRect={},rawRect={},earlyClose=null,viewportFrame=0,innerHeight=800,innerWidth=390,writes=[],queued=0; const performance={now:()=>0};
 const window={visualViewport:{height:800,width:390,offsetTop:0,offsetLeft:0}};
 const document={documentElement:{style:{setProperty:(k,v)=>writes.push([k,v])}}};
 const reconcileViewport=()=>{},requestAnimationFrame=()=>++queued;
 const cases=[[800,0],[500,0],[500,0],[540,0],[700,0],[800,0],[490,10],[490,10]].map(([height,top])=>{
  const count=writes.length,prior={...appliedRect};window.visualViewport.height=height;window.visualViewport.offsetTop=top;applyViewport();
  const expected=Object.keys(appliedRect).filter(k=>prior[k]!==appliedRect[k]).length;
  return{height,top,writes:writes.length-count,pass:appliedRect.height===height&&appliedRect.top===top&&writes.length-count===expected};
 });
 return{cases,queued};`)();fastPathCases=run.cases;fastPathQueued=run.queued;
 }catch(e){fastPathError=e.message}
 const keyboardFastPath=fastPathNoLayout&&!fastPathError&&fastPathQueued===1&&fastPathCases.length===8&&fastPathCases.every(c=>c.pass);
 let earlyCloseCases=[],earlyCloseError=null;
 try {
  const {closingLayoutTarget:t,selectClosingRect:c}=new Function(closeFunctions+";return {closingLayoutTarget,selectClosingRect}")();
  const raw={top:0,left:0,width:390,height:490},layout={width:390,height:800},target=t(raw,layout,800,true,false,1),p={target,until:600};
  earlyCloseCases=[
   ["close",target?.height===800],
   ["other input",t(raw,layout,800,true,true,1)===null],
   ["disabled",t(raw,layout,800,false,false,1)===null],
   ["zoom",t(raw,layout,800,true,false,2)===null],
   ["no keyboard",t({...raw,height:800},layout,800,true,false,1)===null],
   ["no baseline",t(raw,layout,0,true,false,1)===null],
   ["width changed",t(raw,{...layout,width:700},800,true,false,1)===null],
   ["stale raw",c(raw,p,10,1).rect.height===800],
   ["intermediate raw",c({...raw,height:650},p,200,1).rect.height===800],
   ["raw catches",c({...raw,height:800},p,300,1).pending===null],
   ["timeout",c(raw,p,600,1).rect.height===490],
   ["refocus cancel",c(raw,null,30,1).rect.height===490],
   ["rotate",c({...raw,width:700},p,50,1).pending===null],
   ["zoom after",c(raw,p,50,2).pending===null],
   ["toolbar difference",t(raw,{...layout,height:844},800,true,false,1)?.height===800]
  ].map(([name,pass])=>({name,pass}));
 }catch(e){earlyCloseError=e.message}
 const keyboardEarlyClose=!earlyCloseError&&earlyCloseCases.length===15&&earlyCloseCases.every(c=>c.pass)&&viewportFunction.includes("selectClosingRect(raw,earlyClose")&&html.includes("cancelEarlyClose();InputController.register(e.target)")&&html.includes("e.target===draft&&!InputController.isEditable(e.relatedTarget)");
 const checks={singleViewportOwner,keyboardFastPath,keyboardEarlyClose,viewportSequence:!viewportError&&viewportCases.length===12&&viewportCases.every(c=>c.pass),version:!!version&&rules.includes("Chỉ mục rule đang có hiệu lực ("+version+")"),uniqueRuleIds:duplicates.length===0,noDirectFontSizes:directFonts.length===0,classicScriptSyntax:syntaxErrors.length===0&&scripts>0};
 return{version,checks,viewportCases,viewportError,fastPathCases,fastPathError,earlyCloseCases,earlyCloseError,pass:Object.values(checks).every(Boolean),scripts,syntaxErrors,duplicates,directFonts,unused,repeatedRoot,importantCount:(css.match(/!important/g)||[]).length,repeatedCount:repeated.length,repeated};
}
const fs=require('node:fs');const path=require('node:path');
const result=auditDesign(fs.readFileSync(path.join(__dirname,'index.html'),'utf8'),fs.readFileSync(path.join(__dirname,'RULES.md'),'utf8'));
console.log(JSON.stringify(result,null,2));process.exitCode=result.pass?0:1;
