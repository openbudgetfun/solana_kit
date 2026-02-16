# solana_kit_offchain_messages

Create, compile, sign, and verify Solana offchain messages.

Offchain messages allow wallets and applications to sign structured messages that are never submitted to the Solana network. This is the Dart implementation of the [Solana offchain message signing specification](https://github.com/solana-labs/solana/blob/master/docs/src/proposals/off-chain-message-signing.md), related to the signing capabilities in [`@solana/keys`](https://github.com/anza-xyz/kit/tree/main/packages/keys) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_offchain_messages:
```

Since this package is part of the `solana_kit` workspace, you can also use the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Creating offchain messages

There are two versions of offchain messages:

**Version 0** messages include an application domain, formatted content, and required signatories.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

// The application domain is a 32-byte identifier (same format as a Solana
// address) that uniquely identifies the requesting application.
final appDomain = offchainMessageApplicationDomain(
  '11111111111111111111111111111111',
);

final messageV0 = OffchainMessageV0(
  applicationDomain: appDomain,
  content: OffchainMessageContent(
    format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
    text: 'Sign this message to verify your identity.',
  ),
  requiredSignatories: [
    OffchainMessageSignatory(
      address: Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu'),
    ),
  ],
);
```

**Version 1** messages have simpler UTF-8 text content with no application domain:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

final messageV1 = OffchainMessageV1(
  content: 'I agree to the terms and conditions of Acme Corp.',
  requiredSignatories: [
    OffchainMessageSignatory(
      address: Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu'),
    ),
  ],
);
```

### Content formats (v0)

Version 0 messages support three content formats, each with different constraints:

| Format                        | Characters           | Max bytes |
| ----------------------------- | -------------------- | --------- |
| `restrictedAscii1232BytesMax` | ASCII 0x20-0x7E only | 1232      |
| `utf81232BytesMax`            | Any UTF-8            | 1232      |
| `utf865535BytesMax`           | Any UTF-8            | 65535     |

The first two formats are signable by hardware wallets, while the third is not.

```dart
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

final content = OffchainMessageContent(
  format: OffchainMessageContentFormat.utf81232BytesMax,
  text: 'Hello, world!',
);

// Validate content against its declared format.
print(isOffchainMessageContentUtf8Of1232BytesMax(content)); // true

// Throws SolanaError if validation fails.
assertIsOffchainMessageContentUtf8Of1232BytesMax(content);
```

### Application domains

An application domain is a 32-byte value encoded as a base58 string (the same format as a Solana address). It uniquely identifies the application requesting the signature.

```dart
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

// Validate and create an application domain.
final domain = offchainMessageApplicationDomain(
  '11111111111111111111111111111111',
);

// Check validity.
print(isOffchainMessageApplicationDomain(
  '11111111111111111111111111111111',
)); // true

// Throws SolanaError if invalid.
assertIsOffchainMessageApplicationDomain(
  '11111111111111111111111111111111',
);
```

### Compiling offchain message envelopes

An `OffchainMessageEnvelope` bundles the encoded message bytes with a signatures map. Compiling a message creates an envelope with `null` signatures for each required signatory:

```dart
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

// Compile a v0 message.
final envelopeV0 = compileOffchainMessageEnvelope(messageV0);
print(envelopeV0.content.length); // Size of the encoded message bytes.
print(envelopeV0.signatures);     // {Address('mpngs...'): null}

// Compile a v1 message.
final envelopeV1 = compileOffchainMessageEnvelope(messageV1);

// You can also compile specific versions directly.
final envelopeV0Direct = compileOffchainMessageV0Envelope(messageV0);
final envelopeV1Direct = compileOffchainMessageV1Envelope(messageV1);
```

### Signing offchain message envelopes

Sign envelopes with Ed25519 key pairs:

```dart
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

Future<void> main() async {
  final keyPair = await generateKeyPair();

  // Sign and assert all signatures are present.
  final signedEnvelope = signOffchainMessageEnvelope(
    [keyPair],
    envelopeV1,
  );

  // Or partially sign when you don't have all signers yet.
  final partialEnvelope = partiallySignOffchainMessageEnvelope(
    [keyPair],
    envelopeV1,
  );

  // Check if fully signed.
  print(isFullySignedOffchainMessageEnvelope(signedEnvelope)); // true
}
```

### Verifying offchain message envelopes

After collecting all signatures, verify that every required signatory provided a valid Ed25519 signature:

```dart
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

void main() {
  // Throws SolanaError if any signature is missing or invalid.
  verifyOffchainMessageEnvelope(signedEnvelope);
}
```

### Message codecs

The package provides encoders, decoders, and codecs for serializing offchain messages:

```dart
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

// V0 message codec.
final v0Encoder = getOffchainMessageV0Encoder();
final v0Decoder = getOffchainMessageV0Decoder();
final v0Codec = getOffchainMessageV0Codec();

// V1 message codec.
final v1Encoder = getOffchainMessageV1Encoder();
final v1Decoder = getOffchainMessageV1Decoder();
final v1Codec = getOffchainMessageV1Codec();

// Generic message codec (dispatches on version).
final encoder = getOffchainMessageEncoder();
final decoder = getOffchainMessageDecoder();
final codec = getOffchainMessageCodec();

// Envelope codec (message + signatures).
final envelopeEncoder = getOffchainMessageEnvelopeEncoder();
final envelopeDecoder = getOffchainMessageEnvelopeDecoder();
final envelopeCodec = getOffchainMessageEnvelopeCodec();
```

## API Reference

### Sealed classes

- **`OffchainMessage`** -- Sealed base class for offchain messages.
  - **`OffchainMessageV0`** -- Version 0 message with `applicationDomain`, `content` (an `OffchainMessageContent`), and `requiredSignatories`.
  - **`OffchainMessageV1`** -- Version 1 message with `content` (a `String`) and `requiredSignatories`.

### Classes

- **`OffchainMessageEnvelope`** -- Compiled envelope with `content` bytes and `signatures` map.
- **`OffchainMessageSignatory`** -- A required signatory with an `address`.
- **`OffchainMessageContent`** -- V0 content with `format` and `text`.

### Enums

- **`OffchainMessageContentFormat`** -- `restrictedAscii1232BytesMax`, `utf81232BytesMax`, `utf865535BytesMax`.

### Type aliases

- **`OffchainMessageApplicationDomain`** -- Alias for `Address` (32-byte base58 domain).
- **`OffchainMessageVersion`** -- Alias for `int` (0 or 1).

### Functions

| Function                                                       | Description                                                         |
| -------------------------------------------------------------- | ------------------------------------------------------------------- |
| `compileOffchainMessageEnvelope`                               | Compiles an offchain message into an envelope with null signatures. |
| `compileOffchainMessageV0Envelope`                             | Compiles a v0 message into an envelope.                             |
| `compileOffchainMessageV1Envelope`                             | Compiles a v1 message into an envelope.                             |
| `signOffchainMessageEnvelope`                                  | Signs an envelope and asserts all signatures are present.           |
| `partiallySignOffchainMessageEnvelope`                         | Signs an envelope with a subset of required signers.                |
| `isFullySignedOffchainMessageEnvelope`                         | Returns `true` if all signatures are present.                       |
| `assertIsFullySignedOffchainMessageEnvelope`                   | Throws if any signature is missing.                                 |
| `verifyOffchainMessageEnvelope`                                | Verifies all signatures are valid Ed25519 signatures.               |
| `offchainMessageApplicationDomain`                             | Validates and returns an application domain.                        |
| `isOffchainMessageApplicationDomain`                           | Returns `true` if the string is a valid application domain.         |
| `assertIsOffchainMessageApplicationDomain`                     | Throws if the string is not a valid application domain.             |
| `isOffchainMessageContentRestrictedAsciiOf1232BytesMax`        | Validates restricted ASCII content.                                 |
| `isOffchainMessageContentUtf8Of1232BytesMax`                   | Validates UTF-8 content up to 1232 bytes.                           |
| `isOffchainMessageContentUtf8Of65535BytesMax`                  | Validates UTF-8 content up to 65535 bytes.                          |
| `getOffchainMessageV0Encoder` / `Decoder` / `Codec`            | V0 message serialization.                                           |
| `getOffchainMessageV1Encoder` / `Decoder` / `Codec`            | V1 message serialization.                                           |
| `getOffchainMessageEncoder` / `Decoder` / `Codec`              | Generic message serialization.                                      |
| `getOffchainMessageEnvelopeEncoder` / `Decoder` / `Codec`      | Envelope serialization.                                             |
| `getOffchainMessageSigningDomainEncoder` / `Decoder` / `Codec` | The 16-byte `\xffsolana offchain` signing domain prefix.            |

### Constants

- **`maxBodyBytes`** -- Maximum body bytes for any v0 message: `65535`.
- **`maxBodyBytesHardwareWalletSignable`** -- Maximum body bytes for hardware-wallet-signable messages: `1232`.
- **`offchainMessageSigningDomainBytes`** -- The 16-byte signing domain prefix (`\xffsolana offchain`).
