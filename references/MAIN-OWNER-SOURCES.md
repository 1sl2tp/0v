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

## v13.81 phase 3g
- https://github.com/TanStack/table — separate row projection, sorting and presentation.
- https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing — derive read models from events.
Decision: read-only projection over existing fixture API, explicit clock and multiple reasons; no new production dependency.

## v13.82 phase 3h
- https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/coding/data-modeling.md — immutable financial transfers and idempotent IDs.
- https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/reference/transfer.md — stable financial transaction identity.
Decision: attach verification evidence to original fixture receipt, no additional posting and no silent amount change. Production implementation separate.

## v13.83 phase 3i
- https://github.com/JohannesBuchner/imagehash — difference and crop-resistant hashing.
- https://github.com/thorn-oss/perception/blob/main/docs/examples/deduplication.rst — similarity thresholds.
- https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/coding/data-modeling.md — idempotent transaction identity.
Decision: source digest + normalized regions, conservative dHash candidates, no automatic merge. No upstream code copied or dependency added.

## v13.84 phase 3j
- https://github.com/opencv/opencv/blob/5.x/doc/tutorials/imgproc/shapedescriptors/find_contours/find_contours.markdown — region segmentation concepts; current lightweight horizontal projection is not OpenCV contour detection.
- https://github.com/JohannesBuchner/imagehash/blob/master/README.rst — luminance hashes vs cryptographic digests.
- https://github.com/naptha/tesseract.js/blob/master/README.md — reusable OCR worker interface; not installed in this phase.
Decision: local browser decode and review-only region proposals. No upstream code copied, no external dependency.

## v13.85 phase 3k
- https://github.com/naptha/tesseract.js/blob/master/docs/api.md — reusable worker, recognize and language assets. No engine installed.
- https://github.com/PaddlePaddle/PaddleOCR/blob/main/README.md — OCR/document understanding toolkit, separation of recognition and extraction.
Decision: deterministic text-to-field contract ahead of OCR engine; preserve provenance, no inferred payment data, no new dependency.

## v13.86 phase 3l
- https://github.com/naptha/tesseract.js/blob/v6.0.1/docs/api.md — worker lifecycle, recognize, output and language options.
- https://github.com/naptha/tesseract.js/blob/v6.0.1/src/worker-script/index.js — language download/cache behavior.
- https://github.com/naptha/tesseract.js/blob/v6.0.1/package.json — exact version/core compatibility.
Decision: opt-in demo CDN only; no real customer image until self-hosted verified assets. No copied upstream code, no dependency committed.

## v13.87
Internal CHAT reference: docs/bank-bill-ocr-casebook.md (BANK-286/317), bill-amount-rules.mjs (BANK-357/358) and test_bank269_bill_literal_date_clock_20261110.mjs. Reused field semantics and conservative literal date/clock rules only; no private source examples or data copied. Tesseract.js integration unchanged.
