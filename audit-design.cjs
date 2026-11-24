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
 const checks={version:!!version&&rules.includes("Chỉ mục rule đang có hiệu lực ("+version+")"),uniqueRuleIds:duplicates.length===0,noDirectFontSizes:directFonts.length===0,classicScriptSyntax:syntaxErrors.length===0&&scripts>0};
 return{version,checks,pass:Object.values(checks).every(Boolean),scripts,syntaxErrors,duplicates,directFonts,unused,repeatedRoot,importantCount:(css.match(/!important/g)||[]).length,repeatedCount:repeated.length,repeated};
}
const fs=require('node:fs');const path=require('node:path');
const result=auditDesign(fs.readFileSync(path.join(__dirname,'index.html'),'utf8'),fs.readFileSync(path.join(__dirname,'RULES.md'),'utf8'));
console.log(JSON.stringify(result,null,2));process.exitCode=result.pass?0:1;
