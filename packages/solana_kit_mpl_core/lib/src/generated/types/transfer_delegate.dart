// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class TransferDelegate {
  const TransferDelegate();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferDelegate && runtimeType == other.runtimeType && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'TransferDelegate()';
}

Encoder<TransferDelegate> getTransferDelegateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (TransferDelegate value) => <String, Object?>{},
  );
}

Decoder<TransferDelegate> getTransferDelegateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        TransferDelegate(),
  );
}

Codec<TransferDelegate, TransferDelegate> getTransferDelegateCodec() {
  return combineCodec(
    getTransferDelegateEncoder(),
    getTransferDelegateDecoder(),
  );
}
