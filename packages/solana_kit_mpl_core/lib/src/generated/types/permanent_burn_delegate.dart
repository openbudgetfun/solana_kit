// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class PermanentBurnDelegate {
  const PermanentBurnDelegate();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermanentBurnDelegate &&
          runtimeType == other.runtimeType &&
          true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'PermanentBurnDelegate()';
}

Encoder<PermanentBurnDelegate> getPermanentBurnDelegateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (PermanentBurnDelegate value) => <String, Object?>{},
  );
}

Decoder<PermanentBurnDelegate> getPermanentBurnDelegateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        PermanentBurnDelegate(),
  );
}

Codec<PermanentBurnDelegate, PermanentBurnDelegate>
getPermanentBurnDelegateCodec() {
  return combineCodec(
    getPermanentBurnDelegateEncoder(),
    getPermanentBurnDelegateDecoder(),
  );
}
