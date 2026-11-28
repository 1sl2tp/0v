import hashlib, unittest, struct
from io import BytesIO
from PIL import Image
from general_image_verify import verify_general_image

def make(fmt, size=(80,60), mode="RGB", **opts):
    b=BytesIO();Image.new(mode,size).save(b,format=fmt,**opts);return b.getvalue()
def check(data,mime="image/jpeg",**opts):
    return verify_general_image(data,opts.get("size",len(data)),opts.get("sha",hashlib.sha256(data).hexdigest()),mime)

class GeneralImage(unittest.TestCase):
    def test_jpeg_baseline_progressive_grayscale(self):
        for data in (make("JPEG"),make("JPEG",progressive=True),make("JPEG",mode="L")):
            self.assertEqual(check(data)["width"],80)
    def test_png_rgb_rgba_palette(self):
        for mode in ("RGB","RGBA","P","L"):
            self.assertEqual(check(make("PNG",mode=mode),"image/png")["height"],60)
    def test_mime_hash_size(self):
        data=make("JPEG")
        for mime,opts in (("image/png",{}),("image/gif",{}),("image/jpeg",{"sha":"0"*64}),("image/jpeg",{"size":len(data)+1})):
            with self.assertRaises(ValueError): check(data,mime,**opts)
    def test_truncated_trailing_concatenated(self):
        for fmt,mime in (("JPEG","image/jpeg"),("PNG","image/png")):
            data=make(fmt)
            for bad in (data[:-1],data+b"extra",data+data):
                with self.assertRaises(ValueError): check(bad,mime)
    def test_pixel_limit(self):
        for fmt,mime in (("JPEG","image/jpeg"),("PNG","image/png")):
            with self.assertRaises(ValueError): check(make(fmt,(2048,2048)),mime)
    def test_png_crc(self):
        data=bytearray(make("PNG"));data[29]^=1
        with self.assertRaises(ValueError): check(bytes(data),"image/png")
    def test_animated_png(self):
        b=BytesIO();Image.new("RGB",(32,32),"white").save(b,format="PNG",save_all=True,append_images=[Image.new("RGB",(32,32),"black")])
        with self.assertRaises(ValueError): check(b.getvalue(),"image/png")
    def test_corrupt_jpeg_frame(self):
        data=bytearray(make("JPEG"));i=data.index(b"\xff\xc0");data[i+5:i+7]=b"\x00\x00"
        with self.assertRaises(ValueError): check(bytes(data))

if __name__=="__main__": unittest.main()
