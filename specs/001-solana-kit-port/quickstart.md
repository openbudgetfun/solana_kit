# Quickstart: Solana Kit Dart SDK

**Branch**: `001-solana-kit-port` | **Date**: 2026-02-15

## Installation

Add the umbrella package to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit: ^0.1.0
```

Or import individual packages for smaller dependency footprints:

```yaml
dependencies:
  solana_kit_addresses: ^0.1.0
  solana_kit_keys: ^0.1.0
  solana_kit_rpc: ^0.1.0
  solana_kit_transactions: ^0.1.0
```

## Hello World: Airdrop + Transfer

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  // Create an RPC client pointing at devnet
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // Generate a new keypair
  final sender = await generateKeyPair();
  final senderAddress = await getAddressFromPublicKey(sender.publicKey);

  // Request an airdrop of 1 SOL
  final airdropSig = await rpc.requestAirdrop(senderAddress, lamports: 1000000000).send();
  await waitForConfirmation(rpc, airdropSig);

  // Create a recipient
  final recipient = await generateKeyPair();
  final recipientAddress = await getAddressFromPublicKey(recipient.publicKey);

  // Build a transfer transaction
  final blockhash = await rpc.getLatestBlockhash().send();
  final message = createTransactionMessage(version: 0)
      .pipe(setTransactionMessageFeePayer(senderAddress))
      .pipe(setTransactionMessageLifetimeUsingBlockhash(blockhash.value))
      .pipe(appendTransactionMessageInstruction(
        SystemProgram.transfer(
          from: senderAddress,
          to: recipientAddress,
          lamports: 500000000,
        ),
      ));

  // Sign and send
  final signer = await createKeyPairSignerFromKeyPair(sender);
  final signedTx = await signTransaction([signer], message);
  final txSig = await rpc.sendTransaction(signedTx).send();
  await waitForConfirmation(rpc, txSig);

  print('Transfer complete: $txSig');
}
```

## Encode/Decode Account Data

```dart
import 'package:solana_kit_codecs/solana_kit_codecs.dart';

// Define a codec for a program's account structure
final myAccountCodec = getStructCodec([
  ('authority', getAddressCodec()),
  ('balance', getU64Codec()),
  ('name', getUtf8Codec(size: prefixSize(getU32Codec()))),
  ('isActive', getBoolCodec()),
]);

// Decode bytes from chain
final accountData = myAccountCodec.decode(rawBytes);
print('Authority: ${accountData['authority']}');
print('Balance: ${accountData['balance']}');

// Encode for instruction data
final encoded = myAccountCodec.encode({
  'authority': myAddress,
  'balance': BigInt.from(1000000),
  'name': 'My Account',
  'isActive': true,
});
```

## Subscribe to Account Changes

```dart
import 'package:solana_kit/solana_kit.dart';

final subscriptions = createSolanaRpcSubscriptions(
  'wss://api.devnet.solana.com',
);

final stream = subscriptions.accountNotifications(myAddress).subscribe();

await for (final notification in stream) {
  print('Account changed! New lamports: ${notification.value.lamports}');
}
```

## Verification Steps

1. `dart pub get` resolves all dependencies without errors
2. The airdrop + transfer example runs against devnet successfully
3. Codec round-trip produces identical bytes for encode → decode → encode
4. Subscription stream emits at least one notification when account changes
