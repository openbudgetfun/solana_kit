---
"solana_kit_surfpool": minor
---

# Track Surfpool 1.6.0 confidential-transfer cheatcodes

Surfpool 1.6.0 registers two new `surfnet_*` cheatcode methods, and this package now exposes both. Every method the package implemented before keeps its exact name, parameter order, and wire field names, so this release is additive.

`getConfidentialBalance` returns the decrypted confidential-transfer balances of a Token-2022 token account. `deriveConfidentialKeys` turns an owner signature into the ElGamal and AES keys the other confidential cheatcodes need, so a test can drive the confidential suite without a client-side confidential-transfer crypto dependency.

```dart
final keys = await surfnet.deriveConfidentialKeys('base58Signature');

await surfnet.setTokenAccount(
  owner,
  mint,
  SetTokenAccountUpdate(
    confidential: ConfidentialTransferAccountUpdate(
      elgamalPubkey: keys.elgamalPubkey,
      aesKey: keys.aesKey,
      amount: 1_000,
    ),
  ),
  tokenProgram: token2022ProgramAddress,
);

final balance = await surfnet.getConfidentialBalance(
  surfnet.getAta(owner, mint),
  ConfidentialBalanceKeys(aesKey: keys.aesKey),
);
```

`SetTokenAccountUpdate` gains a `confidential` field for the Token-2022 `ConfidentialTransferAccount` extension, and the `SetTokenAccount` builder gains `withConfidentialTransfer`. `ConfidentialBalanceKeys` requires at least one of `aesKey` or `elgamalSecretKey` and throws an `ArgumentError` otherwise; the response's `available` and `pending` are `null` when the matching key was not supplied.

Two upstream constants are now available in Dart: `defaultSurfnetEndpoint` (`http://127.0.0.1:8899`) and `surfnetCheatcodeMethods`, the 28-method manifest that upstream pins against the set its runtime registers.
