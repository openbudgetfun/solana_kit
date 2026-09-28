---
"solana_kit_transaction_confirmation": minor
"solana_kit_rpc_subscriptions_api": minor
---

# Ignore received-notifications in signature confirmation

The recent-signature confirmation strategy can no longer be tricked into treating a received-notification as confirmation. Subscribing with `enableReceivedNotification: true` (`SignatureNotificationsConfig`) makes the RPC report the moment a node receives the signature, before the transaction executes; the strategy previously treated any notification without an `err` as success, so that wiring would resolve confirmation on receipt — the transaction could still fail on-chain while the caller believed it had landed.

The `onSignatureNotification` callback in `RecentSignatureConfirmationConfig` now reports the notification kind through a required `received` flag, and the strategy ignores receipts unconditionally: only a processed-status notification resolves or fails the confirmation.

```dart
onSignatureNotification: (
  signature, {
  required abortSignal,
  required commitment,
  required onNotification,
}) {
  // `received` distinguishes a receipt from a processed status; the
  // strategy ignores receipts either way.
  return signatureNotifications(
    signature,
    SignatureNotificationsConfig(
      commitment: commitment,
      enableReceivedNotification: true,
    ),
  ).subscribe(/* report received accordingly */);
},
```

Callers that never enable received-notifications only need to pass `received: false`.
