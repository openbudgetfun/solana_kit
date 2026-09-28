---
"solana_kit_wallet_adapter": minor
---

# Verify wallet-returned signatures before accepting them

`MobileWallet` now cryptographically verifies every signature a wallet returns before handing it to the caller. Message signatures, signed transactions, and sign-and-send submission signatures are all checked against the authorized account's Ed25519 public key, and a signed transaction must carry the exact message bytes that were submitted — a wallet that returns a different transaction, a signature for a different transaction, or a well-formed forgery is rejected with `WalletStandardErrorCode.invalidResponse`.

A Sign In With Solana proof must now verify against the account it is attached to, and the MWA spec's rule that the returned sign-in address must belong to one of the authorized accounts is enforced: a proof attributed to an account that never signed in is rejected instead of silently falling back to the first authorized account, and non-`ed25519` signature types are rejected rather than passed through.

```dart
// A wallet that returns this can no longer impersonate the account:
final outputs = await mobileWallet
    .feature<SolanaSignMessageFeature>(SolanaFeatureId.signMessage)!
    .signMessage([SolanaSignMessageInput(account: account, message: data)]);
// Throws WalletStandardException(invalidResponse) unless `signature`
// verifies against `account.publicKey` over `data`.
```

The checks mirror the validate-before-trust pattern this workspace already applies in the dApp publisher CLI, which verifies portal-supplied transaction signatures before signing. Backends that return genuine signatures are unaffected.
