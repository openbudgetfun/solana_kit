// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class BubblegumV2 {
  const BubblegumV2();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BubblegumV2 && runtimeType == other.runtimeType && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'BubblegumV2()';
}

Encoder<BubblegumV2> getBubblegumV2Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (BubblegumV2 value) => <String, Object?>{},
  );
}

Decoder<BubblegumV2> getBubblegumV2Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => BubblegumV2(),
  );
}

Codec<BubblegumV2, BubblegumV2> getBubblegumV2Codec() {
  return combineCodec(getBubblegumV2Encoder(), getBubblegumV2Decoder());
}
