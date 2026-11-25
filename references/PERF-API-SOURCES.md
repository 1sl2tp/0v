# Lesson 32 phase 1 — performance sources
- https://github.com/reduxjs/redux-toolkit — https://redux.js.org/toolkit/api/createEntityAdapter — normalized entities and ordered IDs.
- https://github.com/reduxjs/reselect — https://reselect.js.org/usage/best-practices/ — stable inputs and cached outputs.
- https://github.com/TanStack/virtual/blob/main/docs/api/virtualizer.md — measurement caching; https://github.com/TanStack/virtual/tree/main/benchmarks — measure costs before changing virtualization.
Decision: optimize existing store owners rather than install additional runtime libraries; no copied upstream code. Deterministic work counters first, UI/device timing later.

## v13.70 phase 2
- https://github.com/TanStack/virtual/blob/main/packages/virtual-core/src/index.ts — memoized range/index calculation, stable row keys, cached measurements.
- https://github.com/TanStack/virtual/blob/main/docs/api/virtualizer.md — rangeExtractor, getItemKey and measurement cache contracts.
Decision: preserve existing parent Virtualizer and guard DOM writes, reconcile keyed rows with minimal moves; no runtime dependency. Verify actual MutationObserver records rather than claiming device speed.

## v13.71 phase 3
- https://redux.js.org/usage/structuring-reducers/normalizing-state-shape — normalized lookup keyed by ID, relationships by IDs.
- https://redux.js.org/toolkit/api/createEntityAdapter — normalized lookup and ordered IDs.
- https://github.com/matrix-org/matrix-js-sdk/blob/develop/src/models/event-timeline-set.ts — room-scoped event timelines and gap handling.
Decision: reverse index owned by ConversationStore, shared validation for sync and cache, preserve mismatch rejection. No vendored code.
