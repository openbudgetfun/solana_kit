import 'package:solana_kit_helius/src/types/enums.dart';

/// Input for creating a smart transaction.
class CreateSmartTransactionInput {
  const CreateSmartTransactionInput({
    required this.instructions,
    this.signers,
    this.feePayer,
    this.computeUnitLimit,
    this.computeUnitPrice,
    this.lookupTableAddresses,
  });

  factory CreateSmartTransactionInput.fromJson(Map<String, Object?> json) {
    return CreateSmartTransactionInput(
      instructions: json['instructions']! as List<Object?>,
      signers: (json['signers'] as List<Object?>?)?.cast<String>(),
      feePayer: json['feePayer'] as String?,
      computeUnitLimit: json['computeUnitLimit'] as int?,
      computeUnitPrice: json['computeUnitPrice'] as int?,
      lookupTableAddresses: json['lookupTableAddresses'] as String?,
    );
  }

  final List<Object?> instructions;
  final List<String>? signers;
  final String? feePayer;
  final int? computeUnitLimit;
  final int? computeUnitPrice;
  final String? lookupTableAddresses;

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
  const SmartTransactionResult({
    required this.signature,
    this.confirmationStatus,
  });

  factory SmartTransactionResult.fromJson(Map<String, Object?> json) {
    return SmartTransactionResult(
      signature: json['signature']! as String,
      confirmationStatus: json['confirmationStatus'] as String?,
    );
  }

  final String signature;
  final String? confirmationStatus;

  Map<String, Object?> toJson() => {
    'signature': signature,
    if (confirmationStatus != null) 'confirmationStatus': confirmationStatus,
  };
}

/// Input for sending a smart transaction.
class SendSmartTransactionInput {
  const SendSmartTransactionInput({
    required this.instructions,
    this.signers,
    this.feePayer,
    this.computeUnitPrice,
    this.skipPreflight,
    this.maxRetries,
  });

  factory SendSmartTransactionInput.fromJson(Map<String, Object?> json) {
    return SendSmartTransactionInput(
      instructions: json['instructions']! as List<Object?>,
      signers: (json['signers'] as List<Object?>?)?.cast<String>(),
      feePayer: json['feePayer'] as String?,
      computeUnitPrice: json['computeUnitPrice'] as int?,
      skipPreflight: json['skipPreflight'] as bool?,
      maxRetries: json['maxRetries'] as int?,
    );
  }

  final List<Object?> instructions;
  final List<String>? signers;
  final String? feePayer;
  final int? computeUnitPrice;
  final bool? skipPreflight;
  final int? maxRetries;

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
  const BroadcastTransactionRequest({required this.transaction});

  factory BroadcastTransactionRequest.fromJson(Map<String, Object?> json) {
    return BroadcastTransactionRequest(
      transaction: json['transaction']! as String,
    );
  }

  final String transaction;

  Map<String, Object?> toJson() => {'transaction': transaction};
}

/// Request to poll for transaction confirmation.
class PollTransactionConfirmationRequest {
  const PollTransactionConfirmationRequest({
    required this.signature,
    this.timeoutMs,
    this.intervalMs,
    this.commitment,
  });

  factory PollTransactionConfirmationRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return PollTransactionConfirmationRequest(
      signature: json['signature']! as String,
      timeoutMs: json['timeoutMs'] as int?,
      intervalMs: json['intervalMs'] as int?,
      commitment: json['commitment'] != null
          ? CommitmentLevel.fromJson(json['commitment']! as String)
          : null,
    );
  }

  final String signature;
  final int? timeoutMs;
  final int? intervalMs;
  final CommitmentLevel? commitment;

  Map<String, Object?> toJson() => {
    'signature': signature,
    if (timeoutMs != null) 'timeoutMs': timeoutMs,
    if (intervalMs != null) 'intervalMs': intervalMs,
    if (commitment != null) 'commitment': commitment!.toJson(),
  };
}

/// An estimate of compute units for a transaction.
class ComputeUnitsEstimate {
  const ComputeUnitsEstimate({required this.units});

  factory ComputeUnitsEstimate.fromJson(Map<String, Object?> json) {
    return ComputeUnitsEstimate(units: json['units']! as int);
  }

  final int units;

  Map<String, Object?> toJson() => {'units': units};
}
