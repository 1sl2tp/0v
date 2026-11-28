import unittest
from general_auth_contract import validate_authorization,validate_authorization_pair
from general_media_contract import make_manifest
def uid(n): return "00000000-0000-4000-8000-"+str(n).zfill(12)
class GeneralAuthContract(unittest.TestCase):
    def setUp(self):
        self.m=make_manifest(uid(1),uid(2),uid(3),"a"*64,100,"image/jpeg")
        self.session=uid(4); self.user=uid(5)
        self.e={"account":self.m.account,"auth_user":self.user,"session":self.session,
                "destination_room":self.m.room,"role":"admin","aal":"aal2",
                "identity_verified":True,"session_active":True,"account_active":True,
                "destination_member":True,"destination_contact_active":True,
                "anonymous":False,"expires_ms":2000,"authorization_revision":"r1"}
    def test_verified_authorization_scope(self):
        self.assertTrue(validate_authorization(self.m,self.session,self.user,self.e,1000))
        for patch in ({"account":uid(9)},{"auth_user":uid(9)},{"session":uid(9)},
                      {"destination_room":uid(9)},{"role":"user"},{"aal":"aal1"},
                      {"anonymous":True},{"identity_verified":False},{"expires_ms":1000},
                      {"expires_ms":2000.0}):
            with self.assertRaises(PermissionError):
                validate_authorization(self.m,self.session,self.user,self.e|patch,1000)
    def test_revocation_and_membership_before_after(self):
        self.assertTrue(validate_authorization_pair(self.m,self.session,self.user,self.e,self.e,1000,1500))
        for k in ("session_active","account_active","destination_member","destination_contact_active"):
            with self.assertRaises(PermissionError):
                validate_authorization_pair(self.m,self.session,self.user,self.e,self.e|{k:False},1000,1500)
        for patch in ({"authorization_revision":"r2"},{"authorization_revision":None},{"expires_ms":1500}):
            with self.assertRaises(PermissionError):
                validate_authorization_pair(self.m,self.session,self.user,self.e,self.e|patch,1000,1500)
        with self.assertRaises(PermissionError):
            validate_authorization_pair(self.m,self.session,self.user,self.e,self.e,1500,1000)
if __name__=="__main__": unittest.main()
