---
solana_kit_functional: minor
solana_kit_fast_stable_stringify: minor
---

Implement foundation utility packages ported from the `@solana/functional` and
`@solana/fast-stable-stringify` TypeScript packages.

**solana_kit_functional**: Adds the `Pipe` extension which provides a `.pipe()`
method on any value for composable functional pipelines. This is the idiomatic
Dart equivalent of the TS `pipe()` function, used extensively for building
transaction messages. Includes 28 tests covering single/multiple transforms,
type changes, object mutation, combining, nested pipes, and error propagation.

**solana_kit_fast_stable_stringify**: Adds `fastStableStringify()` for
deterministic JSON serialization with sorted object keys. Handles all Dart
primitives, BigInt (serialized as `<value>n`), nested maps, lists, and objects
implementing `ToJsonable`. Includes 15 tests matching the upstream SDK's
`json-stable-stringify` reference output.
