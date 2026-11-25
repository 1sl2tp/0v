# Lesson 31 — source study
- https://github.com/matrix-org/matrix-js-sdk — retry scheduler and sync.
- https://spec.matrix.org/latest/client-server-api/ — client transaction ID, idempotent retry and sync cursor.
- https://github.com/GoogleChrome/workbox — durable queue and replay.
- https://developer.chrome.com/docs/workbox/modules/workbox-background-sync — IndexedDB and browser fallback.
Decision: fixture only; persist before dispatch, retain ID on uncertain response, use SyncController for ordered projection, no production or keyboard changes. No code vendored from these sources.

## v13.68 reload study
- https://spec.matrix.org/v1.18/client-server-api/ — transaction identity scoped to device and request endpoint.
- https://github.com/dexie/Dexie.js — https://dexie.org/docs/Dexie/Dexie.transaction%28%29 — atomic transaction, no network await inside IndexedDB transaction.
- https://developer.chrome.com/docs/workbox/modules/workbox-background-sync — durable failed-request queue. No worker registration in fixture.
Decision: server ledger simulated in a separate key; rebuild ordered projection; same-tab reload only. No vendored code.
