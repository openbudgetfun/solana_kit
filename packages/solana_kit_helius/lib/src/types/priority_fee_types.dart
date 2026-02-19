import 'package:solana_kit_helius/src/types/enums.dart';

/// Request to estimate priority fees for a transaction.
class GetPriorityFeeEstimateRequest {
  const GetPriorityFeeEstimateRequest({
    this.accountKeys,
    this.transaction,
    this.options,
  });

  factory GetPriorityFeeEstimateRequest.fromJson(Map<String, Object?> json) {
    return GetPriorityFeeEstimateRequest(
      accountKeys: (json['accountKeys'] as List<Object?>?)?.cast<String>(),
      transaction: json['transaction'] as String?,
      options: json['options'] != null
          ? PriorityFeeOptions.fromJson(
              json['options']! as Map<String, Object?>,
            )
          : null,
    );
  }

  final List<String>? accountKeys;
  final String? transaction;
  final PriorityFeeOptions? options;

  Map<String, Object?> toJson() => {
    if (accountKeys != null) 'accountKeys': accountKeys,
    if (transaction != null) 'transaction': transaction,
    if (options != null) 'options': options!.toJson(),
  };
}

/// Options for priority fee estimation.
class PriorityFeeOptions {
  const PriorityFeeOptions({
    this.priorityLevel,
    this.includeAllPriorityFeeLevels,
    this.transactionEncoding,
    this.lookbackSlots,
    this.includeVote,
    this.recommended,
  });

  factory PriorityFeeOptions.fromJson(Map<String, Object?> json) {
    return PriorityFeeOptions(
      priorityLevel: json['priorityLevel'] != null
          ? PriorityLevel.fromJson(json['priorityLevel']! as String)
          : null,
      includeAllPriorityFeeLevels: json['includeAllPriorityFeeLevels'] as bool?,
      transactionEncoding: json['transactionEncoding'] as String?,
      lookbackSlots: json['lookbackSlots'] as bool?,
      includeVote: json['includeVote'] as bool?,
      recommended: json['recommended'] as bool?,
    );
  }

  final PriorityLevel? priorityLevel;
  final bool? includeAllPriorityFeeLevels;
  final String? transactionEncoding;
  final bool? lookbackSlots;
  final bool? includeVote;
  final bool? recommended;

  Map<String, Object?> toJson() => {
    if (priorityLevel != null) 'priorityLevel': priorityLevel!.toJson(),
    if (includeAllPriorityFeeLevels != null)
      'includeAllPriorityFeeLevels': includeAllPriorityFeeLevels,
    if (transactionEncoding != null) 'transactionEncoding': transactionEncoding,
    if (lookbackSlots != null) 'lookbackSlots': lookbackSlots,
    if (includeVote != null) 'includeVote': includeVote,
    if (recommended != null) 'recommended': recommended,
  };
}

/// Response containing priority fee estimates.
class GetPriorityFeeEstimateResponse {
  const GetPriorityFeeEstimateResponse({
    this.priorityFeeEstimate,
    this.priorityFeeLevels,
  });

  factory GetPriorityFeeEstimateResponse.fromJson(Map<String, Object?> json) {
    return GetPriorityFeeEstimateResponse(
      priorityFeeEstimate: (json['priorityFeeEstimate'] as num?)?.toDouble(),
      priorityFeeLevels: json['priorityFeeLevels'] != null
          ? MicroLamportPriorityFeeLevels.fromJson(
              json['priorityFeeLevels']! as Map<String, Object?>,
            )
          : null,
    );
  }

  final double? priorityFeeEstimate;
  final MicroLamportPriorityFeeLevels? priorityFeeLevels;

  Map<String, Object?> toJson() => {
    if (priorityFeeEstimate != null) 'priorityFeeEstimate': priorityFeeEstimate,
    if (priorityFeeLevels != null)
      'priorityFeeLevels': priorityFeeLevels!.toJson(),
  };
}

/// Priority fee levels in micro-lamports.
class MicroLamportPriorityFeeLevels {
  const MicroLamportPriorityFeeLevels({
    this.min,
    this.low,
    this.medium,
    this.high,
    this.veryHigh,
    this.unsafeMax,
  });

  factory MicroLamportPriorityFeeLevels.fromJson(Map<String, Object?> json) {
    return MicroLamportPriorityFeeLevels(
      min: (json['min'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      medium: (json['medium'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      veryHigh: (json['veryHigh'] as num?)?.toDouble(),
      unsafeMax: (json['unsafeMax'] as num?)?.toDouble(),
    );
  }

  final double? min;
  final double? low;
  final double? medium;
  final double? high;
  final double? veryHigh;
  final double? unsafeMax;

  Map<String, Object?> toJson() => {
    if (min != null) 'min': min,
    if (low != null) 'low': low,
    if (medium != null) 'medium': medium,
    if (high != null) 'high': high,
    if (veryHigh != null) 'veryHigh': veryHigh,
    if (unsafeMax != null) 'unsafeMax': unsafeMax,
  };
}
