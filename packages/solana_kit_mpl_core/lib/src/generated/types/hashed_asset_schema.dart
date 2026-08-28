// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class HashedAssetSchema {
  const HashedAssetSchema({
    required this.assetHash,
    required this.pluginHashes,
  });

  final Uint8List assetHash;
  final List<Uint8List> pluginHashes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HashedAssetSchema &&
          runtimeType == other.runtimeType &&
          assetHash == other.assetHash &&
          pluginHashes == other.pluginHashes;

  @override
  int get hashCode => Object.hash(assetHash, pluginHashes);

  @override
  String toString() =>
      'HashedAssetSchema(assetHash: $assetHash, pluginHashes: $pluginHashes)';
}

Encoder<HashedAssetSchema> getHashedAssetSchemaEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'assetHash',
      fixEncoderSize(getBytesEncoder(), 32, allowTruncation: false),
    ),
    (
      'pluginHashes',
      getArrayEncoder<Uint8List>(
        transformEncoder(
          fixEncoderSize(getBytesEncoder(), 32, allowTruncation: false),
          (Uint8List value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (HashedAssetSchema value) => <String, Object?>{
      'assetHash': value.assetHash,
      'pluginHashes': value.pluginHashes,
    },
  );
}

Decoder<HashedAssetSchema> getHashedAssetSchemaDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('assetHash', fixDecoderSize(getBytesDecoder(), 32)),
    ('pluginHashes', getArrayDecoder(fixDecoderSize(getBytesDecoder(), 32))),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        HashedAssetSchema(
          assetHash: map['assetHash']! as Uint8List,
          pluginHashes: map['pluginHashes']! as List<Uint8List>,
        ),
  );
}

Codec<HashedAssetSchema, HashedAssetSchema> getHashedAssetSchemaCodec() {
  return combineCodec(
    getHashedAssetSchemaEncoder(),
    getHashedAssetSchemaDecoder(),
  );
}
