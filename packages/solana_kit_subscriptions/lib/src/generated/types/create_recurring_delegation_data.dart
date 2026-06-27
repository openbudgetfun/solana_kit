// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class CreateRecurringDelegationData {
  const CreateRecurringDelegationData({
    required this.nonce,
    required this.amountPerPeriod,
    required this.periodLengthS,
    required this.startTs,
    required this.expiryTs,
    required this.expectedSubscriptionAuthorityInitId,
  });

  final BigInt nonce;
  final BigInt amountPerPeriod;
  final BigInt periodLengthS;
  final BigInt startTs;
  final BigInt expiryTs;
  final BigInt expectedSubscriptionAuthorityInitId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateRecurringDelegationData &&
          runtimeType == other.runtimeType &&
          nonce == other.nonce &&
          amountPerPeriod == other.amountPerPeriod &&
          periodLengthS == other.periodLengthS &&
          startTs == other.startTs &&
          expiryTs == other.expiryTs &&
          expectedSubscriptionAuthorityInitId ==
              other.expectedSubscriptionAuthorityInitId;

  @override
  int get hashCode => Object.hash(
    nonce,
    amountPerPeriod,
    periodLengthS,
    startTs,
    expiryTs,
    expectedSubscriptionAuthorityInitId,
  );

  @override
  String toString() =>
      'CreateRecurringDelegationData(nonce: $nonce, amountPerPeriod: $amountPerPeriod, periodLengthS: $periodLengthS, startTs: $startTs, expiryTs: $expiryTs, expectedSubscriptionAuthorityInitId: $expectedSubscriptionAuthorityInitId)';
}

Encoder<CreateRecurringDelegationData>
getCreateRecurringDelegationDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('nonce', getU64Encoder()),
    ('amountPerPeriod', getU64Encoder()),
    ('periodLengthS', getU64Encoder()),
    ('startTs', getI64Encoder()),
    ('expiryTs', getI64Encoder()),
    ('expectedSubscriptionAuthorityInitId', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateRecurringDelegationData value) => <String, Object?>{
      'nonce': value.nonce,
      'amountPerPeriod': value.amountPerPeriod,
      'periodLengthS': value.periodLengthS,
      'startTs': value.startTs,
      'expiryTs': value.expiryTs,
      'expectedSubscriptionAuthorityInitId':
          value.expectedSubscriptionAuthorityInitId,
    },
  );
}

Decoder<CreateRecurringDelegationData>
getCreateRecurringDelegationDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('nonce', getU64Decoder()),
    ('amountPerPeriod', getU64Decoder()),
    ('periodLengthS', getU64Decoder()),
    ('startTs', getI64Decoder()),
    ('expiryTs', getI64Decoder()),
    ('expectedSubscriptionAuthorityInitId', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CreateRecurringDelegationData(
          nonce: map['nonce']! as BigInt,
          amountPerPeriod: map['amountPerPeriod']! as BigInt,
          periodLengthS: map['periodLengthS']! as BigInt,
          startTs: map['startTs']! as BigInt,
          expiryTs: map['expiryTs']! as BigInt,
          expectedSubscriptionAuthorityInitId:
              map['expectedSubscriptionAuthorityInitId']! as BigInt,
        ),
  );
}

Codec<CreateRecurringDelegationData, CreateRecurringDelegationData>
getCreateRecurringDelegationDataCodec() {
  return combineCodec(
    getCreateRecurringDelegationDataEncoder(),
    getCreateRecurringDelegationDataDecoder(),
  );
}
