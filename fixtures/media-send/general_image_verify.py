"""General still-image verification candidate; no I/O, DB, QR or send.
Preserves original bytes and verifies an expected digest from the manifest.
Not an authorization, malware scanner, or production attestation boundary.
"""
import hashlib, re, struct, warnings, zlib
from io import BytesIO
from PIL import Image, ImageFile
from png_verify import MAX_BYTES, MAX_PIXELS

FORMATS={"image/png":"PNG","image/jpeg":"JPEG"}
def check_dimensions(w,h):
    if not (1<=w<=4096 and 1<=h<=4096 and w*h<=MAX_PIXELS):
        raise ValueError("dimensions")

def png_structure(data):
    if data[:8]!=b"\x89PNG\r\n\x1a\n": raise ValueError("signature")
    pos=8; count=0; header=None; seen_idat=False
    while pos<len(data):
        count+=1
        if count>4096 or pos+12>len(data): raise ValueError("chunk")
        n=struct.unpack_from(">I",data,pos)[0]
        end=pos+12+n
        if end>len(data): raise ValueError("chunk length")
        kind=data[pos+4:pos+8]; body=data[pos+8:pos+8+n]
        crc=struct.unpack_from(">I",data,end-4)[0]
        if zlib.crc32(kind+body)&0xffffffff!=crc: raise ValueError("crc")
        if count==1:
            if kind!=b"IHDR" or n!=13: raise ValueError("header")
            header=struct.unpack_from(">II",body); check_dimensions(*header)
        elif kind==b"IHDR": raise ValueError("duplicate header")
        if kind in (b"acTL",b"fcTL",b"fdAT"): raise ValueError("animated PNG")
        if kind==b"IDAT": seen_idat=True
        if kind==b"IEND":
            if n or not seen_idat or end!=len(data): raise ValueError("end")
            return header
        pos=end
    raise ValueError("missing end")

def jpeg_structure(data):
    # Walk marker lengths and entropy byte stuffing; reject a second image or
    # trailing bytes after the first real EOI. Decoder still validates pixels.
    if data[:2]!=b"\xff\xd8": raise ValueError("signature")
    pos=2; scan=False; found_scan=False; dimensions=None; markers=0
    while pos<len(data):
        if scan:
            pos=data.find(b"\xff",pos)
            if pos<0: break
        elif data[pos]!=255: raise ValueError("marker")
        while pos<len(data) and data[pos]==255: pos+=1
        if pos>=len(data): break
        marker=data[pos]; pos+=1
        if scan and (marker==0 or 0xd0<=marker<=0xd7): continue
        scan=False; markers+=1
        if markers>4096: raise ValueError("marker count")
        if marker==0xd9:
            if pos!=len(data) or not found_scan or dimensions is None: raise ValueError("end")
            return dimensions
        if marker in (0,1,0xd8) or 0xd0<=marker<=0xd7 or pos+2>len(data): raise ValueError("marker")
        n=struct.unpack_from(">H",data,pos)[0]
        if n<2 or pos+n>len(data): raise ValueError("segment length")
        if marker in (0xc0,0xc1,0xc2):
            if dimensions is not None or n<8 or data[pos+2]!=8: raise ValueError("frame")
            h,w=struct.unpack_from(">HH",data,pos+3)
            check_dimensions(w,h); dimensions=(w,h)
        elif marker in (0xc3,0xc5,0xc6,0xc7,0xc9,0xca,0xcb,0xcd,0xce,0xcf):
            raise ValueError("unsupported frame")
        if marker==0xda:
            if dimensions is None: raise ValueError("scan before frame")
            found_scan=True; scan=True
        pos+=n
    raise ValueError("missing end")

def verify_general_image(data, expected_size, expected_sha, expected_mime):
    if expected_mime not in FORMATS: raise ValueError("mime")
    if type(expected_size) is not int or not isinstance(data,bytes) or not 0<len(data)<=MAX_BYTES or len(data)!=expected_size: raise ValueError("size")
    if not isinstance(expected_sha,str) or not re.fullmatch(r"[0-9a-f]{64}",expected_sha) or hashlib.sha256(data).hexdigest()!=expected_sha: raise ValueError("sha256")
    dimensions=(png_structure if expected_mime=="image/png" else jpeg_structure)(data)
    # Never accept truncated bytes if a caller has loosened the Pillow setting.
    if ImageFile.LOAD_TRUNCATED_IMAGES: raise ValueError("unsafe decoder configuration")
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("error",Image.DecompressionBombWarning)
            for decode in (False,True):
                with Image.open(BytesIO(data),formats=[FORMATS[expected_mime]]) as im:
                    if im.format!=FORMATS[expected_mime] or im.size!=dimensions or getattr(im,"n_frames",1)!=1: raise ValueError("image profile")
                    check_dimensions(*im.size)
                    if decode: im.load()
                    else: im.verify()
    except (OSError,SyntaxError,Image.DecompressionBombError,Image.DecompressionBombWarning) as exc:
        raise ValueError("decode") from exc
    return {"sha256":expected_sha,"size":len(data),"mime_type":expected_mime,"width":dimensions[0],"height":dimensions[1]}
