---
solana_kit_rpc_parsed_types: minor
---

Implement RPC parsed types package ported from `@solana/rpc-parsed-types`.

**solana_kit_rpc_parsed_types** (32 tests):

- Typed representations of JSON-parsed account data from the Solana RPC
- Address lookup table, BPF upgradeable loader, config, nonce, stake, sysvar, token, and vote account types
- Sealed class hierarchies for discriminated unions enabling exhaustive pattern matching
- `RpcParsedType<TType, TInfo>` and `RpcParsedInfo<TInfo>` base classes
- All 10 sysvar account types: clock, epochRewards, epochSchedule, fees, lastRestartSlot, recentBlockhashes, rent, slotHashes, slotHistory, stakeHistory
- Token program accounts: account, mint, multisig with `TokenAccountState` enum
