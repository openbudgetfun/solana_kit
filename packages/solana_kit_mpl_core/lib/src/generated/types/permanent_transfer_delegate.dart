// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class PermanentTransferDelegate {
  const PermanentTransferDelegate();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermanentTransferDelegate &&
          runtimeType == other.runtimeType &&
          true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'PermanentTransferDelegate()';
}

Encoder<PermanentTransferDelegate> getPermanentTransferDelegateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (PermanentTransferDelegate value) => <String, Object?>{},
  );
}

Decoder<PermanentTransferDelegate> getPermanentTransferDelegateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        PermanentTransferDelegate(),
  );
}

Codec<PermanentTransferDelegate, PermanentTransferDelegate>
getPermanentTransferDelegateCodec() {
  return combineCodec(
    getPermanentTransferDelegateEncoder(),
    getPermanentTransferDelegateDecoder(),
  );
}
