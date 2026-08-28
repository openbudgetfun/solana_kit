// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authorization_data.dart';

sealed class UseArgs {
  const UseArgs();
}

final class UseArgsV1 extends UseArgs {
  const UseArgsV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UseArgsV1 && authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() => 'UseArgs.V1(authorizationData: $authorizationData)';
}

Encoder<UseArgs> getUseArgsEncoder() {
  return transformEncoder<Map<String, Object?>, UseArgs>(
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
    (UseArgs value) => switch (value) {
      UseArgsV1(authorizationData: final authorizationData) =>
        <String, Object?>{'__kind': 0, 'authorizationData': authorizationData},
    },
  );
}

Decoder<UseArgs> getUseArgsDecoder() {
  return transformDecoder<Map<String, Object?>, UseArgs>(
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
          return UseArgsV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
      }
      throw StateError('Unsupported UseArgs discriminator: ${map['__kind']}');
    },
  );
}

Codec<UseArgs, UseArgs> getUseArgsCodec() {
  return combineCodec(getUseArgsEncoder(), getUseArgsDecoder());
}
