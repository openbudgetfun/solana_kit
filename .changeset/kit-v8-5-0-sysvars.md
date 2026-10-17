---
"solana_kit_sysvars": patch
---

# Fix the `SlotHashes` and `RecentBlockhashes` sysvar length prefix

Ports the wire-format fix from `@solana/sysvars` v8.5.0 (#2116): the entry arrays of `SysvarSlotHashes` and `SysvarRecentBlockhashes` are prefixed with a `u64` length on chain, not a `u32` one. The codecs now use `u64`, so decoded slots, hashes, and fee values are no longer shifted by four bytes.
