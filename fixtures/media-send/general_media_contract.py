"""Pure general-media contract fixture. Not an endpoint or DB implementation.
Inputs actor, canonical destination, ticket and commit evidence must eventually
come from the authenticated server owner. This module does not authenticate,
lock, upload, attest or write. Never accept browser assertions as trusted proof.
"""
from dataclasses import dataclass
import re, uuid
from png_verify import MAX_BYTES

MIME_EXT={"image/png":"png","image/jpeg":"jpg"}
NAMESPACE=uuid.UUID("ab9e85c7-a8f1-4b84-96aa-d3aa7ce5b4d8")
def canonical_uuid(v):
    if not isinstance(v,str): raise ValueError("uuid")
    if str(uuid.UUID(v))!=v: raise ValueError("uuid")
    return v
def digest(v):
    if not isinstance(v,str) or not re.fullmatch(r"[0-9a-f]{64}",v): raise ValueError("sha256")
    return v
@dataclass(frozen=True)
class Manifest:
    account: str
    room: str
    source_asset: str
    sha256: str
    size: int
    mime: str
    client_id: str
    asset_id: str
    storage_key: str
def make_manifest(account,room,source_asset,sha256,size,mime):
    for v in (account,room,source_asset): canonical_uuid(v)
    digest(sha256)
    if type(size) is not int or not 0<size<=MAX_BYTES or mime not in MIME_EXT: raise ValueError("media")
    # Same authenticated actor, room and exact bytes => same retry key.
    # Asset ID is a separate deterministic namespace label.
    identity=":".join((account,room,sha256,str(size)))
    client_id="0v:"+str(uuid.uuid5(NAMESPACE,"client:"+identity))
    asset_id=str(uuid.uuid5(NAMESPACE,"asset:"+identity))
    path="/".join((account,room,"0v-ticket",asset_id+"."+MIME_EXT[mime]))
    return Manifest(account,room,source_asset,sha256,size,mime,client_id,asset_id,path)

def validate_ticket(m,ticket,session,now):
    # Called only with a trusted session and server-issued ticket.
    canonical_uuid(session)
    if type(now) is not int or type(ticket.get("expires_ms")) is not int: raise ValueError("clock")
    expected={"account":m.account,"room":m.room,"client_id":m.client_id,"asset_id":m.asset_id,
              "storage_key":m.storage_key,"sha256":m.sha256,"size":m.size,"mime":m.mime,"session":session}
    if any(ticket.get(k)!=v for k,v in expected.items()): raise ValueError("ticket mismatch")
    if ticket.get("state")=="committed": return "reconcile"
    if ticket.get("state")!="pending" or ticket["expires_ms"]<=now: raise ValueError("ticket state")
    return "upload"

def validate_verified_object(m,proof,auth_user):
    # Proof is server-only, not an upload response or metadata supplied by UI.
    canonical_uuid(auth_user)
    expected={"storage_key":m.storage_key,"owner":auth_user,"sha256":m.sha256,"size":m.size,"mime":m.mime}
    if any(proof.get(k)!=v for k,v in expected.items()): raise ValueError("object mismatch")
    canonical_uuid(proof.get("object_id"))
    if not isinstance(proof.get("object_version"),str) or not proof["object_version"]: raise ValueError("object version")
    for k in ("width","height"):
        if type(proof.get(k)) is not int or not 1<=proof[k]<=4096: raise ValueError("dimensions")
    if proof["width"]*proof["height"]>4_000_000: raise ValueError("dimensions")
    return True

def validate_ack(m,ack):
    # Future commit RPC must return canonical evidence, or its owner must read
    # the committed row and asset before reporting success.
    expected={"account":m.account,"room":m.room,"client_id":m.client_id,"asset_id":m.asset_id,
              "sha256":m.sha256,"size":m.size,"mime":m.mime}
    if any(ack.get(k)!=v for k,v in expected.items()): raise ValueError("ack mismatch")
    canonical_uuid(ack.get("message_id"))
    if ack.get("state")!="committed": raise ValueError("uncommitted")
    return ack["message_id"]
