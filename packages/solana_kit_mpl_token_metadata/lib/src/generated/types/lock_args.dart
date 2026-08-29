// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authorization_data.dart';

sealed class LockArgs {
  const LockArgs();
}

final class LockArgsV1 extends LockArgs {
  const LockArgsV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LockArgsV1 && authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() => 'LockArgs.V1(authorizationData: $authorizationData)';
}

Encoder<LockArgs> getLockArgsEncoder() {
  return transformEncoder<Map<String, Object?>, LockArgs>(
    getDiscriminatedUnionEncoder([
      (
        0,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              transformEncoder(
                getAuthorizationDataEncoder(),
                (AuthorizationData value) => value,
              ),
            ),
          ),
        ]),
      ),
    ], size: getU8Encoder()),
    (LockArgs value) => switch (value) {
      LockArgsV1(authorizationData: final authorizationData) =>
        <String, Object?>{'__kind': 0, 'authorizationData': authorizationData},
    },
  );
}

Decoder<LockArgs> getLockArgsDecoder() {
  return transformDecoder<Map<String, Object?>, LockArgs>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return LockArgsV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
      }
      throw StateError('Unsupported LockArgs discriminator: ${map['__kind']}');
    },
  );
}

Codec<LockArgs, LockArgs> getLockArgsCodec() {
  return combineCodec(getLockArgsEncoder(), getLockArgsDecoder());
}
