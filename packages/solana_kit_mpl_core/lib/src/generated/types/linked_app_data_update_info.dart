// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './external_plugin_adapter_schema.dart';

@immutable
class LinkedAppDataUpdateInfo {
  const LinkedAppDataUpdateInfo({
    required this.schema,
  });

  final ExternalPluginAdapterSchema? schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedAppDataUpdateInfo &&
          runtimeType == other.runtimeType &&
          schema == other.schema;

  @override
  int get hashCode => schema.hashCode;

  @override
  String toString() => 'LinkedAppDataUpdateInfo(schema: $schema)';
}

Encoder<LinkedAppDataUpdateInfo> getLinkedAppDataUpdateInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'schema',
      getNullableEncoder<ExternalPluginAdapterSchema>(
        transformEncoder(
          getExternalPluginAdapterSchemaEncoder(),
          (ExternalPluginAdapterSchema value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (LinkedAppDataUpdateInfo value) => <String, Object?>{
      'schema': value.schema,
    },
  );
}

Decoder<LinkedAppDataUpdateInfo> getLinkedAppDataUpdateInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'schema',
      getNullableDecoder<ExternalPluginAdapterSchema>(
        getExternalPluginAdapterSchemaDecoder(),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        LinkedAppDataUpdateInfo(
          schema: map['schema'] as ExternalPluginAdapterSchema?,
        ),
  );
}

Codec<LinkedAppDataUpdateInfo, LinkedAppDataUpdateInfo>
getLinkedAppDataUpdateInfoCodec() {
  return combineCodec(
    getLinkedAppDataUpdateInfoEncoder(),
    getLinkedAppDataUpdateInfoDecoder(),
  );
}
