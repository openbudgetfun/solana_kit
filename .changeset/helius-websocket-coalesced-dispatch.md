---
"solana_kit_helius": patch
---

# Fix Helius WebSocket notification routing and leaked subscriptions

`HeliusWebSocket` now delivers every notification to **all** local subscriptions the server mapped it to. Solana RPC servers coalesce identical subscriptions and reuse one server-side subscription id for them, and the dispatcher previously stopped after the first match — so two subscriptions with the same method and params on one client meant the second stream never emitted anything, silently. Both streams now receive every notification for their shared server subscription.

Cancelling a subscription before the server acknowledged it also no longer leaks the server-side subscription: the cancellation is remembered, and the unsubscribe request is sent the moment the late acknowledgement names the server-side subscription id (previously no unsubscribe was ever sent, and the orphaned subscription kept streaming dropped notifications until the socket closed). A subscribe request that fails with an error response releases the pending cancellation instead of holding it.

```dart
final accountA = ws.subscribe('accountSubscribe', [address]);
final accountB = ws.subscribe('accountSubscribe', [address]);
// The server coalesces these onto one subscription id; both streams
// now receive each account notification.
```
