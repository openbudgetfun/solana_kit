---
title: Create Instructions
description: Model Solana instructions explicitly with program addresses, account roles, and binary payloads.
---

An instruction is the smallest unit of program interaction on Solana. It answers three questions:

1. **Which program should execute?**
2. **Which accounts should the program read or write?**
3. **What binary payload should the program receive?**

## Minimal instruction

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

final instruction = Instruction(
  programAddress: const Address('11111111111111111111111111111111'),
  accounts: const [],
  data: Uint8List(0),
);
```

This is valid as a model, though most real program interactions require one or more accounts and a structured data payload.

## Instruction with account metadata

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

const feePayer = Address('11111111111111111111111111111111');
const recipient = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

final instruction = Instruction(
  programAddress: const Address('11111111111111111111111111111111'),
  accounts: const [
    AccountMeta(address: feePayer, role: AccountRole.writableSigner),
    AccountMeta(address: recipient, role: AccountRole.writable),
  ],
  data: Uint8List.fromList([1, 2, 3]),
);
```

## Choosing the right account role

Use account roles to express exactly how the runtime should treat each account.

- **`readonly`** — read-only, not a signer
- **`writable`** — mutable, not a signer
- **`readonlySigner`** — signer, but not writable
- **`writableSigner`** — signer and writable

A wrong role can cause transaction failures even when the program address and data payload are correct.

## Encoding instruction data

In simple examples, `Uint8List.fromList(...)` is enough. In real applications, prefer codecs so your instruction layouts are:

- deterministic
- testable
- reusable across encode/decode flows

See [Codecs](../core/codecs) for the recommended approach.

## Where instructions go next

Instructions are usually appended to a transaction message:

```dart
final messageWithInstruction = appendTransactionMessageInstruction(
  instruction,
  message,
);
```

Or combined in a pipeline:

```dart
final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayer(feePayer))
    .pipe(appendTransactionMessageInstruction(instruction));
```

## Next steps

- [Build a Transaction](build-a-transaction)
- [Transactions](../core/transactions)
- [Codecs](../core/codecs)
