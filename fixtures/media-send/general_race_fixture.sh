#!/usr/bin/env bash
set -euo pipefail
# Dedicated throwaway GitHub Actions service; refuse inherited connection settings.
export PGHOST=127.0.0.1 PGPORT=5432 PGUSER=postgres PGDATABASE=forward_fixture_ci PGPASSWORD=fixture_only
psql -X -v ON_ERROR_STOP=1 -f fixtures/media-send/general_race_fixture.sql
tmp=$(mktemp -d);trap 'rm -rf "$tmp"' EXIT
post(){ psql -X -qAt -v ON_ERROR_STOP=1 <<SQL
begin;
select forward_fixture.commit_mock('$1','$2','$3',repeat('$4',64),100,'image/jpeg');
select pg_sleep(0.3);
commit;
SQL
}
post actorA keyA roomA a >"$tmp/a" & a=$!
post actorA keyA roomA a >"$tmp/b" & b=$!
wait "$a";wait "$b";cmp "$tmp/a" "$tmp/b"
test "$(psql -X -Atc "select count(*) from forward_fixture.committed where room='roomA'")" = 1
post actorA keyB roomB b >"$tmp/c" & c=$!
post actorB keyC roomB b >"$tmp/d" & d=$!
wait "$c";wait "$d"
test "$(grep -h -c '"state": "committed"' "$tmp/c" "$tmp/d" | awk '{s+=$1} END{print s}')" = 1
test "$(grep -h -c '"state": "already_present"' "$tmp/c" "$tmp/d" | awk '{s+=$1} END{print s}')" = 1
test "$(psql -X -Atc "select count(*) from forward_fixture.committed where room='roomB'")" = 1
if post actorA keyA roomA c >"$tmp/conflict" 2>&1;then echo 'expected manifest conflict';exit 1;fi
grep -q manifest_conflict "$tmp/conflict"
psql -X -qAt -v ON_ERROR_STOP=1 <<'SQL'
begin;
select forward_fixture.commit_mock('actorA','keyD','roomC',repeat('d',64),100,'image/png');
rollback;
SQL
test "$(psql -X -Atc "select count(*) from forward_fixture.committed where room='roomC'")" = 0
post actorA keyD roomC d >"$tmp/retry"
grep -q '"state": "committed"' "$tmp/retry"
echo 'PASS: same-key ACK, cross-actor dedup, manifest conflict, rollback/retry'
