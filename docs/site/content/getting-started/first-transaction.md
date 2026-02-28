---
title: First Transaction
description: Build, compile, and sign a Solana transaction message.
---

A typical transaction flow:

1. Fetch a recent blockhash.
2. Build a transaction message.
3. Append one or more instructions.
4. Compile to a transaction and sign with a `TransactionSigner`.

```dart
import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');
final feePayer = await generateKeyPair();

final latestBlockhash = await rpc.getLatestBlockhash().send();

final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayer(feePayer.address))
    .pipe(
      setTransactionMessageLifetimeUsingBlockhash(
        latestBlockhash.value.blockhash,
      ),
    );

// Add instructions with appendTransactionMessageInstruction(...)
// and compile/sign as needed for your program interaction.
```

See [Transactions](../core/transactions) for composition patterns and size constraints.
