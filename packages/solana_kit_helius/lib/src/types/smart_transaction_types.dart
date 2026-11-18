import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// Input for creating a smart transaction.
class CreateSmartTransactionInput {
  /// Creates input for a smart transaction.
  const CreateSmartTransactionInput({
    required this.instructions,
    this.signers,
    this.feePayer,
    this.computeUnitLimit,
    this.computeUnitPrice,
    this.lookupTableAddresses,
  });

  /// Creates a [CreateSmartTransactionInput] from a JSON map.
  factory CreateSmartTransactionInput.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CreateSmartTransactionInput(
      instructions: r.requireList<Object?>('instructions'),
      signers: r.optList<String>('signers'),
      feePayer: r.optString('feePayer'),
      computeUnitLimit: r.optInt('computeUnitLimit'),
      computeUnitPrice: r.optInt('computeUnitPrice'),
      lookupTableAddresses: r.optString('lookupTableAddresses'),
    );
  }

  /// Instructions included in the transaction.
  final List<Object?> instructions;

  /// Signers for the transaction.
  ///
  /// The port carries signer addresses only (no private keys), so signing is
  /// left to the caller. Every address here that an instruction also
  /// references is promoted to a required signer in the built transaction.
  final List<String>? signers;

  /// Public key of the fee payer.
  final String? feePayer;

  /// Compute unit limit for the transaction.
  final int? computeUnitLimit;

  /// Compute unit price (priority fee) for the transaction.
  final int? computeUnitPrice;

  /// Address lookup table addresses used by the transaction.
  final String? lookupTableAddresses;

  /// Serializes this input to a JSON map.
  Map<String, Object?> toJson() => {
    'instructions': instructions,
    if (signers != null) 'signers': signers,
    if (feePayer != null) 'feePayer': feePayer,
    if (computeUnitLimit != null) 'computeUnitLimit': computeUnitLimit,
    if (computeUnitPrice != null) 'computeUnitPrice': computeUnitPrice,
    if (lookupTableAddresses != null)
      'lookupTableAddresses': lookupTableAddresses,
  };
}

/// Result of a smart transaction submission.
class SmartTransactionResult {
  /// Creates a smart transaction result.
  const SmartTransactionResult({
    required this.signature,
    this.confirmationStatus,
  });

  /// Creates a [SmartTransactionResult] from a JSON map.
  factory SmartTransactionResult.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return SmartTransactionResult(
      signature: r.requireString('signature'),
      confirmationStatus: r.optString('confirmationStatus'),
    );
  }

  /// Transaction signature.
  final String signature;

  /// Confirmation status of the transaction, when reported.
  final String? confirmationStatus;

  /// Serializes this result to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    if (confirmationStatus != null) 'confirmationStatus': confirmationStatus,
  };
}

/// Input for sending a smart transaction.
class SendSmartTransactionInput {
  /// Creates input for sending a smart transaction.
  const SendSmartTransactionInput({
    required this.instructions,
    this.signers,
    this.feePayer,
    this.computeUnitPrice,
    this.skipPreflight,
    this.maxRetries,
  });

  /// Creates a [SendSmartTransactionInput] from a JSON map.
  factory SendSmartTransactionInput.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return SendSmartTransactionInput(
      instructions: r.requireList<Object?>('instructions'),
      signers: r.optList<String>('signers'),
      feePayer: r.optString('feePayer'),
      computeUnitPrice: r.optInt('computeUnitPrice'),
      skipPreflight: r.optBool('skipPreflight'),
      maxRetries: r.optInt('maxRetries'),
    );
  }

  /// Instructions included in the transaction.
  final List<Object?> instructions;

  /// Signers for the transaction.
  final List<String>? signers;

  /// Public key of the fee payer.
  final String? feePayer;

  /// Compute unit price (priority fee) for the transaction.
  final int? computeUnitPrice;

  /// Whether to skip preflight simulation.
  final bool? skipPreflight;

  /// Maximum number of retries for the transaction.
  final int? maxRetries;

  /// Serializes this input to a JSON map.
  Map<String, Object?> toJson() => {
    'instructions': instructions,
    if (signers != null) 'signers': signers,
    if (feePayer != null) 'feePayer': feePayer,
    if (computeUnitPrice != null) 'computeUnitPrice': computeUnitPrice,
    if (skipPreflight != null) 'skipPreflight': skipPreflight,
    if (maxRetries != null) 'maxRetries': maxRetries,
  };
}

/// Request to broadcast a transaction.
class BroadcastTransactionRequest {
  /// Creates a broadcast transaction request.
  const BroadcastTransactionRequest({required this.transaction});

  /// Creates a [BroadcastTransactionRequest] from a JSON map.
  factory BroadcastTransactionRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return BroadcastTransactionRequest(
      transaction: r.requireString('transaction'),
    );
  }

  /// Serialized transaction to broadcast.
  final String transaction;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'transaction': transaction};
}

/// Options for tracking a broadcast transaction to confirmation.
class BroadcastTransactionOptions {
  /// Creates broadcast options.
  const BroadcastTransactionOptions({
    this.lastValidBlockHeightOffset = 150,
    this.pollTimeoutMs = 60000,
    this.pollIntervalMs = 2000,
    this.skipPreflight = true,
    this.commitment = CommitmentLevel.confirmed,
    this.maxRetries = 0,
  });

  /// How far past the current chain height the transaction may land.
  ///
  /// The effective expiry is the earlier of the blockhash's
  /// `lastValidBlockHeight` and `chainHeight + lastValidBlockHeightOffset`.
  final int lastValidBlockHeightOffset;

  /// Overall polling timeout in milliseconds.
  final int pollTimeoutMs;

  /// Polling cadence in milliseconds.
  final int pollIntervalMs;

  /// Whether to skip preflight simulation when submitting.
  final bool skipPreflight;

  /// Commitment level used for submission and blockhash reads.
  final CommitmentLevel commitment;

  /// Maximum number of retries the sender should perform.
  final int maxRetries;
}

/// Request to poll for transaction confirmation.
class PollTransactionConfirmationRequest {
  /// Creates a poll-confirmation request.
  const PollTransactionConfirmationRequest({
    required this.signature,
    this.timeoutMs,
    this.intervalMs,
    this.commitment,
  });

  /// Creates a [PollTransactionConfirmationRequest] from a JSON map.
  factory PollTransactionConfirmationRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return PollTransactionConfirmationRequest(
      signature: r.requireString('signature'),
      timeoutMs: r.optInt('timeoutMs'),
      intervalMs: r.optInt('intervalMs'),
      commitment: r.optEnum('commitment', CommitmentLevel.fromJson),
    );
  }

  /// Transaction signature to poll for confirmation.
  final String signature;

  /// Maximum time to wait for confirmation, in milliseconds.
  final int? timeoutMs;

  /// Interval between polls, in milliseconds.
  final int? intervalMs;

  /// Commitment level required for confirmation.
  final CommitmentLevel? commitment;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    if (timeoutMs != null) 'timeoutMs': timeoutMs,
    if (intervalMs != null) 'intervalMs': intervalMs,
    if (commitment != null) 'commitment': commitment!.toJson(),
  };
}

/// An estimate of compute units for a transaction.
class ComputeUnitsEstimate {
  /// Creates a compute units estimate.
  const ComputeUnitsEstimate({required this.units});

  /// Creates a [ComputeUnitsEstimate] from a JSON map.
  factory ComputeUnitsEstimate.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);

    return ComputeUnitsEstimate(units: r.requireInt('units'));
  }

  /// Estimated number of compute units.
  final int units;

  /// Serializes this estimate to a JSON map.
  Map<String, Object?> toJson() => {'units': units};
}
