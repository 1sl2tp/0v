# CHAT → 0v migration: read-first

User chose 0v as new UI, CHAT remains backend/operational owner. Do not copy live credentials or create another database.

| Step | State | Gate |
|---|---|---|
| R1 source contract + read projection | E1 candidate | CI fixture denied/foreign/stale |
| R2 approved session host | TODO | same-origin controlled CHAT integration, no tokens transferred, logout/rotation clears UI |
| R3 real directory/thread read | BLOCKED on R2 and SQL scope proof | staging accounts A/B, existing authorized contacts only, no conversation creation or read receipt |
| R4 realtime and offline | TODO | existing CHAT sync/cache owner, no second subscription/polling |
| R5 write/media | TODO | explicit controlled staging, no actual sends in test |
| R6 CRM | TODO | existing business API and idempotency, no payment test on production |

Sources: CHAT main c80dc64eeb7f6d4e07cb6c0fca8305859d0d7755, auth-session-store.js L471–570, v21-sync-engine.js L601–675/2027 and canonicalContact/canonicalMessage. `v21_auth_bootstrap` and `v21_conversation_open` are not assumed read-only. `v21_contacts_sidebar` and `v21_sync_snapshot` are candidates, not yet proven SQL read-only/authorized. Existing CHAT app owner must provide scoped callbacks and clear rendered data on auth/session changes; no origin-crossing token or public data export. Public demo only synthetic. Next inspect current deployed RPC definitions/grants without data, then implement same-origin host integration in separate CHAT PR after existing PR resolution. No DB changes.
