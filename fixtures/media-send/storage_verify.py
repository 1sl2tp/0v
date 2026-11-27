"""Server-only bounded Supabase Storage download adapter.
No browser-supplied URL, token, account or recipient. DB target must come from
the authorized private target RPC. Never expose this worker as an HTTP endpoint
until its authentication/role binding and rate limits are independently tested.
"""
import re
from urllib.request import Request, build_opener, HTTPRedirectHandler
from server_verify import verify_qr_image
from png_verify import MAX_BYTES
UUID=r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
PATH=re.compile(UUID+"/"+UUID+"/0v-ticket/"+UUID+r"\.png")
class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self,*args,**kwargs): return None

def download_exact(project_ref, secret, target, opener=None):
    if not re.fullmatch(r"[a-z0-9]{20}",project_ref) or not secret or not PATH.fullmatch(target["storage_key"]): raise ValueError("invalid storage target")
    n=target["size_bytes"]
    if not isinstance(n,int) or not 0<n<=MAX_BYTES: raise ValueError("size")
    url="https://"+project_ref+".supabase.co/storage/v1/object/authenticated/v21-media/"+target["storage_key"]
    req=Request(url,headers={"Authorization":"Bearer "+secret,"apikey":secret,"Accept":"image/png","Accept-Encoding":"identity"})
    with (opener or build_opener(NoRedirect())).open(req,timeout=10) as res:
        if res.status!=200 or res.geturl()!=url or res.headers.get("Content-Type","").split(";")[0].strip()!="image/png" or res.headers.get("Content-Encoding","identity")!="identity": raise ValueError("storage response")
        length=res.headers.get("Content-Length")
        if length is not None and length!=str(n): raise ValueError("storage length")
        data=res.read(n+1)
        if len(data)!=n: raise ValueError("storage length")
    return data

def verify_and_attest(client_id, read_target, attest, download):
    """All callbacks are trusted server-side, with validated request identity.
    The private SQL attestation re-reads ticket and object under lock.
    Does not send or mark a message sent.
    """
    target=read_target(client_id)
    if target["client_id"]!=client_id or target["state"]!="pending": raise ValueError("ticket")
    info=verify_qr_image(download(target),target["size_bytes"],target["sha256"],target["bin"],target["account"])
    fresh=read_target(client_id)
    if fresh!=target: raise ValueError("target changed")
    attest(client_id,target["object_id"],target["object_version"],info["sha256"],target["recipient_revision"],info["width"],info["height"])
    return {"verified":True}
