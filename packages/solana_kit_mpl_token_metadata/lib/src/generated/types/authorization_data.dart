// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './payload.dart';

@immutable
class AuthorizationData {
  const AuthorizationData({
    required this.payload,
  });

  final Payload payload;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizationData &&
          runtimeType == other.runtimeType &&
          payload == other.payload;

  @override
  int get hashCode => payload.hashCode;

  @override
  String toString() => 'AuthorizationData(payload: $payload)';
}

Encoder<AuthorizationData> getAuthorizationDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('payload', getPayloadEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizationData value) => <String, Object?>{
      'payload': value.payload,
    },
  );
}

Decoder<AuthorizationData> getAuthorizationDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('payload', getPayloadDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AuthorizationData(
          payload: map['payload']! as Payload,
        ),
  );
}

Codec<AuthorizationData, AuthorizationData> getAuthorizationDataCodec() {
  return combineCodec(
    getAuthorizationDataEncoder(),
    getAuthorizationDataDecoder(),
  );
}
