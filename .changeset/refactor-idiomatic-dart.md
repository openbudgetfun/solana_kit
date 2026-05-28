---
"solana_kit_mpl_bubblegum": patch
---

# Refactor to idiomatic Dart patterns

- Add `concatBytes()` and `concatAll()` utilities for efficient byte array concatenation
- Replace `Uint8List.fromList([...a, ...b])` with `concatBytes(a, b)` in merkle tree and hash functions
- Add `@immutable` annotation to internal `_MerkleNode` class
- Use `const` constructor for immutable classes
- Add `zeroBytes32()`, `bytes32FromHex()`, `bytes32ToHex()` utilities for 32-byte arrays
