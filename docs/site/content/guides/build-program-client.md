---
title: Build a Program Client
description: Combine codecs, instructions, and account decoding into a reusable typed client for a Solana program.
---

A program client packages three things together:

1. **instruction builders**
2. **account decoders**
3. **task-oriented helper methods**

That gives the rest of your app one coherent boundary for interacting with a program.

## Step 1: define the instruction layout

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

final incrementInstructionCodec = getStructCodec({
  'discriminator': getU8Codec(),
  'amount': getU64Codec(),
});
```

## Step 2: create an instruction builder

```dart
import 'package:solana_kit/solana_kit.dart';

Instruction buildIncrementInstruction({
  required Address programAddress,
  required Address counterAddress,
  required Address authority,
  required BigInt amount,
}) {
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: counterAddress, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: incrementInstructionCodec.encode({
      'discriminator': 1,
      'amount': amount,
    }),
  );
}
```

## Step 3: create an account decoder

```dart
final counterAccountCodec = getStructCodec({
  'count': getU64Codec(),
});
```

Then decode fetched bytes:

```dart
final decoded = counterAccountCodec.decode(encodedAccount.data);
print(decoded['count']);
```

## Step 4: wrap it in a client boundary

```dart
class CounterProgramClient {
  const CounterProgramClient({required this.rpc, required this.programAddress});

  final Rpc rpc;
  final Address programAddress;

  Future<MaybeEncodedAccount> fetchCounter(Address counterAddress) {
    return fetchEncodedAccount(rpc, counterAddress);
  }

  Instruction buildIncrement({
    required Address counterAddress,
    required Address authority,
    required BigInt amount,
  }) {
    return buildIncrementInstruction(
      programAddress: programAddress,
      counterAddress: counterAddress,
      authority: authority,
      amount: amount,
    );
  }
}
```

At this point, the rest of your app can depend on `CounterProgramClient` instead of knowing the raw layout and account-role details.

## Step 5: add higher-level workflows

Once the client owns the instruction and decode rules, you can add methods like:

- `fetchAndDecodeCounter(...)`
- `buildIncrementMessage(...)`
- `submitIncrement(...)`

Those methods are usually more stable and more meaningful to application code than the raw Solana details underneath.

## Related docs

- [Codecs](../core/codecs)
- [Accounts](../core/accounts)
- [Create Instructions](../getting-started/create-instructions)
