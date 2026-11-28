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

psql -X -v ON_ERROR_STOP=1 -f fixtures/bank-db/callback-01-test.sql
echo 'CALLBACK-01 server fixture passed'

# Additional media acceptance, CI-only, after ALL original bank assertions pass.
# Use the ephemeral local PostgreSQL service, but a separate database.
# Fail closed: media acceptance is mandatory once this fixture is present on main.
for required in general_race_fixture.sh general_race_fixture.sql general_image_verify.py general_media_contract.py test_general_image_verify.py test_general_media_contract.py general_auth_contract.py test_general_auth_contract.py png_verify.py; do
  test -f "fixtures/media-send/$required"
done
echo 'MEDIA-SEND independent database fixture start'
test "$(psql -X -Atc 'select current_database()')" = bank_fixture_ci
psql -X -v ON_ERROR_STOP=1 -c 'CREATE DATABASE forward_fixture_ci'
bash fixtures/media-send/general_race_fixture.sh
test "$(psql -X -Atc 'select current_database()')" = bank_fixture_ci
echo 'MEDIA-SEND independent database fixture PASS'
python3 -m venv "$tmp/media-venv"
"$tmp/media-venv/bin/python" -m pip install --only-binary=:all: Pillow==13.0.0
"$tmp/media-venv/bin/python" - <<'PY'
import sys, unittest
suite = unittest.defaultTestLoader.discover("fixtures/media-send", pattern="test_general*.py")
count = suite.countTestCases()
if count < 19:
    sys.exit(f"MEDIA-SEND incomplete test discovery: {count} < 19")
result = unittest.TextTestRunner(verbosity=2).run(suite)
if not result.wasSuccessful() or result.testsRun != count or result.skipped or result.expectedFailures:
    sys.exit("MEDIA-SEND incomplete or failed execution")
PY
