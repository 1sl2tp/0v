import hashlib, unittest
from test_server_verify import image
from test_qr import payload
from storage_verify import download_exact, verify_and_attest
from worker_api import auth_claims
from test_worker_api import token, Auth, PROJECT, USER
PATH="11111111-1111-4111-8111-111111111111/22222222-2222-4222-8222-222222222222/0v-ticket/eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee.png"
class Response:
    status=200
    def __init__(self,req,data,headers,redirect=False):
        self.req=req; self.data=data; self.headers=headers;self.redirect=redirect
    def geturl(self):return "https://invalid.example" if self.redirect else self.req.full_url
    def read(self,n):return self.data[:n]
    def __enter__(self):return self
    def __exit__(self,*a):pass
class Opener:
    def __init__(self,data,headers,redirect=False):
        self.data=data;self.headers=headers;self.redirect=redirect
    def open(self,req,timeout):
        assert req.full_url=="https://"+PROJECT+".supabase.co/storage/v1/object/authenticated/v21-media/"+PATH
        assert req.get_header("Authorization")=="Bearer fixture"
        return Response(req,self.data,self.headers,self.redirect)
class Integration(unittest.TestCase):
    def test_storage_bytes_to_attestation(self):
        auth_claims(PROJECT,"fixture",token(),Auth({"id":USER}),now=1000)
        data=image(payload())
        t={"state":"pending","client_id":"fixture","storage_key":PATH,"object_id":"id","object_version":"v1","recipient_revision":"r1","size_bytes":len(data),"sha256":hashlib.sha256(data).hexdigest(),"bin":"970000","account":"00123456"}
        headers={"Content-Type":"image/png","Content-Length":str(len(data))}
        writes=[]
        self.assertEqual(verify_and_attest("fixture",lambda _:dict(t),lambda *a:writes.append(a),lambda target:download_exact(PROJECT,"fixture",target,Opener(data,headers))),{"verified":True})
        self.assertEqual(len(writes),1)
        for opener in [Opener(data+b"x",headers),Opener(data,headers,True),Opener(data,{"Content-Type":"text/html"}),Opener(data[:-1],headers)]:
            with self.assertRaises(ValueError):verify_and_attest("fixture",lambda _:dict(t),lambda *a:writes.append(a),lambda target:download_exact(PROJECT,"fixture",target,opener))
        self.assertEqual(len(writes),1)
if __name__=="__main__":unittest.main()
