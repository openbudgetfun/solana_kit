// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class CancelSubscriptionNowData {
  const CancelSubscriptionNowData({
    required this.expectedCurrentPeriodStartTs,
  });

  final BigInt expectedCurrentPeriodStartTs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CancelSubscriptionNowData &&
          runtimeType == other.runtimeType &&
          expectedCurrentPeriodStartTs == other.expectedCurrentPeriodStartTs;

  @override
  int get hashCode => expectedCurrentPeriodStartTs.hashCode;

  @override
  String toString() =>
      'CancelSubscriptionNowData(expectedCurrentPeriodStartTs: $expectedCurrentPeriodStartTs)';
}

Encoder<CancelSubscriptionNowData> getCancelSubscriptionNowDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('expectedCurrentPeriodStartTs', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CancelSubscriptionNowData value) => <String, Object?>{
      'expectedCurrentPeriodStartTs': value.expectedCurrentPeriodStartTs,
    },
  );
}

Decoder<CancelSubscriptionNowData> getCancelSubscriptionNowDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('expectedCurrentPeriodStartTs', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CancelSubscriptionNowData(
          expectedCurrentPeriodStartTs:
              map['expectedCurrentPeriodStartTs']! as BigInt,
        ),
  );
}

Codec<CancelSubscriptionNowData, CancelSubscriptionNowData>
getCancelSubscriptionNowDataCodec() {
  return combineCodec(
    getCancelSubscriptionNowDataEncoder(),
    getCancelSubscriptionNowDataDecoder(),
  );
}
