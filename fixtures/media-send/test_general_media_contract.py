import unittest
from hashlib import sha256
from io import BytesIO
from PIL import Image
from general_media_contract import make_manifest,validate_ticket,validate_verified_object,validate_ack,validate_receipt,validate_source_snapshot,validate_storage_evidence
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
    def test_normalized_receipt_committed_and_duplicate(self):
        m=manifest(); a=ack(m)
        expected={"state":"committed","clientId":m.client_id,"destinationRoom":m.room,"sha256":m.sha256,"sizeBytes":m.size,"messageId":id(6),"destinationAssetId":m.asset_id}
        self.assertEqual(validate_receipt(m,a),expected)
        dup={k:v for k,v in a.items() if k not in ("message_id","asset_id")}
        dup["state"]="already_present"
        self.assertEqual(validate_receipt(m,dup),{k:v for k,v in (expected|{"state":"already_present"}).items() if k not in ("messageId","destinationAssetId")})
        for patch in ({"account":id(9)},{"client_id":"wrong"},{"room":id(9)},{"sha256":"b"*64},{"size":101},{"size":100.0},{"mime":"image/png"},{"message_id":id(6)},{"asset_id":id(9)},{"state":"uploaded"}):
            with self.assertRaises(ValueError): validate_receipt(m,dup|patch)
        with self.assertRaises(ValueError): validate_receipt(m,None)
    def test_source_snapshot_authorization_and_version(self):
        m=manifest(); room=id(10); session=id(5)
        s={"viewer_account":m.account,"session":session,"room":room,"asset_id":m.source_asset,"sha256":m.sha256,"size":m.size,"mime":m.mime,"message_id":id(6),"object_id":id(8),"object_version":"v1","storage_key":"synthetic-source.jpg","authorized":True,"deleted":False}
        self.assertTrue(validate_source_snapshot(m,room,session,s,dict(s)))
        for patch in ({"viewer_account":id(9)},{"session":id(9)},{"room":m.room},{"asset_id":id(9)},{"sha256":"b"*64},{"size":101},{"size":100.0},{"mime":"image/png"},{"authorized":False},{"deleted":True},{"object_version":"v2"},{"object_id":id(9)},{"message_id":id(9)},{"storage_key":"other.jpg"}):
            with self.assertRaises(ValueError): validate_source_snapshot(m,room,session,s,s|patch)
            with self.assertRaises(ValueError): validate_source_snapshot(m,room,session,s|patch,s)
        with self.assertRaises(ValueError): validate_source_snapshot(m,m.room,session,s,s)
    def test_storage_evidence_exact_original_bytes_and_versions(self):
        for fmt,mime in (("JPEG","image/jpeg"),("PNG","image/png")):
            buf=BytesIO(); Image.new("RGB",(32,24),(22,44,66)).save(buf,format=fmt)
            data=buf.getvalue(); m=manifest(sha256=sha256(data).hexdigest(),size=len(data),mime=mime)
            room=id(10); session=id(5); user=id(7)
            s={"viewer_account":m.account,"session":session,"room":room,"asset_id":m.source_asset,"sha256":m.sha256,"size":m.size,"mime":m.mime,"message_id":id(6),"object_id":id(11),"object_version":"s1","storage_key":"synthetic-source","authorized":True,"deleted":False}
            t={"storage_key":m.storage_key,"owner":user,"sha256":m.sha256,"size":m.size,"mime":m.mime,"object_id":id(8),"object_version":"t1","width":32,"height":24}
            def check(sb=s,sa=s,sd=data,tb=t,ta=t,td=data):
                return validate_storage_evidence(m,room,session,user,sb,sa,sd,tb,ta,td)
            self.assertEqual(check()["object_version"],"t1")
            for patch in ({"object_version":"t2"},{"object_id":id(9)},{"owner":id(9)},{"storage_key":"other"},{"size":m.size+1},{"sha256":"b"*64},{"mime":"image/gif"}):
                with self.assertRaises(ValueError): check(ta=t|patch)
            with self.assertRaises(ValueError): check(sa=s|{"authorized":False})
            with self.assertRaises(ValueError): check(sd=data[:-1])
            with self.assertRaises(ValueError): check(td=data[:-1]+bytes([data[-1]^1]))
            with self.assertRaises(ValueError): check(tb=t|{"width":31},ta=t|{"width":31})
    def test_shared_mobile_client_identity_vectors(self):
        # Identical synthetic vectors in #297 mobile-forward-01-policy.test.mjs.
        vectors=[
            (21,2,1,100,"ec41e4fd-a38d-5b22-8d13-43faa6813c5d","def7d78f-c874-52e7-9486-e00e1aa7f087"),
            (22,2,1,100,"767036da-c7ec-5d60-ba81-adfc645078ea","6f93e758-e55a-5fda-8e40-33045e30458d"),
            (21,3,1,100,"1c970cae-454b-55e4-9c86-28fec25498c7","d97bd0e2-b054-5da5-b686-a7a33c64ed38"),
            (21,2,4,100,"2d8c1415-b022-5e0f-8a4f-aaf15a7c194d","a4354c8d-657f-50ea-97a7-bd5bd8bbfb08"),
            (21,2,1,101,"aee147fc-8f40-5e66-87ca-393cf09be055","f24dc62c-cf7a-5685-80a1-a3294ca2262e")]
        for actor,room,h,size,client,asset in vectors:
            m=make_manifest(id(actor),id(room),id(101),str(h).zfill(64),size,"image/jpeg")
            self.assertEqual(m.client_id,"0v:"+client)
            self.assertEqual(m.asset_id,asset)
            self.assertNotEqual(m.client_id,"0v:forward:"+m.room+":"+m.source_asset)
    def test_receipt_identity_namespaces_are_distinct(self):
        m=manifest()
        ui_key="0v:forward:"+m.room+":"+m.source_asset
        result=validate_receipt(m,ack(m))
        self.assertEqual(result["clientId"],m.client_id)
        self.assertEqual(result["destinationAssetId"],m.asset_id)
        self.assertNotEqual(result["clientId"],ui_key)
        self.assertNotEqual(result["destinationAssetId"],m.source_asset)
        for patch in ({"client_id":ui_key},{"asset_id":m.source_asset},
                      {"asset_id":m.client_id[3:]},{"client_id":"0v:"+m.asset_id}):
            with self.assertRaises(ValueError):
                validate_receipt(m,ack(m)|patch)
if __name__=="__main__": unittest.main()
