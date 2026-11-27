import base64,json,unittest
from worker_api import auth_claims
PROJECT="a"*20
USER="aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
SESSION="cccccccc-cccc-4ccc-8ccc-cccccccccccc"
def token(**change):
    claims={"iss":"https://"+PROJECT+".supabase.co/auth/v1","aud":"authenticated","role":"authenticated","aal":"aal2","sub":USER,"session_id":SESSION,"exp":2000,**change}
    return "e30."+base64.urlsafe_b64encode(json.dumps(claims).encode()).decode().rstrip("=")+".fixture"
class Response:
    status=200
    def __init__(self,req,user):self.req=req;self.user=user
    def geturl(self):return self.req.full_url
    def read(self,n):return json.dumps(self.user).encode()
    def __enter__(self):return self
    def __exit__(self,*a):pass
class Auth:
    def __init__(self,user):self.user=user
    def open(self,req,timeout):return Response(req,self.user)
class WorkerAuth(unittest.TestCase):
    def test_scope(self):
        self.assertEqual(auth_claims(PROJECT,"fixture",token(),Auth({"id":USER}),now=1000)["session_id"],SESSION)
    def test_denials(self):
        for jwt in [token(aal="aal1"),token(role="service_role"),token(iss="other"),token(exp=999),token(session_id="bad"),token(is_anonymous=True)]:
            with self.assertRaises(PermissionError):auth_claims(PROJECT,"fixture",jwt,Auth({"id":USER}),now=1000)
        with self.assertRaises(PermissionError):auth_claims(PROJECT,"fixture",token(),Auth({"id":SESSION}),now=1000)
if __name__=="__main__":unittest.main()
