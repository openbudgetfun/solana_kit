---
title: Fetch an Account
description: Read encoded or jsonParsed account data and handle missing accounts safely.
---

Solana account reads usually fall into two categories:

- **encoded reads** — get the raw bytes and decode them yourself
- **jsonParsed reads** — let the RPC return a structured representation for known programs

In Solana Kit, both paths return explicit result models so you can distinguish an account that is present from an account that does not exist.

<!-- {=docsFetchAccountSection} -->

## Fetch an account

Use `fetchEncodedAccount` when you want the raw account bytes plus its Solana
metadata. Decode it later with the codec or parser that matches your program.

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
  const address = Address('11111111111111111111111111111111');

  final maybeAccount = await fetchEncodedAccount(rpc, address);

  switch (maybeAccount) {
    case ExistingAccount<Uint8List>(:final account):
      print('Owner: ${account.programAddress}');
      print('Bytes: ${account.data.length}');
    case NonExistingAccount():
      print('No account exists at $address');
  }
}
```

Use `fetchJsonParsedAccount` when the RPC can return a structured
`jsonParsed` representation for a well-known program. Use encoded reads when
you need byte-perfect custom decoding or when the RPC does not expose a parsed
view for your program.

<!-- {/docsFetchAccountSection} -->

## Fetch multiple accounts

```dart
final accounts = await fetchEncodedAccounts(
  rpc,
  const [
    Address('11111111111111111111111111111111'),
    Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
  ],
);

print('Fetched ${accounts.length} accounts');
```

Batch reads are especially useful when building dashboards, indexer workers, and program clients that need to hydrate several related accounts at once.

## Decode after fetching

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

## When to use jsonParsed

Use `fetchJsonParsedAccount` or `fetchJsonParsedAccounts` when:

- the RPC already knows how to structure the account data
- you are reading a well-known system/SPL account type
- you prefer a human-readable response over a byte-oriented decode flow

Use encoded reads when you need full control over the layout or you are interacting with custom program data.

## Reuse a higher-level account client

If your app reads accounts from several places, create a `SolanaAccountClient`
once and reuse it as the account boundary for your service or repository layer.

```dart
final accountClient = createSolanaAccountClient(rpc);
final maybeAccount = await accountClient.fetchEncodedAccount(
  const Address('11111111111111111111111111111111'),
);

print(maybeAccount.exists);
```

This keeps RPC request wiring in one place while preserving the same
`MaybeAccount`-based result models.

## Next steps

- [Accounts](../core/accounts)
- [Codecs](../core/codecs)
- [Build a Program Client](../guides/build-program-client)
