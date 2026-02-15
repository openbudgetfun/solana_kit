/// Response from the `getEpochSchedule` RPC method.
class EpochSchedule {
  /// Creates a new [EpochSchedule].
  const EpochSchedule({
    required this.firstNormalEpoch,
    required this.firstNormalSlot,
    required this.leaderScheduleSlotOffset,
    required this.slotsPerEpoch,
    required this.warmup,
  });

  /// First normal-length epoch after the warmup period.
  final BigInt firstNormalEpoch;

  /// The first slot after the warmup period.
  final BigInt firstNormalSlot;

  /// The number of slots before beginning of an epoch to calculate a leader
  /// schedule for that epoch.
  final BigInt leaderScheduleSlotOffset;

  /// The maximum number of slots in each epoch.
  final BigInt slotsPerEpoch;

  /// Whether epochs start short and grow.
  final bool warmup;
}

/// Builds the JSON-RPC params list for `getEpochSchedule`.
List<Object?> getEpochScheduleParams() {
  return [];
}
