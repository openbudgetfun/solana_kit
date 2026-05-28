---
"solana_kit_rpc_subscriptions_api": major
---

# Replace string encodings with typed enums

Replace string encoding fields with typed enums in…

Replace string encoding fields with typed enums in subscription notification config classes.

The `encoding` field on `AccountNotificationsConfig`, `BlockNotificationsConfig`, and `ProgramNotificationsConfig` has been changed from `String?` to `AccountEncoding?` or `TransactionEncoding?` respectively. This is a breaking change: callers that previously passed raw strings like `'base64'` or `'jsonParsed'` must now use the corresponding enum values such as `AccountEncoding.base64` or `AccountEncoding.jsonParsed`.

This aligns the subscriptions API with the same encoding-enum migration applied to the RPC request API, ensuring consistent type safety across both surfaces. The wire format is unchanged — the enums serialize to the same JSON strings — so no server-side compatibility is affected.

Migration example:

```dart
// Before
AccountNotificationsConfig(encoding: 'base64')
// After
AccountNotificationsConfig(encoding: AccountEncoding.base64)
```
