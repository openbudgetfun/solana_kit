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

## [0.9.3](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.3) (2026-09-12)

### Changed

- **No package-specific changes were recorded; `solana_kit_codecs_core` was updated to 0.9.3 as part of group `main`.**

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### 🐛 Fixed

#### Validate codec boundaries and compact lengths

Numeric codecs now keep reads and writes within the supplied byte view, preventing access to adjacent backing-buffer data. Short-u16 decoders reject overflowing values and overlong aliases so malformed compact lengths cannot be accepted as valid Solana wire data. Size-prefixed decoders reject negative, fractional, non-finite, and oversized lengths before decoding their contents.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_codecs_core` was updated to 0.9.1 as part of group `main`.

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 🐛 Fixed

#### Support Keccak-256 on Flutter web

Preserve exact 64-bit Keccak state with `BigInt`, allowing JavaScript and WebAssembly Flutter builds to use the existing Keccak-256 API safely.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #224](https://github.com/openbudgetfun/solana_kit/pull/224)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### 🐛 Fixed

#### Reject over-capacity generated values

Adds an opt-in non-truncating mode to fixed-size encoders and codecs. Codama fixed-size types now use that mode so generated string, byte, and collection encoders pad values within capacity but reject oversized encoded values.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #216](https://github.com/openbudgetfun/solana_kit/pull/216)

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

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`48216f9`](https://github.com/openbudgetfun/solana_kit/commit/48216f9af0ff058d7db83994e5bdb3b9be95fdf8) · _Last updated in:_ [`b7f5419`](https://github.com/openbudgetfun/solana_kit/commit/b7f5419bbe792d4ba1731eba227088d8f74a3ebb)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🚀 Feature

#### Add Keccak-256 hash function

Adds a pure-Dart Keccak-256 implementation (`keccak256()`) to `solana_kit_codecs_core`. This is the hash function used by the Bubblegum compressed NFT program (not to be confused with SHA3-256, which uses different padding).

Note: Keccak-256 round constants exceed 2^53, so `ignore_for_file: avoid_js_rounded_ints` is applied to the implementation file. This is acceptable because the Solana SDK targets native platforms where `int` is 64-bit.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Align byte containment with upstream

Align byte containment helpers with upstream behavior for…

Align byte containment helpers with upstream behavior for negative offsets and boundary checks, including regression coverage for offset handling.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
