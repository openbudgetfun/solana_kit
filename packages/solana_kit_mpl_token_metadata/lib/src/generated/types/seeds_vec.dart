// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class SeedsVec {
  const SeedsVec({
    required this.seeds,
  });

  final List<Uint8List> seeds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeedsVec &&
          runtimeType == other.runtimeType &&
          seeds == other.seeds;

  @override
  int get hashCode => seeds.hashCode;

  @override
  String toString() => 'SeedsVec(seeds: $seeds)';
}

Encoder<SeedsVec> getSeedsVecEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'seeds',
      getArrayEncoder<Uint8List>(
        transformEncoder(
          addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
          (Uint8List value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (SeedsVec value) => <String, Object?>{
      'seeds': value.seeds,
    },
  );
}

Decoder<SeedsVec> getSeedsVecDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'seeds',
      getArrayDecoder(addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SeedsVec(
      seeds: map['seeds']! as List<Uint8List>,
    ),
  );
}

Codec<SeedsVec, SeedsVec> getSeedsVecCodec() {
  return combineCodec(getSeedsVecEncoder(), getSeedsVecDecoder());
}
