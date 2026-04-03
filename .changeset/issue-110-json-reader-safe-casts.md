---
"solana_kit_helius": patch
---

Introduce internal `JsonReader` helper that replaces unsafe `.cast<T>()` list
casts and bare `as` casts in all `fromJson` factories with explicit typed
accessors. Parse errors now surface at construction time via a descriptive
`FormatException` that includes the field name, rather than deferring until
element access. All ten type files (`das_types`, `enhanced_types`, `zk_types`,
`wallet_types`, `webhook_types`, `rpc_v2_types`, `auth_types`, `staking_types`,
`priority_fee_types`, `smart_transaction_types`) have been migrated. The public
API is unchanged.
