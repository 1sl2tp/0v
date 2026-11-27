import hashlib, struct, unittest, zlib
from png_verify import verify_png
def chunk(kind,payload):
    return struct.pack(">I",len(payload))+kind+payload+struct.pack(">I",zlib.crc32(kind+payload)&0xffffffff)
def png(raw=b"\x00\xff\x00\x00",w=1,h=1,color=2):
    return b"\x89PNG\r\n\x1a\n"+chunk(b"IHDR",struct.pack(">IIBBBBB",w,h,8,color,0,0,0))+chunk(b"IDAT",zlib.compress(raw))+chunk(b"IEND",b"")
def verify(data): return verify_png(data,len(data),hashlib.sha256(data).hexdigest())
class Verify(unittest.TestCase):
    def test_valid(self): self.assertEqual(verify(png())["width"],1)
    def test_wrong_hash(self):
        with self.assertRaises(ValueError): verify_png(png(),len(png()),"0"*64)
    def test_invalid(self):
        good=png()
        for bad in [b"not png",good[:-1],good+b"x",good[:29]+b"\x00"+good[30:],png(b"\x05\x00\x00\x00"),png(b"\x00"),png(b"\x00"*1000),png(w=4097),png(color=3)]:
            with self.subTest(size=len(bad)),self.assertRaises(ValueError): verify(bad)
if __name__=="__main__": unittest.main()
