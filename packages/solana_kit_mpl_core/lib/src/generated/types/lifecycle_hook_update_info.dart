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
class LifecycleHookUpdateInfo {
  const LifecycleHookUpdateInfo({
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
      other is LifecycleHookUpdateInfo &&
          runtimeType == other.runtimeType &&
          _listEquals(lifecycleChecks, other.lifecycleChecks) &&
          _listEquals(extraAccounts, other.extraAccounts) &&
          schema == other.schema;

  @override
  int get hashCode => Object.hash(
    _listHashCode(lifecycleChecks),
    _listHashCode(extraAccounts),
    schema,
  );

  @override
  String toString() =>
      'LifecycleHookUpdateInfo(lifecycleChecks: $lifecycleChecks, extraAccounts: $extraAccounts, schema: $schema)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a);
}

Encoder<LifecycleHookUpdateInfo> getLifecycleHookUpdateInfoEncoder() {
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
    (LifecycleHookUpdateInfo value) => <String, Object?>{
      'lifecycleChecks': value.lifecycleChecks,
      'extraAccounts': value.extraAccounts,
      'schema': value.schema,
    },
  );
}

Decoder<LifecycleHookUpdateInfo> getLifecycleHookUpdateInfoDecoder() {
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
        LifecycleHookUpdateInfo(
          lifecycleChecks:
              map['lifecycleChecks']
                  as List<(HookableLifecycleEvent, ExternalCheckResult)>?,
          extraAccounts: map['extraAccounts'] as List<ExtraAccount>?,
          schema: map['schema'] as ExternalPluginAdapterSchema?,
        ),
  );
}

Codec<LifecycleHookUpdateInfo, LifecycleHookUpdateInfo>
getLifecycleHookUpdateInfoCodec() {
  return combineCodec(
    getLifecycleHookUpdateInfoEncoder(),
    getLifecycleHookUpdateInfoDecoder(),
  );
}
