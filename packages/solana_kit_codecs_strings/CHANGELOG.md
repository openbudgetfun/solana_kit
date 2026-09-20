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

#### Add the upstream size-prefix and UTF-8 codec options

Ports the last two surfaces from upstream `@solana/kit` v8.3.0. Both are additive: no existing behavior changes.

`requireSizePrefix` is a named parameter on `getArrayDecoder`, `getArrayCodec`, `getSetDecoder`, `getSetCodec`, `getMapDecoder`, and `getMapCodec`. Upstream defaults it to `false`, where an exhausted byte array decodes as an empty collection so a collection can be appended to an existing layout. This port defaults it to `true` and throws, because a silently empty collection hides truncated input. Pass `requireSizePrefix: false` to opt in:

```dart
final lenient = getArrayCodec(getU8Codec(), requireSizePrefix: false);
lenient.decode(Uint8List(0)); // []
getArrayCodec(getU8Codec()).decode(Uint8List(0)); // throws
```

`Utf8CodecConfig` is accepted by `getUtf8Encoder`, `getUtf8Decoder`, and `getUtf8Codec`, and carries upstream's three options:

- `fatal` rejects malformed input instead of replacing it. Upstream defaults to `false`, decoding bad bytes as `U+FFFD`; this port defaults to `true` and raises a `FormatException` from decoding and, for lone surrogates, from encoding.
- `ignoreBOM` preserves a leading byte order mark. Both default to `false`, which strips it, matching Dart's `Utf8Decoder`.
- `removeNullCharacters` strips `U+0000` from decoded strings. Upstream defaults to `true`; this port defaults to `false` so the decoded value reflects the bytes exactly.

The two divergent defaults exist so that malformed or null-padded account and instruction data cannot decode silently. To take upstream's behavior explicitly:

```dart
final codec = getUtf8Codec(
  const Utf8CodecConfig(fatal: false, removeNullCharacters: true),
);
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [cf4ab87](https://github.com/openbudgetfun/solana_kit/commit/cf4ab873e32bb2ce2f4fe69e73fbc8aa6162894b)

#### Align error code numbers with upstream and report malformed UTF-8 as a code

`SolanaErrorCode` numbers now match upstream `@solana/kit` exactly. Two port-only codes were occupying numbers upstream uses for its UTF-8 codes, which made any cross-SDK comparison of those numbers wrong.

The UTF-8 codec also stops raising a bare `FormatException` and reports through the error codes upstream defines:

- `codecsInvalidUtf8Bytes` (`8078026`) for a malformed byte sequence, carrying the `offset` where decoding failed.
- `codecsInvalidUtf8String` (`8078027`) for a lone surrogate, carrying its `index`. This is thrown when encoding with `fatal: true` and, with `fatal: false`, both directions keep replacing the offending unit with `U+FFFD`.

Two port-only codes moved or went away:

- `codecsInvalidBoolean` moved from `8078027` to `8078999`. The number had to change because `8078027` is upstream's `CODECS__INVALID_UTF8_STRING`. This port validates that booleans are encoded as `0` or `1` and upstream does not, so the code has no upstream counterpart and now sits at the end of the codec block, where upstream cannot collide with it. If you match on `SolanaErrorCode.codecsInvalidBoolean.value`, update the number; matching on the enum member is unaffected.
- `codecsStringContainsNullCharacters` was removed. Nothing in the workspace threw it, and upstream has no equivalent. Use `Utf8CodecConfig.removeNullCharacters` to control null handling instead.

```dart
try {
  getUtf8Decoder().decode(bytes);
} on SolanaError catch (error) {
  if (error.code == SolanaErrorCode.codecsInvalidUtf8Bytes) {
    print('bad bytes at ${error.context['offset']}');
  }
}
```

`solana_kit_memo`, `solana_kit_offchain_messages`, and `solana_kit_attestation_service` only had tests asserting the old `FormatException` for malformed UTF-8; those assertions now check the error code, and `solana_kit_memo` declares the `solana_kit_errors` dev dependency that needs.

`upstream:error-codes`, which also runs as part of `docs:check`, compares this enum against `.repos/kit/packages/errors/src/codes.ts` and fails on a number mismatch or an occupied number, so this cannot drift again without CI saying so.

_Owner:_ Ifiok Jr. · _Introduced in:_ [a8f643f](https://github.com/openbudgetfun/solana_kit/commit/a8f643f1ae7e6594fbfa972d473f7042b1f6ace0)

### Fixes

#### Speed up base-X codecs, BigInt JSON parsing, and fixed-point parsing

Same results, less work per call. No public API, output byte, or error behavior changed; `upstream:parity` passes against `@solana/kit@8.3.0` and the full workspace suite is green.

The base-X codecs converted through `BigInt`, scaled the alphabet with `String.indexOf` and a fresh one-character string per input character, and built output with repeated `insert(0, …)` calls that reallocate and shift the whole list each time. Encoding a typical base58 address cost roughly 600 µs, so compiling a 20-account transaction spent measurable milliseconds on address encoding alone. The conversion now folds digits into a byte buffer with word-sized carry arithmetic, indexes the alphabet through a cached code-unit lookup, and writes output in order:

```dart
// Before: BigInt division per character plus O(n²) list inserts.
// After: one carry pass per character over a preallocated buffer.
final converted = _convertToBytes(value, alphabet);
bytes
  ..fillRange(offset, offset + converted.leadingZeroes, 0)
  ..setAll(offset + converted.leadingZeroes, converted.bytes);
```

Measured on an interleaved best-of-N benchmark, with the previous implementation running in the same process to cancel machine noise:

| Operation                        | Before   | After   | Improvement |
| -------------------------------- | -------- | ------- | ----------- |
| base58 encode, typical address   | 22.97 µs | 2.88 µs | 8.0x        |
| base58 decode, 32 bytes          | 16.79 µs | 3.24 µs | 5.2x        |
| base58 encode, 64-byte signature | 52.89 µs | 8.44 µs | 6.3x        |

`parseJsonWithBigInts` allocated a one-character string and ran up to two regular expressions per character of the payload, then rebuilt the document character by character. It now scans by code unit, copies literal runs as substrings, and hoists the exponent pattern:

| Operation                 | Before   | After    | Improvement |
| ------------------------- | -------- | -------- | ----------- |
| parse a 28 KB RPC payload | 2.198 ms | 1.089 ms | 2.0x        |

Also removed in the same pass: a redundant full copy in the UTF-8 encoder and the base64 decoder (both `utf8.encode` and `base64.decode` already return `Uint8List`), a double copy of every version-1 instruction payload, and two regular expressions that were compiled per parsed value in the fixed-point codecs.

Behavior is pinned by tests rather than assumed. `base_x_property_test.dart` round-trips random byte strings across every length from 0 to 512 bytes, covers leading-zero-only input, alphabets wider than a byte, and non-power-of-two alphabets, and asserts arbitrary-precision digit strings beyond 64 bits. A degenerate one-character alphabet is now rejected with an `ArgumentError` when the codec is created; previously it produced silent zero output on encode and looped forever on decode.

`bench:all` also gains coverage where the regression was invisible: the address benchmark previously measured only the all-ones System Program address, which is base58's leading-zero fast path and exercises no base conversion at all.

_Owner:_ Ifiok Jr. · _Introduced in:_ [b22257e](https://github.com/openbudgetfun/solana_kit/commit/b22257e1d1cb146eda742cd3da352b6a90a49f1d)

## [0.9.3](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.3) (2026-09-12)

### Changed

- **No package-specific changes were recorded; `solana_kit_codecs_strings` was updated to 0.9.3 as part of group `main`.**

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### 🐛 Fixed

#### Validate option and hexadecimal wire inputs

Reject invalid option presence flags, truncated None padding, and mismatched constant None markers. Reject incomplete hexadecimal byte pairs that previously lost their final character and returned incorrect write offsets.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_codecs_strings` was updated to 0.9.1 as part of group `main`.

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 🐛 Fixed

#### Sync upstream `@solana/kit` v7.1.1

Tracks upstream APIs and behavior through `v7.1.1`:

- `solana_kit`: README now documents `v7.1.1` as the latest supported upstream version.
- `solana_kit_codecs_strings`: base-X decoders now report the end of the buffer as the next offset when no bytes remain to decode, matching upstream `@solana/codecs-strings` (#1926).
- `solana_kit_rpc_transformers`: subscription responses for `blockSubscribe`/`blockNotification` now consult the `blockNotifications` numeric allow-list, matching upstream `@solana/rpc-transformers` (#1925).
- `solana_kit_instruction_plans`: `successfulSingleTransactionPlanResultFromTransaction` is deprecated in favor of `successfulSingleTransactionPlanResult` with an explicit context, matching upstream `@solana/instruction-plans` (#1924).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #220](https://github.com/openbudgetfun/solana_kit/pull/220) · _Related issues:_ [#1924](https://github.com/openbudgetfun/solana_kit/issues/1924), [#1925](https://github.com/openbudgetfun/solana_kit/issues/1925), [#1926](https://github.com/openbudgetfun/solana_kit/issues/1926)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### 💥 Breaking Change

#### Preserve UTF-8 data exactly during decoding

UTF-8 codecs now preserve embedded null characters and reject malformed byte sequences. Lossy compatibility modes and null-character rejection modes have been removed; callers can opt into null removal explicitly with `removeNullCharacters` after decoding.

```dart
final value = getUtf8Codec().decode(bytes);
final withoutPadding = removeNullCharacters(value);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #218](https://github.com/openbudgetfun/solana_kit/pull/218)

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

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add UTF-8 null-char decoding controls

Add strict and explicit UTF-8 null-character decoding…

Add strict and explicit UTF-8 null-character decoding controls to `solana_kit_codecs_strings`, while preserving the default `@solana/kit` compatibility behavior that strips decoded null characters.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ad3e6ad`](https://github.com/openbudgetfun/solana_kit/commit/ad3e6ad2cef3860dd70c2802650b773a25f3b356) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
