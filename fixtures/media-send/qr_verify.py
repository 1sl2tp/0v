"""Strict static VietQR account-transfer subset. Input must come from a trusted
image decoder, not from a client-supplied payload. No bank ownership lookup."""
import binascii, re
def tlv(value):
    out={}
    while value:
        if len(value)<4 or not value[:4].isascii() or not value[:4].isdigit(): raise ValueError("tlv header")
        k,n=value[:2],int(value[2:4])
        if not n or len(value)<4+n or k in out: raise ValueError("tlv length or duplicate")
        out[k]=value[4:4+n]
        value=value[4+n:]
    return out
def verify_recipient(payload, expected_bin, expected_account):
    if not isinstance(payload,str) or not payload.isascii() or not 1<=len(payload)<=512: raise ValueError("payload")
    if not re.fullmatch(r"\d{6}",expected_bin) or not re.fullmatch(r"\d{1,19}",expected_account): raise ValueError("configuration")
    if not re.fullmatch(r"[0-9A-Fa-f]{4}",payload[-4:]) or payload[-8:-4]!="6304": raise ValueError("crc field")
    if binascii.crc_hqx(payload[:-4].encode("ascii"),0xffff)!=int(payload[-4:],16): raise ValueError("crc")
    fields=tlv(payload)
    if set(fields)-{"00","01","38","53","58","63"} or fields.get("00")!="01" or fields.get("01")!="11" or fields.get("53")!="704" or fields.get("58")!="VN": raise ValueError("unsupported static profile")
    transfer=tlv(fields.get("38",""))
    if set(transfer)!={"00","01","02"} or transfer["00"]!="A000000727" or transfer["02"]!="QRIBFTTA": raise ValueError("service")
    beneficiary=tlv(transfer["01"])
    if beneficiary!={"00":expected_bin,"01":expected_account}: raise ValueError("recipient mismatch")
    return True
