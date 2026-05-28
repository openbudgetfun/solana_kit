---
"solana_kit_keys": patch
---

# Zero KeyPair private key memory on GC

SEC-02: Add Finalizer-based memory zeroing for KeyPair private keys.

- Added `Finalizer` that zeros internal key bytes when `KeyPair` is garbage collected
- Added `dispose()` method to explicitly zero key bytes on demand
- Added `isDisposed` property to check if `dispose()` has been called
- `privateKey` and `publicKey` getters now throw `StateError` after `dispose()`
- Documented limitations of Dart's GC-based finalization
- 4 new tests covering dispose behavior
