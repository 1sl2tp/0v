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


def validate_receipt(m, receipt):
    """Pure normalization for an authenticated owner's canonical receipt.
    A duplicate receipt is not a message ACK; never expose another sender's IDs.
    Does not authorize a request or certify that a live owner exists.
    """
    if not isinstance(receipt, dict):
        raise ValueError("receipt")
    expected={"account":m.account,"room":m.room,"client_id":m.client_id,
              "sha256":m.sha256,"size":m.size,"mime":m.mime}
    if any(receipt.get(k)!=v for k,v in expected.items()) or type(receipt.get("size")) is not int:
        raise ValueError("receipt mismatch")
    state=receipt.get("state")
    result={"state":state,"clientId":m.client_id,"destinationRoom":m.room,
            "sha256":m.sha256,"sizeBytes":m.size}
    if state=="committed":
        result["messageId"]=validate_ack(m,receipt)
        result["destinationAssetId"]=m.asset_id
    elif state=="already_present":
        if receipt.get("message_id") is not None or receipt.get("asset_id") is not None:
            raise ValueError("duplicate receipt contains message identity")
    else:
        raise ValueError("receipt state")
    return result


def validate_source_snapshot(m, source_room, session, before, after):
    """Fixture for the official owner's source-read boundary.
    Both snapshots must come from the authenticated owner after authorization,
    never from client data. This is not an authorization or Storage adapter.
    Reject changed/deleted/revoked source between authorized reads.
    """
    canonical_uuid(source_room)
    canonical_uuid(session)
    if source_room == m.room:
        raise ValueError("source room")
    expected={"viewer_account":m.account,"session":session,"room":source_room,
              "asset_id":m.source_asset,"sha256":m.sha256,"size":m.size,"mime":m.mime}
    fields=("message_id","object_id","object_version","storage_key")
    for snapshot in (before,after):
        if not isinstance(snapshot,dict) or any(snapshot.get(k)!=v for k,v in expected.items()):
            raise ValueError("source mismatch")
        if type(snapshot.get("size")) is not int or snapshot.get("authorized") is not True or snapshot.get("deleted") is not False:
            raise ValueError("source unavailable")
        for k in ("message_id","object_id"):
            canonical_uuid(snapshot.get(k))
        for k in ("object_version","storage_key"):
            if not isinstance(snapshot.get(k),str) or not snapshot[k]:
                raise ValueError("source object identity")
    if any(before[k]!=after[k] for k in fields):
        raise ValueError("source changed")
    return True


def validate_storage_evidence(m, source_room, session, auth_user,
                              source_before, source_after, source_bytes,
                              target_before, target_after, target_bytes):
    """Offline evidence composition only; no network, write, grant or send.
    Trusted snapshots must be obtained by the authorized official owner.
    The eventual commit transaction must still recheck current authorization
    and the exact destination object identity under its own lock.
    """
    from general_image_verify import verify_general_image
    validate_source_snapshot(m, source_room, session, source_before, source_after)
    for target in (target_before,target_after):
        if not isinstance(target,dict) or type(target.get("size")) is not int:
            raise ValueError("target evidence")
        validate_verified_object(m,target,auth_user)
    keys=("object_id","object_version","storage_key","owner","sha256","size","mime","width","height")
    if any(target_before[k]!=target_after[k] for k in keys):
        raise ValueError("target changed")
    src=verify_general_image(source_bytes,m.size,m.sha256,m.mime)
    dst=verify_general_image(target_bytes,m.size,m.sha256,m.mime)
    if source_bytes!=target_bytes or src!=dst:
        raise ValueError("original bytes changed")
    if (dst["width"],dst["height"])!=(target_after["width"],target_after["height"]):
        raise ValueError("target dimensions")
    return {"object_id":target_after["object_id"],"object_version":target_after["object_version"],
            "sha256":dst["sha256"],"size":dst["size"],"mime":dst["mime_type"],
            "width":dst["width"],"height":dst["height"]}
