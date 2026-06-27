// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


@immutable
class PlanTerms {
  const PlanTerms({
    required this.amount,
    required this.periodHours,
    required this.createdAt,
  });

  final BigInt amount;
  final BigInt periodHours;
  final BigInt createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanTerms &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          periodHours == other.periodHours &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(amount, periodHours, createdAt);

  @override
  String toString() => 'PlanTerms(amount: $amount, periodHours: $periodHours, createdAt: $createdAt)';
}

Encoder<PlanTerms> getPlanTermsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('amount', getU64Encoder()),
    ('periodHours', getU64Encoder()),
    ('createdAt', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PlanTerms value) => <String, Object?>{
      'amount': value.amount,
      'periodHours': value.periodHours,
      'createdAt': value.createdAt,
    },
  );
}

Decoder<PlanTerms> getPlanTermsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('amount', getU64Decoder()),
    ('periodHours', getU64Decoder()),
    ('createdAt', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => PlanTerms(
      amount: map['amount']! as BigInt,
      periodHours: map['periodHours']! as BigInt,
      createdAt: map['createdAt']! as BigInt,
    ),
  );
}

Codec<PlanTerms, PlanTerms> getPlanTermsCodec() {
  return combineCodec(getPlanTermsEncoder(), getPlanTermsDecoder());
}
