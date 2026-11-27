# Build the isolated static lab; do not serve any other repository files.
from pathlib import Path
import struct, zlib, shutil
src=Path(__file__).resolve().parent
out=src.parent/'geometry-publish'
dest=out/'mobile-geometry-lab'
dest.mkdir(parents=True,exist_ok=True)
for f in ('index.html','manifest.webmanifest','sw.js'):
    shutil.copyfile(src/f,dest/f)
def chunk(t,d):
    return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
for n in (192,512):
    raw=bytearray()
    for y in range(n):
        raw.append(0)
        for x in range(n):
            u,v=x/n,y/n
            border=(.25<u<.75 and .1<v<.9 and (u<.27 or u>.73 or v<.12 or v>.88 or abs(v-.23)<.008 or abs(v-.65)<.008 or abs(v-.75)<.008))
            raw.extend((30,30,30) if border else ((220,220,220) if .27<u<.73 and .75<v<.88 else (255,255,255)))
    data=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',n,n,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(raw,9))+chunk(b'IEND',b'')
    (dest/f'icon-{n}.png').write_bytes(data)
(out/'index.html').write_text('<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0;url=./mobile-geometry-lab/"><a href="./mobile-geometry-lab/">Mobile Geometry Lab</a>',encoding='utf-8')
assert (dest/'index.html').read_bytes()==(src/'index.html').read_bytes()
print('Geometry lab only: 5 files; isolated PWA scope.')
