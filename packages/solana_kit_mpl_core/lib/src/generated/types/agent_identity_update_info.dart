// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './external_check_result.dart';
import './hookable_lifecycle_event.dart';

@immutable
class AgentIdentityUpdateInfo {
  const AgentIdentityUpdateInfo({
    required this.uri,
    required this.lifecycleChecks,
  });

  final String? uri;
  final List<(HookableLifecycleEvent, ExternalCheckResult)>? lifecycleChecks;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentIdentityUpdateInfo &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          _listEquals(lifecycleChecks, other.lifecycleChecks);

  @override
  int get hashCode => Object.hash(uri, _listHashCode(lifecycleChecks));

  @override
  String toString() =>
      'AgentIdentityUpdateInfo(uri: $uri, lifecycleChecks: $lifecycleChecks)';
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

Encoder<AgentIdentityUpdateInfo> getAgentIdentityUpdateInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'uri',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
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
  ]);

  return transformEncoder(
    structEncoder,
    (AgentIdentityUpdateInfo value) => <String, Object?>{
      'uri': value.uri,
      'lifecycleChecks': value.lifecycleChecks,
    },
  );
}

Decoder<AgentIdentityUpdateInfo> getAgentIdentityUpdateInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'uri',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
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
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AgentIdentityUpdateInfo(
          uri: map['uri'] as String?,
          lifecycleChecks:
              map['lifecycleChecks']
                  as List<(HookableLifecycleEvent, ExternalCheckResult)>?,
        ),
  );
}

Codec<AgentIdentityUpdateInfo, AgentIdentityUpdateInfo>
getAgentIdentityUpdateInfoCodec() {
  return combineCodec(
    getAgentIdentityUpdateInfoEncoder(),
    getAgentIdentityUpdateInfoDecoder(),
  );
}
