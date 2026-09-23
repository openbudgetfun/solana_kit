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
    this.confidential,
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

  /// Configures the Token-2022 confidential-transfer extension on the account.
  ///
  /// Only Token-2022 accounts support this.
  final ConfidentialTransferAccountUpdate? confidential;

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

    final confidential = this.confidential;
    return <String, Object?>{
      if (amount != null) 'amount': amount,

      if (delegate != null) 'delegate': delegate!.value,

      if (clearDelegate) 'delegate': 'null',

      if (state != null) 'state': state,

      if (delegatedAmount != null) 'delegatedAmount': delegatedAmount,

      if (closeAuthority != null) 'closeAuthority': closeAuthority!.value,

      if (clearCloseAuthority) 'closeAuthority': 'null',

      if (confidential != null) 'confidential': confidential.toJson(),
    };
  }
}

/// Configures the Token-2022 `ConfidentialTransferAccount` extension on a
/// token account set through `surfnet_setTokenAccount`.
///
/// This is a test-only cheatcode: it fabricates a configured (and optionally
/// funded) confidential account directly, bypassing the real on-chain
/// configure / deposit / apply-pending-balance instruction flow.
@immutable
class ConfidentialTransferAccountUpdate {
  /// Creates a confidential-transfer account update.
  const ConfidentialTransferAccountUpdate({
    required this.elgamalPubkey,
    required this.aesKey,
    this.amount,
    this.approved,
    this.allowConfidentialCredits,
    this.allowNonConfidentialCredits,
    this.maximumPendingBalanceCreditCounter,
  });

  /// The owner's ElGamal public key, base58 or base64 encoded (32 bytes).
  ///
  /// The confidential balance is encrypted to this key, and confidential
  /// payment clients read it off the account to encrypt transfers.
  final String elgamalPubkey;

  /// The owner's AES secret key, base58 or base64 encoded (16 bytes).
  ///
  /// Produces the `decryptable_available_balance` the owner reads to learn its
  /// balance. Even a zero-balance receive-only account needs a valid encrypted
  /// zero here, so this is required for every confidential account.
  final String aesKey;

  /// Confidential available balance to set. Defaults to `0` upstream.
  final int? amount;

  /// Whether the account is approved for confidential transfers.
  ///
  /// Defaults to `true` upstream.
  final bool? approved;

  /// Whether the account accepts incoming confidential credits.
  ///
  /// Defaults to `true` upstream.
  final bool? allowConfidentialCredits;

  /// Whether the base account accepts incoming non-confidential credits.
  ///
  /// Defaults to `true` upstream.
  final bool? allowNonConfidentialCredits;

  /// Maximum pending-balance credit counter. Defaults to `65536` upstream.
  final int? maximumPendingBalanceCreditCounter;

  /// Encodes this update as JSON-RPC parameters.
  Map<String, Object?> toJson() {
    _assertNonNegative(amount, 'amount');
    _assertNonNegative(
      maximumPendingBalanceCreditCounter,
      'maximumPendingBalanceCreditCounter',
    );

    return <String, Object?>{
      'elgamalPubkey': elgamalPubkey,
      'aesKey': aesKey,

      if (amount != null) 'amount': amount,

      if (approved != null) 'approved': approved,

      if (allowConfidentialCredits != null)
        'allowConfidentialCredits': allowConfidentialCredits,

      if (allowNonConfidentialCredits != null)
        'allowNonConfidentialCredits': allowNonConfidentialCredits,

      if (maximumPendingBalanceCreditCounter != null)
        'maximumPendingBalanceCreditCounter':
            maximumPendingBalanceCreditCounter,
    };
  }
}

/// The owner's confidential-transfer secrets, passed to
/// `surfnet_getConfidentialBalance` so it can decrypt a token account.
///
/// Each key unlocks a different half of the balance, so they are independently
/// optional: a caller holding only one still gets the half it can read. At
/// least one key must be supplied.
@immutable
class ConfidentialBalanceKeys {
  /// Creates confidential balance decryption keys.
  const ConfidentialBalanceKeys({this.aesKey, this.elgamalSecretKey});

  /// The owner's AES key, base58 or base64 encoded (16 bytes).
  ///
  /// Decrypts the available balance.
  final String? aesKey;

  /// The owner's ElGamal *secret* key, base58 or base64 encoded (32 bytes).
  ///
  /// This is not the public key stored on the account. Decrypts the pending
  /// balance.
  final String? elgamalSecretKey;

  /// Encodes these keys as JSON-RPC parameters.
  Map<String, Object?> toJson() {
    if (aesKey == null && elgamalSecretKey == null) {
      throw ArgumentError('Provide at least one of aesKey or elgamalSecretKey');
    }

    return <String, Object?>{
      if (aesKey != null) 'aesKey': aesKey,

      if (elgamalSecretKey != null) 'elgamalSecretKey': elgamalSecretKey,
    };
  }
}

/// The decrypted confidential-transfer balances of a Token-2022 token account,
/// returned by `surfnet_getConfidentialBalance`.
@immutable
class ConfidentialBalance {
  /// Creates a confidential balance value.
  const ConfidentialBalance({
    required this.available,
    required this.pending,
    required this.pendingBalanceCreditCounter,
  });

  /// Creates a confidential balance value from JSON.
  factory ConfidentialBalance.fromJson(Object? json) {
    final map = _expectMap(json, 'ConfidentialBalance');
    return ConfidentialBalance(
      available: _optionalInt(map['available'], 'available'),
      pending: _optionalInt(map['pending'], 'pending'),
      pendingBalanceCreditCounter: _expectInt(
        map['pendingBalanceCreditCounter'],
        'pendingBalanceCreditCounter',
      ),
    );
  }

  /// Available (spendable) balance, or `null` when the request supplied no
  /// [ConfidentialBalanceKeys.aesKey].
  final int? available;

  /// Pending (credited but not yet applied) balance, or `null` when the
  /// request supplied no [ConfidentialBalanceKeys.elgamalSecretKey].
  final int? pending;

  /// How many confidential credits sit in the pending balance.
  ///
  /// A non-zero value means an `ApplyPendingBalance` is required before the
  /// credits appear in [available].
  final int pendingBalanceCreditCounter;

  /// Encodes this value as JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'available': available,
      'pending': pending,
      'pendingBalanceCreditCounter': pendingBalanceCreditCounter,
    };
  }
}

/// The confidential-transfer keys derived for a token account, returned by
/// `surfnet_deriveConfidentialKeys`.
///
/// All three values are base58-encoded and feed directly into the other
/// confidential cheatcodes.
@immutable
class ConfidentialKeys {
  /// Creates derived confidential-transfer keys.
  const ConfidentialKeys({
    required this.elgamalPubkey,
    required this.elgamalSecretKey,
    required this.aesKey,
  });

  /// Creates derived confidential-transfer keys from JSON.
  factory ConfidentialKeys.fromJson(Object? json) {
    final map = _expectMap(json, 'ConfidentialKeys');
    return ConfidentialKeys(
      elgamalPubkey: _expectString(map['elgamalPubkey'], 'elgamalPubkey'),
      elgamalSecretKey: _expectString(
        map['elgamalSecretKey'],
        'elgamalSecretKey',
      ),
      aesKey: _expectString(map['aesKey'], 'aesKey'),
    );
  }

  /// ElGamal public key, for [ConfidentialTransferAccountUpdate.elgamalPubkey].
  final String elgamalPubkey;

  /// ElGamal secret key, for [ConfidentialBalanceKeys.elgamalSecretKey].
  final String elgamalSecretKey;

  /// AES key, for [ConfidentialTransferAccountUpdate.aesKey] and
  /// [ConfidentialBalanceKeys.aesKey].
  final String aesKey;

  /// Encodes this value as JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'elgamalPubkey': elgamalPubkey,
      'elgamalSecretKey': elgamalSecretKey,
      'aesKey': aesKey,
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
