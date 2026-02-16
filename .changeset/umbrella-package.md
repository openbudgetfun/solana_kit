---
solana_kit: minor
---

Implement umbrella package re-exporting all Solana Kit Dart SDK packages.

**solana_kit** (10 tests):

- Re-exports all 28 public packages from the SDK (accounts, addresses, codecs, errors, instructions, keys, rpc, signers, transactions, etc.)
- `getMinimumBalanceForRentExemption` helper computing rent exemption without RPC call
- Handles ambiguous exports with explicit `hide` directives for conflicting names
