---
title: Accounts
description: Understand encoded accounts, maybe-account wrappers, jsonParsed reads, and decode flows.
---

Accounts are where most Solana application state lives. Solana Kit gives you a few distinct layers so you can choose the right boundary for your use case.

## Core account models

### `Account<TData>`

Represents an existing account with:

- `address`
- `data`
- `lamports`
- `programAddress`
- `space`
- `executable`

### `MaybeAccount<TData>`

A sealed result type for “this account may or may not exist”.

Pattern matching keeps the control flow explicit:

```dart
switch (maybeAccount) {
  case ExistingAccount<Uint8List>(:final account):
    print(account.address);
  case NonExistingAccount(:final address):
    print('Missing: $address');
}
```

## Encoded vs parsed reads

### Encoded reads

Use encoded reads when:

- the account belongs to a custom program
- you need byte-perfect control over decoding
- you already have codecs/decoders for the layout

Helpers:

- `fetchEncodedAccount`
- `fetchEncodedAccounts`
- `decodeAccount`
- `decodeMaybeAccount`

### Parsed reads

Use parsed reads when:

- the RPC supports `jsonParsed` for the account type
- you want a human-readable result quickly
- you are working with common system or SPL account types

Helpers:

- `fetchJsonParsedAccount`
- `fetchJsonParsedAccounts`

## Typical decode flow

<!-- {=docsDecodeAccountSection} -->

## Decode a fetched account

Keep transport and binary-layout logic separate: fetch the encoded account
first, then decode it with the codec or decoder that matches your program.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

Future<void> loadDecodedAccount(
  Rpc rpc,
  Address address,
  Decoder<int> decoder,
) async {
  final maybeEncoded = await fetchEncodedAccount(rpc, address);
  final maybeDecoded = decodeMaybeAccount(maybeEncoded, decoder);

  switch (maybeDecoded) {
    case ExistingAccount<int>(:final account):
      print('Decoded value: ${account.data}');
    case NonExistingAccount():
      print('Account not found: $address');
  }
}
```

This boundary keeps RPC concerns, existence handling, and binary decoding easy
to test independently.

<!-- {/docsDecodeAccountSection} -->

This split is intentional:

- transport and RPC behavior stay in the fetch layer
- binary-layout knowledge stays in your decoder or codec layer

## Account assertions

The package also provides assertion helpers for workflows that expect an account to exist or decode successfully.

These helpers are useful when you want domain-specific errors instead of open-ended nullable control flow.

## Related packages

- `solana_kit_accounts` — fetch, parse, and decode helpers
- `solana_kit_rpc_types` — shared account response models
- `solana_kit_rpc_parsed_types` — typed parsed-account models for known programs
- `solana_kit_codecs_*` — custom binary layouts
- `solana_kit_program_client_core` — higher-level patterns for typed program clients

## Read next

- [Fetch an Account](../getting-started/fetch-an-account)
- [Codecs](codecs)
- [Build a Program Client](../guides/build-program-client)
