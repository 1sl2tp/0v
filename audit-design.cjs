// Static design audit. Run: node audit-design.cjs [--json]
// Reports cascade review candidates; does not prove computed-style equivalence.
function auditDesign(html,rules,baseline){
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
 const protectedRanges=[["// KeyboardController:","/* Opt-in dynamic"],["let preFocusAnchor=null;","// The form-width ResizeObserver"],["function composerMode(","draft.addEventListener('input',resizeDraft)"],["/* Surface Parent:","/* FL owner:"]];
 const keyboardBaseline=typeof baseline==="string"&&protectedRanges.every(([a,b])=>{const part=s=>{const x=s.indexOf(a),y=s.indexOf(b,x);return x>=0&&y>x?s.slice(x,y):null};return part(html)!==null&&part(html)===part(baseline)});
 let inputCases=[],inputError=null;
 try{
  const src=html.slice(html.indexOf("function canonicalText("),html.indexOf("function commitNumericField("))+"\n"+html.match(/function normalizeLines\(value\)\{[^\n]+/)[0];
  const {canonicalText:c,searchText:k,committedMessage:m,numericText:n}=new Function(src+";return {canonicalText,searchText,committedMessage,numericText}")();
  inputCases=[
   ["NFC",c("Tie\u0302\u0301ng Vie\u0323\u0302t")==="Tiếng Việt"],
   ["search NFC",k("Đa\u0323̆ng")===k("Đặng")],
   ["ellipsis",m("… ...").text==="… ..."],
   ["Vietnamese",m("đặng thị hồng…").text==="Đặng thị hồng…"],
   ["original",m("  tiếng việt...  ").originalText==="  tiếng việt...  "],
   ["link",m("https://example.com/a...").text==="https://example.com/a..."],
   ["emoji",m("👨‍👩‍👧‍👦 …").text==="👨‍👩‍👧‍👦 …"],
   ["number",n("12a34",6,false)==="1234"],
   ["money",n("1.250.000",12,true)==="1.250.000"],
   ["empty",n("",12,true)===""],
   ["limit",n("1234567",6,false)==="123456"]
  ].map(([name,pass])=>({name,pass}));
 }catch(e){inputError=e.message}
 const textInputContract=!inputError&&inputCases.length===11&&inputCases.every(c=>c.pass)&&css.includes("--input-font-floor:16px")&&css.includes("--input-font-size:max(var(--input-font-floor),var(--type-input))")&&!html.includes("function normalizeDraft(")&&html.includes("if(Input.isComposing(draft,e))return;")&&html.includes("commitNumericField(el,p.maxDigits,p.grouped)");
 let inputApiCases=[],inputApiError=null;
 try{
  const src=html.slice(html.indexOf("const Input=(()=>{"),html.indexOf("function normalizeLines(value)"));
  const run=new Function(src+`
 function fake(tag){return {tagName:tag.toUpperCase(),type:'text',lang:'',dataset:{},attrs:{},events:{},classList:{add(){}},hasAttribute(k){return k in this.attrs},setAttribute(k,v){this.attrs[k]=v},addEventListener(k,f){(this.events[k]??=[]).push(f)}}}
 const document={createElement:fake},calls=[];
 function commitNumericField(el,max,grouped){calls.push([el,max,grouped])}
 function isTextComposing(el,e){return !!e?.isComposing}
 function committedMessage(v){return v}function searchText(v){return v}
 `.replace("const document={createElement:fake},calls=[];","var document={createElement:fake},calls=[];")+`
 const a=Input.create({type:'text',value:'abc',label:'Tên'}),q=Input.create({type:'quantity',value:'10'}),m=Input.create({type:'money',value:'1000'}),n=Input.create({type:'multiline'}),d=fake('textarea');
 let updates=0;const search=Input.create({type:'search',onCommittedInput:()=>updates++});
 search.events.input[0]({isComposing:true});search.events.input[0]({isComposing:false});search.events.compositionend[0]({});
 Input.bind(d,{type:'chat'});Input.bind(q,{type:'quantity'});
 let bad=false;try{Input.create({type:'unknown'})}catch{bad=true}
 return [['text',a.value==='abc'&&a.attrs['aria-label']==='Tên'],['six profiles',Object.keys(Input.types).length===6],['quantity',q.inputMode==='numeric'&&calls[0][1]===6&&!calls[0][2]],['money',m.inputMode==='numeric'&&calls[1][1]===12&&calls[1][2]],['multiline',n.tagName==='TEXTAREA'&&n.rows===4],['existing node',Input.bind(d,{type:'chat'})===d],['idempotent',calls.length===2],['search IME',updates===2],['invalid type',bad]].map(([name,pass])=>({name,pass}));
 `)();inputApiCases=run;
 }catch(e){inputApiError=e.message}
 const inputApiContract=!inputApiError&&inputApiCases.length===9&&inputApiCases.every(c=>c.pass);
 let buttonApiCases=[],buttonApiError=null;
 try{
  const src=html.slice(html.indexOf("const IconController={"),html.indexOf("ButtonController.scan(document);"));
  const run=new Function(src+`
 function fake(tag){const el={tagName:tag.toUpperCase(),attrs:{},dataset:{},children:[],events:{},className:'',textContent:'',id:'',classList:{contains(k){return el.className.split(/\\s+/).includes(k)}},setAttribute(k,v){this.attrs[k]=String(v)},getAttribute(k){return this.attrs[k]},hasAttribute(k){return k in this.attrs},addEventListener(k,f){(this.events[k]??=[]).push(f)},append(c){this.children.push(c);c.parent=this},querySelectorAll(k){return k==='svg'?this.children.filter(c=>c.tagName==='SVG'):[]},querySelector(k){return this.children.find(c=>c.attrs['data-api-icon'])||null},closest(k){return k==='button'?this.parent:null},replaceWith(c){const p=this.parent;p.children[p.children.indexOf(this)]=c;c.parent=p}};return el}
 const document={createElement:fake,createElementNS:(_ns,tag)=>fake(tag)};
 let clicks=0;const a=Button.create({kind:'text',text:'OK',onClick:()=>clicks++}),b=Button.create({kind:'outline',disabled:true}),c=Button.create({kind:'icon',icon:'copy',label:'Sao chép'}),d=Button.create({kind:'primary',type:'submit',text:'Gửi'});
 a.events.click[0]();Button.bind(a);const first=c.children[0];Icon.replace(c,'copied');
 let badKind=false,badIcon=false,badLabel=false;try{Button.create({kind:'unknown'})}catch{badKind=true}try{Icon.create('unknown')}catch{badIcon=true}try{Button.create({icon:'copy'})}catch{badLabel=true}
 return [['text/default',a.type==='button'&&a.dataset.buttonKind==='text'],['outline/disabled',b.disabled&&b.dataset.buttonKind==='outline'],['icon/name',c.attrs['aria-label']==='Sao chép'&&c.dataset.buttonKind==='icon'],['primary/submit',d.type==='submit'&&d.dataset.buttonShape==='round'],['callback once',clicks===1&&a.events.click.length===1],['glyph replaced',first!==c.children[0]&&c.children[0].attrs['data-api-icon']==='copied'&&c.children.length===1],['decorative',c.children[0].attrs['aria-hidden']==='true'],['invalid kind',badKind],['invalid glyph',badIcon],['missing label',badLabel]].map(([name,pass])=>({name,pass}));
 `)();buttonApiCases=run;
 }catch(e){buttonApiError=e.message}
 const buttonApiContract=!buttonApiError&&buttonApiCases.length===10&&buttonApiCases.every(c=>c.pass)&&html.includes("if(tag==='button')return Button.create(")&&html.includes("Icon.replace(b,'copied')");
 let popupApiCases=[],popupApiError=null;
 try{
  const src=html.slice(html.indexOf("const PopupController="),html.indexOf("const IconController="));
  popupApiCases=new Function(src+`
 let listeners=0,raf=0,removed=0,fail=false,disposals=[];
 function fake(tag){return {tagName:tag.toUpperCase(),dataset:{},attrs:{},children:[],events:{},open:false,style:{values:{},getPropertyValue(k){return this.values[k]},setProperty(k,v){this.values[k]=v}},setAttribute(k,v){this.attrs[k]=v},append(n){this.children.push(n)},addEventListener(k,f){this.events[k]=f},showModal(){if(fail)throw Error('test');this.open=true},close(v){this.returnValue=v;this.open=false;this.events.close?.()},remove(){removed++}}}
 const document={createElement:fake,querySelector:()=>null,body:{append(){}}};
 const target={addEventListener(){listeners++},removeEventListener(){listeners--}};
 const window={...target,visualViewport:{...target,width:390,height:500,offsetTop:8,offsetLeft:0}};
 const innerWidth=390,innerHeight=800,requestAnimationFrame=()=>++raf,cancelAnimationFrame=()=>{};
 const Button={create(o){const b=fake('button');b.options=o;return b}};
 const a=Popup.open({type:'form',title:'Form',content:fake('input'),onDispose:r=>disposals.push(r)}),before=listeners;
 const rejected=Popup.open({type:'menu',title:'Menu',onDispose:r=>disposals.push(r)});
 const same=PopupController.active===a&&a.open;
 const closed=Popup.close(a,'ok'),clean=listeners===0&&PopupController.active===null;
 const noActive=Popup.close()===false;
 const levels=['menu','confirm','form','media','preview'].map(type=>{const d=Popup.open({type,title:type});const n=d.dataset.popupLevel;Popup.close(d);return n}).join(',');
 let invalid=false,missing=false,failed=false;try{Popup.open({type:'bad',title:'x'})}catch{invalid=true}try{Popup.open({type:'form',title:''})}catch{missing=true}
 fail=true;try{Popup.open({type:'form',title:'error',onDispose:r=>disposals.push(r)})}catch{failed=true}
 return [['profiles',levels==='1,2,3,4,4'],['named native',a.attrs['aria-label']==='Form'],['safe initial focus',a.children.at(-1).attrs.autofocus===''],['viewport',a.style.values['--popup-height']==='500px'&&a.style.values['--popup-top']==='8px'],['listeners',before===3],['reject second',rejected===null&&same&&disposals[0]==='busy'],['close result',closed&&a.returnValue==='ok'],['cleanup',clean&&disposals.filter(x=>x==='close').length===1],['close idle',noActive],['invalid profile',invalid],['missing label',missing],['open error',failed&&PopupController.active===null&&disposals.at(-1)==='error']].map(([name,pass])=>({name,pass}));
 `)();
 }catch(e){popupApiError=e.message}
 const popupApiContract=!popupApiError&&popupApiCases.length===12&&popupApiCases.every(c=>c.pass);
 let typeApiCases=[],typeApiError=null;
 try{
  const src=html.slice(html.indexOf("const Typography=(()=>{"),html.indexOf("function make(tag,cls,txt)"));
  typeApiCases=new Function(src+`
 const document={createElement(tag){return {tagName:tag.toUpperCase(),dataset:{},textContent:'',isContentEditable:false,hasAttribute:()=>false}}};
 const a=Typography.create({role:'body',text:'Tiếng Việt… <b>...'}),b=Typography.create({role:'money',text:'1.250.000 đ',weight:'bold',decoration:'underline'});
 const same=Typography.bind(b,{role:'number'})===b;
 const throws=f=>{try{f();return false}catch{return true}};
 return [['roles',Typography.roles.length===10],['text preserved',a.textContent==='Tiếng Việt… <b>...'],['body',a.dataset.typeRole==='body'],['same node',same],['clear variants',!b.dataset.typeWeight&&!b.dataset.typeDecoration],['invalid role',throws(()=>Typography.create({role:'bad'}))],['invalid weight',throws(()=>Typography.create({role:'body',weight:900}))],['invalid decoration',throws(()=>Typography.create({role:'body',decoration:'bad'}))],['editable',throws(()=>Typography.bind({tagName:'SPAN',isContentEditable:true},{role:'body'}))],['input rejected',throws(()=>Typography.create({role:'body',tag:'input'}))],['number original',b.textContent==='1.250.000 đ']].map(([name,pass])=>({name,pass}));
 `)();
 }catch(e){typeApiError=e.message}
 const typeApiContract=!typeApiError&&typeApiCases.length===11&&typeApiCases.every(c=>c.pass)&&['--font-ui:', '--weight-regular:400','--weight-medium:500','--weight-semibold:600','--weight-bold:700','--type-input:17px','--line-input:22px','--type-chat:18px','--line-chat:27px'].every(x=>css.includes(x))&&css.includes('[data-type-role=money]')&&css.includes('font-variant-numeric:tabular-nums')&&!html.slice(html.indexOf('const Typography=(()=>{'),html.indexOf('function make(tag,cls,txt)')).includes('.style');
 let geoCases=[],geoError=null;
 try{
  const src=html.slice(html.indexOf("const Geometry=(()=>{"),html.indexOf("function make(tag,cls,txt)"));
  geoCases=new Function(src+`
 const document={createElement(tag){return {tagName:tag.toUpperCase(),dataset:{},children:[],append(c){this.children.push(c)}}}};
 const a={x:0,y:0,width:100,height:80},b={x:10,y:10,width:40,height:40},c={x:60,y:10,width:50,height:40},d={x:40,y:10,width:30,height:30};
 const throws=f=>{try{f();return false}catch{return true}};
 const row=Layout.create({kind:'row',gap:'md',columnGap:'xs',radius:'lg',children:['A','B']}),grid=Layout.create({kind:'grid',columns:3}),frame=Layout.frame({size:'sm',shape:'round',children:['A']});
 return [['rect',Geometry.rect(a).right===100],['contain',Geometry.inside(a,b)===0],['overflow',Geometry.inside(a,c)===10],['overlap',Geometry.overlap(b,d)===10],['touch edge',Geometry.overlap(b,{x:50,y:10,width:20,height:40})===0],['gap x',Geometry.gap(b,c)===10],['gap y',Geometry.gap(b,{x:10,y:58,width:40,height:10},'y')===8],['center',Geometry.centerDelta(a,b)===20],['square',Geometry.squareError(b)===0&&Geometry.squareError(a)===20],['insets',Geometry.equalInsets(a,{x:20,y:0,width:60,height:80})===0],['adaptive threshold',Geometry.columnCount(367,180,8)===1&&Geometry.columnCount(368,180,8)===2],['zero width',Geometry.columnCount(0,180,8)===1],['bad rect',throws(()=>Geometry.rect({x:0,y:0,width:-1,height:4}))],['bad axis',throws(()=>Geometry.gap(a,b,'z'))],['bad grid budget',throws(()=>Geometry.columnCount(100,0,8))],['row props',row.dataset.geoLayout==='row'&&row.dataset.geoRowGap==='md'&&row.dataset.geoColumnGap==='xs'&&row.children.length===2&&row.dataset.geoRadius==='lg'],['grid columns',grid.dataset.geoColumns==='3'],['frame',frame.dataset.geoShape==='round'&&frame.dataset.geoFrameSize==='sm'],['invalid layout',throws(()=>Layout.create({kind:'bad'}))],['invalid gap',throws(()=>Layout.create({gap:10}))],['invalid columns',throws(()=>Layout.create({columns:5}))],['invalid frame',throws(()=>Layout.frame({shape:'bad'}))]].map(([name,pass])=>({name,pass}));
 `)();
 }catch(e){geoError=e.message}
 const geometryApiContract=!geoError&&geoCases.length===22&&geoCases.every(c=>c.pass)&&css.includes('repeat(var(--geo-columns,2),minmax(0,1fr))')&&css.includes('repeat(auto-fit,minmax(min(100%,var(--geo-column-min)),1fr))')&&html.includes('Geometry.inside(parent,child)')&&html.includes('Geometry.overlap(a,b)');
 const mainFactory=html.slice(html.indexOf('/* MAIN VIEW FACTORIES */'),html.indexOf('/* END MAIN VIEW FACTORIES */'));
 const applicationCoverage=mainFactory.includes('Main.mount();')&&mainFactory.includes('Contact.create(')&&mainFactory.includes('Layout.slot(')&&mainFactory.includes('Typography.create(')&&mainFactory.includes('Button.create(')&&mainFactory.includes("Input.create({type:'search'")&&mainFactory.includes("Input.create({type:'chat'")&&html.includes('messages.append(Message.create(')&&html.includes("Popup.open({type:'form',title:'Thêm danh bạ'")&&css.includes('#app [data-type-role=version]');
 const apiProofContract=html.includes("get('apicheck')==='1'")&&html.includes('window.apiProof=Object.freeze({report,describe})')&&html.includes("heading.dataset.typeRole='title'")&&html.includes("node.dataset.typeRole='detail'");
 const mainBody=html.slice(html.indexOf('<body>'),html.indexOf('<script>',html.indexOf('<body>'))).trim();
 const familyCoverage=mainBody==='<body>'&&mainFactory.includes("family:'Keyboard'")&&mainFactory.includes("family:'Scroll'")&&html.includes('window.familyAudit=()=>FamilyRegistry.audit()');
 const parentRuntime=html.includes('Layout.applyProfile(e,classes)')&&mainFactory.includes('return Button.bind(e)')&&css.includes('[data-layout-profile=contact-row]')&&css.includes('[data-avatar-profile]')&&css.includes('[data-button-text-role=detail]');
 const rebuiltMain=mainFactory.includes('Main.mount();')&&mainFactory.includes('Contact.create(')&&!html.includes('function bindMainParents()')&&!/<div id="app"/.test(mainBody);
 const unifiedOwners=html.includes('const OwnerRuntime=Object.freeze(')&&html.includes('const KeyboardController=Object.freeze(')&&html.includes('const Avatar=(()=>{')&&html.includes('const Surface=(()=>{')&&html.includes('MISSING-PARENT')&&html.includes('MISSING-SLOT')&&css.includes('[data-ui-slot~="panel-head"]')&&css.includes('[data-ui-slot~="message"]');
 const surfaceContract=(()=>{try{const src=html.slice(html.indexOf('const Surface=(()=>{'),html.indexOf('const Popup=(()=>{'));const S=new Function('const Layout={create:()=>({dataset:{}})};'+src+';return Surface')();const nodes=S.variants.map(variant=>S.create({variant}));const valid=nodes.every((n,i)=>n.dataset.surfaceVariant===S.variants[i]&&n.dataset.surfaceOwner==='Surface');const glass=S.bind({dataset:{}},'g1');let invalid=false,mixed=false;try{S.apply({dataset:{}},'unknown')}catch(e){invalid=true}try{S.apply(glass,'raised')}catch(e){mixed=true}return valid&&invalid&&mixed&&glass.dataset.glass==='g1'&&['subtle','outlined','raised','selected'].every(v=>css.includes('[data-surface-owner=Surface][data-surface-variant='+v+']'))&&css.includes('--surface-raised-shadow')&&html.includes('renderSurfaceLab(panel)')}catch(e){return false}})();
 const avatarContract=(()=>{try{const src=html.slice(html.indexOf('const Avatar=(()=>{'),html.indexOf('const DisplayRoles='));const A=new Function(src+';return Avatar')();return A.initials('Nguyễn Văn')==='NV'&&A.initials('')==='?'&&A.sizes.length===4&&A.shapes.length===3&&html.includes("Avatar.create({text:avatar,size:'directory'})")&&html.includes("Avatar.update($('#currentAvatar')")&&css.includes('object-fit:cover')&&html.includes('renderAvatarLab(panel)')}catch(e){return false}})();
 const mediaContract=(()=>{try{const source=html.slice(html.indexOf('const MediaController={'),html.indexOf('const PopupController='));const M=new Function(source+';return MediaController')();return M.fit(640,360,320,320)===.5&&M.fit(360,640,320,320)===.5&&M.fit(40,40,320,320)===1&&M.fit(0,40,320,320)===0&&html.includes('MediaController.gallery([...types]')&&html.includes('renderMediaLab(panel)')&&css.includes('[data-media-viewer-stage]>img')}catch(e){return false}})();
 const mediaGestureContract=(()=>{try{const source=html.slice(html.indexOf('const MediaController={'),html.indexOf('const PopupController='));const M=new Function(source+';return MediaController')();const p=M.gesturePair({x:0,y:0},{x:6,y:8});return p.x===3&&p.y===4&&p.distance===10&&M.clampZoom(.2)===1&&M.clampZoom(10)===4&&M.clampZoom(2)===2&&html.includes("listeners.abort();pointers.clear()")&&html.includes("['pointercancel',onEnd]")&&css.includes('[data-media-viewer-stage]{touch-action:none')}catch(e){return false}})();
 const systemsContract=html.includes('renderSystemsLab(panel)')&&html.includes('const Motion=Object.freeze(')&&html.includes('const Responsive=Object.freeze(')&&html.includes('const State=Object.freeze(')&&html.includes('const Theme=Object.freeze(')&&html.includes('async compress(file,')&&html.includes('releaseVideo(el)')&&html.includes('snapshot(el)')&&html.includes("density='balanced'")&&html.includes('panel({title,status=')&&css.includes('[data-responsive-profile=cards]');
 const releaseUpdaterContract=(()=>{try{const src=html.slice(html.indexOf('const parts=v=>'),html.indexOf(' const live=',html.indexOf('const ReleaseUpdater=')));const newer=new Function(src+';return newer')();return newer('v13.46','v13.45')&&newer('v14.0','v13.99')&&!newer('v13.45','v13.45')&&!newer('v13.9','v13.45')&&!newer('bad','v13.45')&&html.includes("cache:'no-store'")&&html.includes("published!==pending")&&html.includes("location.replace(target.href)")&&html.includes("!dirty&&!document.hidden")}catch{return false}})();
 const collectionContract=(()=>{try{const src=html.slice(html.indexOf('const Collection=(()=>{'),html.indexOf('/* MAIN VIEW FACTORIES */'));const C=new Function('const Input={searchKey:s=>String(s).toLowerCase()};'+src+';return Collection')();const items=[{id:'a',name:'Bánh 2',group:'A'},{id:'b',name:'Bánh 10',group:'A',disabled:true},{id:'c',name:'Sữa',group:'B'}];const m=C.create(items);m.toggle('a');m.setView({group:'B'});m.selectVisible();if(m.status().selected!==2||m.status().visibleSelected!==1)return false;m.setView({group:'A',order:'name-desc'});m.selectVisible();if(m.selectedIds().join(',')!=='a,c'||m.visible()[0].id!=='b')return false;m.selectVisible(false);if(m.selectedIds().join(',')!=='c')return false;let duplicate=false;try{C.create([items[0],items[0]])}catch{duplicate=true}const single=C.create(items,{mode:'single'});single.toggle('a');single.toggle('c');return duplicate&&single.selectedIds().join(',')==='c'&&C.searchKey('SỮA ĐẶC')==='sua dac'&&C.searchKey('Nước')==='nuoc'&&C.project([{id:'v',name:'Đặng Thị Sữa'}],{query:'dang thi sua'}).length===1&&html.includes('Collection.project(Object.entries(people)')&&html.includes('renderCollectionLab(panel)')}catch{return false}})();
 const virtualContract=(()=>{try{const src=html.slice(html.indexOf('const Virtualizer=(()=>{'),html.indexOf('/* MAIN VIEW FACTORIES */'));const V=new Function(src+';return Virtualizer')();const first=V.range(10000,0,280,44,4),mid=V.range(10000,220000,280,44,4),end=V.range(10000,99999999,280,44,4),empty=V.range(0,0,280);let invalid=false;try{V.range(1,0,280,0)}catch{invalid=true}return first.start===0&&first.end===11&&first.total===440000&&mid.first===5000&&mid.start===4996&&mid.end===5011&&end.end===10000&&end.last===10000&&empty.total===0&&invalid&&html.includes("observer.disconnect();viewport.removeEventListener('scroll',schedule)")&&html.includes('ScrollController.writeLocal(viewport')&&html.includes('renderVirtualLab(panel)')}catch{return false}})();
 const checks={virtualContract,collectionContract,releaseUpdaterContract,systemsContract,mediaGestureContract,mediaContract,avatarContract,surfaceContract,rebuiltMain,unifiedOwners,parentRuntime,familyCoverage,apiProofContract,applicationCoverage,singleViewportOwner,keyboardFastPath,keyboardEarlyClose,keyboardBaseline,textInputContract,inputApiContract,buttonApiContract,popupApiContract,typeApiContract,geometryApiContract,viewportSequence:!viewportError&&viewportCases.length===12&&viewportCases.every(c=>c.pass),version:!!version&&rules.includes("Chỉ mục rule đang có hiệu lực ("+version+")"),uniqueRuleIds:duplicates.length===0,noDirectFontSizes:directFonts.length===0,classicScriptSyntax:syntaxErrors.length===0&&scripts>0};
 return{version,checks,viewportCases,viewportError,fastPathCases,fastPathError,earlyCloseCases,earlyCloseError,inputCases,inputError,inputApiCases,inputApiError,buttonApiCases,buttonApiError,popupApiCases,popupApiError,typeApiCases,typeApiError,geoCases,geoError,pass:Object.values(checks).every(Boolean),scripts,syntaxErrors,duplicates,directFonts,unused,repeatedRoot,importantCount:(css.match(/!important/g)||[]).length,repeatedCount:repeated.length,repeated};
}
const fs=require('node:fs');const path=require('node:path');
const result=auditDesign(fs.readFileSync(path.join(__dirname,'index.html'),'utf8'),fs.readFileSync(path.join(__dirname,'RULES.md'),'utf8'),fs.readFileSync(path.join(__dirname,'release-v13.27.html'),'utf8'));

const crypto=require('node:crypto'),manifest=JSON.parse(fs.readFileSync(path.join(__dirname,'references/upstream/astryx/manifest.json'),'utf8'));
const prefix='references/upstream/astryx/';
const sourceCheck=manifest.repository==='https://github.com/meta/astryx'&&/^[a-f0-9]{40}$/.test(manifest.commit)&&manifest.license==='MIT'&&manifest.files.length===18&&new Set(manifest.files.map(f=>f.local)).size===18&&manifest.files.some(f=>f.source==='LICENSE')&&manifest.files.every(f=>{if(typeof f.source!=='string'||f.source.split('/').some(s=>s==='..'||!s)||f.local!==prefix+f.source+(f.source==='LICENSE'?'':'.txt'))return false;const b=fs.readFileSync(path.join(__dirname,f.local));return crypto.createHash('sha1').update('blob '+b.length+'\0').update(b).digest('hex')===f.sha&&(f.source!=='LICENSE'||b.toString().includes('MIT License'))});
result.checks.astryxSourceIntegrity=sourceCheck;result.pass=result.pass&&sourceCheck;result.astryx={commit:manifest.commit,files:manifest.files.length,integrity:sourceCheck};


const adobe=JSON.parse(fs.readFileSync(path.join(__dirname,'references/upstream/adobe-react-spectrum/manifest.json'),'utf8'));
const adobePrefix='references/upstream/adobe-react-spectrum/';
const adobeOK=adobe.repository==='https://github.com/adobe/react-spectrum'&&/^[a-f0-9]{40}$/.test(adobe.commit)&&adobe.license==='Apache-2.0'&&adobe.files.length===11&&new Set(adobe.files.map(f=>f.local)).size===11&&['LICENSE','NOTICE.txt'].every(s=>adobe.files.some(f=>f.source===s))&&adobe.files.every(f=>{if(typeof f.source!=='string'||f.source.split('/').some(s=>s==='..'||!s)||f.local!==adobePrefix+f.source+(/\.(ts|tsx)$/.test(f.source)?'.txt':''))return false;const b=fs.readFileSync(path.join(__dirname,f.local));return crypto.createHash('sha1').update('blob '+b.length+'\0').update(b).digest('hex')===f.sha});
result.checks.adobeSourceIntegrity=adobeOK;result.pass=result.pass&&adobeOK;result.adobe={commit:adobe.commit,files:adobe.files.length,integrity:adobeOK};

console.log(JSON.stringify(result,null,2));process.exitCode=result.pass?0:1;
