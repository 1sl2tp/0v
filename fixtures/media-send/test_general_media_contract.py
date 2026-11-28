import unittest
from general_media_contract import make_manifest,validate_ticket,validate_verified_object,validate_ack
def id(n): return "00000000-0000-4000-8000-"+str(n).zfill(12)
def manifest(**extra):
    return make_manifest(**({"account":id(1),"room":id(2),"source_asset":id(3),"sha256":"a"*64,"size":100,"mime":"image/jpeg"}|extra))
def ack(m):
    return {"account":m.account,"room":m.room,"client_id":m.client_id,"asset_id":m.asset_id,"sha256":m.sha256,"size":m.size,"mime":m.mime,"state":"committed","message_id":id(6)}
class MediaContract(unittest.TestCase):
    def test_stable_and_room_account_bound(self):
        m=manifest()
        self.assertRegex(m.client_id,r"^0v:[0-9a-f-]{36}$")
        self.assertEqual(m.client_id,manifest(source_asset=id(4)).client_id)
        self.assertNotEqual(m.client_id,manifest(room=id(4)).client_id)
        self.assertNotEqual(m.client_id,manifest(account=id(4)).client_id)
        self.assertNotEqual(m.client_id,manifest(sha256="b"*64).client_id)
        self.assertNotEqual(m.client_id,manifest(size=101).client_id)
        self.assertNotEqual(m.client_id[3:],m.asset_id)
    def test_manifest_validation(self):
        self.assertTrue(manifest().storage_key.endswith(".jpg"))
        self.assertTrue(manifest(mime="image/png").storage_key.endswith(".png"))
        for x in ({"size":0},{"size":15728641},{"sha256":"bad"},{"mime":"image/gif"},{"room":"wrong"},{"size":True}):
            with self.assertRaises(ValueError): manifest(**x)
    def test_ticket_exact_session_and_expiry(self):
        m=manifest(); t=ack(m)|{"storage_key":m.storage_key,"session":id(5),"expires_ms":1000,"state":"pending"}
        self.assertEqual(validate_ticket(m,t,id(5),999),"upload")
        self.assertEqual(validate_ticket(m,t|{"state":"committed"},id(5),1001),"reconcile")
        for x,s,n in (({},id(6),999),({},id(5),1000),({"mime":"image/png"},id(5),999),({"storage_key":"wrong"},id(5),999),({"room":id(9)},id(5),999)):
            with self.assertRaises(ValueError): validate_ticket(m,t|x,s,n)
    def test_verified_object_bound(self):
        m=manifest();p={"storage_key":m.storage_key,"owner":id(7),"sha256":m.sha256,"size":m.size,"mime":m.mime,"object_id":id(8),"object_version":"v1","width":400,"height":300}
        self.assertTrue(validate_verified_object(m,p,id(7)))
        for x in ({"owner":id(9)},{"object_version":""},{"sha256":"b"*64},{"size":101},{"mime":"image/png"},{"width":4096,"height":4096}):
            with self.assertRaises(ValueError): validate_verified_object(m,p|x,id(7))
    def test_ack_not_transport_success(self):
        m=manifest();a=ack(m)
        self.assertEqual(validate_ack(m,a),id(6))
        for x in ({"state":"uploaded"},{"room":id(9)},{"account":id(9)},{"client_id":"wrong"},{"asset_id":id(9)},{"sha256":"b"*64},{"size":101},{"mime":"image/png"},{"message_id":None}):
            with self.assertRaises(ValueError): validate_ack(m,a|x)
if __name__=="__main__": unittest.main()
