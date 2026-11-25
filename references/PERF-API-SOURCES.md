# Lesson 32 phase 1 — performance sources
- https://github.com/reduxjs/redux-toolkit — https://redux.js.org/toolkit/api/createEntityAdapter — normalized entities and ordered IDs.
- https://github.com/reduxjs/reselect — https://reselect.js.org/usage/best-practices/ — stable inputs and cached outputs.
- https://github.com/TanStack/virtual/blob/main/docs/api/virtualizer.md — measurement caching; https://github.com/TanStack/virtual/tree/main/benchmarks — measure costs before changing virtualization.
Decision: optimize existing store owners rather than install additional runtime libraries; no copied upstream code. Deterministic work counters first, UI/device timing later.

## v13.70 phase 2
- https://github.com/TanStack/virtual/blob/main/packages/virtual-core/src/index.ts — memoized range/index calculation, stable row keys, cached measurements.
- https://github.com/TanStack/virtual/blob/main/docs/api/virtualizer.md — rangeExtractor, getItemKey and measurement cache contracts.
Decision: preserve existing parent Virtualizer and guard DOM writes, reconcile keyed rows with minimal moves; no runtime dependency. Verify actual MutationObserver records rather than claiming device speed.
