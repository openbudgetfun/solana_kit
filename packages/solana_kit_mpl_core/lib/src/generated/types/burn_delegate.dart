// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class BurnDelegate {
  const BurnDelegate();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BurnDelegate && runtimeType == other.runtimeType && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'BurnDelegate()';
}

Encoder<BurnDelegate> getBurnDelegateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (BurnDelegate value) => <String, Object?>{},
  );
}

Decoder<BurnDelegate> getBurnDelegateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => BurnDelegate(),
  );
}

Codec<BurnDelegate, BurnDelegate> getBurnDelegateCodec() {
  return combineCodec(getBurnDelegateEncoder(), getBurnDelegateDecoder());
}
