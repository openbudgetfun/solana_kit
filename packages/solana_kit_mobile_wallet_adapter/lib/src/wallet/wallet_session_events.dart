/// Types of MWA session lifecycle events.
enum MwaSessionEventType {
  /// The scenario has been created and is ready.
  ready,

  /// The scenario is actively serving dApp clients.
  servingClients,

  /// The scenario has finished serving clients.
  servingComplete,

  /// The scenario has completed normally.
  complete,

  /// The scenario encountered an error.
  error,

  /// The scenario has finished teardown.
  teardownComplete,

  /// The device is in low-power mode and no connection has been received.
  lowPowerNoConnection,
}

/// A session lifecycle event from the MWA scenario.
class MwaSessionEvent {
  const MwaSessionEvent({
    required this.type,
    required this.sessionId,
    this.error,
  });

  /// The type of session event.
  final MwaSessionEventType type;

  /// The session identifier.
  final String sessionId;

  /// Error information, if [type] is [MwaSessionEventType.error].
  final Object? error;
}
