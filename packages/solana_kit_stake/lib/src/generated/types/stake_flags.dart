// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class StakeFlags {
  const StakeFlags({required this.bits});

  final int bits;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeFlags &&
          runtimeType == other.runtimeType &&
          bits == other.bits;

  @override
  int get hashCode => bits.hashCode;

  @override
  String toString() => 'StakeFlags(bits: $bits)';
}

Encoder<StakeFlags> getStakeFlagsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('bits', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (StakeFlags value) => <String, Object?>{'bits': value.bits},
  );
}

Decoder<StakeFlags> getStakeFlagsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('bits', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        StakeFlags(bits: map['bits']! as int),
  );
}

Codec<StakeFlags, StakeFlags> getStakeFlagsCodec() {
  return combineCodec(getStakeFlagsEncoder(), getStakeFlagsDecoder());
}
