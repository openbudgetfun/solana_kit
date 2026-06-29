/// A pair of broadcast streams carrying subscription notifications and errors.
class NotificationStreams {
  /// Creates a [NotificationStreams] from its [notifications] and [errors] streams.
  const NotificationStreams({
    required this.notifications,
    required this.errors,
  });

  /// The stream of subscription notifications.
  final Stream<Object?> notifications;

  /// The stream of errors emitted by the subscription.
  final Stream<Object?> errors;
}
