---
"solana_kit_wallet_adapter": minor
---

# Verify Wallet Standard signatures before accepting them

`WalletAccountSigner` now cryptographically verifies every signature a Wallet Standard wallet returns before handing it to the caller, closing the same gap the mobile-wallet path already guards against:

- Message signatures must verify against the authorized account's Ed25519 public key over the returned signed bytes.
- A signed transaction must include the account's signature, and that signature must verify over the returned transaction's message bytes.
- A sign-and-send submission signature must be a genuine signature of the **submitted** transaction's message bytes — verified against the authorized account first and every declared signer public key second — so a reported signature for a different transaction is rejected before the caller records it for confirmation tracking.

Anything else fails with `WalletStandardErrorCode.invalidResponse`. A compromised wallet can no longer attach well-formed forgeries as if the account had signed, which matters when wallet signatures are composed with local signers in the same transaction.

```dart
final signer = WalletAccountSigner(wallet: wallet, account: account, chain: chain);
// Throws WalletStandardException(invalidResponse) unless the wallet's
// signature verifies against `account.publicKey`.
final signed = await signer.modifyAndSignTransactions([transaction]);
```

Transaction modification itself remains permitted, as the `TransactionModifyingSigner` contract documents — but any modification must come with a genuine signature by the authorized account over the modified bytes.
