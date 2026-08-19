// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

@immutable
class StakePool {
  StakePool({
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
  }) : discriminator = Uint8List.fromList([
         0x79,
         0x22,
         0xce,
         0x15,
         0x4f,
         0x7f,
         0xff,
         0x1c,
       ]);

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
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
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
      'discriminator': Uint8List.fromList([
        0x79,
        0x22,
        0xce,
        0x15,
        0x4f,
        0x7f,
        0xff,
        0x1c,
      ]),
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

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'stakePool account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (StakePool, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8).encode(
        Uint8List.fromList([0x79, 0x22, 0xce, 0x15, 0x4f, 0x7f, 0xff, 0x1c]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      StakePool(
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
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<StakePool>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<StakePool>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<StakePool, StakePool> getStakePoolCodec() {
  return combineCodec(getStakePoolEncoder(), getStakePoolDecoder());
}

Account<StakePool> decodeStakePool(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getStakePoolDecoder());
}
