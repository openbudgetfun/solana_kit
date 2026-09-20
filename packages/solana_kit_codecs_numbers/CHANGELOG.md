# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.10.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.10.0) (2026-09-21)

### Breaking changes

#### Raise the Dart and Flutter baseline

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. `solana_kit_lints` ships the raised floor to consumers, so it carries the same breaking bump. Every other package raises only the Dart SDK floor.

Raising the language version also switches `dart format` to the tall style, so 83 files across library, test, script, and Codama-generated trees are reflowed. The renderer pipes generated output through `dart format`, so regenerating stays consistent.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [5f5fe01](https://github.com/openbudgetfun/solana_kit/commit/5f5fe01f3e2220ccfee54cc26e82c3face26589d) · _Last updated in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

### Features

#### Add 256-bit number codecs and tap codec helpers

Ports the two additive codec surfaces from upstream `@solana/kit` v8.3.0.

`solana_kit_codecs_numbers` gains 256-bit integer codecs: `getU256Codec`, `getU256Encoder`, and `getU256Decoder` for unsigned values in `[0, 2^256 - 1]`, plus `getI256Codec`, `getI256Encoder`, and `getI256Decoder` for signed values in `[-(2^255), 2^255 - 1]`. Both serialize as 32 bytes, honour the `endian` option, and always decode to `BigInt`, matching the existing 64-bit and 128-bit codecs.

`solana_kit_codecs_core` gains tap helpers that observe values or bytes without modifying them. Because any callback may throw, they double as validation guards that need no identity `transformEncoder`:

```dart
final guarded = tapDecoderBytes(getU8Decoder(), (bytes, offset) {
  if (bytes[offset] > 1) throw StateError('Expected a 0 or a 1');
});

final spanned = tapEncoderBytes(getU8Encoder(), (bytes, pre, post) {
  print('wrote ${post - pre} bytes at $pre');
});
```

`tapEncoder`, `tapDecoder`, and `tapCodec` observe values; `tapEncoderBytes`, `tapDecoderBytes`, and `tapCodecBytes` observe bytes and offsets. Each wrapper preserves the size characteristics of the codec it wraps, so `FixedSizeEncoder` stays fixed-size and `VariableSizeEncoder` keeps its `maxSize`.

Note that Dart's `Codec` is not an `Encoder` or a `Decoder`, so the value-level wrappers are typed against the encoder or decoder they observe; use `tapCodec` and `tapCodecBytes` to wrap a codec.

_Owner:_ Ifiok Jr. · _Introduced in:_ [220066e](https://github.com/openbudgetfun/solana_kit/commit/220066ecb27aa738fd787ac8ada3918540435cc1)

#### Track @solana/kit v8.3.0

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

_Owner:_ Ifiok Jr. · _Introduced in:_ [220066e](https://github.com/openbudgetfun/solana_kit/commit/220066ecb27aa738fd787ac8ada3918540435cc1)

### Fixes

#### Reject truncated numeric reads with `SolanaError` instead of `RangeError`

A decoder reading a fixed-width field out of malformed wire data could raise a raw `RangeError` or `IndexError` out of the SDK instead of the documented `SolanaError`, so a caller catching `SolanaError` saw an escaped exception rather than a rejection it could handle. A truncated account, transaction, or RPC payload reaching the decoders was enough to trigger it; no signature or cluster access was required.

The guard that upstream `@solana/kit` applies in its number decoder factory was missing from three ports of it. `numberDecoderFactory` and `floatDecoderFactory` read through a `ByteData` view without first checking that the requested width was available, and the six `BigInt` decoders (`u64`, `i64`, `u128`, `i128`, `u256`, `i256`) indexed bytes directly with the same gap. All eight now call `assertByteArrayIsNotEmptyForCodec` and `assertByteArrayHasEnoughBytesForCodec` before reading, raising `codecsCannotDecodeEmptyByteArray` or `codecsInvalidByteLength` as upstream does. A new `bigIntDecoderFactory` carries the guard for the multi-word widths.

Two further escape sites in `solana_kit_transaction_messages` are fixed. The version 1 instruction payload slice computed `pos + numInstructionDataBytes` and sliced without confirming the buffer held that many bytes; it now asserts the length the way upstream's `fixDecoderSize` wrapper does. The transaction version decoder read `bytes[offset]` unguarded — upstream tolerates this because JavaScript yields `undefined`, which then silently takes the legacy branch and misreports a truncated buffer as an unversioned message, so this port rejects the empty buffer rather than reproducing that fallback.

Encoders are unchanged and still raise `RangeError` when a destination buffer is too small. Upstream writes into a scratch buffer and then `bytes.set`s it, which throws in JavaScript too, so that behavior is deliberate parity rather than a defect.

Callers that caught `RangeError` around a decode should catch `SolanaError`. Callers that already caught `SolanaError` now see malformed input rejected where it previously surfaced as a crash.

_Owner:_ Ifiok Jr. · _Introduced in:_ [f21cd21](https://github.com/openbudgetfun/solana_kit/commit/f21cd21d26750d70f0c72e6acf8440346cf8175e)

## [0.9.3](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.3) (2026-09-12)

### Changed

- **No package-specific changes were recorded; `solana_kit_codecs_numbers` was updated to 0.9.3 as part of group `main`.**

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### 🐛 Fixed

#### Validate codec boundaries and compact lengths

Numeric codecs now keep reads and writes within the supplied byte view, preventing access to adjacent backing-buffer data. Short-u16 decoders reject overflowing values and overlong aliases so malformed compact lengths cannot be accepted as valid Solana wire data. Size-prefixed decoders reject negative, fractional, non-finite, and oversized lengths before decoding their contents.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_codecs_numbers` was updated to 0.9.1 as part of group `main`.

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 🚀 Feature

#### Typed tuple codecs and explicit integer factories

Add typed `getTuple2Encoder`/`getTuple2Decoder` helpers to `solana_kit_codecs_data_structures`, exposing two-element tuples as Dart records. Give the integer codec factories in `solana_kit_codecs_numbers` explicit generic specializations while preserving their existing `FixedSizeEncoder<num>` public return types. `codama-renderers-dart` now emits `getTuple2*` for arity-2 tuple nodes, escapes Dart reserved-word identifiers, keeps generated `instructionData` locals collision-free, and gives generated byte/list fields recursive value equality and hashing.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_codecs_numbers` was updated to 0.8.0 as part of group `main`.

## [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.7.0) (2026-08-18)

### 📖 Documentation

#### Reformat package docs

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-08-12)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)
