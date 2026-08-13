# solana_kit_transaction_introspection

[![pub package](https://img.shields.io/pub/v/solana_kit_transaction_introspection.svg)](https://pub.dev/packages/solana_kit_transaction_introspection)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_transaction_introspection)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_transaction_introspection)

Decode confirmed Solana transactions and walk their outer and inner instructions in a form that the auto-generated `@solana-program/*` clients can `identify` and `parse` directly.

This is the Dart port of [`@solana/transaction-introspection`](https://github.com/anza-xyz/kit/tree/main/packages/transaction-introspection) from the Solana TypeScript SDK.

## Key APIs

- `decodeTransactionFromRpcResponse(Map<String, Object?>?)` — decodes a `getTransaction` response (`'base64'`, `'base58'`, or `'json'`) into a `DecodedRpcTransaction` (compiled message + loaded ALT addresses + wire-format transaction for binary encodings).
- `walkInstructions({compiledMessage, meta, loadedAddresses})` — returns every instruction in display order as `TracedInstruction`s (each outer instruction followed by its CPI inner instructions), with account indices resolved to `AccountMeta`s.
- `getInstructionsFromCompiledTransactionMessage(compiledMessage, {loadedAddresses})` — returns the outer instructions as resolved `Instruction`s.
- `getInnerInstructionsFromMeta(meta, accountMetas)` — returns the inner instructions from a `getTransaction` `meta` as `TracedInstruction`s.

## Usage

```dart
import 'package:solana_kit_transaction_introspection/solana_kit_transaction_introspection.dart';

void main() {
  // `rpcTx` is a `getTransaction` response map.
  final decoded = decodeTransactionFromRpcResponse(rpcTx);
  for (final ix in walkInstructions(
    compiledMessage: decoded.compiledMessage,
    loadedAddresses: decoded.loadedAddresses,
  )) {
    print(ix.trace);
    print(ix.programAddress);
  }
}
```

`'jsonParsed'` responses are not supported: their instructions arrive pre-parsed by the server and lack raw bytes, so they cannot be round-tripped through the auto-generated `parseXInstruction` clients. Prefer `'base64'` when bandwidth allows — it is the most compact and the returned `transaction` is re-encodable.