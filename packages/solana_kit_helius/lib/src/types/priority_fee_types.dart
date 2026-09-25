import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// Request to estimate priority fees for a transaction.
class GetPriorityFeeEstimateRequest {
  /// Creates a priority fee estimate request.
  const GetPriorityFeeEstimateRequest({
    this.accountKeys,
    this.transaction,
    this.options,
  });

  /// Creates a [GetPriorityFeeEstimateRequest] from a JSON map.
  factory GetPriorityFeeEstimateRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetPriorityFeeEstimateRequest(
      accountKeys: r.optList<String>('accountKeys'),
      transaction: r.optString('transaction'),
      options: r.optDecoded('options', PriorityFeeOptions.fromJson),
    );
  }

  /// Account keys involved in the transaction, used to estimate fees.
  final List<String>? accountKeys;

  /// Serialized transaction to estimate fees for.
  final String? transaction;

  /// Additional options controlling the fee estimation.
  final PriorityFeeOptions? options;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    if (accountKeys != null) 'accountKeys': accountKeys,
    if (transaction != null) 'transaction': transaction,
    if (options != null) 'options': options!.toJson(),
  };
}

/// Options for priority fee estimation.
class PriorityFeeOptions {
  /// Creates priority fee estimation options.
  const PriorityFeeOptions({
    this.priorityLevel,
    this.includeAllPriorityFeeLevels,
    this.transactionEncoding,
    this.lookbackSlots,
    this.includeVote,
    this.recommended,
  });

  /// Creates a [PriorityFeeOptions] from a JSON map.
  factory PriorityFeeOptions.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return PriorityFeeOptions(
      priorityLevel: r.optEnum('priorityLevel', PriorityLevel.fromJson),
      includeAllPriorityFeeLevels: r.optBool('includeAllPriorityFeeLevels'),
      transactionEncoding: r.optString('transactionEncoding'),
      lookbackSlots: r.optBool('lookbackSlots'),
      includeVote: r.optBool('includeVote'),
      recommended: r.optBool('recommended'),
    );
  }

  /// Desired priority level for the fee estimate.
  final PriorityLevel? priorityLevel;

  /// Whether to return fee estimates for all priority levels.
  final bool? includeAllPriorityFeeLevels;

  /// Encoding of the transaction provided in the request.
  final String? transactionEncoding;

  /// Whether to compute the estimate over a lookback window of slots.
  final bool? lookbackSlots;

  /// Whether to include vote transactions in the estimate.
  final bool? includeVote;

  /// Whether to return a recommended priority fee.
  final bool? recommended;

  /// Serializes these options to a JSON map.
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
  /// Creates a priority fee estimate response.
  const GetPriorityFeeEstimateResponse({
    this.priorityFeeEstimate,
    this.priorityFeeLevels,
  });

  /// Creates a [GetPriorityFeeEstimateResponse] from a JSON map.
  factory GetPriorityFeeEstimateResponse.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetPriorityFeeEstimateResponse(
      priorityFeeEstimate: r.optDouble('priorityFeeEstimate'),
      priorityFeeLevels: r.optDecoded(
        'priorityFeeLevels',
        MicroLamportPriorityFeeLevels.fromJson,
      ),
    );
  }

  /// Estimated priority fee in micro-lamports.
  final double? priorityFeeEstimate;

  /// Breakdown of priority fee estimates across levels.
  final MicroLamportPriorityFeeLevels? priorityFeeLevels;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    if (priorityFeeEstimate != null) 'priorityFeeEstimate': priorityFeeEstimate,
    if (priorityFeeLevels != null)
      'priorityFeeLevels': priorityFeeLevels!.toJson(),
  };
}

/// Priority fee levels in micro-lamports.
class MicroLamportPriorityFeeLevels {
  /// Creates a micro-lamport priority fee levels breakdown.
  const MicroLamportPriorityFeeLevels({
    this.min,
    this.low,
    this.medium,
    this.high,
    this.veryHigh,
    this.unsafeMax,
  });

  /// Creates a [MicroLamportPriorityFeeLevels] from a JSON map.
  factory MicroLamportPriorityFeeLevels.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return MicroLamportPriorityFeeLevels(
      min: r.optDouble('min'),
      low: r.optDouble('low'),
      medium: r.optDouble('medium'),
      high: r.optDouble('high'),
      veryHigh: r.optDouble('veryHigh'),
      unsafeMax: r.optDouble('unsafeMax'),
    );
  }

  /// Minimum observed priority fee.
  final double? min;

  /// Low priority fee level.
  final double? low;

  /// Medium priority fee level.
  final double? medium;

  /// High priority fee level.
  final double? high;

  /// Very high priority fee level.
  final double? veryHigh;

  /// Maximum observed priority fee, may be unsafe to use.
  final double? unsafeMax;

  /// Serializes these levels to a JSON map.
  Map<String, Object?> toJson() => {
    if (min != null) 'min': min,
    if (low != null) 'low': low,
    if (medium != null) 'medium': medium,
    if (high != null) 'high': high,
    if (veryHigh != null) 'veryHigh': veryHigh,
    if (unsafeMax != null) 'unsafeMax': unsafeMax,
  };
}
