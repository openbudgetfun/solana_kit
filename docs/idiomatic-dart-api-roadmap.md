# Solana Kit: Idiomatic Dart API Deep Dive

## Goals

1. Keep parity with upstream `@solana/kit`.
2. Make the API feel native to Dart (discoverable, type-safe, composable).
3. Preserve performance and tree-shakeability.

## Current Strengths

- Strong use of immutable value objects and `copyWith`.
- Good use of sealed classes in several domains (`Option`, parsed types, plans).
- Extension types already used for important primitives (`Address`, `Signature`, typed numeric wrappers).
- Broad package modularity enables selective dependency footprints.

## Key Friction Points (With Concrete Targets)

### 1) Stringly RPC surface and dynamic response handling

- Current usage frequently relies on `rpc.request('methodName', params).send()`.
- Downstream helpers still cast into `Map<String, dynamic>` and parse manually.
- Targets:
  - `packages/solana_kit_rpc/lib/src/rpc.dart`
  - `packages/solana_kit_accounts/lib/src/fetch_account.dart`

Impact:

- Weak IDE autocomplete.
- More runtime failures and manual shape validation.

### 2) Transaction message composition mirrors TS-style free functions

- Message transforms are mostly `setX(value, message)` function style, often combined with `.pipe`.
- Targets:
  - `packages/solana_kit_transaction_messages/lib/src/fee_payer.dart`
  - `packages/solana_kit_transaction_messages/lib/src/instructions.dart`

Impact:

- Less Dart-idiomatic than extension/fluent APIs.
- Discoverability is lower from code completion on `TransactionMessage`.

### 3) Lifetime typing in transactions is too loose

- `TransactionLifetimeConstraint` is `typedef ... = Object` and `TransactionWithLifetime` stores `Object`.
- `compileTransaction` can emit internal `_NoLifetime` placeholder.
- Targets:
  - `packages/solana_kit_transactions/lib/src/lifetime.dart`
  - `packages/solana_kit_transactions/lib/src/compile_transaction.dart`

Impact:

- Harder to reason about correctness at compile time.
- More runtime type checks and branching.

### 4) Codec generic precision remains partially erased

- Union codecs return `Object?`, causing adapter/cast overhead in higher-level APIs.
- Targets:
  - `packages/solana_kit_codecs_data_structures/lib/src/union.dart`

Impact:

- Weaker type inference for users writing custom codecs.

## Dart-First Design Direction

### A) Fluent extensions for immutable domain objects

- Keep function helpers for parity.
- Add extension APIs as the preferred Dart surface.
- Example:
  - `message.withFeePayer(...).withBlockhashLifetime(...).appendInstruction(...)`

### B) Generated typed RPC facade

- Preserve low-level `request()` for escape hatches.
- Add generated method layer:
  - `rpc.getBalance(address, config: ...)`
  - `rpc.getAccountInfo(address, config: ...)`
- Return typed response wrappers and reduce dynamic map parsing.

### C) Sealed domain hierarchies instead of `Object`

- Introduce sealed `TransactionLifetimeConstraint` with concrete variants.
- Remove placeholder lifetime values.
- Make invalid states unrepresentable.

### D) Better async ergonomics

- Add higher-level futures/streams for common workflows:
  - `sendAndConfirm(...)`
  - cancellable stream subscriptions with well-scoped lifetimes.

### E) Codec API specialization

- Introduce typed union variants (`Union2`, `Union3` style helpers) while retaining generic union primitives.

## Prioritized Execution Plan

### Phase 1 (Additive, low risk)

1. Add fluent extension methods for `TransactionMessage`.
2. Document preferred Dart-idiomatic usage in package README and root examples.
3. Add extension methods for common transaction helper flows.

### Phase 2 (Additive + generated ergonomics)

1. Introduce typed RPC convenience facade over `request()`.
2. Add generated method docs and examples.
3. Keep full parity coverage tests against existing behavior.

### Phase 3 (Type safety hardening)

1. Replace `Object` lifetime constraint with a sealed hierarchy.
2. Remove `_NoLifetime` fallback path.
3. Update compiler pipeline to enforce lifetime presence explicitly.

### Phase 4 (Advanced ergonomics/perf)

1. Codec type inference improvements for unions.
2. Optional isolate-backed decoding for heavy payloads.
3. Rich typed error helpers layered over numeric codes.

## Success Criteria

- New users can complete a transaction flow without touching `Map<String, dynamic>`.
- IDE autocomplete leads users toward typed methods/extensions first.
- Fewer runtime type checks in high-traffic paths.
- Existing APIs remain available for upstream parity and migration safety.
