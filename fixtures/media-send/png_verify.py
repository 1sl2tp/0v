"""Bounded strict PNG byte verifier (stage B; no storage/network or QR decoding).
Only noninterlaced 8-bit grayscale/RGB/GA/RGBA, IHDR+IDAT+IEND.
Unsupported bank PNG profiles must be rejected, not silently accepted.
"""
import hashlib, struct, zlib
MAX_BYTES=15*1024*1024
MAX_PIXELS=4_000_000
def verify_png(data, expected_size, expected_sha):
    if not isinstance(data,bytes) or not 0<len(data)<=MAX_BYTES or len(data)!=expected_size:
        raise ValueError("size")
    if hashlib.sha256(data).hexdigest()!=expected_sha:
        raise ValueError("sha256")
    if data[:8]!=b"\x89PNG\r\n\x1a\n": raise ValueError("signature")
    offset=8; width=height=channels=0; compressed=[]; ended=False; count=0
    while offset<len(data):
        count+=1
        if count>4096 or offset+12>len(data): raise ValueError("chunk")
        n=struct.unpack_from(">I",data,offset)[0]
        if n>MAX_BYTES or offset+12+n>len(data): raise ValueError("chunk length")
        kind=data[offset+4:offset+8]; payload=data[offset+8:offset+8+n]
        crc=struct.unpack_from(">I",data,offset+8+n)[0]
        if zlib.crc32(kind+payload)&0xffffffff!=crc: raise ValueError("crc")
        offset+=12+n
        if kind==b"IHDR" and count==1 and n==13:
            width,height,depth,color,compression,filter_method,interlace=struct.unpack(">IIBBBBB",payload)
            channels={0:1,2:3,4:2,6:4}.get(color,0)
            if not (1<=width<=4096 and 1<=height<=4096 and width*height<=MAX_PIXELS and depth==8 and channels and compression==filter_method==interlace==0):
                raise ValueError("unsupported profile")
        elif kind==b"IDAT" and width:
            compressed.append(payload)
        elif kind==b"IEND" and width and compressed and n==0 and offset==len(data):
            ended=True; break
        else: raise ValueError("unsupported chunk/order")
    if not ended: raise ValueError("missing end")
    stride=width*channels+1; required=stride*height
    inflater=zlib.decompressobj()
    try: raw=inflater.decompress(b"".join(compressed),required+1)
    except zlib.error as exc: raise ValueError("inflate") from exc
    if len(raw)!=required or not inflater.eof or inflater.unused_data or inflater.unconsumed_tail:
        raise ValueError("decoded length")
    if any(raw[i]>4 for i in range(0,required,stride)): raise ValueError("filter")
    # All filters 0..4 define a reversible byte transformation for this fixed profile.
    return {"sha256":expected_sha,"size":len(data),"width":width,"height":height}
