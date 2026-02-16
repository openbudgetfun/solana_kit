# solana_kit_addresses

Base58-encoded Solana address utilities for the Solana Kit Dart SDK -- a Dart port of [`@solana/addresses`](https://github.com/anza-xyz/kit/tree/main/packages/addresses).

## Installation

Add `solana_kit_addresses` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_addresses:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Creating and validating addresses

The `Address` type is a zero-overhead extension type wrapping a `String`. Use the `address()` factory function to create a validated address from an untrusted string, or the `Address()` constructor directly when you know the string is valid.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  // Create a validated address from an untrusted string.
  // Throws SolanaError if the string is not a valid base58-encoded 32-byte address.
  final myAddress = address('11111111111111111111111111111112');

  // For known-good strings you can use the constructor directly (no validation).
  const systemProgram = Address('11111111111111111111111111111111');

  // Check whether a string is a valid Solana address without throwing.
  final valid = isAddress('11111111111111111111111111111112'); // true
  final invalid = isAddress('not-a-valid-address'); // false

  // Assert validity -- throws SolanaError on failure.
  assertIsAddress('11111111111111111111111111111112');
}
```

### Converting between addresses and public keys

Convert between a raw 32-byte Ed25519 public key (`Uint8List`) and a base58-encoded `Address`.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  // Suppose you have a 32-byte public key from an Ed25519 key pair.
  final publicKeyBytes = Uint8List(32); // replace with real bytes

  // Convert raw public key bytes to an Address.
  final addr = getAddressFromPublicKey(publicKeyBytes);
  print(addr.value); // base58-encoded string

  // Convert an Address back to raw 32-byte public key bytes.
  final bytesAgain = getPublicKeyFromAddress(addr);
  print(bytesAgain.length); // 32
}
```

### Encoding and decoding addresses

The address codec encodes and decodes `Address` values as fixed-size 32-byte binary representations. This is useful for serializing addresses in on-chain data structures.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  final addr = address('11111111111111111111111111111112');

  // Get a fixed-size encoder (Address -> 32 bytes).
  final encoder = getAddressEncoder();
  final bytes = encoder.encode(addr);
  print(bytes.length); // 32

  // Get a fixed-size decoder (32 bytes -> Address).
  final decoder = getAddressDecoder();
  final decoded = decoder.decode(bytes);
  print(decoded.value); // '11111111111111111111111111111112'

  // Or use the combined codec.
  final codec = getAddressCodec();
  final roundTripped = codec.decode(codec.encode(addr));
  print(roundTripped.value == addr.value); // true
}
```

### Comparing addresses

The `getAddressComparator()` function returns a comparator that sorts addresses using base58 collation rules, matching the ordering used by the Solana runtime.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  final addresses = [
    address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
    address('11111111111111111111111111111111'),
    address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL'),
  ];

  final comparator = getAddressComparator();
  addresses.sort(comparator);

  // Addresses are now in base58 collation order.
  for (final addr in addresses) {
    print(addr.value);
  }
}
```

### Checking if an address is on/off the Ed25519 curve

Solana program-derived addresses (PDAs) must NOT fall on the Ed25519 curve. Use these utilities to verify curve membership.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  // Check raw compressed point bytes (32 bytes).
  final pointBytes = Uint8List(32); // replace with real bytes
  final onCurve = compressedPointBytesAreOnCurve(pointBytes);
  print('On curve: $onCurve');

  // Check an address directly.
  final addr = address('11111111111111111111111111111112');
  print('Is on curve: ${isOnCurveAddress(addr)}');
  print('Is off curve: ${isOffCurveAddress(addr)}');

  // Assert curve membership -- throws SolanaError on failure.
  assertIsOnCurveAddress(addr);

  // Assert off-curve (useful for validating PDAs).
  // assertIsOffCurveAddress(somePda);
}
```

### Deriving program-derived addresses (PDAs)

Program-derived addresses are deterministic addresses derived from a program address and a set of seeds. The runtime guarantees that no private key exists for a PDA.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

Future<void> main() async {
  const programAddress = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  // Derive a PDA with string and byte seeds.
  // Seeds can be String values (UTF-8 encoded) or Uint8List byte arrays.
  // Maximum 16 seeds, each at most 32 bytes.
  final (pda, bump) = await getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: ['metadata', Uint8List.fromList([1, 2, 3])],
  );

  print('PDA: ${pda.value}');
  print('Bump seed: $bump'); // 0-255

  // The PDA is guaranteed to be off the Ed25519 curve.
  print('Off curve: ${isOffCurveAddress(pda)}'); // true
}
```

### Creating addresses with a seed (SHA-256 based)

This is the older `createAccountWithSeed` style derivation, which differs from PDA derivation. It concatenates the base address, seed, and program address and takes their SHA-256 hash.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

Future<void> main() async {
  const baseAddress = Address('11111111111111111111111111111111');
  const programAddress = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  // Create an address derived from a base address, seed, and program address.
  // The seed can be a String (UTF-8 encoded) or Uint8List, at most 32 bytes.
  final derived = await createAddressWithSeed(
    baseAddress: baseAddress,
    programAddress: programAddress,
    seed: 'my-seed',
  );

  print('Derived address: ${derived.value}');
}
```

## API Reference

### Types

| Export                  | Description                                                                                                   |
| ----------------------- | ------------------------------------------------------------------------------------------------------------- |
| `Address`               | Extension type wrapping `String` -- a validated base58-encoded 32-byte Solana address. Zero runtime overhead. |
| `ProgramDerivedAddress` | Type alias for `(Address pda, int bump)` -- a derived address paired with its bump seed.                      |

### Address creation and validation

| Function                  | Description                                                                              |
| ------------------------- | ---------------------------------------------------------------------------------------- |
| `address(String)`         | Creates a validated `Address` from an untrusted string. Throws on invalid input.         |
| `assertIsAddress(String)` | Asserts that a string is a valid base58 Solana address. Throws `SolanaError` on failure. |
| `isAddress(String)`       | Returns `true` if the string is a valid base58 Solana address.                           |

### Public key conversion

| Function                             | Description                                              |
| ------------------------------------ | -------------------------------------------------------- |
| `getAddressFromPublicKey(Uint8List)` | Converts a 32-byte Ed25519 public key to an `Address`.   |
| `getPublicKeyFromAddress(Address)`   | Converts an `Address` to its 32-byte Ed25519 public key. |

### Codecs

| Function              | Description                                                                          |
| --------------------- | ------------------------------------------------------------------------------------ |
| `getAddressEncoder()` | Returns a `FixedSizeEncoder<Address>` that encodes an address into exactly 32 bytes. |
| `getAddressDecoder()` | Returns a `FixedSizeDecoder<Address>` that decodes exactly 32 bytes into an address. |
| `getAddressCodec()`   | Returns a `FixedSizeCodec<Address, Address>` combining encoder and decoder.          |

### Comparator

| Function                 | Description                                                   |
| ------------------------ | ------------------------------------------------------------- |
| `getAddressComparator()` | Returns a `Comparator<Address>` using base58 collation rules. |

### Curve checks

| Function                                    | Description                                                             |
| ------------------------------------------- | ----------------------------------------------------------------------- |
| `compressedPointBytesAreOnCurve(Uint8List)` | Returns `true` if the 32-byte compressed point is on the Ed25519 curve. |
| `isOnCurveAddress(Address)`                 | Returns `true` if the address decodes to a point on the Ed25519 curve.  |
| `isOffCurveAddress(Address)`                | Returns `true` if the address is NOT on the Ed25519 curve.              |
| `assertIsOnCurveAddress(Address)`           | Asserts the address is on curve. Throws `SolanaError` on failure.       |
| `assertIsOffCurveAddress(Address)`          | Asserts the address is off curve. Throws `SolanaError` on failure.      |

### Program-derived addresses

| Function                                                                                                       | Description                                                                                                |
| -------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `getProgramDerivedAddress({required Address programAddress, required List<Object> seeds})`                     | Derives a PDA by searching for a valid bump seed (255 down to 0). Returns `Future<ProgramDerivedAddress>`. |
| `createAddressWithSeed({required Address baseAddress, required Address programAddress, required Object seed})` | Creates a SHA-256-based derived address. Returns `Future<Address>`.                                        |
