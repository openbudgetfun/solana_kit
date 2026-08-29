// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authority.dart';
import './external_check_result.dart';
import './external_plugin_adapter_type.dart';
import './hookable_lifecycle_event.dart';

@immutable
class ExternalRegistryRecord {
  const ExternalRegistryRecord({
    required this.pluginType,
    required this.authority,
    required this.lifecycleChecks,
    required this.offset,
    required this.dataOffset,
    required this.dataLen,
  });

  final ExternalPluginAdapterType pluginType;
  final Authority authority;
  final List<(HookableLifecycleEvent, ExternalCheckResult)>? lifecycleChecks;
  final BigInt offset;
  final BigInt? dataOffset;
  final BigInt? dataLen;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalRegistryRecord &&
          runtimeType == other.runtimeType &&
          pluginType == other.pluginType &&
          authority == other.authority &&
          _listEquals(lifecycleChecks, other.lifecycleChecks) &&
          offset == other.offset &&
          dataOffset == other.dataOffset &&
          dataLen == other.dataLen;

  @override
  int get hashCode => Object.hash(
    pluginType,
    authority,
    _listHashCode(lifecycleChecks),
    offset,
    dataOffset,
    dataLen,
  );

  @override
  String toString() =>
      'ExternalRegistryRecord(pluginType: $pluginType, authority: $authority, lifecycleChecks: $lifecycleChecks, offset: $offset, dataOffset: $dataOffset, dataLen: $dataLen)';
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

Encoder<ExternalRegistryRecord> getExternalRegistryRecordEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('pluginType', getExternalPluginAdapterTypeEncoder()),
    ('authority', getAuthorityEncoder()),
    (
      'lifecycleChecks',
      getNullableEncoder<List<(HookableLifecycleEvent, ExternalCheckResult)>>(
        transformEncoder(
          getArrayEncoder(
            transformEncoder(
              getTuple2Encoder(
                getHookableLifecycleEventEncoder(),
                getExternalCheckResultEncoder(),
              ),
              ((HookableLifecycleEvent, ExternalCheckResult) value) => value,
            ),
          ),
          (List<(HookableLifecycleEvent, ExternalCheckResult)> value) => value,
        ),
      ),
    ),
    ('offset', getU64Encoder()),
    (
      'dataOffset',
      getNullableEncoder<BigInt>(
        transformEncoder(getU64Encoder(), (BigInt value) => value),
      ),
    ),
    (
      'dataLen',
      getNullableEncoder<BigInt>(
        transformEncoder(getU64Encoder(), (BigInt value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ExternalRegistryRecord value) => <String, Object?>{
      'pluginType': value.pluginType,
      'authority': value.authority,
      'lifecycleChecks': value.lifecycleChecks,
      'offset': value.offset,
      'dataOffset': value.dataOffset,
      'dataLen': value.dataLen,
    },
  );
}

Decoder<ExternalRegistryRecord> getExternalRegistryRecordDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('pluginType', getExternalPluginAdapterTypeDecoder()),
    ('authority', getAuthorityDecoder()),
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
    ('offset', getU64Decoder()),
    ('dataOffset', getNullableDecoder<BigInt>(getU64Decoder())),
    ('dataLen', getNullableDecoder<BigInt>(getU64Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ExternalRegistryRecord(
          pluginType: map['pluginType']! as ExternalPluginAdapterType,
          authority: map['authority']! as Authority,
          lifecycleChecks:
              map['lifecycleChecks']
                  as List<(HookableLifecycleEvent, ExternalCheckResult)>?,
          offset: map['offset']! as BigInt,
          dataOffset: map['dataOffset'] as BigInt?,
          dataLen: map['dataLen'] as BigInt?,
        ),
  );
}

Codec<ExternalRegistryRecord, ExternalRegistryRecord>
getExternalRegistryRecordCodec() {
  return combineCodec(
    getExternalRegistryRecordEncoder(),
    getExternalRegistryRecordDecoder(),
  );
}
