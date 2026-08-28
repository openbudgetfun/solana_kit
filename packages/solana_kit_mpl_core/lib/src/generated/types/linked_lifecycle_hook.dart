// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './authority.dart';
import './external_plugin_adapter_schema.dart';
import './extra_account.dart';

@immutable
class LinkedLifecycleHook {
  const LinkedLifecycleHook({
    required this.hookedProgram,
    required this.extraAccounts,
    required this.dataAuthority,
    required this.schema,
  });

  final Address hookedProgram;
  final List<ExtraAccount>? extraAccounts;
  final Authority? dataAuthority;
  final ExternalPluginAdapterSchema schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedLifecycleHook &&
          runtimeType == other.runtimeType &&
          hookedProgram == other.hookedProgram &&
          extraAccounts == other.extraAccounts &&
          dataAuthority == other.dataAuthority &&
          schema == other.schema;

  @override
  int get hashCode =>
      Object.hash(hookedProgram, extraAccounts, dataAuthority, schema);

  @override
  String toString() =>
      'LinkedLifecycleHook(hookedProgram: $hookedProgram, extraAccounts: $extraAccounts, dataAuthority: $dataAuthority, schema: $schema)';
}

Encoder<LinkedLifecycleHook> getLinkedLifecycleHookEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('hookedProgram', getAddressEncoder()),
    (
      'extraAccounts',
      getNullableEncoder<List<ExtraAccount>>(
        getArrayEncoder<ExtraAccount>(
          transformEncoder(
            getExtraAccountEncoder(),
            (ExtraAccount value) => value,
          ),
        ),
      ),
    ),
    ('dataAuthority', getNullableEncoder<Authority>(getAuthorityEncoder())),
    ('schema', getExternalPluginAdapterSchemaEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (LinkedLifecycleHook value) => <String, Object?>{
      'hookedProgram': value.hookedProgram,
      'extraAccounts': value.extraAccounts,
      'dataAuthority': value.dataAuthority,
      'schema': value.schema,
    },
  );
}

Decoder<LinkedLifecycleHook> getLinkedLifecycleHookDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('hookedProgram', getAddressDecoder()),
    (
      'extraAccounts',
      getNullableDecoder<List<ExtraAccount>>(
        getArrayDecoder(getExtraAccountDecoder()),
      ),
    ),
    ('dataAuthority', getNullableDecoder<Authority>(getAuthorityDecoder())),
    ('schema', getExternalPluginAdapterSchemaDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        LinkedLifecycleHook(
          hookedProgram: map['hookedProgram']! as Address,
          extraAccounts: map['extraAccounts'] as List<ExtraAccount>?,
          dataAuthority: map['dataAuthority'] as Authority?,
          schema: map['schema']! as ExternalPluginAdapterSchema,
        ),
  );
}

Codec<LinkedLifecycleHook, LinkedLifecycleHook> getLinkedLifecycleHookCodec() {
  return combineCodec(
    getLinkedLifecycleHookEncoder(),
    getLinkedLifecycleHookDecoder(),
  );
}
