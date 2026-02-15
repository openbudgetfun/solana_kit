---
solana_kit_addresses: minor
solana_kit_keys: minor
---

Implement addresses and keys packages ported from `@solana/addresses` and `@solana/keys`.

**solana_kit_addresses** (65 tests):

- `Address` extension type wrapping validated base58-encoded 32-byte strings
- Address codec (`getAddressEncoder`/`getAddressDecoder`/`getAddressCodec`) for 32-byte fixed-size encoding
- Address comparator with base58 collation rules matching Solana runtime ordering
- Ed25519 curve checking (`compressedPointBytesAreOnCurve`, `isOnCurveAddress`, `isOffCurveAddress`)
- PDA derivation (`getProgramDerivedAddress`) with SHA-256, bump seed search, and seed validation
- `createAddressWithSeed` for deterministic address derivation
- Public key to/from address conversion utilities

**solana_kit_keys** (36 tests):

- `Signature` and `SignatureBytes` extension types for Ed25519 signatures
- Key pair generation, creation from bytes, and creation from private key bytes
- Ed25519 sign/verify operations using `ed25519_edwards` package
- Signature validation (string length, byte length, base58 decoding)
- Private key validation and public key derivation
