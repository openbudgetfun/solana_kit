// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class AddBlocker {
  const AddBlocker();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddBlocker && runtimeType == other.runtimeType && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AddBlocker()';
}

Encoder<AddBlocker> getAddBlockerEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (AddBlocker value) => <String, Object?>{},
  );
}

Decoder<AddBlocker> getAddBlockerDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AddBlocker(),
  );
}

Codec<AddBlocker, AddBlocker> getAddBlockerCodec() {
  return combineCodec(getAddBlockerEncoder(), getAddBlockerDecoder());
}
