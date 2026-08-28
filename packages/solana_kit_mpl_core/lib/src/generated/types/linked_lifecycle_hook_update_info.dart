// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './external_check_result.dart';
import './external_plugin_adapter_schema.dart';
import './extra_account.dart';
import './hookable_lifecycle_event.dart';

@immutable
class LinkedLifecycleHookUpdateInfo {
  const LinkedLifecycleHookUpdateInfo({
    required this.lifecycleChecks,
    required this.extraAccounts,
    required this.schema,
  });

  final List<(HookableLifecycleEvent, ExternalCheckResult)>? lifecycleChecks;
  final List<ExtraAccount>? extraAccounts;
  final ExternalPluginAdapterSchema? schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedLifecycleHookUpdateInfo &&
          runtimeType == other.runtimeType &&
          lifecycleChecks == other.lifecycleChecks &&
          extraAccounts == other.extraAccounts &&
          schema == other.schema;

  @override
  int get hashCode => Object.hash(lifecycleChecks, extraAccounts, schema);

  @override
  String toString() =>
      'LinkedLifecycleHookUpdateInfo(lifecycleChecks: $lifecycleChecks, extraAccounts: $extraAccounts, schema: $schema)';
}

Encoder<LinkedLifecycleHookUpdateInfo>
getLinkedLifecycleHookUpdateInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'lifecycleChecks',
      getNullableEncoder<List<(HookableLifecycleEvent, ExternalCheckResult)>>(
        getArrayEncoder<(HookableLifecycleEvent, ExternalCheckResult)>(
          transformEncoder(
            getTuple2Encoder(
              getHookableLifecycleEventEncoder(),
              getExternalCheckResultEncoder(),
            ),
            ((HookableLifecycleEvent, ExternalCheckResult) value) => value,
          ),
        ),
      ),
    ),
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
    (
      'schema',
      getNullableEncoder<ExternalPluginAdapterSchema>(
        getExternalPluginAdapterSchemaEncoder(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (LinkedLifecycleHookUpdateInfo value) => <String, Object?>{
      'lifecycleChecks': value.lifecycleChecks,
      'extraAccounts': value.extraAccounts,
      'schema': value.schema,
    },
  );
}

Decoder<LinkedLifecycleHookUpdateInfo>
getLinkedLifecycleHookUpdateInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'lifecycleChecks',
      getNullableDecoder<List<(HookableLifecycleEvent, ExternalCheckResult)>>(
        getArrayDecoder(
          getTuple2Decoder(
            getHookableLifecycleEventDecoder(),
            getExternalCheckResultDecoder(),
          ),
        ),
      ),
    ),
    (
      'extraAccounts',
      getNullableDecoder<List<ExtraAccount>>(
        getArrayDecoder(getExtraAccountDecoder()),
      ),
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
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        LinkedLifecycleHookUpdateInfo(
          lifecycleChecks:
              map['lifecycleChecks']
                  as List<(HookableLifecycleEvent, ExternalCheckResult)>?,
          extraAccounts: map['extraAccounts'] as List<ExtraAccount>?,
          schema: map['schema'] as ExternalPluginAdapterSchema?,
        ),
  );
}

Codec<LinkedLifecycleHookUpdateInfo, LinkedLifecycleHookUpdateInfo>
getLinkedLifecycleHookUpdateInfoCodec() {
  return combineCodec(
    getLinkedLifecycleHookUpdateInfoEncoder(),
    getLinkedLifecycleHookUpdateInfoDecoder(),
  );
}
