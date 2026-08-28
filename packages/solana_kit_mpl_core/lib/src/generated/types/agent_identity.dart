// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

@immutable
class AgentIdentity {
  const AgentIdentity({
    required this.uri,
  });

  final String uri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentIdentity &&
          runtimeType == other.runtimeType &&
          uri == other.uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => 'AgentIdentity(uri: $uri)';
}

Encoder<AgentIdentity> getAgentIdentityEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (AgentIdentity value) => <String, Object?>{
      'uri': value.uri,
    },
  );
}

Decoder<AgentIdentity> getAgentIdentityDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AgentIdentity(
      uri: map['uri']! as String,
    ),
  );
}

Codec<AgentIdentity, AgentIdentity> getAgentIdentityCodec() {
  return combineCodec(getAgentIdentityEncoder(), getAgentIdentityDecoder());
}
