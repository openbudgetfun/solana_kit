/// Builds the JSON-RPC params list for `voteSubscribe`.
///
/// This subscription is unstable and only available if the validator was
/// started with the `--rpc-pubsub-enable-vote-subscription` flag.
///
/// This subscription takes no parameters. The notification value contains
/// the vote hash, signature, slots, timestamp, and vote pubkey.
List<Object?> voteNotificationsParams() {
  return [];
}
