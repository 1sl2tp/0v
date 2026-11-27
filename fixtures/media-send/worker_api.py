"""Trusted QR worker candidate. No public listener, secrets or deployment.
Only server-controlled DB connection factory (dedicated login with worker
membership) and private Storage credential. Caller never supplies DB claims.
"""
import base64, json, re, time, uuid
from urllib.request import Request, build_opener
from storage_verify import NoRedirect, download_exact, verify_and_attest
CLIENT=re.compile(r"0v:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")

def auth_claims(project_ref, publishable_key, bearer, opener=None, now=None):
    if not re.fullmatch(r"[a-z0-9]{20}",project_ref) or not isinstance(bearer,str) or len(bearer)>16384 or not re.fullmatch(r"[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+",bearer):
        raise PermissionError("invalid access token")
    # Auth service validates this exact token before its claims are used.
    url="https://"+project_ref+".supabase.co/auth/v1/user"
    req=Request(url,headers={"Authorization":"Bearer "+bearer,"apikey":publishable_key,"Accept":"application/json"})
    with (opener or build_opener(NoRedirect())).open(req,timeout=10) as response:
        if response.status!=200 or response.geturl()!=url: raise PermissionError("auth rejected")
        raw=response.read(65537)
        if len(raw)>65536: raise PermissionError("auth response")
        user=json.loads(raw)
    part=bearer.split(".")[1]
    claims=json.loads(base64.urlsafe_b64decode(part+"="*(-len(part)%4)))
    if not isinstance(user,dict) or not isinstance(claims,dict): raise PermissionError("auth claims")
    if claims.get("iss")!="https://"+project_ref+".supabase.co/auth/v1" or claims.get("aud")!="authenticated" or claims.get("role")!="authenticated" or claims.get("aal")!="aal2" or claims.get("is_anonymous",False) is not False or user.get("is_anonymous",False) is not False or user.get("id")!=claims.get("sub"):
        raise PermissionError("auth scope")
    try:
        sub=str(uuid.UUID(claims["sub"])); sid=str(uuid.UUID(claims["session_id"]))
    except (ValueError,KeyError,TypeError,AttributeError) as exc: raise PermissionError("identity") from exc
    stamp=time.time() if now is None else now
    exp=claims.get("exp")
    if type(exp) is not int or exp<=stamp: raise PermissionError("expired")
    return {"sub":sub,"session_id":sid,"aal":"aal2","role":"authenticated","is_anonymous":False,"exp":exp}

class PrivateDB:
    """Fixed SQL only; connection factory is private. Each call uses a new
    transaction and clears request claims at transaction end. Never use pool
    session state as authentication. Underlying SQL checks active auth.sessions.
    """
    def __init__(self, connect, claims):
        self.connect=connect; self.claims=dict(claims)
    def _call(self, sql, params):
        if self.claims["exp"]<=time.time(): raise PermissionError("expired")
        conn=self.connect()
        try:
            with conn:
                with conn.cursor() as cur:
                    cur.execute("SET LOCAL ROLE v0_qr_worker")
                    cur.execute("SELECT set_config('request.jwt.claim.sub', '', true), set_config('request.jwt.claims', %s, true)",(json.dumps(self.claims),))
                    cur.execute(sql,params)
                    return cur.fetchone()[0]
        finally:
            conn.close()
    def prepare(self, contact, client, asset, body, size, sha):
        return self._call("SELECT v0_private.media_send_prepare(%s::uuid,%s,%s::uuid,%s,%s::bigint,%s)",(contact,client,asset,body,size,sha))
    def target(self, client):
        return self._call("SELECT v0_private.media_qr_target(%s)",(client,))
    def attest(self, client,obj,version,sha,revision,width,height):
        return self._call("SELECT v0_private.media_qr_attest(%s,%s::uuid,%s,%s,%s::uuid,%s::integer,%s::integer)",(client,obj,version,sha,revision,width,height))
    def commit(self, client):
        return self._call("SELECT v0_private.media_qr_commit(%s)",(client,))

def verify_request(project_ref, publishable_key, storage_secret, bearer, client_id, connect, auth_open=None, storage_open=None):
    if not isinstance(client_id,str) or not CLIENT.fullmatch(client_id): raise ValueError("client id")
    claims=auth_claims(project_ref,publishable_key,bearer,auth_open)
    db=PrivateDB(connect,claims)
    return verify_and_attest(client_id,db.target,db.attest,lambda target:download_exact(project_ref,storage_secret,target,storage_open))
