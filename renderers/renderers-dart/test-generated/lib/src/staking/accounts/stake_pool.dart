// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class StakePool {
  const StakePool({
    required this.discriminator,
    required this.admin,
    required this.rewardMint,
    required this.stakeMint,
    required this.totalStaked,
    required this.rewardRate,
    required this.minStakeDuration,
    required this.maxStakers,
    required this.currentStakers,
    required this.isActive,
    required this.bump,
  });

  final Uint8List discriminator;
  final Address admin;
  final Address rewardMint;
  final Address stakeMint;
  final BigInt totalStaked;
  final BigInt rewardRate;
  final BigInt minStakeDuration;
  final int maxStakers;
  final int currentStakers;
  final bool isActive;
  final int bump;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakePool &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          admin == other.admin &&
          rewardMint == other.rewardMint &&
          stakeMint == other.stakeMint &&
          totalStaked == other.totalStaked &&
          rewardRate == other.rewardRate &&
          minStakeDuration == other.minStakeDuration &&
          maxStakers == other.maxStakers &&
          currentStakers == other.currentStakers &&
          isActive == other.isActive &&
          bump == other.bump;

  @override
  int get hashCode => Object.hash(
    discriminator,
    admin,
    rewardMint,
    stakeMint,
    totalStaked,
    rewardRate,
    minStakeDuration,
    maxStakers,
    currentStakers,
    isActive,
    bump,
  );

  @override
  String toString() =>
      'StakePool(discriminator: $discriminator, admin: $admin, rewardMint: $rewardMint, stakeMint: $stakeMint, totalStaked: $totalStaked, rewardRate: $rewardRate, minStakeDuration: $minStakeDuration, maxStakers: $maxStakers, currentStakers: $currentStakers, isActive: $isActive, bump: $bump)';
}

/// The size of the [StakePool] account data in bytes.
const int stakePoolSize = 138;

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<StakePool> getStakePoolEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', fixEncoderSize(getBytesEncoder(), 8)),
    ('admin', getAddressEncoder()),
    ('rewardMint', getAddressEncoder()),
    ('stakeMint', getAddressEncoder()),
    ('totalStaked', getU64Encoder()),
    ('rewardRate', getU64Encoder()),
    ('minStakeDuration', getI64Encoder()),
    ('maxStakers', getU32Encoder()),
    ('currentStakers', getU32Encoder()),
    ('isActive', getBooleanEncoder()),
    ('bump', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (StakePool value) => <String, Object?>{
      'discriminator': value.discriminator,
      'admin': value.admin,
      'rewardMint': value.rewardMint,
      'stakeMint': value.stakeMint,
      'totalStaked': value.totalStaked,
      'rewardRate': value.rewardRate,
      'minStakeDuration': value.minStakeDuration,
      'maxStakers': value.maxStakers,
      'currentStakers': value.currentStakers,
      'isActive': value.isActive,
      'bump': value.bump,
    },
  );
}

Decoder<StakePool> getStakePoolDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('admin', getAddressDecoder()),
    ('rewardMint', getAddressDecoder()),
    ('stakeMint', getAddressDecoder()),
    ('totalStaked', getU64Decoder()),
    ('rewardRate', getU64Decoder()),
    ('minStakeDuration', getI64Decoder()),
    ('maxStakers', getU32Decoder()),
    ('currentStakers', getU32Decoder()),
    ('isActive', getBooleanDecoder()),
    ('bump', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => StakePool(
      discriminator: map['discriminator']! as Uint8List,
      admin: map['admin']! as Address,
      rewardMint: map['rewardMint']! as Address,
      stakeMint: map['stakeMint']! as Address,
      totalStaked: map['totalStaked']! as BigInt,
      rewardRate: map['rewardRate']! as BigInt,
      minStakeDuration: map['minStakeDuration']! as BigInt,
      maxStakers: map['maxStakers']! as int,
      currentStakers: map['currentStakers']! as int,
      isActive: map['isActive']! as bool,
      bump: map['bump']! as int,
    ),
  );
}

Codec<StakePool, StakePool> getStakePoolCodec() {
  return combineCodec(getStakePoolEncoder(), getStakePoolDecoder());
}

Account<StakePool> decodeStakePool(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getStakePoolDecoder());
}
