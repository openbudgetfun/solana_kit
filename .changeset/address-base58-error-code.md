---
"solana_kit_address": patch
---

# Throw the address-scoped error for non-base58 address characters

`assertIsAddress` validated string length and decoded byte count with dedicated `SolanaErrorCode`s, but a string in range whose characters fall outside the base58 alphabet leaked the codec's own error instead. That input now throws `SolanaErrorCode.addressesInvalidBase58EncodedAddress` with the `putativeAddress` context and the codec failure as its cause, matching the upstream `@solana/kit` error contract. `isAddress` still returns false for the same input.
