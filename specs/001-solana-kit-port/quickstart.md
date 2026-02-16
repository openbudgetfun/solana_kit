# Quickstart: Solana Kit Dart SDK

**Branch**: `001-solana-kit-port` | **Date**: 2026-02-16

## Installation

Add the umbrella package to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit: ^0.0.1
```

Or import individual packages for smaller dependency footprints:

```yaml
dependencies:
  solana_kit_addresses: ^0.0.1
  solana_kit_keys: ^0.0.1
  solana_kit_rpc: ^0.0.1
  solana_kit_transactions: ^0.0.1
```

## Hello World: Airdrop + Transfer

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  // Create an RPC client pointing at devnet.
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');

  // Generate a new keypair signer (synchronous).
  final signer = generateKeyPairSigner();
  final senderAddress = signer.address;

  // Request an airdrop of 1 SOL.
  final airdropSig = await rpc
      .request(
        'requestAirdrop',
        [senderAddress.value, Lamports(BigInt.from(1000000000)).value],
      )
      .send();
  print('Airdrop signature: $airdropSig');

  // Create a recipient.
  final recipient = generateKeyPairSigner();
  final recipientAddress = recipient.address;

  // Build a transfer transaction message.
  final blockhashResponse = await rpc
      .request('getLatestBlockhash', <Object?>[])
      .send();

  final transferInstruction = Instruction(
    programAddress: const Address('11111111111111111111111111111111'),
    accounts: [
      AccountMeta(
        address: senderAddress,
        role: AccountRole.writableSigner,
      ),
      AccountMeta(
        address: recipientAddress,
        role: AccountRole.writableSigner,
      ),
    ],
    // System program transfer instruction data
    // (instruction index 2 + lamports as u64 LE).
    data: Uint8List.fromList([
      2, 0, 0, 0, // transfer instruction index
      0, 101, 205, 29, 0, 0, 0, 0, // 500_000_000 lamports LE
    ]),
  );

  final blockhashConstraint = BlockhashLifetimeConstraint(
    blockhash: blockhashResponse['blockhash'] as String,
    lastValidBlockHeight: BigInt.from(
      blockhashResponse['lastValidBlockHeight'] as int,
    ),
  );

  // Build the transaction message using pipe for composition.
  final message = createTransactionMessage(version: TransactionVersion.v0)
      .pipe((msg) => setTransactionMessageFeePayer(senderAddress, msg))
      .pipe(
        (msg) => setTransactionMessageLifetimeUsingBlockhash(
          blockhashConstraint,
          msg,
        ),
      )
      .pipe(
        (msg) => appendTransactionMessageInstruction(
          transferInstruction,
          msg,
        ),
      );

  // Sign and send.
  final signedTx = await signTransactionMessageWithSigners(message);
  final encodedTx = getBase64EncodedWireTransaction(signedTx);
  final txSig = await rpc
      .request('sendTransaction', [encodedTx])
      .send();

  print('Transfer complete: $txSig');
}
```

## Encode/Decode Account Data

```dart
import 'package:solana_kit_codecs/solana_kit_codecs.dart';

// Define a codec for a program's account structure.
final myAccountCodec = getStructCodec([
  ('authority', addCodecSizePrefix(getUtf8Codec(), getU32Codec())),
  ('balance', getU64Codec()),
  ('name', addCodecSizePrefix(getUtf8Codec(), getU32Codec())),
  ('isActive', getBoolCodec()),
]);

// Decode bytes from chain.
final accountData = myAccountCodec.decode(rawBytes);
print('Authority: ${accountData['authority']}');
print('Balance: ${accountData['balance']}');

// Encode for instruction data.
final encoded = myAccountCodec.encode({
  'authority': 'E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ',
  'balance': BigInt.from(1000000),
  'name': 'My Account',
  'isActive': true,
});
```

## Subscribe to Account Changes

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final subscriptions = createSolanaRpcSubscriptions(
    'wss://api.devnet.solana.com',
  );

  final myAddress = const Address('E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ');

  // Create an abort controller to manage the subscription lifecycle.
  final abortController = AbortController();

  final stream = await subscriptions
      .request('accountNotifications', [myAddress.value])
      .subscribe(RpcSubscribeOptions(abortSignal: abortController.signal));

  await for (final notification in stream) {
    print('Account changed! Data: $notification');
    // Call abortController.abort() when done to unsubscribe.
    break;
  }
}
```

## Verification Steps

1. `dart pub get` resolves all dependencies without errors
2. Codec round-trip produces identical bytes for encode -> decode -> encode
3. All 3,633 tests pass across 35 packages
4. `dart analyze` reports zero warnings or errors across the entire workspace
