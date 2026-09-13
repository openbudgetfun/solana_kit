---
"solana_kit": minor
"solana_kit_codecs_core": minor
"solana_kit_codecs_numbers": minor
"solana_kit_errors": patch
---

# Track @solana/kit v8.3.0

The workspace now tracks upstream `@solana/kit` v8.3.0 (previously v8.2.0), and `upstream:parity` passes against it. This entry maps every change in that upstream release to its Dart counterpart.

Ported in this release:

- `u256` and `i256` number codecs (`getU256Codec`, `getI256Codec` and their encoder/decoder pairs) serialize 32 bytes, honour the `endian` option, validate the full range on encode, and decode to `BigInt`, mirroring the existing 64-bit and 128-bit codecs.
- Tap codec helpers observe values or bytes without modifying them: `tapEncoder`, `tapDecoder`, and `tapCodec` observe values, while `tapEncoderBytes`, `tapDecoderBytes`, and `tapCodecBytes` observe raw bytes and offsets. Each wrapper preserves the size characteristics of what it wraps, and any tap may throw, which makes them validation guards that need no identity `transformEncoder`.

Already present before this release, and now covered by the v8.3.0 claim:

- The `getAgGenesisCert` RPC method and its allowed numeric keypaths.
- `isSolanaRequest` recognising `getAgGenesisCert` and `getTransactionsForAddress`, which is also what fixed upstream's `bigint` parsing for `getTransactionsForAddress` responses.

No Dart change needed:

- `HasAddress` and the `InstructionAccountInput` / `InstructionSignerInput` widening are TypeScript type-level changes. Dart has no structural typing, and this port's `ResolvedInstructionAccount` already wraps an `Object` value, so it accepts addresses, address-bearing objects, `ProgramDerivedAddress` values, and `AccountMeta` role overrides at runtime without a cast.
- Marking `role` as `readonly` on the writable and signer account types is already true here: `AccountMeta.role` is a `final` field.
- `createLazyKeyPairSignerFromBytes` exists upstream to defer an asynchronous WebCrypto key import. Signer creation in this port is synchronous, so there is nothing to defer and the type is not needed.

Verification:

- `upstream:parity` passes against `@solana/kit@8.3.0`
- `upstream:check` reports the metadata is internally consistent for tracked version 8.3.0
- The `@solana/kit` reference pin moved to tag `v8.3.0`
