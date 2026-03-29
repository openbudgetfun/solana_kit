---
title: Build a Token Transfer Flow
description: Assemble a production-friendly transfer pipeline from inputs to confirmation.
---

A transfer flow is more than a single helper call. In practice, you need to:

1. collect inputs
2. fetch chain state
3. build the message
4. sign
5. send
6. confirm
7. classify failures

This guide focuses on the shape of that pipeline so you can adapt it to SOL transfers, SPL token transfers, or your own typed program client.

## Step 1: gather the inputs

Typical transfer inputs:

- the sender signer or wallet
- the recipient address
- the amount
- an instruction builder or program client
- an RPC client

Keeping these explicit at the function boundary makes the transfer flow easier to test.

## Step 2: fetch the latest blockhash

```dart
final latestBlockhash = await rpc.getLatestBlockhash().send();
```

A blockhash-based transaction must include a valid lifetime constraint before it can be signed.

## Step 3: build the transfer instruction

Whether you use a system-program helper, a token-program client, or a custom instruction builder, the output should be an `Instruction`.

```dart
final transferInstruction = buildTransferInstruction(
  sender: sender.address,
  recipient: recipient,
  amount: amount,
);
```

## Step 4: build the transaction message

```dart
final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayerSigner(sender))
    .pipe(
      setTransactionMessageLifetimeUsingBlockhash(
        BlockhashLifetimeConstraint(
          blockhash: latestBlockhash.value.blockhash,
          lastValidBlockHeight: latestBlockhash.value.lastValidBlockHeight,
        ),
      ),
    )
    .pipe(appendTransactionMessageInstruction(transferInstruction));
```

## Step 5: sign and submit

```dart
final signedTransaction = await signTransactionMessageWithSigners(message);

final signature = await sendAndConfirmTransaction(
  rpc: rpc,
  transaction: signedTransaction,
);
```

## Step 6: map failures by domain

Useful high-level buckets:

- **RPC failures** — provider downtime, transport errors, malformed responses
- **transaction failures** — missing signers, expired blockhash, signature issues
- **program/instruction failures** — insufficient funds, invalid accounts, program-specific rules

`SolanaError` domains make it easier to route these to the right product behavior.

## Why this structure scales

This shape works equally well for:

- one-off wallet sends
- backend automation
- mobile wallet adapter integrations
- typed program clients
- instruction-plan-based multi-step workflows

## Related docs

- [First Transaction](../getting-started/first-transaction)
- [Transactions](../core/transactions)
- [Signers](../core/signers)
- [Errors and Diagnostics](../core/errors-and-diagnostics)
