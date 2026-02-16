/// The set of all stable Solana RPC subscription method names.
///
/// These 6 methods are available on all clusters and considered stable:
/// - `accountSubscribe` / `accountUnsubscribe`
/// - `logsSubscribe` / `logsUnsubscribe`
/// - `programSubscribe` / `programUnsubscribe`
/// - `rootSubscribe` / `rootUnsubscribe`
/// - `signatureSubscribe` / `signatureUnsubscribe`
/// - `slotSubscribe` / `slotUnsubscribe`
const List<String> solanaRpcSubscriptionsMethodsStable = [
  'accountSubscribe',
  'logsSubscribe',
  'programSubscribe',
  'rootSubscribe',
  'signatureSubscribe',
  'slotSubscribe',
];

/// The set of all Solana RPC subscription method names, including unstable
/// methods.
///
/// This includes all 6 stable methods plus 3 unstable methods:
/// - `blockSubscribe` / `blockUnsubscribe` (unstable)
/// - `slotsUpdatesSubscribe` / `slotsUpdatesUnsubscribe` (unstable)
/// - `voteSubscribe` / `voteUnsubscribe` (unstable)
const List<String> solanaRpcSubscriptionsMethodsUnstable = [
  ...solanaRpcSubscriptionsMethodsStable,
  'blockSubscribe',
  'slotsUpdatesSubscribe',
  'voteSubscribe',
];

/// The set of all stable Solana RPC subscription notification names.
///
/// These are the method names used on the client side, which get transformed
/// to `{name}Subscribe` / `{name}Unsubscribe` for the JSON-RPC call.
const List<String> solanaRpcSubscriptionsNotificationsStable = [
  'accountNotifications',
  'logsNotifications',
  'programNotifications',
  'rootNotifications',
  'signatureNotifications',
  'slotNotifications',
];

/// The set of all Solana RPC subscription notification names, including
/// unstable ones.
const List<String> solanaRpcSubscriptionsNotificationsUnstable = [
  ...solanaRpcSubscriptionsNotificationsStable,
  'blockNotifications',
  'slotsUpdatesNotifications',
  'voteNotifications',
];

/// Returns `true` if [methodName] is a stable Solana RPC subscription method.
bool isSolanaRpcSubscriptionMethodStable(String methodName) {
  return solanaRpcSubscriptionsMethodsStable.contains(methodName);
}

/// Returns `true` if [methodName] is a Solana RPC subscription method
/// (stable or unstable).
bool isSolanaRpcSubscriptionMethod(String methodName) {
  return solanaRpcSubscriptionsMethodsUnstable.contains(methodName);
}

/// Transforms a notification name to its corresponding subscribe method name.
///
/// For example, `'accountNotifications'` becomes `'accountSubscribe'`.
String notificationNameToSubscribeMethod(String notificationName) {
  return notificationName.replaceAll(RegExp(r'Notifications$'), 'Subscribe');
}

/// Transforms a notification name to its corresponding unsubscribe method
/// name.
///
/// For example, `'accountNotifications'` becomes `'accountUnsubscribe'`.
String notificationNameToUnsubscribeMethod(String notificationName) {
  return notificationName.replaceAll(RegExp(r'Notifications$'), 'Unsubscribe');
}
