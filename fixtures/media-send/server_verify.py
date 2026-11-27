"""Candidate server-side verifier. No HTTP endpoint or credentials.
Call only after authenticating an active ticket and reading trusted DB fields.
The caller must fetch the exact immutable object from Storage, not a client URL.
"""
from io import BytesIO
from PIL import Image
import zxingcpp
from png_verify import verify_png
from qr_verify import verify_recipient

def verify_qr_image(data, expected_size, expected_sha, expected_bin, expected_account):
    info=verify_png(data,expected_size,expected_sha)
    with Image.open(BytesIO(data),formats=["PNG"]) as image:
        if image.size!=(info["width"],info["height"]): raise ValueError("dimensions")
        image.load()
        rgba=image.convert("RGBA")
        if rgba.getchannel("A").getextrema()!=(255,255): raise ValueError("transparent QR")
        barcodes=zxingcpp.read_barcodes(rgba.convert("RGB"),formats=zxingcpp.BarcodeFormat.QRCode)
    if len(barcodes)!=1 or not barcodes[0].valid: raise ValueError("exactly one QR required")
    payload=barcodes[0].bytes.decode("ascii",errors="strict")
    verify_recipient(payload,expected_bin,expected_account)
    return info

def verify_ticket(ticket, load_exact, expected_recipient):
    """Internal API contract. load_exact takes trusted path and returns
    (bytes, object_id, version, owner_id). The caller MUST recheck these
    fields under lock when recording attestation, then commit separately.
    """
    if ticket["state"]!="pending" or not ticket["storage_key"]: raise ValueError("ticket state")
    data, object_id, version, owner=load_exact(ticket["storage_key"])
    if not object_id or not version or owner!=ticket["auth_user"]: raise ValueError("object identity")
    info=verify_qr_image(data,ticket["size_bytes"],ticket["sha256"],expected_recipient["bin"],expected_recipient["account"])
    return {**info,"object_id":object_id,"object_version":version}
