---
"solana_kit_mpl_bubblegum": major
---

# Sync MPL Bubblegum errors and instruction discriminators

Added the upstream Bubblegum collection seller-fee errors from commit `68e4bc20`, exported generated error helpers from the generated barrel, corrected the canonical Bubblegum program address, and encoded generated instructions with Anchor 8-byte discriminators instead of ordinal indices.

```dart
// Before: instructions encoded with an ordinal index discriminator
final data = Uint8List.fromList([0x00, ...args]);

// After: generated encoders emit the Anchor 8-byte discriminator
final data = getTransferInstructionDataEncoder().encode(
  TransferInstructionData(leafOwner: owner, ...),
);
```
