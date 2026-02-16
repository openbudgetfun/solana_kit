---
solana_kit_rpc_subscriptions_api: minor
---

Implement RPC subscriptions API package ported from `@solana/rpc-subscriptions-api`.

**solana_kit_rpc_subscriptions_api** (61 tests):

- 6 stable subscription methods: `accountNotifications`, `logsNotifications`, `programNotifications`, `rootNotifications`, `signatureNotifications`, `slotNotifications`
- 3 unstable subscription methods: `blockNotifications`, `slotsUpdatesNotifications`, `voteNotifications`
- Sealed `LogsFilter` type (All/AllWithVotes/Mentions) with JSON serialization
- Sealed `BlockNotificationsFilter` type (All/MentionsAccountOrProgram)
- `solanaRpcSubscriptionsMethodsStable` and `solanaRpcSubscriptionsMethodsUnstable` composition
- Helper functions: `notificationNameToSubscribeMethod()`, `notificationNameToUnsubscribeMethod()`
- Config types for each subscription with proper encoding commitment/maxSupportedTransactionVersion
