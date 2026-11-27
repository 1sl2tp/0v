#!/usr/bin/env bash
set -euo pipefail
export PGHOST=127.0.0.1 PGPORT=5432 PGUSER=postgres PGDATABASE=media_fixture_ci PGPASSWORD=fixture_only
psql -X -v ON_ERROR_STOP=1 -f fixtures/media-send/race-setup.sql
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
post(){
 psql -X -qAt -v ON_ERROR_STOP=1 <<'SQL'
begin;
set local fixture.uid='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
set local fixture.jwt='{"session_id":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","aal":"aal2"}';
select v0_private.media_send_commit('0v:dddddddd-dddd-4ddd-8ddd-dddddddddddd');
select pg_sleep(0.5);
commit;
SQL
}
post >"$tmp/a" & a=$!
post >"$tmp/b" & b=$!
wait "$a"; wait "$b"
cmp "$tmp/a" "$tmp/b"
test "$(psql -X -Atc "select count(*) from public.v21_messages where client_id='0v:dddddddd-dddd-4ddd-8ddd-dddddddddddd'")" = 1
test "$(psql -X -Atc "select count(*) from public.v21_media_assets where id='eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee'")" = 1
echo 'MEDIA-SEND-01 concurrent commit: same ACK, one message and one asset'
