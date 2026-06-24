import 'dart:collection';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// A SOL funding instruction for funding many accounts.
@immutable
class SolAccountFunding {
  /// Creates an account funding request.
  const SolAccountFunding({required this.address, required this.lamports});

  /// Address whose lamport balance should be set.
  final Address address;

  /// Lamports to assign to [address].
  final int lamports;
}

/// Information about a generated or configured keypair.
@immutable
class KeypairInfo {
  /// Creates keypair information from a public key and 64-byte secret key.
  KeypairInfo({required this.publicKey, required Uint8List secretKey})
    : _secretKey = Uint8List.fromList(secretKey) {
    if (secretKey.length != 64) {
      throw ArgumentError.value(
        secretKey.length,
        'secretKey.length',
        'must be 64 bytes',
      );
    }
  }

  /// Public key for the keypair.
  final Address publicKey;

  /// Alias for [publicKey] used by APIs that talk about account addresses.
  Address get address => publicKey;

  /// 64-byte Solana CLI-compatible secret key.
  Uint8List get secretKey => Uint8List.fromList(_secretKey);

  final Uint8List _secretKey;
}

/// Advanced token-account fields accepted by `surfnet_setTokenAccount`.
@immutable
class SetTokenAccountUpdate {
  /// Creates a token account update.
  const SetTokenAccountUpdate({
    this.amount,
    this.delegate,
    this.clearDelegate = false,
    this.state,
    this.delegatedAmount,
    this.closeAuthority,
    this.clearCloseAuthority = false,
  });

  /// Token amount to set.
  final int? amount;

  /// Delegate address to set.
  final Address? delegate;

  /// Whether to clear the delegate.
  ///
  /// Surfpool currently expects the literal string `'null'` for clear
  /// operations, matching the upstream Rust SDK behavior.
  final bool clearDelegate;

  /// Token account state string, for example `initialized`.
  final String? state;

  /// Delegated token amount to set.
  final int? delegatedAmount;

  /// Close authority address to set.
  final Address? closeAuthority;

  /// Whether to clear the close authority.
  ///
  /// Surfpool currently expects the literal string `'null'` for clear
  /// operations, matching the upstream Rust SDK behavior.
  final bool clearCloseAuthority;

  /// Encodes this update as JSON-RPC parameters.
  Map<String, Object?> toJson() {
    _assertNonNegative(amount, 'amount');
    _assertNonNegative(delegatedAmount, 'delegatedAmount');

    if (delegate != null && clearDelegate) {
      throw ArgumentError('delegate and clearDelegate are mutually exclusive');
    }
    if (closeAuthority != null && clearCloseAuthority) {
      throw ArgumentError(
        'closeAuthority and clearCloseAuthority are mutually exclusive',
      );
    }

    return <String, Object?>{
      if (amount != null) 'amount': amount,
      if (delegate != null) 'delegate': delegate!.value,
      if (clearDelegate) 'delegate': 'null',
      if (state != null) 'state': state,
      if (delegatedAmount != null) 'delegatedAmount': delegatedAmount,
      if (closeAuthority != null) 'closeAuthority': closeAuthority!.value,
      if (clearCloseAuthority) 'closeAuthority': 'null',
    };
  }
}

/// Options for `surfnet_resetAccount`.
@immutable
class ResetAccountOptions {
  /// Creates reset options.
  const ResetAccountOptions({this.includeOwnedAccounts});

  /// Whether to reset accounts owned by the target account as well.
  final bool? includeOwnedAccounts;

  /// Encodes these options as JSON-RPC parameters.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (includeOwnedAccounts != null)
        'includeOwnedAccounts': includeOwnedAccounts,
    };
  }
}

/// Options for `surfnet_streamAccount`.
@immutable
class StreamAccountOptions {
  /// Creates stream options.
  const StreamAccountOptions({this.includeOwnedAccounts});

  /// Whether to stream accounts owned by the target account as well.
  final bool? includeOwnedAccounts;

  /// Encodes these options as JSON-RPC parameters.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (includeOwnedAccounts != null)
        'includeOwnedAccounts': includeOwnedAccounts,
    };
  }
}

/// Deployment configuration for `surfnet_writeProgram`.
@immutable
class DeployOptions {
  /// Creates deployment options for a known [programId].
  DeployOptions({
    required this.programId,
    this.soPath,
    Uint8List? soBytes,
    this.idlPath,
  }) : _soBytes = soBytes == null ? null : Uint8List.fromList(soBytes) {
    if ((soPath == null) == (soBytes == null)) {
      throw ArgumentError('Provide exactly one of soPath or soBytes');
    }
  }

  /// Program address where the bytecode will be registered.
  final Address programId;

  /// Path to a compiled `.so` artifact.
  final String? soPath;

  /// Raw compiled program bytes.
  Uint8List? get soBytes {
    final soBytes = _soBytes;
    if (soBytes == null) return null;
    return Uint8List.fromList(soBytes);
  }

  final Uint8List? _soBytes;

  /// Optional Anchor IDL JSON file to register after deployment.
  final String? idlPath;
}

/// Epoch information returned by Surfpool time travel methods.
@immutable
class EpochInfoValue {
  /// Creates epoch information.
  const EpochInfoValue({
    required this.absoluteSlot,
    required this.slotIndex,
    required this.slotsInEpoch,
    required this.epoch,
    required this.blockHeight,
    this.transactionCount,
  });

  /// Creates epoch information from JSON.
  factory EpochInfoValue.fromJson(Object? json) {
    final map = _expectMap(json, 'EpochInfoValue');
    return EpochInfoValue(
      absoluteSlot: _expectInt(map['absoluteSlot'], 'absoluteSlot'),
      slotIndex: _expectInt(map['slotIndex'], 'slotIndex'),
      slotsInEpoch: _expectInt(map['slotsInEpoch'], 'slotsInEpoch'),
      epoch: _expectInt(map['epoch'], 'epoch'),
      blockHeight: _expectInt(map['blockHeight'], 'blockHeight'),
      transactionCount: _optionalInt(
        map['transactionCount'],
        'transactionCount',
      ),
    );
  }

  /// Absolute slot number.
  final int absoluteSlot;

  /// Slot index within the current epoch.
  final int slotIndex;

  /// Number of slots in the current epoch.
  final int slotsInEpoch;

  /// Epoch number.
  final int epoch;

  /// Block height.
  final int blockHeight;

  /// Optional transaction count.
  final int? transactionCount;

  /// Encodes this value as JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'absoluteSlot': absoluteSlot,
      'slotIndex': slotIndex,
      'slotsInEpoch': slotsInEpoch,
      'epoch': epoch,
      'blockHeight': blockHeight,
      if (transactionCount != null) 'transactionCount': transactionCount,
    };
  }
}

/// Clock value attached to Surfpool runtime events.
@immutable
class ClockValue {
  /// Creates a clock value.
  const ClockValue({
    this.slot,
    this.epochStartTimestamp,
    this.epoch,
    this.leaderScheduleEpoch,
    this.unixTimestamp,
  });

  /// Creates a clock value from JSON.
  factory ClockValue.fromJson(Object? json) {
    final map = _expectMap(json, 'ClockValue');
    return ClockValue(
      slot: _optionalInt(map['slot'], 'slot'),
      epochStartTimestamp: _optionalInt(
        map['epochStartTimestamp'],
        'epochStartTimestamp',
      ),
      epoch: _optionalInt(map['epoch'], 'epoch'),
      leaderScheduleEpoch: _optionalInt(
        map['leaderScheduleEpoch'],
        'leaderScheduleEpoch',
      ),
      unixTimestamp: _optionalInt(map['unixTimestamp'], 'unixTimestamp'),
    );
  }

  /// Current slot.
  final int? slot;

  /// Epoch start timestamp.
  final int? epochStartTimestamp;

  /// Current epoch.
  final int? epoch;

  /// Leader schedule epoch.
  final int? leaderScheduleEpoch;

  /// Unix timestamp.
  final int? unixTimestamp;

  /// Encodes this value as JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (slot != null) 'slot': slot,
      if (epochStartTimestamp != null)
        'epochStartTimestamp': epochStartTimestamp,
      if (epoch != null) 'epoch': epoch,
      if (leaderScheduleEpoch != null)
        'leaderScheduleEpoch': leaderScheduleEpoch,
      if (unixTimestamp != null) 'unixTimestamp': unixTimestamp,
    };
  }
}

/// Flat runtime event value used by the upstream JS SDK.
@immutable
class SimnetEventValue {
  /// Creates a runtime event value.
  SimnetEventValue({
    required this.kind,
    this.message,
    this.timestamp,
    this.initialTransactionCount,
    this.clock,
    this.epochInfo,
    this.clockCommand,
    this.slotIntervalMs,
    this.accountPubkey,
    this.transactionSignature,
    Iterable<String>? logs,
    this.computeUnitsConsumed,
    this.fee,
    this.errorMessage,
    this.tag,
    this.profileKey,
    this.profileSlot,
    this.runbookId,
    Iterable<String>? runbookErrors,
  }) : _logs = logs == null ? null : List<String>.unmodifiable(logs),
       _runbookErrors = runbookErrors == null
           ? null
           : List<String>.unmodifiable(runbookErrors);

  /// Creates a runtime event value from JSON.
  factory SimnetEventValue.fromJson(Object? json) {
    final map = _expectMap(json, 'SimnetEventValue');
    return SimnetEventValue(
      kind: _expectString(map['kind'], 'kind'),
      message: _optionalString(map['message'], 'message'),
      timestamp: _optionalString(map['timestamp'], 'timestamp'),
      initialTransactionCount: _optionalInt(
        map['initialTransactionCount'],
        'initialTransactionCount',
      ),
      clock: map['clock'] == null ? null : ClockValue.fromJson(map['clock']),
      epochInfo: map['epochInfo'] == null
          ? null
          : EpochInfoValue.fromJson(map['epochInfo']),
      clockCommand: _optionalString(map['clockCommand'], 'clockCommand'),
      slotIntervalMs: _optionalInt(map['slotIntervalMs'], 'slotIntervalMs'),
      accountPubkey: _optionalString(map['accountPubkey'], 'accountPubkey'),
      transactionSignature: _optionalString(
        map['transactionSignature'],
        'transactionSignature',
      ),
      logs: _optionalStringList(map['logs'], 'logs'),
      computeUnitsConsumed: _optionalInt(
        map['computeUnitsConsumed'],
        'computeUnitsConsumed',
      ),
      fee: _optionalInt(map['fee'], 'fee'),
      errorMessage: _optionalString(map['errorMessage'], 'errorMessage'),
      tag: _optionalString(map['tag'], 'tag'),
      profileKey: _optionalString(map['profileKey'], 'profileKey'),
      profileSlot: _optionalInt(map['profileSlot'], 'profileSlot'),
      runbookId: _optionalString(map['runbookId'], 'runbookId'),
      runbookErrors: _optionalStringList(map['runbookErrors'], 'runbookErrors'),
    );
  }

  /// Event discriminator.
  final String kind;

  /// Human-readable message, when present.
  final String? message;

  /// Event timestamp, when present.
  final String? timestamp;

  /// Initial transaction count on runtime startup.
  final int? initialTransactionCount;

  /// Clock payload for clock events.
  final ClockValue? clock;

  /// Epoch information payload.
  final EpochInfoValue? epochInfo;

  /// Clock command name.
  final String? clockCommand;

  /// Slot interval in milliseconds.
  final int? slotIntervalMs;

  /// Account public key for account update events.
  final String? accountPubkey;

  /// Transaction signature for transaction events.
  final String? transactionSignature;

  /// Logs attached to transaction or profile events.
  UnmodifiableListView<String>? get logs {
    final logs = _logs;
    if (logs == null) return null;
    return UnmodifiableListView(logs);
  }

  final List<String>? _logs;

  /// Compute units consumed.
  final int? computeUnitsConsumed;

  /// Transaction fee.
  final int? fee;

  /// Error message for failed transaction or runtime error events.
  final String? errorMessage;

  /// Profile tag.
  final String? tag;

  /// Profile key.
  final String? profileKey;

  /// Profile slot.
  final int? profileSlot;

  /// Runbook id.
  final String? runbookId;

  /// Runbook errors.
  UnmodifiableListView<String>? get runbookErrors {
    final runbookErrors = _runbookErrors;
    if (runbookErrors == null) return null;
    return UnmodifiableListView(runbookErrors);
  }

  final List<String>? _runbookErrors;

  /// Encodes this event as JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'kind': kind,
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
      if (initialTransactionCount != null)
        'initialTransactionCount': initialTransactionCount,
      if (clock != null) 'clock': clock!.toJson(),
      if (epochInfo != null) 'epochInfo': epochInfo!.toJson(),
      if (clockCommand != null) 'clockCommand': clockCommand,
      if (slotIntervalMs != null) 'slotIntervalMs': slotIntervalMs,
      if (accountPubkey != null) 'accountPubkey': accountPubkey,
      if (transactionSignature != null)
        'transactionSignature': transactionSignature,
      if (_logs != null) 'logs': _logs,
      if (computeUnitsConsumed != null)
        'computeUnitsConsumed': computeUnitsConsumed,
      if (fee != null) 'fee': fee,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (tag != null) 'tag': tag,
      if (profileKey != null) 'profileKey': profileKey,
      if (profileSlot != null) 'profileSlot': profileSlot,
      if (runbookId != null) 'runbookId': runbookId,
      if (_runbookErrors != null) 'runbookErrors': _runbookErrors,
    };
  }
}

void _assertNonNegative(int? value, String name) {
  if (value == null) return;
  if (value < 0) {
    throw ArgumentError.value(value, name, 'must be non-negative');
  }
}

Map<String, Object?> _expectMap(Object? value, String name) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  throw FormatException('$name must be a JSON object', value);
}

String _expectString(Object? value, String name) {
  if (value is String) return value;
  throw FormatException('$name must be a string', value);
}

String? _optionalString(Object? value, String name) {
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('$name must be a string', value);
}

int _expectInt(Object? value, String name) {
  if (value is int) return value;
  throw FormatException('$name must be an integer', value);
}

int? _optionalInt(Object? value, String name) {
  if (value == null) return null;
  if (value is int) return value;
  throw FormatException('$name must be an integer', value);
}

List<String>? _optionalStringList(Object? value, String name) {
  if (value == null) return null;
  if (value is List) {
    return [for (final item in value) _expectString(item, name)];
  }
  throw FormatException('$name must be a list of strings', value);
}
