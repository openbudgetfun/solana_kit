# solana_kit_address

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_address)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_address)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_address)

Core Address extension type, codecs, comparator, and PublicKey utilities for the
[Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides the `Address` extension type for validated base58-encoded Solana
addresses, codecs for serializing and deserializing addresses,
a comparator for sorting addresses by base58 collation rules,
and helpers for converting between public key bytes and addresses.

## Installation

<!-- {=packageInstallSection:"solana_kit_address"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_address": ^0.5.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

```dart
import 'package:solana_kit_address/solana_kit_address.dart';

// Create a validated address
final addr = address('11111111111111111111111111111111');

// Check if a string is a valid address
if (isAddress(someString)) {
  // it's valid
}

// Encode/decode addresses
final codec = getAddressCodec();
final bytes = codec.encode(addr);
final decoded = codec.decode(bytes);

// Compare addresses using base58 collation order
final comparator = getAddressComparator();
addresses.sort(comparator);

// Convert between public key bytes and addresses
final publicKeyBytes = getPublicKeyFromAddress(addr);
final addrFromKey = getAddressFromPublicKey(publicKeyBytes);
```

## Key APIs

| API                         | Description                                             |
| --------------------------- | ------------------------------------------------------- |
| `Address`                   | Extension type wrapping a validated base58 string       |
| `address()`                 | Factory that validates and creates an `Address`         |
| `assertIsAddress()`         | Throws if the string is not a valid address             |
| `isAddress()`               | Returns `true`/`false` without throwing                 |
| `getAddressCodec()`         | Returns a fixed-size codec for encoding/decoding        |
| `getAddressEncoder()`       | Returns an encoder that produces exactly 32 bytes       |
| `getAddressDecoder()`       | Returns a decoder that reads 32 bytes into an `Address` |
| `getAddressComparator()`    | Returns a base58 collation-order `Comparator<Address>`  |
| `getAddressFromPublicKey()` | Converts 32-byte Ed25519 public key to `Address`        |
| `getPublicKeyFromAddress()` | Converts an `Address` to 32-byte Ed25519 public key     |
