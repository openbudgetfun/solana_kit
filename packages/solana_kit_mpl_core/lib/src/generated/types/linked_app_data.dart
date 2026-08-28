// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './authority.dart';
import './external_plugin_adapter_schema.dart';

@immutable
class LinkedAppData {
  const LinkedAppData({
    required this.dataAuthority,
    required this.schema,
  });

  final Authority dataAuthority;
  final ExternalPluginAdapterSchema schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedAppData &&
          runtimeType == other.runtimeType &&
          dataAuthority == other.dataAuthority &&
          schema == other.schema;

  @override
  int get hashCode => Object.hash(dataAuthority, schema);

  @override
  String toString() =>
      'LinkedAppData(dataAuthority: $dataAuthority, schema: $schema)';
}

Encoder<LinkedAppData> getLinkedAppDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('dataAuthority', getAuthorityEncoder()),
    ('schema', getExternalPluginAdapterSchemaEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (LinkedAppData value) => <String, Object?>{
      'dataAuthority': value.dataAuthority,
      'schema': value.schema,
    },
  );
}

Decoder<LinkedAppData> getLinkedAppDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('dataAuthority', getAuthorityDecoder()),
    ('schema', getExternalPluginAdapterSchemaDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => LinkedAppData(
      dataAuthority: map['dataAuthority']! as Authority,
      schema: map['schema']! as ExternalPluginAdapterSchema,
    ),
  );
}

Codec<LinkedAppData, LinkedAppData> getLinkedAppDataCodec() {
  return combineCodec(getLinkedAppDataEncoder(), getLinkedAppDataDecoder());
}
