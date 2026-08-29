// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './authority.dart';
import './external_plugin_adapter_schema.dart';

@immutable
class AppDataInitInfo {
  const AppDataInitInfo({
    required this.dataAuthority,
    required this.initPluginAuthority,
    required this.schema,
  });

  final Authority dataAuthority;
  final Authority? initPluginAuthority;
  final ExternalPluginAdapterSchema? schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppDataInitInfo &&
          runtimeType == other.runtimeType &&
          dataAuthority == other.dataAuthority &&
          initPluginAuthority == other.initPluginAuthority &&
          schema == other.schema;

  @override
  int get hashCode => Object.hash(dataAuthority, initPluginAuthority, schema);

  @override
  String toString() =>
      'AppDataInitInfo(dataAuthority: $dataAuthority, initPluginAuthority: $initPluginAuthority, schema: $schema)';
}

Encoder<AppDataInitInfo> getAppDataInitInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('dataAuthority', getAuthorityEncoder()),
    (
      'initPluginAuthority',
      getNullableEncoder<Authority>(
        transformEncoder(getAuthorityEncoder(), (Authority value) => value),
      ),
    ),
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
    (AppDataInitInfo value) => <String, Object?>{
      'dataAuthority': value.dataAuthority,
      'initPluginAuthority': value.initPluginAuthority,
      'schema': value.schema,
    },
  );
}

Decoder<AppDataInitInfo> getAppDataInitInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('dataAuthority', getAuthorityDecoder()),
    (
      'initPluginAuthority',
      getNullableDecoder<Authority>(getAuthorityDecoder()),
    ),
    (
      'schema',
      getNullableDecoder<ExternalPluginAdapterSchema>(
        getExternalPluginAdapterSchemaDecoder(),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AppDataInitInfo(
      dataAuthority: map['dataAuthority']! as Authority,
      initPluginAuthority: map['initPluginAuthority'] as Authority?,
      schema: map['schema'] as ExternalPluginAdapterSchema?,
    ),
  );
}

Codec<AppDataInitInfo, AppDataInitInfo> getAppDataInitInfoCodec() {
  return combineCodec(getAppDataInitInfoEncoder(), getAppDataInitInfoDecoder());
}
