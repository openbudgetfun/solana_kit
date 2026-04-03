// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// Request to estimate priority fees for a transaction.
class GetPriorityFeeEstimateRequest {
  const GetPriorityFeeEstimateRequest({
    this.accountKeys,
    this.transaction,
    this.options,
  });

  factory GetPriorityFeeEstimateRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetPriorityFeeEstimateRequest(
      accountKeys: r.optList<String>('accountKeys'),
      transaction: r.optString('transaction'),
      options: r.optDecoded('options', PriorityFeeOptions.fromJson),
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
    final r = JsonReader(json);
    return GetPriorityFeeEstimateResponse(
      priorityFeeEstimate: r.optDouble('priorityFeeEstimate'),
      priorityFeeLevels: r.optDecoded(
        'priorityFeeLevels',
        MicroLamportPriorityFeeLevels.fromJson,
      ),
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
