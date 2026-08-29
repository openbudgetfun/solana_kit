// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './external_plugin_adapter_schema.dart';
import './linked_data_key.dart';

@immutable
class DataSectionInitInfo {
  const DataSectionInitInfo({
    required this.parentKey,
    required this.schema,
  });

  final LinkedDataKey parentKey;
  final ExternalPluginAdapterSchema schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSectionInitInfo &&
          runtimeType == other.runtimeType &&
          parentKey == other.parentKey &&
          schema == other.schema;

  @override
  int get hashCode => Object.hash(parentKey, schema);

  @override
  String toString() =>
      'DataSectionInitInfo(parentKey: $parentKey, schema: $schema)';
}

Encoder<DataSectionInitInfo> getDataSectionInitInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('parentKey', getLinkedDataKeyEncoder()),
    ('schema', getExternalPluginAdapterSchemaEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DataSectionInitInfo value) => <String, Object?>{
      'parentKey': value.parentKey,
      'schema': value.schema,
    },
  );
}

Decoder<DataSectionInitInfo> getDataSectionInitInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('parentKey', getLinkedDataKeyDecoder()),
    ('schema', getExternalPluginAdapterSchemaDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        DataSectionInitInfo(
          parentKey: map['parentKey']! as LinkedDataKey,
          schema: map['schema']! as ExternalPluginAdapterSchema,
        ),
  );
}

Codec<DataSectionInitInfo, DataSectionInitInfo> getDataSectionInitInfoCodec() {
  return combineCodec(
    getDataSectionInitInfoEncoder(),
    getDataSectionInitInfoDecoder(),
  );
}
