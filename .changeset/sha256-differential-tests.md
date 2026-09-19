---
"solana_kit_anchor": patch
"solana_kit_sns": patch
---

# Verify both hand-written SHA-256 implementations against an independent hash

`solana_kit_anchor` and `solana_kit_sns` each carry their own pure-Dart SHA-256. Anchor uses it to derive program discriminators and SNS to derive name account addresses, so a defect in either changes which instruction or account a program resolves to — a wrong result rather than an exception. Both were covered only by a handful of fixed NIST vectors, which pin the round function but rarely land on the padding and block boundaries where a length bug hides.

Each package now has a `sha256_differential_test.dart` comparing its implementation against `package:crypto` (the same dependency `solana_kit_addresses` already uses). Coverage includes every input length from 0 to 200, which crosses the 55/56-byte padding transitions and the 64-byte block boundary, lengths from 255 through 10000 for multi-block behavior, randomized inputs, and all-zero and all-`0xff` buffers. Anchor additionally checks `instructionDiscriminator` against the truncated namespaced digest, and SNS checks `getHashedName` against `sha256("SPL Name Service" + name)`.

Both implementations agree with the reference on every case. No library behavior changes.
