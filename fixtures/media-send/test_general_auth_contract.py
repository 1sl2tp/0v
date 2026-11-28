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
    def test_composed_offline_evidence_rejects_cross_scope(self):
        # Synthetic evidence only; this test does not perform or authorize a write.
        from hashlib import sha256
        from io import BytesIO
        from PIL import Image
        from general_media_contract import validate_ticket,validate_storage_evidence,validate_receipt
        buf=BytesIO(); Image.new("RGB",(16,12),(12,24,36)).save(buf,format="PNG")
        data=buf.getvalue()
        m=make_manifest(self.m.account,self.m.room,self.m.source_asset,sha256(data).hexdigest(),len(data),"image/png")
        room=uid(10)
        common={"sha256":m.sha256,"size":m.size,"mime":m.mime}
        s=common|{"viewer_account":m.account,"session":self.session,"room":room,"asset_id":m.source_asset,"message_id":uid(11),"object_id":uid(12),"object_version":"s1","storage_key":"fixture-source","authorized":True,"deleted":False}
        t=common|{"storage_key":m.storage_key,"owner":self.user,"object_id":uid(13),"object_version":"t1","width":16,"height":12}
        ticket=common|{"account":m.account,"room":m.room,"client_id":m.client_id,"asset_id":m.asset_id,"storage_key":m.storage_key,"session":self.session,"expires_ms":1800,"state":"pending"}
        receipt=common|{"account":m.account,"room":m.room,"client_id":m.client_id,"asset_id":m.asset_id,"message_id":uid(14),"state":"committed"}
        def examine(auth=self.e,source=s,target=t,reservation=ticket,ack=receipt,finish=1500):
            validate_authorization_pair(m,self.session,self.user,self.e,auth,1000,finish)
            self.assertEqual(validate_ticket(m,reservation,self.session,finish),"upload")
            validate_storage_evidence(m,room,self.session,self.user,s,source,data,t,target,data)
            return validate_receipt(m,ack)
        self.assertEqual(examine()["messageId"],uid(14))
        for kwargs in ({"auth":self.e|{"session_active":False}},
                       {"source":s|{"authorized":False}},
                       {"target":t|{"object_version":"t2"}},
                       {"reservation":ticket|{"session":uid(9)}},
                       {"ack":receipt|{"asset_id":uid(9)}},
                       {"ack":receipt|{"state":"uploaded"}},
                       {"finish":1800}):
            with self.assertRaises((ValueError,PermissionError)):
                examine(**kwargs)
if __name__=="__main__": unittest.main()
