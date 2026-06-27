// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


@immutable
class CreateFixedDelegationData {
  const CreateFixedDelegationData({
    required this.nonce,
    required this.amount,
    required this.expiryTs,
    required this.expectedSubscriptionAuthorityInitId,
  });

  final BigInt nonce;
  final BigInt amount;
  final BigInt expiryTs;
  final BigInt expectedSubscriptionAuthorityInitId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateFixedDelegationData &&
          runtimeType == other.runtimeType &&
          nonce == other.nonce &&
          amount == other.amount &&
          expiryTs == other.expiryTs &&
          expectedSubscriptionAuthorityInitId == other.expectedSubscriptionAuthorityInitId;

  @override
  int get hashCode => Object.hash(nonce, amount, expiryTs, expectedSubscriptionAuthorityInitId);

  @override
  String toString() => 'CreateFixedDelegationData(nonce: $nonce, amount: $amount, expiryTs: $expiryTs, expectedSubscriptionAuthorityInitId: $expectedSubscriptionAuthorityInitId)';
}

Encoder<CreateFixedDelegationData> getCreateFixedDelegationDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('nonce', getU64Encoder()),
    ('amount', getU64Encoder()),
    ('expiryTs', getI64Encoder()),
    ('expectedSubscriptionAuthorityInitId', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateFixedDelegationData value) => <String, Object?>{
      'nonce': value.nonce,
      'amount': value.amount,
      'expiryTs': value.expiryTs,
      'expectedSubscriptionAuthorityInitId': value.expectedSubscriptionAuthorityInitId,
    },
  );
}

Decoder<CreateFixedDelegationData> getCreateFixedDelegationDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('nonce', getU64Decoder()),
    ('amount', getU64Decoder()),
    ('expiryTs', getI64Decoder()),
    ('expectedSubscriptionAuthorityInitId', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CreateFixedDelegationData(
      nonce: map['nonce']! as BigInt,
      amount: map['amount']! as BigInt,
      expiryTs: map['expiryTs']! as BigInt,
      expectedSubscriptionAuthorityInitId: map['expectedSubscriptionAuthorityInitId']! as BigInt,
    ),
  );
}

Codec<CreateFixedDelegationData, CreateFixedDelegationData> getCreateFixedDelegationDataCodec() {
  return combineCodec(getCreateFixedDelegationDataEncoder(), getCreateFixedDelegationDataDecoder());
}
