# Lesson 33 phase 1
- https://github.com/adobe/react-spectrum/tree/main/packages/%40react-stately/collections — collection ownership and stable item identity.
- https://react.dev/learn/keeping-components-pure — separate rendering from state updates.
- https://github.com/1sl2tp/0v/blob/main/references/COMPONENT-API.md — existing parent contracts.
Decision: migrate plain-text and contact presentation through existing parents first; do not replace fixture state or keyboard at the same time. No upstream code copied.

## v13.74 phase 2
- https://redux.js.org/usage/structuring-reducers/normalizing-state-shape — single normalized source for related entities.
- https://redux.js.org/toolkit/api/createEntityAdapter — stable IDs and derived selectors.
- https://matrix-org.github.io/matrix-js-sdk/classes/matrix.Room.html — room-scoped ordered timelines.
Decision: keep existing Store APIs, use MainDataController as fixture adapter, retain legacy seed display and QA rollback; no runtime dependency or copied upstream code.

## v13.75 phase 3a
- https://github.com/dinerojs/dinero.js/blob/main/README.md — immutable money, bigint and explicit precision.
- https://github.com/tc39/proposal-temporal/blob/main/docs/timezone.md — distinguish instant, local calendar/time and zone.
Decision: retain exact Foundation APIs, use narrow fixture boundary adapter, no new dependency. Do not infer short date year or change reconciliation policy.

## v13.76 phase 3b
- https://github.com/statelyai/xstate — explicit state transitions and guards.
- https://github.com/stripe/stripe-node/blob/master/README.md — idempotency keys and safe retry.
- https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Webhook_Security_Cheat_Sheet.md — verify event and persist processed IDs before suppressing duplicate delivery.
Decision: narrow local fixture guard only; durable idempotency remains a production adapter responsibility. Do not loosen real bill matching or send notices.

## v13.77 phase 3c
- https://github.com/aws-samples/transactional-outbox-pattern/blob/main/README.md — separate committed write and relay, duplicate handling.
- https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html — atomic intent and idempotent consumer.
Decision: reuse existing evidence owner, expose read-only order projection, do not implement real outbox transport in UI.

## v13.78 phase 3d
- https://www.unicode.org/cldr/charts/50/verify/dates/vi.html — Vietnamese date patterns.
- https://github.com/unicode-org/cldr/blob/main/docs/site/translation/date-time/date-time-patterns.md — locale date fields.
- https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Webhook_Security_Cheat_Sheet.md — verify and persist processed event IDs for duplicate handling.
Decision: explicit calendar dates, conservative fixture-only candidate matching; no date inference or durable posting claim.

## v13.79 phase 3e
- https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing — replay, immutable event history and idempotent consumers.
- https://github.com/matrix-org/matrix-js-sdk/blob/develop/src/client.ts — sync reconnect states and retry.
Decision: bounded local event dispatcher, deterministic recompute, no production event store or transport.

## v13.80 phase 3f
- https://github.com/w3c/IndexedDB — IndexedDB transaction atomicity and completion.
- https://developer.mozilla.org/en-US/docs/Web/API/IDBTransaction/complete_event — publish only on transaction completion.
- https://github.com/postgres/postgres/blob/master/doc/src/sgml/ddl.sgml — unique constraints and durable relational design (future production adapter only).
Decision: isolated bounded journal for fixtures; no server/database migration or real posting.
