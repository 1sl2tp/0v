"""MEDIA-SEND-02: offline contract for authorization evidence, not an auth API.
Derived from #276 worker auth checks and private actor/contact guards.
All input evidence represents synthetic results of an already authenticated
official owner. No JWT decoding, secrets, network, SQL, roles or live writes.
A passing fixture never grants access. The live owner must establish and
recheck the evidence, including account state and membership, under its lock.
"""
from general_media_contract import canonical_uuid

def validate_authorization(m, session, auth_user, evidence, now):
    canonical_uuid(session)
    canonical_uuid(auth_user)
    if not isinstance(evidence,dict) or type(now) is not int:
        raise PermissionError("invalid evidence")
    expected={"account":m.account,"auth_user":auth_user,"session":session,
              "destination_room":m.room,"role":"admin","aal":"aal2"}
    if any(evidence.get(k)!=v for k,v in expected.items()):
        raise PermissionError("scope mismatch")
    for key in ("identity_verified","session_active","account_active",
                "destination_member","destination_contact_active"):
        if evidence.get(key) is not True:
            raise PermissionError("authorization denied")
    if evidence.get("anonymous") is not False:
        raise PermissionError("anonymous")
    expires=evidence.get("expires_ms")
    if type(expires) is not int or expires<=now:
        raise PermissionError("expired")
    return True

def validate_authorization_pair(m,session,auth_user,before,after,start_ms,end_ms):
    if type(start_ms) is not int or type(end_ms) is not int or end_ms<start_ms:
        raise PermissionError("invalid clock")
    validate_authorization(m,session,auth_user,before,start_ms)
    validate_authorization(m,session,auth_user,after,end_ms)
    # A changed authorization revision is not evidence for the original operation.
    revision=before.get("authorization_revision")
    if not isinstance(revision,str) or not revision or after.get("authorization_revision")!=revision:
        raise PermissionError("authorization changed")
    return True
