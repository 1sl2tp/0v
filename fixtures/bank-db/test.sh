#!/usr/bin/env bash
set -euo pipefail
# CI-only PostgreSQL service; never accept a production connection.
export PGHOST=127.0.0.1 PGPORT=5432 PGUSER=postgres PGDATABASE=bank_fixture_ci PGPASSWORD=fixture_only
psql -X -v ON_ERROR_STOP=1 -f fixtures/bank-db/schema.sql
psql -X -v ON_ERROR_STOP=1 -f fixtures/bank-db/test.sql
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
post() {
 psql -X -v ON_ERROR_STOP=1 -c "SELECT bank_fixture_v116.post_receipt('fixture:123456789','race-$1','bill-race-$1','customer-$1',500000,'bank','2026-11-25T09:00:00+07','bank:race','2026-11-25T08:59:00+07');"
}
post a >"$tmp/a" 2>&1 & a=$!
post b >"$tmp/b" 2>&1 & b=$!
ra=0; rb=0; wait "$a" || ra=$?; wait "$b" || rb=$?
if [[ "$ra" == 0 && "$rb" != 0 ]]; then grep -q 'duplicate key' "$tmp/b"; elif [[ "$rb" == 0 && "$ra" != 0 ]]; then grep -q 'duplicate key' "$tmp/a"; else cat "$tmp/a" "$tmp/b"; exit 1; fi
test "$(psql -X -Atc "SELECT count(*) FROM bank_fixture_v116.receipt WHERE bank_key='bank:race'")" = 1
test "$(psql -X -Atc "SELECT sum(amount) FROM bank_fixture_v116.receipt")" = 1300001.6
echo 'PostgreSQL fixture serial, rollback and concurrent duplicate checks passed'

psql -X -v ON_ERROR_STOP=1 -f fixtures/bank-db/bill-read-test.sql
echo '0v isolated bill-read permission and projection checks passed'
