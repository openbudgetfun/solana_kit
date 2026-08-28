// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class ImmutableMetadata {
  const ImmutableMetadata();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImmutableMetadata && runtimeType == other.runtimeType && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ImmutableMetadata()';
}

Encoder<ImmutableMetadata> getImmutableMetadataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (ImmutableMetadata value) => <String, Object?>{},
  );
}

Decoder<ImmutableMetadata> getImmutableMetadataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ImmutableMetadata(),
  );
}

Codec<ImmutableMetadata, ImmutableMetadata> getImmutableMetadataCodec() {
  return combineCodec(
    getImmutableMetadataEncoder(),
    getImmutableMetadataDecoder(),
  );
}
