# solana_kit_offchain_messages

[![pub package](https://img.shields.io/pub/v/solana_kit_offchain_messages.svg)](https://pub.dev/packages/solana_kit_offchain_messages) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_offchain_messages/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_offchain_messages) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_offchain_messages)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_offchain_messages)

Create, compile, sign, and verify Solana offchain messages. Offchain messages let wallets sign structured data that is never submitted to the network, following the [off-chain message signing specification](https://github.com/solana-labs/solana/blob/master/docs/src/proposals/off-chain-message-signing.md).

<!-- {=packageInstallSection:"solana_kit_offchain_messages"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_offchain_messages": ^0.5.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_offchain_messages"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_offchain_messages
- API reference: https://pub.dev/documentation/solana_kit_offchain_messages/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_offchain_messages
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_offchain_messages

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Creating offchain messages

Version 0 messages include an application domain, formatted content, and required signatories.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

void main() {
  const signerA = Address('11111111111111111111111111111111');
  const signerB = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  final message = OffchainMessageV0(
    applicationDomain: offchainMessageApplicationDomain(
      '11111111111111111111111111111111',
    ),
    content: const OffchainMessageContent(
      format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      text: 'Hello from Solana Kit',
    ),
    requiredSignatories: const [
      OffchainMessageSignatory(address: signerA),
      OffchainMessageSignatory(address: signerB),
    ],
  );

  final envelope = compileOffchainMessageEnvelope(message);

  print('Envelope byte length: ${envelope.content.length}');
  print('Required signatures: ${envelope.signatures.length}');
}
```

Version 1 messages have simpler UTF-8 text content with no application domain.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

void main() {
  final message = OffchainMessageV1(
    content: 'I agree to the terms and conditions of Acme Corp.',
    requiredSignatories: const [
      OffchainMessageSignatory(address: Address('11111111111111111111111111111111')),
    ],
  );

  final envelope = compileOffchainMessageEnvelope(message);
  print('Envelope byte length: ${envelope.content.length}');
}
```

### Signing and verifying

`signOffchainMessageEnvelope` fills the envelope's signature map with key pairs, and `verifyOffchainMessageEnvelope` checks that all required signatories have valid signatures. Signing, verification, and envelope codecs validate the complete message, including its content and version-specific signer rules.

`isFullySignedOffchainMessageEnvelope` and `assertIsFullySignedOffchainMessageEnvelope` check that every signer named in the encoded message has a non-null signature, even when a required address is absent from the map. These presence checks do not verify signatures cryptographically. When accepting a wallet response, compare the decoded message with the one you requested (using `assertOffchainMessageV1Equal` for v1), then call `verifyOffchainMessageEnvelope`.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

void main() {
  final keyPair = generateKeyPair();

  final message = OffchainMessageV0(
    applicationDomain: offchainMessageApplicationDomain(
      '11111111111111111111111111111111',
    ),
    content: const OffchainMessageContent(
      format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      text: 'Sign to verify your identity.',
    ),
    requiredSignatories: [
      OffchainMessageSignatory(
        address: getAddressFromPublicKey(keyPair.publicKey),
      ),
    ],
  );
  final envelope = compileOffchainMessageEnvelope(message);

  final signed = signOffchainMessageEnvelope([keyPair], envelope);
  verifyOffchainMessageEnvelope(signed);

  print('Envelope verified');
}
```

### Codecs

Each message version has encoder, decoder, and codec factories, plus a version-dispatching codec and an envelope codec.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

void main() {
  final v0Codec = getOffchainMessageV0Codec();
  final v1Codec = getOffchainMessageV1Codec();
  final codec = getOffchainMessageCodec();
  final envelopeCodec = getOffchainMessageEnvelopeCodec();

  final v0 = OffchainMessageV0(
    applicationDomain: offchainMessageApplicationDomain(
      '11111111111111111111111111111111',
    ),
    content: const OffchainMessageContent(
      format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      text: 'Hello',
    ),
    requiredSignatories: const [
      OffchainMessageSignatory(address: Address('11111111111111111111111111111111')),
    ],
  );

  print(v0Codec.encode(v0).length);
  print(
    v1Codec
        .encode(
          OffchainMessageV1(
            content: 'Hello',
            requiredSignatories: const [
              OffchainMessageSignatory(address: Address('11111111111111111111111111111111')),
            ],
          ),
        )
        .length,
  );
  print(codec.encode(v0).length);
  print(envelopeCodec.encode(compileOffchainMessageEnvelope(v0)).length);
}
```

## Key APIs

- `OffchainMessageV0` / `OffchainMessageV1`: the two message versions.
- `OffchainMessageContent`, `OffchainMessageSignatory`, `offchainMessageApplicationDomain`.
- `compileOffchainMessageEnvelope`, `signOffchainMessageEnvelope`, `verifyOffchainMessageEnvelope`.
- Codec factories: `getOffchainMessageV0Codec`, `getOffchainMessageV1Codec`, `getOffchainMessageCodec`, `getOffchainMessageEnvelopeCodec`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_offchain_messages"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_offchain_messages`.

- Import path: `package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
