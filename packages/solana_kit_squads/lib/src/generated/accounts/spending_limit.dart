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

import '../types/period.dart';

@immutable
class SpendingLimit {
  SpendingLimit({
    required this.multisig,
    required this.createKey,
    required this.vaultIndex,
    required this.mint,
    required this.amount,
    required this.period,
    required this.remainingAmount,
    required this.lastReset,
    required this.bump,
    required this.members,
    required this.destinations,
  }) : discriminator = Uint8List.fromList([
         0x0a,
         0xc9,
         0x1b,
         0xa0,
         0xda,
         0xc3,
         0xde,
         0x98,
       ]);

  final Uint8List discriminator;
  final Address multisig;
  final Address createKey;
  final int vaultIndex;
  final Address mint;
  final BigInt amount;
  final Period period;
  final BigInt remainingAmount;
  final BigInt lastReset;
  final int bump;
  final List<Address> members;
  final List<Address> destinations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpendingLimit &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          multisig == other.multisig &&
          createKey == other.createKey &&
          vaultIndex == other.vaultIndex &&
          mint == other.mint &&
          amount == other.amount &&
          period == other.period &&
          remainingAmount == other.remainingAmount &&
          lastReset == other.lastReset &&
          bump == other.bump &&
          members == other.members &&
          destinations == other.destinations;

  @override
  int get hashCode => Object.hash(
    discriminator,
    multisig,
    createKey,
    vaultIndex,
    mint,
    amount,
    period,
    remainingAmount,
    lastReset,
    bump,
    members,
    destinations,
  );

  @override
  String toString() =>
      'SpendingLimit(discriminator: $discriminator, multisig: $multisig, createKey: $createKey, vaultIndex: $vaultIndex, mint: $mint, amount: $amount, period: $period, remainingAmount: $remainingAmount, lastReset: $lastReset, bump: $bump, members: $members, destinations: $destinations)';
}

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<SpendingLimit> getSpendingLimitEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('multisig', getAddressEncoder()),
    ('createKey', getAddressEncoder()),
    ('vaultIndex', getU8Encoder()),
    ('mint', getAddressEncoder()),
    ('amount', getU64Encoder()),
    ('period', getPeriodEncoder()),
    ('remainingAmount', getU64Encoder()),
    ('lastReset', getI64Encoder()),
    ('bump', getU8Encoder()),
    (
      'members',
      getArrayEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'destinations',
      getArrayEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (SpendingLimit value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x0a,
        0xc9,
        0x1b,
        0xa0,
        0xda,
        0xc3,
        0xde,
        0x98,
      ]),
      'multisig': value.multisig,
      'createKey': value.createKey,
      'vaultIndex': value.vaultIndex,
      'mint': value.mint,
      'amount': value.amount,
      'period': value.period,
      'remainingAmount': value.remainingAmount,
      'lastReset': value.lastReset,
      'bump': value.bump,
      'members': value.members,
      'destinations': value.destinations,
    },
  );
}

Decoder<SpendingLimit> getSpendingLimitDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('multisig', getAddressDecoder()),
    ('createKey', getAddressDecoder()),
    ('vaultIndex', getU8Decoder()),
    ('mint', getAddressDecoder()),
    ('amount', getU64Decoder()),
    ('period', getPeriodDecoder()),
    ('remainingAmount', getU64Decoder()),
    ('lastReset', getI64Decoder()),
    ('bump', getU8Decoder()),
    ('members', getArrayDecoder(getAddressDecoder())),
    ('destinations', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'spendingLimit account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SpendingLimit, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x0a, 0xc9, 0x1b, 0xa0, 0xda, 0xc3, 0xde, 0x98]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      SpendingLimit(
        multisig: map['multisig']! as Address,
        createKey: map['createKey']! as Address,
        vaultIndex: map['vaultIndex']! as int,
        mint: map['mint']! as Address,
        amount: map['amount']! as BigInt,
        period: map['period']! as Period,
        remainingAmount: map['remainingAmount']! as BigInt,
        lastReset: map['lastReset']! as BigInt,
        bump: map['bump']! as int,
        members: map['members']! as List<Address>,
        destinations: map['destinations']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<SpendingLimit>(
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
      VariableSizeDecoder<SpendingLimit>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SpendingLimit, SpendingLimit> getSpendingLimitCodec() {
  return combineCodec(getSpendingLimitEncoder(), getSpendingLimitDecoder());
}

Account<SpendingLimit> decodeSpendingLimit(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getSpendingLimitDecoder());
}
