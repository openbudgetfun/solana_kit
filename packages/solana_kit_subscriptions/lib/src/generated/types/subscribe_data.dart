// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class SubscribeData {
  const SubscribeData({
    required this.planId,
    required this.planBump,
    required this.expectedMint,
    required this.expectedAmount,
    required this.expectedPeriodHours,
    required this.expectedCreatedAt,
    required this.expectedSubscriptionAuthorityInitId,
  });

  final BigInt planId;
  final int planBump;
  final Address expectedMint;
  final BigInt expectedAmount;
  final BigInt expectedPeriodHours;
  final BigInt expectedCreatedAt;
  final BigInt expectedSubscriptionAuthorityInitId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscribeData &&
          runtimeType == other.runtimeType &&
          planId == other.planId &&
          planBump == other.planBump &&
          expectedMint == other.expectedMint &&
          expectedAmount == other.expectedAmount &&
          expectedPeriodHours == other.expectedPeriodHours &&
          expectedCreatedAt == other.expectedCreatedAt &&
          expectedSubscriptionAuthorityInitId ==
              other.expectedSubscriptionAuthorityInitId;

  @override
  int get hashCode => Object.hash(
    planId,
    planBump,
    expectedMint,
    expectedAmount,
    expectedPeriodHours,
    expectedCreatedAt,
    expectedSubscriptionAuthorityInitId,
  );

  @override
  String toString() =>
      'SubscribeData(planId: $planId, planBump: $planBump, expectedMint: $expectedMint, expectedAmount: $expectedAmount, expectedPeriodHours: $expectedPeriodHours, expectedCreatedAt: $expectedCreatedAt, expectedSubscriptionAuthorityInitId: $expectedSubscriptionAuthorityInitId)';
}

Encoder<SubscribeData> getSubscribeDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('planId', getU64Encoder()),
    ('planBump', getU8Encoder()),
    ('expectedMint', getAddressEncoder()),
    ('expectedAmount', getU64Encoder()),
    ('expectedPeriodHours', getU64Encoder()),
    ('expectedCreatedAt', getI64Encoder()),
    ('expectedSubscriptionAuthorityInitId', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SubscribeData value) => <String, Object?>{
      'planId': value.planId,
      'planBump': value.planBump,
      'expectedMint': value.expectedMint,
      'expectedAmount': value.expectedAmount,
      'expectedPeriodHours': value.expectedPeriodHours,
      'expectedCreatedAt': value.expectedCreatedAt,
      'expectedSubscriptionAuthorityInitId':
          value.expectedSubscriptionAuthorityInitId,
    },
  );
}

Decoder<SubscribeData> getSubscribeDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('planId', getU64Decoder()),
    ('planBump', getU8Decoder()),
    ('expectedMint', getAddressDecoder()),
    ('expectedAmount', getU64Decoder()),
    ('expectedPeriodHours', getU64Decoder()),
    ('expectedCreatedAt', getI64Decoder()),
    ('expectedSubscriptionAuthorityInitId', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SubscribeData(
      planId: map['planId']! as BigInt,
      planBump: map['planBump']! as int,
      expectedMint: map['expectedMint']! as Address,
      expectedAmount: map['expectedAmount']! as BigInt,
      expectedPeriodHours: map['expectedPeriodHours']! as BigInt,
      expectedCreatedAt: map['expectedCreatedAt']! as BigInt,
      expectedSubscriptionAuthorityInitId:
          map['expectedSubscriptionAuthorityInitId']! as BigInt,
    ),
  );
}

Codec<SubscribeData, SubscribeData> getSubscribeDataCodec() {
  return combineCodec(getSubscribeDataEncoder(), getSubscribeDataDecoder());
}
