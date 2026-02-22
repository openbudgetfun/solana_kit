# solana_kit_errors

[![pub package](https://img.shields.io/pub/v/solana_kit_errors.svg)](https://pub.dev/packages/solana_kit_errors)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_errors/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Error codes, structured error class, and error conversion utilities for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/errors`](https://github.com/anza-xyz/kit/tree/main/packages/errors) from the Solana TypeScript SDK.

## Installation

Install with:

```bash
dart pub add solana_kit_errors
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_errors
- API reference: https://pub.dev/documentation/solana_kit_errors/latest/

## Usage

### Creating errors

Every error in the Solana Kit SDK is a `SolanaError` carrying a numeric code from `SolanaErrorCode` and an optional context map. The context map provides structured data that is interpolated into the human-readable error message.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

// Simple error with no context.
final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
print(error);
// SolanaError#1: The network has progressed past the last block for which
// this transaction could have been committed.

// Error with context variables interpolated into the message.
final notFoundError = SolanaError(
  SolanaErrorCode.accountsAccountNotFound,
  {'address': '11111111111111111111111111111111'},
);
print(notFoundError);
// SolanaError#3230000: Account not found at address: 11111111111111111111111111111111
```

`SolanaError` implements `Exception`, so it can be thrown and caught like any Dart exception:

```dart
try {
  throw SolanaError(SolanaErrorCode.transactionFeePayerMissing);
} on SolanaError catch (e) {
  print('Code: ${e.code}');
  print('Context: ${e.context}');
  print('Message: $e');
}
```

The context map is made unmodifiable at construction time, so it cannot be accidentally mutated after creation.

### Checking errors with `isSolanaError`

The `isSolanaError` function acts as a type guard. It checks whether a value is a `SolanaError` and optionally whether it matches a specific error code.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void handleError(Object? error) {
  // Check if it is any SolanaError.
  if (isSolanaError(error)) {
    print('Got a Solana error with code: ${(error as SolanaError).code}');
  }

  // Check for a specific error code.
  if (isSolanaError(error, SolanaErrorCode.transactionFeePayerMissing)) {
    print('Transaction is missing a fee payer!');
  }

  // Returns false for non-SolanaError values.
  print(isSolanaError('not an error'));  // false
  print(isSolanaError(null));            // false
}
```

### Error codes (`SolanaErrorCode`)

`SolanaErrorCode` is an abstract final class containing 100+ `static const int` codes organized by category. The numeric values are kept in sync with the upstream TypeScript package for cross-implementation interoperability.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

// General errors (1 - 10)
SolanaErrorCode.blockHeightExceeded;          // 1
SolanaErrorCode.invalidNonce;                  // 2
SolanaErrorCode.lamportsOutOfRange;            // 6

// JSON-RPC errors (-32768 to -32000)
SolanaErrorCode.jsonRpcParseError;             // -32700
SolanaErrorCode.jsonRpcInternalError;          // -32603
SolanaErrorCode.jsonRpcServerErrorNodeUnhealthy; // -32005

// Address errors (2800000 - 2800999)
SolanaErrorCode.addressesInvalidByteLength;    // 2800000
SolanaErrorCode.addressesInvalidBase58EncodedAddress; // 2800002

// Account errors (3230000 - 3230999)
SolanaErrorCode.accountsAccountNotFound;       // 3230000
SolanaErrorCode.accountsFailedToDecodeAccount; // 3230002

// Key errors (3704000 - 3704999)
SolanaErrorCode.keysInvalidKeyPairByteLength;  // 3704000
SolanaErrorCode.keysInvalidSignatureByteLength; // 3704002

// Instruction errors (4128000 - 4128999)
SolanaErrorCode.instructionExpectedToHaveAccounts; // 4128000

// Instruction runtime errors (4615000 - 4615999)
SolanaErrorCode.instructionErrorInsufficientFunds; // 4615006
SolanaErrorCode.instructionErrorCustom;        // 4615026

// Signer errors (5508000 - 5508999)
SolanaErrorCode.signerExpectedKeyPairSigner;   // 5508001

// Transaction errors (5663000 - 5663999)
SolanaErrorCode.transactionFeePayerMissing;    // 5663011
SolanaErrorCode.transactionSignaturesMissing;  // 5663009

// Transaction runtime errors (7050000 - 7050999)
SolanaErrorCode.transactionErrorBlockhashNotFound; // 7050008

// Codec errors (8078000 - 8078999)
SolanaErrorCode.codecsCannotDecodeEmptyByteArray; // 8078000
SolanaErrorCode.codecsNumberOutOfRange;        // 8078011

// RPC errors (8100000 - 8100999)
SolanaErrorCode.rpcIntegerOverflow;            // 8100000
SolanaErrorCode.rpcTransportHttpError;         // 8100002
```

### Error message interpolation

Error messages are templates with `$variable` placeholders that are filled from the context map. The `getErrorMessage` function performs this interpolation.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

// Get an interpolated message directly.
final message = getErrorMessage(
  SolanaErrorCode.addressesInvalidByteLength,
  {'actualLength': 28},
);
print(message);
// Expected base58 encoded address to decode to a byte array of length 32.
// Actual length: 28.

// Missing context values leave the placeholder as-is.
final partial = getErrorMessage(SolanaErrorCode.addressesInvalidByteLength);
print(partial);
// Expected base58 encoded address to decode to a byte array of length 32.
// Actual length: $actualLength.

// Unknown error codes produce a fallback message.
final unknown = getErrorMessage(999999);
print(unknown);
// Solana error #999999
```

### Converting JSON-RPC errors

When you receive an error response from a Solana JSON-RPC endpoint, use `getSolanaErrorFromJsonRpcError` to convert it into a `SolanaError`.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

// Typical JSON-RPC error response from a Solana node.
final rpcError = {
  'code': -32005,
  'message': 'Node is unhealthy',
  'data': <String, Object?>{},
};

final solanaError = getSolanaErrorFromJsonRpcError(rpcError);
print(solanaError.code == SolanaErrorCode.jsonRpcServerErrorNodeUnhealthy);
// true

// Preflight failure errors automatically extract the nested transaction error.
final preflightError = {
  'code': -32002,
  'message': 'Transaction simulation failed',
  'data': {
    'err': 'BlockhashNotFound',
    'logs': <String>[],
  },
};

final preflightSolanaError = getSolanaErrorFromJsonRpcError(preflightError);
print(preflightSolanaError.code ==
    SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure);
// true

// The nested cause is available in the context.
final cause = preflightSolanaError.context['cause'] as SolanaError;
print(cause.code == SolanaErrorCode.transactionErrorBlockhashNotFound);
// true

// Malformed responses (missing required fields) produce a malformedJsonRpcError.
final malformed = getSolanaErrorFromJsonRpcError({'unexpected': 'data'});
print(malformed.code == SolanaErrorCode.malformedJsonRpcError);
// true
```

### Converting transaction errors

Transaction errors from RPC responses use a Rust enum-like format. The `getSolanaErrorFromTransactionError` function handles both string and map forms.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

// Simple string error.
final error = getSolanaErrorFromTransactionError('BlockhashNotFound');
print(error.code == SolanaErrorCode.transactionErrorBlockhashNotFound);
// true

// Error with nested context.
final rentError = getSolanaErrorFromTransactionError({
  'InsufficientFundsForRent': {'account_index': 2},
});
print(rentError.code == SolanaErrorCode.transactionErrorInsufficientFundsForRent);
// true
print(rentError.context['accountIndex']); // 2
```

### Converting instruction errors

Instruction errors come nested within transaction errors, typically as `{'InstructionError': [index, error]}`. Use `getSolanaErrorFromInstructionError` to convert them directly.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

// Simple instruction error.
final error = getSolanaErrorFromInstructionError(0, 'InsufficientFunds');
print(error.code == SolanaErrorCode.instructionErrorInsufficientFunds);
// true
print(error.context['index']); // 0

// Custom program error with an error code.
final customError = getSolanaErrorFromInstructionError(1, {'Custom': 42});
print(customError.code == SolanaErrorCode.instructionErrorCustom);
// true
print(customError.context['code']);  // 42
print(customError.context['index']); // 1

// Transaction errors containing InstructionError are automatically delegated.
final txError = getSolanaErrorFromTransactionError({
  'InstructionError': [0, 'InvalidAccountData'],
});
print(txError.code == SolanaErrorCode.instructionErrorInvalidAccountData);
// true
```

### Unwrapping simulation errors

When a transaction simulation fails, the actual error is wrapped in a simulation error. Use `unwrapSimulationError` to get at the underlying cause.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

final simulationError = SolanaError(
  SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
  {
    'cause': SolanaError(SolanaErrorCode.transactionErrorBlockhashNotFound),
    'logs': <String>[],
  },
);

final underlying = unwrapSimulationError(simulationError);
print(underlying is SolanaError); // true
print((underlying! as SolanaError).code ==
    SolanaErrorCode.transactionErrorBlockhashNotFound); // true

// Non-simulation errors are returned as-is.
final regularError = SolanaError(SolanaErrorCode.blockHeightExceeded);
print(identical(unwrapSimulationError(regularError), regularError)); // true
```

### Context encoding and decoding

The `encodeContextObject` and `decodeEncodedContext` functions serialize error context maps to and from compact base64 strings, useful for transmitting error details.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

final context = {'address': '11111111111111111111111111111111', 'index': 0};

// Encode to a compact base64 string.
final encoded = encodeContextObject(context);
print(encoded); // base64 string

// Decode back to the original map.
final decoded = decodeEncodedContext(encoded);
print(decoded['address']); // 11111111111111111111111111111111
```

## API Reference

### Classes

- **`SolanaError`** -- Core error class implementing `Exception`. Carries an `int code` and an unmodifiable `Map<String, Object?> context`.
- **`SolanaErrorCode`** -- Abstract final class with 100+ `static const int` error codes grouped by category (general, JSON-RPC, addresses, accounts, keys, instructions, instruction errors, signers, transactions, transaction errors, codecs, RPC, RPC subscriptions, program clients, invariant violations).
- **`RpcEnumErrorConfig`** -- Configuration class for mapping Solana RPC enum-style errors to `SolanaError` instances.

### Functions

- **`isSolanaError(Object? e, [int? code])`** -- Type guard that checks whether a value is a `SolanaError`, optionally matching a specific code.
- **`getErrorMessage(int code, [Map<String, Object?> context])`** -- Returns the interpolated error message for a given error code and context.
- **`getSolanaErrorFromJsonRpcError(Object?)`** -- Converts a JSON-RPC error response map into a `SolanaError`.
- **`getSolanaErrorFromTransactionError(Object)`** -- Converts a Solana RPC transaction error into a `SolanaError`.
- **`getSolanaErrorFromInstructionError(num index, Object)`** -- Converts a Solana RPC instruction error into a `SolanaError`.
- **`getSolanaErrorFromRpcError(RpcEnumErrorConfig, Object)`** -- Low-level converter for RPC enum-style errors.
- **`unwrapSimulationError(Object?)`** -- Extracts the underlying cause from simulation-related errors.
- **`encodeContextObject(Map<String, Object?>)`** -- Encodes a context map to a compact base64 string.
- **`decodeEncodedContext(String)`** -- Decodes a base64-encoded context string back into a map.

### Constants

- **`solanaErrorMessages`** -- `Map<int, String>` mapping every `SolanaErrorCode` to its human-readable message template.
