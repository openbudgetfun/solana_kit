// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authorization_data.dart';

sealed class MintArgs {
  const MintArgs();
}

final class MintArgsV1 extends MintArgs {
  const MintArgsV1({
    required this.amount,
    required this.authorizationData,
  });

  final BigInt amount;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MintArgsV1 &&
          amount == other.amount &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(amount, authorizationData);

  @override
  String toString() =>
      'MintArgs.V1(amount: $amount, authorizationData: $authorizationData)';
}

Encoder<MintArgs> getMintArgsEncoder() {
  return transformEncoder<Map<String, Object?>, MintArgs>(
    getDiscriminatedUnionEncoder([
      (
        0,
        getStructEncoder([
          ('amount', getU64Encoder()),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
    ], size: getU8Encoder()),
    (MintArgs value) => switch (value) {
      MintArgsV1(
        amount: final amount,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 0,
          'amount': amount,
          'authorizationData': authorizationData,
        },
    },
  );
}

Decoder<MintArgs> getMintArgsDecoder() {
  return transformDecoder<Map<String, Object?>, MintArgs>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('amount', getU64Decoder()),
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
          return MintArgsV1(
            amount: map['amount']! as BigInt,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
      }
      throw StateError('Unsupported MintArgs discriminator: ${map['__kind']}');
    },
  );
}

Codec<MintArgs, MintArgs> getMintArgsCodec() {
  return combineCodec(getMintArgsEncoder(), getMintArgsDecoder());
}
