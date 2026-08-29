// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './authority.dart';
import './external_check_result.dart';
import './external_plugin_adapter_schema.dart';
import './extra_account.dart';
import './hookable_lifecycle_event.dart';

@immutable
class LifecycleHookInitInfo {
  const LifecycleHookInitInfo({
    required this.hookedProgram,
    required this.initPluginAuthority,
    required this.lifecycleChecks,
    required this.extraAccounts,
    required this.dataAuthority,
    required this.schema,
  });

  final Address hookedProgram;
  final Authority? initPluginAuthority;
  final List<(HookableLifecycleEvent, ExternalCheckResult)> lifecycleChecks;
  final List<ExtraAccount>? extraAccounts;
  final Authority? dataAuthority;
  final ExternalPluginAdapterSchema? schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifecycleHookInitInfo &&
          runtimeType == other.runtimeType &&
          hookedProgram == other.hookedProgram &&
          initPluginAuthority == other.initPluginAuthority &&
          _listEquals(lifecycleChecks, other.lifecycleChecks) &&
          _listEquals(extraAccounts, other.extraAccounts) &&
          dataAuthority == other.dataAuthority &&
          schema == other.schema;

  @override
  int get hashCode => Object.hash(
    hookedProgram,
    initPluginAuthority,
    _listHashCode(lifecycleChecks),
    _listHashCode(extraAccounts),
    dataAuthority,
    schema,
  );

  @override
  String toString() =>
      'LifecycleHookInitInfo(hookedProgram: $hookedProgram, initPluginAuthority: $initPluginAuthority, lifecycleChecks: $lifecycleChecks, extraAccounts: $extraAccounts, dataAuthority: $dataAuthority, schema: $schema)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left is List<Object?> && right is List<Object?>) {
      if (!_listEquals(left, right)) return false;
    } else if (left != right) {
      return false;
    }
  }
  return true;
}

Object? _deepHash(Object? value) {
  if (value is List<Object?>) {
    return Object.hashAll(value.map(_deepHash));
  }
  return value;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a.map(_deepHash));
}

Encoder<LifecycleHookInitInfo> getLifecycleHookInitInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('hookedProgram', getAddressEncoder()),
    (
      'initPluginAuthority',
      getNullableEncoder<Authority>(
        transformEncoder(getAuthorityEncoder(), (Authority value) => value),
      ),
    ),
    (
      'lifecycleChecks',
      getArrayEncoder(
        transformEncoder(
          getTuple2Encoder(
            getHookableLifecycleEventEncoder(),
            getExternalCheckResultEncoder(),
          ),
          ((HookableLifecycleEvent, ExternalCheckResult) value) => value,
        ),
      ),
    ),
    (
      'extraAccounts',
      getNullableEncoder<List<ExtraAccount>>(
        transformEncoder(
          getArrayEncoder(
            transformEncoder(
              getExtraAccountEncoder(),
              (ExtraAccount value) => value,
            ),
          ),
          (List<ExtraAccount> value) => value,
        ),
      ),
    ),
    (
      'dataAuthority',
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
    (LifecycleHookInitInfo value) => <String, Object?>{
      'hookedProgram': value.hookedProgram,
      'initPluginAuthority': value.initPluginAuthority,
      'lifecycleChecks': value.lifecycleChecks,
      'extraAccounts': value.extraAccounts,
      'dataAuthority': value.dataAuthority,
      'schema': value.schema,
    },
  );
}

Decoder<LifecycleHookInitInfo> getLifecycleHookInitInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('hookedProgram', getAddressDecoder()),
    (
      'initPluginAuthority',
      getNullableDecoder<Authority>(getAuthorityDecoder()),
    ),
    (
      'lifecycleChecks',
      getArrayDecoder(
        getTuple2Decoder(
          getHookableLifecycleEventDecoder(),
          getExternalCheckResultDecoder(),
        ),
      ),
    ),
    (
      'extraAccounts',
      getNullableDecoder<List<ExtraAccount>>(
        getArrayDecoder(getExtraAccountDecoder()),
      ),
    ),
    ('dataAuthority', getNullableDecoder<Authority>(getAuthorityDecoder())),
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
        LifecycleHookInitInfo(
          hookedProgram: map['hookedProgram']! as Address,
          initPluginAuthority: map['initPluginAuthority'] as Authority?,
          lifecycleChecks:
              map['lifecycleChecks']!
                  as List<(HookableLifecycleEvent, ExternalCheckResult)>,
          extraAccounts: map['extraAccounts'] as List<ExtraAccount>?,
          dataAuthority: map['dataAuthority'] as Authority?,
          schema: map['schema'] as ExternalPluginAdapterSchema?,
        ),
  );
}

Codec<LifecycleHookInitInfo, LifecycleHookInitInfo>
getLifecycleHookInitInfoCodec() {
  return combineCodec(
    getLifecycleHookInitInfoEncoder(),
    getLifecycleHookInitInfoDecoder(),
  );
}
