import binascii, unittest
from qr_verify import verify_recipient
def t(k,v): return k+str(len(v)).zfill(2)+v
def payload(account="00123456",bank="970000",method="11",extra=""):
    merchant=t("00","A000000727")+t("01",t("00",bank)+t("01",account))+t("02","QRIBFTTA")
    data=t("00","01")+t("01",method)+t("38",merchant)+t("53","704")+t("58","VN")+extra+"6304"
    return data+format(binascii.crc_hqx(data.encode("ascii"),0xffff),"04X")
class VerifyQR(unittest.TestCase):
    def test_valid(self): self.assertTrue(verify_recipient(payload(),"970000","00123456"))
    def test_reject(self):
        for p in [payload(account="123456"),payload(bank="970001"),payload(method="12"),payload(extra=t("54","100")),payload(extra=t("38","x")),payload()[:-4]+"0000"]:
            with self.subTest(payload=p),self.assertRaises(ValueError): verify_recipient(p,"970000","00123456")
if __name__=="__main__": unittest.main()
