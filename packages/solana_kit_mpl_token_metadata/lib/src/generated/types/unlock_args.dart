// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authorization_data.dart';

sealed class UnlockArgs {
  const UnlockArgs();
}

final class UnlockArgsV1 extends UnlockArgs {
  const UnlockArgsV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlockArgsV1 && authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() => 'UnlockArgs.V1(authorizationData: $authorizationData)';
}

Encoder<UnlockArgs> getUnlockArgsEncoder() {
  return transformEncoder<Map<String, Object?>, UnlockArgs>(
    getDiscriminatedUnionEncoder([
      (
        0,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
    ], size: getU8Encoder()),
    (UnlockArgs value) => switch (value) {
      UnlockArgsV1(authorizationData: final authorizationData) =>
        <String, Object?>{'__kind': 0, 'authorizationData': authorizationData},
    },
  );
}

Decoder<UnlockArgs> getUnlockArgsDecoder() {
  return transformDecoder<Map<String, Object?>, UnlockArgs>(
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
          return UnlockArgsV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
      }
      throw StateError(
        'Unsupported UnlockArgs discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<UnlockArgs, UnlockArgs> getUnlockArgsCodec() {
  return combineCodec(getUnlockArgsEncoder(), getUnlockArgsDecoder());
}
