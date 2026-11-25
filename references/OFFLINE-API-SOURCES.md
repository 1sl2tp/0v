# Lesson 31 — source study
- https://github.com/matrix-org/matrix-js-sdk — retry scheduler and sync.
- https://spec.matrix.org/latest/client-server-api/ — client transaction ID, idempotent retry and sync cursor.
- https://github.com/GoogleChrome/workbox — durable queue and replay.
- https://developer.chrome.com/docs/workbox/modules/workbox-background-sync — IndexedDB and browser fallback.
Decision: fixture only; persist before dispatch, retain ID on uncertain response, use SyncController for ordered projection, no production or keyboard changes. No code vendored from these sources.
