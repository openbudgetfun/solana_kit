# solana_kit_errors

[![pub package](https://img.shields.io/pub/v/solana_kit_errors.svg)](https://pub.dev/packages/solana_kit_errors) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_errors/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_errors) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_errors)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_errors)

Structured errors for the Solana Kit SDK. Every failure in the SDK is a `SolanaError` carrying a numeric code from `SolanaErrorCode` and an optional context map, so callers can route on codes instead of parsing message strings.

This is the Dart port of [`@solana/errors`](https://github.com/anza-xyz/kit/tree/main/packages/errors) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_errors"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_errors": ^0.9.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_errors"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_errors
- API reference: https://pub.dev/documentation/solana_kit_errors/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_errors
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_errors

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Creating errors

`SolanaError` implements `Exception`, so it can be thrown and caught like any Dart exception. The context map is made unmodifiable at construction time.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  // Simple error with no context.
  final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
  print(error);

  // Error with context variables interpolated into the message.
  final notFoundError = SolanaError(
    SolanaErrorCode.accountsAccountNotFound,
    {'address': '11111111111111111111111111111111'},
  );
  print(notFoundError);

  try {
    throw SolanaError(SolanaErrorCode.transactionFeePayerMissing);
  } on SolanaError catch (e) {
    print('Code: ${e.code}');
    print('Context: ${e.context}');
    print('Message: $e');
  }
}
```

### Checking errors with `isSolanaError`

`isSolanaError` is a type guard. It checks whether a value is a `SolanaError` and optionally whether it matches a specific error code.

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
  print(isSolanaError('not an error')); // false
  print(isSolanaError(null)); // false
}

void main() {
  handleError(SolanaError(SolanaErrorCode.transactionFeePayerMissing));
}
```

### Error message interpolation

Error messages are templates with `$variable` placeholders filled from the context map. `getErrorMessage` performs the interpolation.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  // Get an interpolated message directly.
  final message = getErrorMessage(
    SolanaErrorCode.addressesInvalidByteLength,
    {'actualLength': 28},
  );
  print(message);

  // Missing context values leave the placeholder as-is.
  final partial = getErrorMessage(SolanaErrorCode.addressesInvalidByteLength);
  print(partial);

  // Codes without a message template produce a fallback message.
  final unknown = getErrorMessage(SolanaErrorCode.blockHeightExceeded);
  print(unknown);
}
```

### Converting JSON-RPC errors

`getSolanaErrorFromJsonRpcError` converts a JSON-RPC error response into a `SolanaError`. Preflight failures automatically extract the nested transaction error.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  // Typical JSON-RPC error response from a Solana node.
  final rpcError = <String, Object?>{
    'code': -32005,
    'message': 'Node is unhealthy',
    'data': <String, Object?>{},
  };

  final solanaError = getSolanaErrorFromJsonRpcError(rpcError);
  print(solanaError.code == SolanaErrorCode.jsonRpcServerErrorNodeUnhealthy);

  // Preflight failure errors automatically extract the nested transaction error.
  final preflightError = <String, Object?>{
    'code': -32002,
    'message': 'Transaction simulation failed',
    'data': <String, Object?>{
      'err': 'BlockhashNotFound',
      'logs': <String>[],
    },
  };

  final preflightSolanaError = getSolanaErrorFromJsonRpcError(preflightError);
  print(
    preflightSolanaError.code ==
        SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
  );

  // The nested cause is available in the context.
  final cause = preflightSolanaError.context['cause'] as SolanaError;
  print(cause.code == SolanaErrorCode.transactionErrorBlockhashNotFound);

  // Malformed responses produce a malformedJsonRpcError.
  final malformed = getSolanaErrorFromJsonRpcError({'unexpected': 'data'});
  print(malformed.code == SolanaErrorCode.malformedJsonRpcError);
}
```

### Converting transaction and instruction errors

Transaction errors from RPC responses use a Rust enum-like format. `getSolanaErrorFromTransactionError` handles both string and map forms, and delegates `InstructionError` entries to `getSolanaErrorFromInstructionError`.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  // Simple string error.
  final error = getSolanaErrorFromTransactionError('BlockhashNotFound');
  print(error.code == SolanaErrorCode.transactionErrorBlockhashNotFound);

  // Error with nested context.
  final rentError = getSolanaErrorFromTransactionError({
    'InsufficientFundsForRent': {'account_index': 2},
  });
  print(rentError.code == SolanaErrorCode.transactionErrorInsufficientFundsForRent);
  print(rentError.context['accountIndex']); // 2

  // Instruction errors nested in transaction errors are delegated.
  final txError = getSolanaErrorFromTransactionError({
    'InstructionError': [0, 'InvalidAccountData'],
  });
  print(txError.code == SolanaErrorCode.instructionErrorInvalidAccountData);

  // Custom program error with an error code.
  final customError = getSolanaErrorFromInstructionError(1, {'Custom': 42});
  print(customError.code == SolanaErrorCode.instructionErrorCustom);
  print(customError.context['code']); // 42
  print(customError.context['index']); // 1
}
```

### Unwrapping simulation errors

When a transaction simulation fails, the actual error is wrapped in a simulation error. `unwrapSimulationError` gets at the underlying cause.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  final simulationError = SolanaError(
    SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
    {
      'cause': SolanaError(SolanaErrorCode.transactionErrorBlockhashNotFound),
      'logs': <String>[],
    },
  );

  final underlying = unwrapSimulationError(simulationError);
  print(underlying is SolanaError);
  print(
    (underlying! as SolanaError).code ==
        SolanaErrorCode.transactionErrorBlockhashNotFound,
  );

  // Non-simulation errors are returned as-is.
  final regularError = SolanaError(SolanaErrorCode.blockHeightExceeded);
  print(identical(unwrapSimulationError(regularError), regularError));
}
```

### Context encoding and decoding

`encodeContextObject` and `decodeEncodedContext` serialize error context maps to and from compact base64 strings, useful for transmitting error details.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  final context = {
    'address': '11111111111111111111111111111111',
    'index': 0,
  };

  // Encode to a compact base64 string.
  final encoded = encodeContextObject(context);
  print(encoded);

  // Decode back to the original map.
  final decoded = decodeEncodedContext(encoded);
  print(decoded['address']);
}
```

<!-- {=errorDomainHelpersSection} -->

### Typed Error Domains

`solana_kit_errors` includes domain helpers layered over numeric error codes. Use them to route error handling without hardcoding code ranges throughout your application.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void handleSolanaFailure(SolanaError error) {
  if (error.isInDomain(SolanaErrorDomain.rpc)) {
    print('RPC failure: $error');
    return;
  }

  if (error.isInDomain(SolanaErrorDomain.transaction)) {
    print('Transaction failure: $error');
    return;
  }

  print('Unhandled Solana error: $error');
}
```

This keeps your error-routing logic readable while still preserving the exact numeric code and context payload when you need lower-level diagnostics.

<!-- {/errorDomainHelpersSection} -->

### Preferred construction helpers

Use `createSolanaError(...)` and `wrapSolanaError(...)` when you want consistent null stripping, shared context keys, and nested-cause preservation.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  final error = wrapSolanaError(
    SolanaErrorCode.accountsFailedToDecodeAccount,
    StateError('decoder failed'),
    context: {
      SolanaErrorContextKeys.address: '11111111111111111111111111111111',
      SolanaErrorContextKeys.operation: 'decodeAccount',
    },
  );

  print(error.context[SolanaErrorContextKeys.causeType]); // StateError
}
```

Prefer shared keys such as `address`, `operation`, `methodName`, `path`, `statusCode`, and `url` so diagnostics stay predictable across packages.

## API Reference

### Classes

- `SolanaError`: core error class implementing `Exception`. Carries an `int code` and an unmodifiable `Map<String, Object?> context`.
- `SolanaErrorCode`: abstract final class with 100+ `static const int` error codes grouped by category (general, JSON-RPC, addresses, accounts, keys, instructions, instruction errors, signers, transactions, transaction errors, codecs, RPC, RPC subscriptions, program clients, invariant violations).
- `RpcEnumErrorConfig`: configuration class for mapping Solana RPC enum-style errors to `SolanaError` instances.
- `SolanaErrorContextKeys`: shared key names for structured diagnostics such as `address`, `operation`, `methodName`, `path`, `statusCode`, and nested cause fields.
- `SolanaErrorDomain`: enum describing high-level error domains (for example `rpc`, `transaction`, `codecs`, `mobileWalletAdapter`).

### Functions

- `isSolanaError(Object? e, [int? code])`: type guard that checks whether a value is a `SolanaError`, optionally matching a specific code.
- `getSolanaErrorDomain(int code)`: classifies numeric error codes into typed `SolanaErrorDomain` values.
- `isSolanaErrorCodeInDomain(int code, SolanaErrorDomain domain)`: checks if a numeric code belongs to a domain.
- `isSolanaErrorInDomain(Object? error, SolanaErrorDomain domain)`: checks if an `Object?` is a `SolanaError` in a domain.
- `getErrorMessage(int code, [Map<String, Object?> context])`: returns the interpolated error message for a given error code and context.
- `createSolanaError(int, {Map<String, Object?> context, Object? cause})`: creates a `SolanaError` with normalized context and optional nested cause details.
- `wrapSolanaError(int, Object, {Map<String, Object?> context})`: wraps an existing exception or `SolanaError` while preserving structured cause information.
- `createSolanaErrorContext(Map<String, Object?>, {Object? cause})`: normalizes context maps by dropping nulls and attaching consistent nested-cause metadata.
- `getSolanaErrorFromJsonRpcError(Object?)`: converts a JSON-RPC error response map into a `SolanaError`.
- `getSolanaErrorFromTransactionError(Object)`: converts a Solana RPC transaction error into a `SolanaError`.
- `getSolanaErrorFromInstructionError(num index, Object)`: converts a Solana RPC instruction error into a `SolanaError`.
- `getSolanaErrorFromRpcError(RpcEnumErrorConfig, Object)`: low-level converter for RPC enum-style errors.
- `unwrapSimulationError(Object?)`: extracts the underlying cause from simulation-related errors.
- `encodeContextObject(Map<String, Object?>)`: encodes a context map to a compact base64 string.
- `decodeEncodedContext(String)`: decodes a base64-encoded context string back into a map.

### Constants

- `solanaErrorMessages`: `Map<int, String>` mapping every `SolanaErrorCode` to its human-readable message template.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_errors"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_errors/solana_kit_errors.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_errors`.

- Import path: `package:solana_kit_errors/solana_kit_errors.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
