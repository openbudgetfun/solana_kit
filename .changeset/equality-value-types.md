---
"solana_kit_rpc_types": patch
"solana_kit_rpc_api": patch
"solana_kit_instructions": patch
"solana_kit_transaction_messages": patch
"solana_kit_transaction_confirmation": patch
"solana_kit_rpc_spec_types": patch
"solana_kit_rpc_parsed_types": patch
---

Add `==` and `hashCode` to public value-type, config, and response classes.

Implements issue #114. All config, request, and response classes in the RPC
layer, as well as core instruction and transaction-message value types, now
support structural equality. This enables correct use in `Set`s, as `Map` keys,
and in test assertions.

All affected classes are also annotated with `@immutable` to satisfy the
`avoid_equals_and_hash_code_on_mutable_classes` lint rule, since every field
is already `final`.

Packages that did not previously depend on `meta` now declare `meta: any`
explicitly (`solana_kit_rpc_api`, `solana_kit_transaction_confirmation`,
`solana_kit_rpc_spec_types`, `solana_kit_rpc_parsed_types`).
