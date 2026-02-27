// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class StakeInfo {
  const StakeInfo({
    required this.amount,
    required this.startTime,
    required this.endTime,
    required this.isLocked,
  });

  final BigInt amount;
  final BigInt startTime;
  final BigInt? endTime;
  final bool isLocked;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeInfo &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          isLocked == other.isLocked;

  @override
  int get hashCode => Object.hash(amount, startTime, endTime, isLocked);

  @override
  String toString() =>
      'StakeInfo(amount: $amount, startTime: $startTime, endTime: $endTime, isLocked: $isLocked)';
}

Encoder<StakeInfo> getStakeInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('amount', getU64Encoder()),
    ('startTime', getI64Encoder()),
    ('endTime', getNullableEncoder(getI64Encoder())),
    ('isLocked', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (StakeInfo value) => <String, Object?>{
      'amount': value.amount,
      'startTime': value.startTime,
      'endTime': value.endTime,
      'isLocked': value.isLocked,
    },
  );
}

Decoder<StakeInfo> getStakeInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('amount', getU64Decoder()),
    ('startTime', getI64Decoder()),
    ('endTime', getNullableDecoder(getI64Decoder())),
    ('isLocked', getBooleanDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => StakeInfo(
      amount: map['amount']! as BigInt,
      startTime: map['startTime']! as BigInt,
      endTime: map['endTime'] as BigInt?,
      isLocked: map['isLocked']! as bool,
    ),
  );
}

Codec<StakeInfo, StakeInfo> getStakeInfoCodec() {
  return combineCodec(getStakeInfoEncoder(), getStakeInfoDecoder());
}
