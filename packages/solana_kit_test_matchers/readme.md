# solana_kit_test_matchers

Custom test matchers for the Solana Kit Dart SDK -- provides assertion helpers for Solana errors, addresses, byte arrays, and transactions.

This is an internal package (`publish_to: none`) used by other packages in the `solana_kit` monorepo for testing.

## Installation

Since this is an internal package, add it as a dev dependency referencing the local path:

```yaml
dev_dependencies:
  solana_kit_test_matchers:
```

This package is not published to pub.dev.

## Usage

### Solana error matchers

Match errors by code, code with context, or simply by type.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  test('error has the expected code', () {
    final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
    expect(error, isSolanaErrorWithCode(SolanaErrorCode.blockHeightExceeded));
  });

  test('error has the expected code and context', () {
    final error = SolanaError(
      SolanaErrorCode.accountsAccountNotFound,
      {'address': '11111111111111111111111111111111'},
    );

    expect(
      error,
      isSolanaErrorWithCodeAndContext(
        SolanaErrorCode.accountsAccountNotFound,
        {'address': '11111111111111111111111111111111'},
      ),
    );
  });

  test('function throws a SolanaError with a specific code', () {
    expect(
      () => throw SolanaError(SolanaErrorCode.transactionFeePayerMissing),
      throwsSolanaErrorWithCode(SolanaErrorCode.transactionFeePayerMissing),
    );
  });

  test('value is any SolanaError', () {
    final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
    expect(error, isSolanaErrorMatcher);
  });

  test('function throws any SolanaError', () {
    expect(
      () => throw SolanaError(SolanaErrorCode.blockHeightExceeded),
      throwsSolanaError,
    );
  });
}
```

### Address matchers

Validate and compare Solana addresses in tests.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  test('value is a valid Solana address', () {
    final addr = address('11111111111111111111111111111111');
    expect(addr, isValidSolanaAddress);
  });

  test('two addresses are equal', () {
    final addr1 = address('11111111111111111111111111111111');
    final addr2 = address('11111111111111111111111111111111');
    expect(addr1, equalsAddress(addr2));
  });
}
```

### Byte array matchers

Compare byte arrays, check lengths, and verify prefixes.

```dart
import 'dart:typed_data';

import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  test('byte arrays are equal', () {
    final expected = Uint8List.fromList([0x01, 0x02, 0x03]);
    final actual = Uint8List.fromList([0x01, 0x02, 0x03]);
    expect(actual, equalsBytes(expected));
  });

  test('byte array has the expected length', () {
    final bytes = Uint8List(32);
    expect(bytes, hasByteLength(32));
  });

  test('byte array starts with a prefix', () {
    final bytes = Uint8List.fromList([0x01, 0x02, 0x03, 0x04, 0x05]);
    final prefix = Uint8List.fromList([0x01, 0x02]);
    expect(bytes, startsWithBytes(prefix));
  });
}
```

### Transaction matchers

Verify transaction signature state.

```dart
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  // Verify a transaction is fully signed (all signatures populated and non-zero).
  // test('transaction is fully signed', () {
  //   expect(signedTransaction, isFullySignedTransactionMatcher);
  // });

  // Verify a transaction has the expected number of signatures.
  // test('transaction has 2 signatures', () {
  //   expect(transaction, hasSignatureCount(2));
  // });
}
```

## API Reference

### Solana error matchers

| Matcher / Function | Description |
|--------------------|-------------|
| `isSolanaErrorWithCode(int code)` | Matches a `SolanaError` with the given error code. |
| `throwsSolanaErrorWithCode(int code)` | Matches a function that throws a `SolanaError` with the given code. |
| `isSolanaErrorWithCodeAndContext(int code, Map<String, Object?> context)` | Matches a `SolanaError` with the given code whose context contains the expected entries. |
| `isSolanaErrorMatcher` | Matches any `SolanaError` instance. |
| `throwsSolanaError` | Matches a function that throws any `SolanaError`. |

### Address matchers

| Matcher / Function | Description |
|--------------------|-------------|
| `isValidSolanaAddress` | Matches a value that is a valid Solana `Address`. |
| `equalsAddress(Address expected)` | Matches an `Address` that equals the expected address. |

### Byte array matchers

| Matcher / Function | Description |
|--------------------|-------------|
| `equalsBytes(Uint8List expected)` | Matches a `Uint8List` that is byte-for-byte equal to the expected value. |
| `hasByteLength(int length)` | Matches a `Uint8List` with the given length. |
| `startsWithBytes(Uint8List prefix)` | Matches a `Uint8List` that starts with the given prefix bytes. |

### Transaction matchers

| Matcher / Function | Description |
|--------------------|-------------|
| `isFullySignedTransactionMatcher` | Matches a `Transaction` with all signatures populated and non-zero. |
| `hasSignatureCount(int count)` | Matches a `Transaction` with exactly `count` signatures. |
