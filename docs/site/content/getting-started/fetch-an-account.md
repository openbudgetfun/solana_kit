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
```

Use `fetchJsonParsedAccount` when the RPC can return a structured
`jsonParsed` representation for a well-known program.

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

For custom programs, fetch encoded bytes first and then decode them with a codec or decoder:

```dart
final decodedAccount = decodeAccount(myEncodedAccount, myDecoder);
```

This keeps transport concerns and binary-layout concerns separate.

## When to use jsonParsed

Use `fetchJsonParsedAccount` or `fetchJsonParsedAccounts` when:

- the RPC already knows how to structure the account data
- you are reading a well-known system/SPL account type
- you prefer a human-readable response over a byte-oriented decode flow

Use encoded reads when you need full control over the layout or you are interacting with custom program data.

## Next steps

- [Accounts](../core/accounts)
- [Codecs](../core/codecs)
- [Build a Program Client](../guides/build-program-client)
