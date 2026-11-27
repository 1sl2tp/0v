import hashlib, unittest
from test_server_verify import image
from test_qr import payload
from storage_verify import verify_and_attest, download_exact
class VerifyStorage(unittest.TestCase):
    def test_orchestration(self):
        data=image(payload())
        target={"state":"pending","client_id":"fixture","object_id":"id","object_version":"v1","recipient_revision":"r1","size_bytes":len(data),"sha256":hashlib.sha256(data).hexdigest(),"bin":"970000","account":"00123456"}
        calls=[]
        self.assertEqual(verify_and_attest("fixture",lambda _:dict(target),lambda *a:calls.append(a),lambda _:data),{"verified":True})
        self.assertEqual(len(calls),1)
        snapshots=iter([target,{**target,"object_version":"v2"}])
        with self.assertRaises(ValueError): verify_and_attest("fixture",lambda _:next(snapshots),lambda *a:calls.append(a),lambda _:data)
        self.assertEqual(len(calls),1)
    def test_path_rejected_before_network(self):
        class NoNetwork:
            def open(self,*a,**k): raise AssertionError("unexpected network")
        with self.assertRaises(ValueError): download_exact("a"*20,"fixture",{"storage_key":"https://example.test","size_bytes":10},NoNetwork())
if __name__=="__main__": unittest.main()
