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
          _listEquals(extraAccounts, other.extraAccounts) &&
          dataAuthority == other.dataAuthority &&
          schema == other.schema;

  @override
  int get hashCode => Object.hash(
    hookedProgram,
    _listHashCode(extraAccounts),
    dataAuthority,
    schema,
  );

  @override
  String toString() =>
      'LinkedLifecycleHook(hookedProgram: $hookedProgram, extraAccounts: $extraAccounts, dataAuthority: $dataAuthority, schema: $schema)';
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

Encoder<LinkedLifecycleHook> getLinkedLifecycleHookEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('hookedProgram', getAddressEncoder()),
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
