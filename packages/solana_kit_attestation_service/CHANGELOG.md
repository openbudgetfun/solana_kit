# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_attestation_service [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_attestation_service/v0.1.0) (2026-09-12)

### Breaking changes

#### Add the Solana Attestation Service program client

Introduces `solana_kit_attestation_service`, a generated program client for the Solana Attestation Service, the on-chain protocol for verifiable credentials where issuers register credentials, declare schemas, and issue attestations that verifiers can fetch and decode.

The package ships generated instruction builders and parsers for all 12 instructions, codecs for the `Credential`, `Schema`, and `Attestation` accounts with their 1-byte discriminators, the seven program PDAs (credential, schema, attestation, schema mint, attestation mint, event authority, and SAS authority), the `AttestationServiceError` codes with an `isAttestationServiceError` matcher, and a schema-driven codec that serializes and deserializes an attestation's raw `data` blob against its schema layout, including Rust `char` code points and lossless hex fallbacks for non-UTF-8 string bytes.

```dart
final (credential, _) = await findCredentialPda(
  seeds: const CredentialSeeds(authority: authority, name: 'my-credential'),
);
final data = serializeAttestationData(schema, {'name': 'Alice', 'age': 42});
```

`solana_kit_address_constants` gains the canonical `solanaAttestationServiceProgramAddress` constant.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #251](https://github.com/openbudgetfun/solana_kit/pull/251)

## solana_kit_attestation_service [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_attestation_service/v0.2.0) (2026-09-21)

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

### Fixes

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

#### Restore complete version inventories in package READMEs

The `versions.json` data source that renders every package README's installation section had drifted: packages first released after the legacy knope era were never added, so their READMEs told consumers to depend on a bare `^` with no version. The retired `solana_kit_functional` entry and a stale `solana_kit_mobile_wallet_adapter_example` version were also lingering.

The inventory now matches every package's `pubspec.yaml`, the `solana_kit_functional` key is gone, and the affected installation sections render the real published version again:

```yaml
dependencies:
  "solana_kit_jupiter": ^0.9.3
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [4c8855b](https://github.com/openbudgetfun/solana_kit/commit/4c8855bd608bb9f05324b001b552c9329679e441)
