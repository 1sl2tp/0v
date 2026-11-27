import hashlib, unittest
from io import BytesIO
from PIL import Image
import zxingcpp
from server_verify import verify_qr_image, verify_ticket
from test_qr import payload

def image(value):
    barcode=zxingcpp.create_barcode(value,zxingcpp.BarcodeFormat.QRCode)
    im=Image.fromarray(zxingcpp.write_barcode_to_image(barcode,scale=5)).convert("RGB")
    buf=BytesIO(); im.save(buf,format="PNG"); return buf.getvalue()
def check(data): return verify_qr_image(data,len(data),hashlib.sha256(data).hexdigest(),"970000","00123456")
class VerifyImage(unittest.TestCase):
    def test_valid(self): self.assertGreater(check(image(payload()))["width"],0)
    def test_wrong_account(self):
        with self.assertRaises(ValueError): check(image(payload(account="00123457")))
    def test_no_qr(self):
        buf=BytesIO(); Image.new("RGB",(100,100),"white").save(buf,format="PNG")
        with self.assertRaises(ValueError): check(buf.getvalue())
    def test_exact_ticket(self):
        data=image(payload())
        t={"state":"pending","storage_key":"fixture/only","auth_user":"owner","size_bytes":len(data),"sha256":hashlib.sha256(data).hexdigest()}
        def load(path):
            self.assertEqual(path,"fixture/only"); return data,"id","v1","owner"
        self.assertEqual(verify_ticket(t,load,{"bin":"970000","account":"00123456"})["object_version"],"v1")
        with self.assertRaises(ValueError): verify_ticket(t,lambda _: (data,"id","v1","other"),{"bin":"970000","account":"00123456"})
if __name__=="__main__": unittest.main()
