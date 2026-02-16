# solana_kit_keys

Ed25519 key pair generation, signing, and signature verification for the Solana Kit Dart SDK -- a Dart port of [`@solana/keys`](https://github.com/anza-xyz/kit/tree/main/packages/keys).

## Installation

Add `solana_kit_keys` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_keys:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Generating a key pair

Generate a random Ed25519 key pair containing a 32-byte private key (seed) and its corresponding 32-byte public key.

```dart
import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final keyPair = generateKeyPair();

  print('Private key length: ${keyPair.privateKey.length}'); // 32
  print('Public key length: ${keyPair.publicKey.length}'); // 32
}
```

### Creating a key pair from bytes

Restore a key pair from a 64-byte array where the first 32 bytes are the private key and the last 32 bytes are the public key. The function verifies that the public key matches the private key.

```dart
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  // A 64-byte array: [32 bytes private key | 32 bytes public key]
  final bytes = Uint8List(64); // replace with real key bytes

  // Throws SolanaError if:
  // - bytes is not exactly 64 bytes
  // - public key does not match the private key
  final keyPair = createKeyPairFromBytes(bytes);
  print(keyPair.privateKey.length); // 32
  print(keyPair.publicKey.length); // 32
}
```

### Creating a key pair from a private key

If you only have the 32-byte private key (seed), derive the corresponding public key automatically.

```dart
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  // A 32-byte private key (seed).
  final privateKeyBytes = Uint8List(32); // replace with real bytes

  // Derives the public key from the private key.
  // Throws SolanaError if privateKeyBytes is not exactly 32 bytes.
  final keyPair = createKeyPairFromPrivateKeyBytes(privateKeyBytes);
  print(keyPair.publicKey.length); // 32
}
```

### Deriving a public key from a private key

If you need just the public key bytes without constructing a full `KeyPair`:

```dart
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final privateKeyBytes = Uint8List(32); // replace with real bytes

  // Returns the 32-byte Ed25519 public key corresponding to the private key.
  final publicKeyBytes = getPublicKeyFromPrivateKey(privateKeyBytes);
  print(publicKeyBytes.length); // 32
}
```

### Signing data

Sign arbitrary byte data with a 32-byte private key. Returns a 64-byte Ed25519 signature.

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final keyPair = generateKeyPair();
  final message = Uint8List.fromList(utf8.encode('Hello, Solana!'));

  // Sign the message with the private key.
  final sig = signBytes(keyPair.privateKey, message);
  print('Signature length: ${sig.value.length}'); // 64
}
```

### Verifying signatures

Verify that a signature was produced by the holder of a given public key.

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final keyPair = generateKeyPair();
  final message = Uint8List.fromList(utf8.encode('Hello, Solana!'));

  // Sign the message.
  final sig = signBytes(keyPair.privateKey, message);

  // Verify the signature with the public key.
  final isValid = verifySignature(keyPair.publicKey, sig, message);
  print('Signature valid: $isValid'); // true

  // Verification fails with a wrong public key.
  final otherKeyPair = generateKeyPair();
  final isInvalid = verifySignature(otherKeyPair.publicKey, sig, message);
  print('Signature valid with wrong key: $isInvalid'); // false
}
```

### Working with base58-encoded signatures

The `Signature` extension type wraps a base58-encoded string representation of a 64-byte Ed25519 signature. Use the `signature()` factory to create a validated instance.

```dart
import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  const rawSigString =
      '5cFvJAqcyB5VGjkzvcTxUKwcirYvJrBWLQEjRCBXhDrGi'
      'JLbDDQfpnEhcACxNLEBjcDjSbGNpGSmSCXtHRpzKNG';

  // Validate and wrap a base58-encoded signature string.
  final sig = signature(rawSigString);
  print(sig.value); // the base58-encoded string

  // Check without throwing.
  final valid = isSignature(rawSigString); // true
  final invalid = isSignature('too-short'); // false
}
```

### Working with raw signature bytes

The `SignatureBytes` extension type wraps a `Uint8List` that is exactly 64 bytes. Use the `signatureBytes()` factory for validation.

```dart
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final rawBytes = Uint8List(64); // replace with real signature bytes

  // Validate and wrap raw signature bytes.
  final sig = signatureBytes(rawBytes);
  print(sig.value.length); // 64

  // Check without throwing.
  final valid = isSignatureBytes(rawBytes); // true
  final invalid = isSignatureBytes(Uint8List(32)); // false
}
```

### Validating private keys

```dart
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final validKey = Uint8List(32);
  final invalidKey = Uint8List(16);

  // Assert that bytes represent a valid 32-byte Ed25519 private key.
  assertIsPrivateKey(validKey); // OK

  // Throws SolanaError with keysInvalidPrivateKeyByteLength.
  // assertIsPrivateKey(invalidKey);
}
```

### Connecting addresses and key pairs

Use `solana_kit_addresses` together with `solana_kit_keys` to convert between key pairs and Solana addresses.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final keyPair = generateKeyPair();

  // Convert the public key to a Solana address.
  final addr = getAddressFromPublicKey(keyPair.publicKey);
  print('Address: ${addr.value}');

  // Convert the address back to public key bytes.
  final publicKeyBytes = getPublicKeyFromAddress(addr);
  print('Public key length: ${publicKeyBytes.length}'); // 32
}
```

## API Reference

### Types

| Export           | Description                                                                                                       |
| ---------------- | ----------------------------------------------------------------------------------------------------------------- |
| `KeyPair`        | Class holding a 32-byte `privateKey` and a 32-byte `publicKey` (`Uint8List` fields).                              |
| `Signature`      | Extension type wrapping `String` -- a validated base58-encoded 64-byte Ed25519 signature. Zero runtime overhead.  |
| `SignatureBytes` | Extension type wrapping `Uint8List` -- a validated 64-byte Ed25519 signature in raw bytes. Zero runtime overhead. |

### Key pair generation

| Function                                      | Description                                                                                |
| --------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `generateKeyPair()`                           | Generates a new random Ed25519 `KeyPair`.                                                  |
| `createKeyPairFromBytes(Uint8List)`           | Creates a `KeyPair` from a 64-byte array (32 private + 32 public). Validates the key pair. |
| `createKeyPairFromPrivateKeyBytes(Uint8List)` | Creates a `KeyPair` from a 32-byte private key, deriving the public key.                   |

### Public key derivation

| Function                                | Description                                                        |
| --------------------------------------- | ------------------------------------------------------------------ |
| `getPublicKeyFromPrivateKey(Uint8List)` | Derives the 32-byte Ed25519 public key from a 32-byte private key. |

### Signing and verification

| Function                                                                   | Description                                                                 |
| -------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `signBytes(Uint8List privateKey, Uint8List data)`                          | Signs data with a 32-byte private key. Returns `SignatureBytes` (64 bytes). |
| `verifySignature(Uint8List publicKey, SignatureBytes sig, Uint8List data)` | Returns `true` if the signature is valid for the given public key and data. |

### Signature creation and validation

| Function                            | Description                                                                            |
| ----------------------------------- | -------------------------------------------------------------------------------------- |
| `signature(String)`                 | Creates a validated `Signature` from a base58-encoded string. Throws on invalid input. |
| `signatureBytes(Uint8List)`         | Creates validated `SignatureBytes` from a 64-byte array. Throws on invalid input.      |
| `isSignature(String)`               | Returns `true` if the string is a valid base58-encoded 64-byte signature.              |
| `isSignatureBytes(Uint8List)`       | Returns `true` if the byte array is exactly 64 bytes.                                  |
| `assertIsSignature(String)`         | Asserts the string is a valid base58 signature. Throws `SolanaError` on failure.       |
| `assertIsSignatureBytes(Uint8List)` | Asserts the byte array is exactly 64 bytes. Throws `SolanaError` on failure.           |

### Private key validation

| Function                        | Description                                                                  |
| ------------------------------- | ---------------------------------------------------------------------------- |
| `assertIsPrivateKey(Uint8List)` | Asserts the byte array is exactly 32 bytes. Throws `SolanaError` on failure. |
