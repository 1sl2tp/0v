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
