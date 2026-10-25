---
"solana_kit_keys": patch
---

# Zero expanded-key intermediates after key generation and signing

`KeyPair.dispose` zeroes the stored seed, but `generateKeyPair`, `signBytes`, and `getPublicKeyFromPrivateKey` each derived a fresh 64-byte expanded key — seed plus public key — and left it unzeroed on the heap until garbage collection. All three now zero the expanded key (and the seed copy) in a `finally` block, so the only surviving copy of key material lives in objects whose lifetime the caller controls.
