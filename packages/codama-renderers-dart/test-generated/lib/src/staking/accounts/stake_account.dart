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
class StakeAccount {
  StakeAccount({
    required this.owner,
    required this.pool,
    required this.stakedAmount,
    required this.rewardDebt,
    required this.stakedAt,
    required this.bump,
  }) : discriminator = Uint8List.fromList([
         0x50,
         0x9e,
         0x43,
         0x7c,
         0x32,
         0xbd,
         0xc0,
         0xff,
       ]);

  final Uint8List discriminator;
  final Address owner;
  final Address pool;
  final BigInt stakedAmount;
  final BigInt rewardDebt;
  final BigInt stakedAt;
  final int bump;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeAccount &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          owner == other.owner &&
          pool == other.pool &&
          stakedAmount == other.stakedAmount &&
          rewardDebt == other.rewardDebt &&
          stakedAt == other.stakedAt &&
          bump == other.bump;

  @override
  int get hashCode => Object.hash(
    discriminator,
    owner,
    pool,
    stakedAmount,
    rewardDebt,
    stakedAt,
    bump,
  );

  @override
  String toString() =>
      'StakeAccount(discriminator: $discriminator, owner: $owner, pool: $pool, stakedAmount: $stakedAmount, rewardDebt: $rewardDebt, stakedAt: $stakedAt, bump: $bump)';
}

/// The size of the [StakeAccount] account data in bytes.
const int stakeAccountSize = 97;

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<StakeAccount> getStakeAccountEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('owner', getAddressEncoder()),
    ('pool', getAddressEncoder()),
    ('stakedAmount', getU64Encoder()),
    ('rewardDebt', getU64Encoder()),
    ('stakedAt', getI64Encoder()),
    ('bump', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (StakeAccount value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x50,
        0x9e,
        0x43,
        0x7c,
        0x32,
        0xbd,
        0xc0,
        0xff,
      ]),
      'owner': value.owner,
      'pool': value.pool,
      'stakedAmount': value.stakedAmount,
      'rewardDebt': value.rewardDebt,
      'stakedAt': value.stakedAt,
      'bump': value.bump,
    },
  );
}

Decoder<StakeAccount> getStakeAccountDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('owner', getAddressDecoder()),
    ('pool', getAddressDecoder()),
    ('stakedAmount', getU64Decoder()),
    ('rewardDebt', getU64Decoder()),
    ('stakedAt', getI64Decoder()),
    ('bump', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'stakeAccount account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (StakeAccount, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x50, 0x9e, 0x43, 0x7c, 0x32, 0xbd, 0xc0, 0xff]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      StakeAccount(
        owner: map['owner']! as Address,
        pool: map['pool']! as Address,
        stakedAmount: map['stakedAmount']! as BigInt,
        rewardDebt: map['rewardDebt']! as BigInt,
        stakedAt: map['stakedAt']! as BigInt,
        bump: map['bump']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<StakeAccount>(
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
      VariableSizeDecoder<StakeAccount>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<StakeAccount, StakeAccount> getStakeAccountCodec() {
  return combineCodec(getStakeAccountEncoder(), getStakeAccountDecoder());
}

Account<StakeAccount> decodeStakeAccount(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getStakeAccountDecoder());
}
