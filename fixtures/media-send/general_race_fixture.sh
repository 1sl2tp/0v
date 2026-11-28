#!/usr/bin/env bash
set -euo pipefail
# Dedicated throwaway GitHub Actions service; refuse inherited connection settings.
export PGHOST=127.0.0.1 PGPORT=5432 PGUSER=postgres PGDATABASE=forward_fixture_ci PGPASSWORD=fixture_only
psql -X -v ON_ERROR_STOP=1 -f fixtures/media-send/general_race_fixture.sql
tmp=$(mktemp -d);trap 'rm -rf "$tmp"' EXIT
post(){
 local asset
 case "$2" in
 keyA) asset=00000000-0000-4000-8000-000000000001;;
 keyB) asset=00000000-0000-4000-8000-000000000002;;
 keyC) asset=00000000-0000-4000-8000-000000000003;;
 keyD) asset=00000000-0000-4000-8000-000000000004;;
 *) return 1;;
 esac
 asset=${5:-$asset}
 psql -X -qAt -v ON_ERROR_STOP=1 <<SQL
begin;
select forward_fixture.commit_mock('$1','$2','$3',repeat('$4',64),100,'image/jpeg','$asset'::uuid);
select pg_sleep(0.3);
commit;
SQL
}
post actorA keyA roomA a >"$tmp/a" & a=$!
post actorA keyA roomA a >"$tmp/b" & b=$!
wait "$a";wait "$b";cmp "$tmp/a" "$tmp/b"
grep -q '"asset_id": "00000000-0000-4000-8000-000000000001"' "$tmp/a"
if post actorA keyA roomA a 00000000-0000-4000-8000-000000000009 >"$tmp/asset_conflict" 2>&1; then echo "expected reserved asset conflict";exit 1;fi
grep -q manifest_conflict "$tmp/asset_conflict"
test "$(psql -X -Atc "select count(*) from forward_fixture.committed where room='roomA'")" = 1
post actorA keyB roomB b >"$tmp/c" & c=$!
post actorB keyC roomB b >"$tmp/d" & d=$!
wait "$c";wait "$d"
test "$(grep -h -c '"state": "committed"' "$tmp/c" "$tmp/d" | awk '{s+=$1} END{print s}')" = 1
test "$(grep -h -c '"state": "already_present"' "$tmp/c" "$tmp/d" | awk '{s+=$1} END{print s}')" = 1
test "$(psql -X -Atc "select count(*) from forward_fixture.committed where room='roomB'")" = 1
# A duplicate receipt must replay identically, and cannot be reused for new bytes.
if grep -q '"state": "already_present"' "$tmp/c"; then
 duplicate_actor=actorA; duplicate_key=keyB; duplicate_file="$tmp/c"
else
 duplicate_actor=actorB; duplicate_key=keyC; duplicate_file="$tmp/d"
fi
post "$duplicate_actor" "$duplicate_key" roomB b >"$tmp/duplicate_replay"
cmp "$duplicate_file" "$tmp/duplicate_replay"
if grep -q '"asset_id"\|"message_id"' "$duplicate_file"; then echo "duplicate leaks identity";exit 1;fi
if post "$duplicate_actor" "$duplicate_key" roomB b 00000000-0000-4000-8000-000000000009 >"$tmp/duplicate_asset_conflict" 2>&1;then echo "expected duplicate reserved asset conflict";exit 1;fi
grep -q manifest_conflict "$tmp/duplicate_asset_conflict"
if post "$duplicate_actor" "$duplicate_key" roomB c >"$tmp/duplicate_conflict" 2>&1;then echo 'expected duplicate receipt conflict';exit 1;fi
grep -q manifest_conflict "$tmp/duplicate_conflict"
test "$(psql -X -Atc "select count(*) from forward_fixture.receipt where room='roomB'")" = 2
if post actorA keyA roomA c >"$tmp/conflict" 2>&1;then echo 'expected manifest conflict';exit 1;fi
grep -q manifest_conflict "$tmp/conflict"
psql -X -qAt -v ON_ERROR_STOP=1 <<'SQL'
begin;
select forward_fixture.commit_mock('actorA','keyD','roomC',repeat('d',64),100,'image/jpeg','00000000-0000-4000-8000-000000000004'::uuid);
rollback;
SQL
test "$(psql -X -Atc "select count(*) from forward_fixture.committed where room='roomC'")" = 0
test "$(psql -X -Atc "select count(*) from forward_fixture.receipt where room='roomC'")" = 0
post actorA keyD roomC d >"$tmp/retry"
grep -q '"state": "committed"' "$tmp/retry"
grep -q '"asset_id": "00000000-0000-4000-8000-000000000004"' "$tmp/retry"
echo 'PASS: same-key ACK, cross-actor dedup, duplicate receipt replay/conflict, rollback/retry, reserved asset identity'

# Cross-language assertion: use the actual pure manifest generator and ACK
# validator against the disposable fixture, not a separately invented UUID.
PYTHONPATH=fixtures/media-send python3 - <<'PY'
import json, subprocess
from general_media_contract import make_manifest, validate_receipt
def query(sql):
    return subprocess.check_output(["psql","-X","-qAt","-v","ON_ERROR_STOP=1","-c",sql],text=True).strip()
assert query("select current_database()") == "forward_fixture_ci"
m=make_manifest("00000000-0000-4000-8000-000000000021",
                "00000000-0000-4000-8000-000000000022",
                "00000000-0000-4000-8000-000000000023","e"*64,100,"image/png")
# Every interpolated value is generated from fixed synthetic literals above.
sql=f"select forward_fixture.commit_mock('{m.account}','{m.client_id}','{m.room}','{m.sha256}',{m.size},'{m.mime}','{m.asset_id}'::uuid)"
receipt=json.loads(query(sql))
assert receipt["asset_id"] == m.asset_id
assert validate_receipt(m,receipt)["messageId"] == receipt["message_id"]
assert json.loads(query(sql)) == receipt
assert query(f"select asset_id from forward_fixture.committed where actor='{m.account}' and client_key='{m.client_id}'") == m.asset_id
print("PASS: Python manifest = PostgreSQL reserved asset = canonical ACK; exact replay")
PY
