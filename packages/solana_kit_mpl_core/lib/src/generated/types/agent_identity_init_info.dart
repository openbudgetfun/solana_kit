// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './authority.dart';
import './external_check_result.dart';
import './hookable_lifecycle_event.dart';

@immutable
class AgentIdentityInitInfo {
  const AgentIdentityInitInfo({
    required this.uri,
    required this.initPluginAuthority,
    required this.lifecycleChecks,
  });

  final String uri;
  final Authority? initPluginAuthority;
  final List<(HookableLifecycleEvent, ExternalCheckResult)> lifecycleChecks;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentIdentityInitInfo &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          initPluginAuthority == other.initPluginAuthority &&
          lifecycleChecks == other.lifecycleChecks;

  @override
  int get hashCode => Object.hash(uri, initPluginAuthority, lifecycleChecks);

  @override
  String toString() =>
      'AgentIdentityInitInfo(uri: $uri, initPluginAuthority: $initPluginAuthority, lifecycleChecks: $lifecycleChecks)';
}

Encoder<AgentIdentityInitInfo> getAgentIdentityInitInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    (
      'initPluginAuthority',
      getNullableEncoder<Authority>(getAuthorityEncoder()),
    ),
    (
      'lifecycleChecks',
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
  ]);

  return transformEncoder(
    structEncoder,
    (AgentIdentityInitInfo value) => <String, Object?>{
      'uri': value.uri,
      'initPluginAuthority': value.initPluginAuthority,
      'lifecycleChecks': value.lifecycleChecks,
    },
  );
}

Decoder<AgentIdentityInitInfo> getAgentIdentityInitInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
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
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AgentIdentityInitInfo(
          uri: map['uri']! as String,
          initPluginAuthority: map['initPluginAuthority'] as Authority?,
          lifecycleChecks:
              map['lifecycleChecks']!
                  as List<(HookableLifecycleEvent, ExternalCheckResult)>,
        ),
  );
}

Codec<AgentIdentityInitInfo, AgentIdentityInitInfo>
getAgentIdentityInitInfoCodec() {
  return combineCodec(
    getAgentIdentityInitInfoEncoder(),
    getAgentIdentityInitInfoDecoder(),
  );
}
