import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/lifetime.dart';

/// Transaction version type.
enum TransactionVersion {
  /// A legacy (unversioned) transaction.
  legacy,

  /// A version 0 transaction.
  v0,

  /// A version 1 transaction.
  v1;

  /// The numeric value for versioned messages.
  /// Legacy has no numeric version.
  int? get versionNumber => switch (this) {
    legacy => null,
    v0 => 0,
    v1 => 1,
  };
}

/// The maximum supported transaction version.
const maxSupportedTransactionVersion = 1;

/// Transaction-message v1 resource and prioritization configuration.
class V1TransactionConfig {
  /// Creates a v1 transaction configuration.
  const V1TransactionConfig({
    this.computeUnitLimit,
    this.heapSize,
    this.loadedAccountsDataSizeLimit,
    this.priorityFeeLamports,
  });

  /// Maximum number of compute units the transaction may consume.
  final int? computeUnitLimit;

  /// Requested heap frame size in bytes.
  final int? heapSize;

  /// Maximum size in bytes for loaded account data.
  final int? loadedAccountsDataSizeLimit;

  /// Total priority fee in lamports.
  final BigInt? priorityFeeLamports;

  /// Whether this config has no defined values.
  bool get isEmpty =>
      computeUnitLimit == null &&
      heapSize == null &&
      loadedAccountsDataSizeLimit == null &&
      priorityFeeLamports == null;

  /// Creates a copy with selected fields replaced.
  V1TransactionConfig copyWith({
    int? computeUnitLimit,
    bool clearComputeUnitLimit = false,
    int? heapSize,
    bool clearHeapSize = false,
    int? loadedAccountsDataSizeLimit,
    bool clearLoadedAccountsDataSizeLimit = false,
    BigInt? priorityFeeLamports,
    bool clearPriorityFeeLamports = false,
  }) {
    return V1TransactionConfig(
      computeUnitLimit: clearComputeUnitLimit
          ? null
          : (computeUnitLimit ?? this.computeUnitLimit),
      heapSize: clearHeapSize ? null : (heapSize ?? this.heapSize),
      loadedAccountsDataSizeLimit: clearLoadedAccountsDataSizeLimit
          ? null
          : (loadedAccountsDataSizeLimit ?? this.loadedAccountsDataSizeLimit),
      priorityFeeLamports: clearPriorityFeeLamports
          ? null
          : (priorityFeeLamports ?? this.priorityFeeLamports),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is V1TransactionConfig &&
          computeUnitLimit == other.computeUnitLimit &&
          heapSize == other.heapSize &&
          loadedAccountsDataSizeLimit == other.loadedAccountsDataSizeLimit &&
          priorityFeeLamports == other.priorityFeeLamports;

  @override
  int get hashCode => Object.hash(
    computeUnitLimit,
    heapSize,
    loadedAccountsDataSizeLimit,
    priorityFeeLamports,
  );
}

/// A transaction message that can be built step by step.
///
/// All transform functions return new instances (immutable pattern).
class TransactionMessage {
  /// Creates a [TransactionMessage] with the given parameters.
  const TransactionMessage({
    required this.version,
    this.instructions = const [],
    this.feePayer,
    this.lifetimeConstraint,
    this.config,
  });

  /// The version of this transaction message.
  final TransactionVersion version;

  /// The instructions in this transaction message.
  final List<Instruction> instructions;

  /// The fee payer address for this transaction message.
  final Address? feePayer;

  /// The lifetime constraint for this transaction message.
  final LifetimeConstraint? lifetimeConstraint;

  /// Transaction-message v1 resource and prioritization configuration.
  final V1TransactionConfig? config;

  /// Creates a copy of this [TransactionMessage] with the given fields
  /// replaced.
  TransactionMessage copyWith({
    TransactionVersion? version,
    List<Instruction>? instructions,
    Address? feePayer,
    bool clearFeePayer = false,
    LifetimeConstraint? lifetimeConstraint,
    bool clearLifetimeConstraint = false,
    V1TransactionConfig? config,
    bool clearConfig = false,
  }) => TransactionMessage(
    version: version ?? this.version,
    instructions: instructions != null
        ? List<Instruction>.unmodifiable(instructions)
        : this.instructions,
    feePayer: clearFeePayer ? null : (feePayer ?? this.feePayer),
    lifetimeConstraint: clearLifetimeConstraint
        ? null
        : (lifetimeConstraint ?? this.lifetimeConstraint),
    config: clearConfig ? null : (config ?? this.config),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionMessage &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          _listEquals(instructions, other.instructions) &&
          feePayer == other.feePayer &&
          lifetimeConstraint == other.lifetimeConstraint &&
          config == other.config;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    Object.hashAll(instructions),
    feePayer,
    lifetimeConstraint,
    config,
  );

  @override
  String toString() =>
      'TransactionMessage(version: $version, instructions: $instructions, '
      'feePayer: $feePayer, lifetimeConstraint: $lifetimeConstraint, config: $config)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
