# solana_kit_accounts

[![pub package](https://img.shields.io/pub/v/solana_kit_accounts.svg)](https://pub.dev/packages/solana_kit_accounts)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_accounts/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Account fetching, decoding, and assertion utilities for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/accounts`](https://github.com/anza-xyz/kit/tree/main/packages/accounts) from the Solana TypeScript SDK.

## Installation

Add `solana_kit_accounts` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_accounts:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Documentation

- Package page: https://pub.dev/packages/solana_kit_accounts
- API reference: https://pub.dev/documentation/solana_kit_accounts/latest/

## Usage

### The Account type

The `Account<TData>` class contains all the information relevant to a Solana account: its address, data, and on-chain metadata.

```dart
import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  // An encoded account stores its data as raw bytes.
  final encodedAccount = Account<Uint8List>(
    address: const Address('11111111111111111111111111111111'),
    data: Uint8List.fromList([1, 2, 3, 4]),
    executable: false,
    lamports: Lamports(BigInt.from(1000000000)),
    programAddress: const Address('11111111111111111111111111111111'),
    space: BigInt.from(4),
  );

  print(encodedAccount.address); // Address('11111111111111111111111111111111')
  print(encodedAccount.lamports); // Lamports(1000000000)
  print(encodedAccount.executable); // false
  print(encodedAccount.data.length); // 4

  // The EncodedAccount type alias is Account<Uint8List>.
  final EncodedAccount sameType = encodedAccount;
}
```

### MaybeAccount -- handling accounts that may not exist

`MaybeAccount<TData>` is a sealed class hierarchy that represents an account that may or may not exist on-chain. Pattern matching is the idiomatic way to handle both cases.

```dart
import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void handleAccount(MaybeAccount<Uint8List> maybeAccount) {
  switch (maybeAccount) {
    case ExistingAccount<Uint8List>(:final account):
      print('Account exists with ${account.data.length} bytes');
      print('Lamports: ${account.lamports}');
    case NonExistingAccount():
      print('Account does not exist at ${maybeAccount.address}');
  }

  // Or use the exists flag.
  if (maybeAccount.exists) {
    print('Found at ${maybeAccount.address}');
  }
}
```

### Fetching accounts from the RPC

Use `fetchEncodedAccount` and `fetchEncodedAccounts` to retrieve accounts from a Solana RPC node. These functions use the `getAccountInfo` and `getMultipleAccounts` RPC methods with base64 encoding.

```dart
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // Fetch a single account.
  final maybeAccount = await fetchEncodedAccount(
    rpc,
    const Address('11111111111111111111111111111111'),
  );

  if (maybeAccount.exists) {
    print('Account found at ${maybeAccount.address}');
  }

  // Fetch with a specific commitment level.
  final confirmedAccount = await fetchEncodedAccount(
    rpc,
    const Address('11111111111111111111111111111111'),
    config: FetchAccountConfig(commitment: Commitment.confirmed),
  );

  // Fetch multiple accounts at once.
  final accounts = await fetchEncodedAccounts(
    rpc,
    [
      const Address('11111111111111111111111111111111'),
      const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
    ],
  );
  print('Fetched ${accounts.length} accounts');
}
```

### Fetching JSON-parsed accounts

The `fetchJsonParsedAccount` and `fetchJsonParsedAccounts` functions use the `jsonParsed` encoding, which returns human-readable data for well-known program accounts (e.g. SPL Token accounts).

```dart
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');
  const tokenAccountAddress = Address(
    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
  );

  // Fetch a single JSON-parsed account.
  final account = await fetchJsonParsedAccount(rpc, tokenAccountAddress);
  if (account case ExistingAccount<Object>(:final account)) {
    if (account.data case JsonParsedAccountData<Map<String, Object?>>(:final parsedAccountMeta, :final data)) {
      print('Program: ${parsedAccountMeta?.program}');
      print('Type: ${parsedAccountMeta?.type}');
      print('Parsed data: $data');
    }
  }
}
```

### Decoding accounts

Transform an `EncodedAccount` into an `Account<TData>` using a `Decoder`.

```dart
import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// A simple data type for demonstration.
class MyData {
  const MyData(this.value);
  final int value;
}

// A decoder that reads a little-endian u32 from the account data.
class MyDataDecoder implements Decoder<MyData> {
  const MyDataDecoder();

  @override
  MyData decode(Uint8List bytes, [int offset = 0]) => read(bytes, offset).$1;

  @override
  (MyData, int) read(Uint8List bytes, int offset) {
    final byteData = ByteData.sublistView(bytes);
    final value = byteData.getUint32(offset, Endian.little);
    return (MyData(value), offset + 4);
  }

  @override
  int get fixedSize => 4;

  @override
  int? get maxSize => 4;
}

void main() {
  // Create an encoded account.
  final encodedAccount = Account<Uint8List>(
    address: const Address('11111111111111111111111111111111'),
    data: Uint8List.fromList([42, 0, 0, 0]),
    executable: false,
    lamports: Lamports(BigInt.from(1000000)),
    programAddress: const Address('11111111111111111111111111111111'),
    space: BigInt.from(4),
  );

  // Decode the account using a custom decoder.
  const decoder = MyDataDecoder();
  final decodedAccount = decodeAccount<MyData>(encodedAccount, decoder);
  print(decodedAccount.data.value); // 42
}
```

For `MaybeAccount`, use `decodeMaybeAccount`:

```dart
Future<void> fetchAndDecode() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');
  const decoder = MyDataDecoder();

  final maybeFetched = await fetchEncodedAccount(
    rpc,
    const Address('11111111111111111111111111111111'),
  );
  final maybeDecoded = decodeMaybeAccount<MyData>(maybeFetched, decoder);

  switch (maybeDecoded) {
    case ExistingAccount<MyData>(:final account):
      print('Decoded value: ${account.data.value}');
    case NonExistingAccount():
      print('Account not found');
  }
}
```

### Asserting account state

Use assertion functions to validate account existence and decoding state.

```dart
import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // Assert that a MaybeAccount exists.
  // Throws SolanaError with code accountsAccountNotFound if it does not.
  final maybeAccount = await fetchEncodedAccount(
    rpc,
    const Address('11111111111111111111111111111111'),
  );
  assertAccountExists(maybeAccount);

  // Assert multiple accounts all exist.
  // Throws SolanaError with code accountsOneOrMoreAccountsNotFound.
  final accounts = await fetchEncodedAccounts(rpc, [
    const Address('11111111111111111111111111111111'),
    const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
  ]);
  assertAccountsExist(accounts);

  // Assert that an account stores decoded data (not Uint8List).
  // Throws SolanaError with code accountsExpectedDecodedAccount
  // if the data field is still a Uint8List (i.e. not yet decoded).
  // assertAccountDecoded(decodedAccount);

  // Assert all accounts in a list are decoded.
  // Throws SolanaError with code accountsExpectedAllAccountsToBeDecoded.
  // assertAccountsDecoded(decodedAccounts);
}
```

### Parsing raw RPC account data

Convert raw JSON-RPC account maps into typed `MaybeAccount` instances.

```dart
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  const addr = Address('11111111111111111111111111111111');

  // Parse a base64-encoded RPC response.
  final account = parseBase64RpcAccount(addr, {
    'data': ['AQAAAA==', 'base64'],
    'executable': false,
    'lamports': 1000000000,
    'owner': '11111111111111111111111111111111',
    'space': 4,
  });

  if (account case ExistingAccount(:final data)) {
    print('Data length: ${data.length}');
  }

  // Parse a null response (account not found).
  final missing = parseBase64RpcAccount(addr, null);
  print(missing.exists); // false

  // Parse a jsonParsed-encoded RPC response.
  final jsonParsed = parseJsonRpcAccount(addr, {
    'data': {
      'parsed': {
        'info': {'balance': 1000},
        'type': 'account',
      },
      'program': 'system',
      'space': 4,
    },
    'executable': false,
    'lamports': 1000000000,
    'owner': '11111111111111111111111111111111',
    'space': 4,
  });
}
```

## API Reference

### Classes

| Class                          | Description                                                              |
| ------------------------------ | ------------------------------------------------------------------------ |
| `BaseAccount`                  | Base properties: `executable`, `lamports`, `programAddress`, `space`.    |
| `Account<TData>`               | Extends `BaseAccount` with `address` and `data` of type `TData`.         |
| `MaybeAccount<TData>`          | Sealed class: account that may or may not exist.                         |
| `ExistingAccount<TData>`       | Extends `MaybeAccount`. Wraps an `Account<TData>` with `exists == true`. |
| `NonExistingAccount<TData>`    | Extends `MaybeAccount`. Only has `address` with `exists == false`.       |
| `FetchAccountConfig`           | Optional config: `commitment`, `minContextSlot`.                         |
| `JsonParsedAccountData<TData>` | Parsed account data with optional `ParsedAccountMeta`.                   |
| `ParsedAccountMeta`            | Metadata from jsonParsed responses: `program`, `type`.                   |

### Type aliases

| Type                  | Description                                                      |
| --------------------- | ---------------------------------------------------------------- |
| `EncodedAccount`      | `Account<Uint8List>` -- an account with raw byte data.           |
| `MaybeEncodedAccount` | `MaybeAccount<Uint8List>` -- a maybe-account with raw byte data. |

### Fetch functions

| Function                                             | Description                                                                         |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `fetchEncodedAccount(rpc, address, {config?})`       | Fetches a single `MaybeEncodedAccount` using `getAccountInfo` with base64 encoding. |
| `fetchEncodedAccounts(rpc, addresses, {config?})`    | Fetches multiple `MaybeEncodedAccount`s using `getMultipleAccounts`.                |
| `fetchJsonParsedAccount(rpc, address, {config?})`    | Fetches a single `MaybeAccount<Object>` using `jsonParsed` encoding.                |
| `fetchJsonParsedAccounts(rpc, addresses, {config?})` | Fetches multiple `MaybeAccount<Object>`s using `jsonParsed` encoding.               |

### Decode functions

| Function                                       | Description                                               |
| ---------------------------------------------- | --------------------------------------------------------- |
| `decodeAccount<T>(encodedAccount, decoder)`    | Decodes an `EncodedAccount` into an `Account<T>`.         |
| `decodeMaybeAccount<T>(maybeEncoded, decoder)` | Decodes a `MaybeEncodedAccount` into a `MaybeAccount<T>`. |

### Assertion functions

| Function                                  | Description                                             |
| ----------------------------------------- | ------------------------------------------------------- |
| `assertAccountExists<T>(maybeAccount)`    | Throws if the account does not exist.                   |
| `assertAccountsExist<T>(accounts)`        | Throws if any account does not exist.                   |
| `assertAccountDecoded<T>(account)`        | Throws if the account data is still a `Uint8List`.      |
| `assertMaybeAccountDecoded<T>(account)`   | Throws if an existing account's data is still encoded.  |
| `assertAccountsDecoded<T>(accounts)`      | Throws if any account's data is still encoded.          |
| `assertMaybeAccountsDecoded<T>(accounts)` | Throws if any existing account's data is still encoded. |

### Parse functions

| Function                                      | Description                                                                       |
| --------------------------------------------- | --------------------------------------------------------------------------------- |
| `parseBase64RpcAccount(address, rpcAccount?)` | Parses a base64-encoded RPC account map into a `MaybeEncodedAccount`.             |
| `parseBase58RpcAccount(address, rpcAccount?)` | Parses a base58-encoded RPC account map into a `MaybeEncodedAccount`.             |
| `parseJsonRpcAccount(address, rpcAccount?)`   | Parses a jsonParsed RPC account map into a `MaybeAccount<JsonParsedAccountData>`. |
| `parseBaseAccount(rpcAccount)`                | Extracts `BaseAccount` properties from a raw RPC account map.                     |

### Constants

| Constant          | Description                                                         |
| ----------------- | ------------------------------------------------------------------- |
| `baseAccountSize` | `128` -- the number of bytes for account metadata (excluding data). |
