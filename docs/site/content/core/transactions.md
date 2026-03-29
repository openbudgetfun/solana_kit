---
title: Transactions
description: Compose messages, attach signers, compile transactions, and confirm results with explicit typed steps.
---

Solana Kit intentionally splits the transaction stack into a few focused layers.

- `solana_kit_instructions` models program invocations.
- `solana_kit_transaction_messages` builds immutable message state.
- `solana_kit_signers` models who can authorize, mutate, or submit a transaction.
- `solana_kit_transactions` handles wire-format transactions and signatures.
- `solana_kit_transaction_confirmation` handles confirmation strategies.

## Recommended mental model

Think in four phases:

1. **Describe intent** — create instructions.
2. **Build message state** — set fee payer, lifetime, and instruction order.
3. **Authorize** — attach signers and produce signatures.
4. **Submit and confirm** — send the signed transaction and wait for a final outcome.

## Message construction

Use immutable message transforms:

```dart
final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayer(feePayerAddress))
    .pipe(setTransactionMessageLifetimeUsingBlockhash(blockhashConstraint))
    .pipe(appendTransactionMessageInstruction(instruction));
```

This style makes transaction assembly predictable and easy to test.

## Signing strategies

Use `signTransactionMessageWithSigners(...)` when all required signers are attached to the message and you want a fully signed transaction.

Use `partiallySignTransactionMessageWithSigners(...)` when a transaction will move through multiple signing stages.

Use `signAndSendTransactionMessageWithSigners(...)` when the message contains a `TransactionSendingSigner`, such as a wallet adapter.

## Confirmation strategies

<!-- {=docsSendAndConfirmSection} -->

## Send and confirm a signed transaction

Once you have a signed `Transaction`, use the additive confirmation helper for
an end-to-end “send then wait for confirmation” flow.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

Future<void> sendAndWait(
  Rpc rpc,
  Transaction signedTransaction,
) async {
  final signature = await sendAndConfirmTransaction(
    rpc: rpc,
    transaction: signedTransaction,
  );

  print('Confirmed signature: ${signature.value}');
}
```

For lower-level control, `solana_kit_transaction_confirmation` also exposes
strategy factories for block-height expiry, durable nonce invalidation,
signature notifications, and timeout racing.

<!-- {/docsSendAndConfirmSection} -->

## When to use instruction plans

If your operation spans multiple transactions or has parallel/sequential structure, move up to `solana_kit_instruction_plans`.

That package helps you model transaction orchestration explicitly instead of hiding it in ad hoc control flow.

## Read next

- [Create Instructions](../getting-started/create-instructions)
- [Build a Transaction](../getting-started/build-a-transaction)
- [Signers](signers)
- [Build a Token Transfer Flow](../guides/build-token-transfer-flow)
