/// Builds the JSON-RPC params list for `slotsUpdatesSubscribe`.
///
/// This subscription is unstable. The format of this subscription may change
/// in the future, and may not be supported by every node.
///
/// This subscription takes no parameters. The notification value is a
/// discriminated union with a `type` field indicating the kind of slot update.
List<Object?> slotsUpdatesNotificationsParams() {
  return [];
}
