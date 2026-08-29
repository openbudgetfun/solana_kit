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

import '../types/member.dart';

@immutable
class Multisig {
  Multisig({
    required this.createKey,
    required this.configAuthority,
    required this.threshold,
    required this.timeLock,
    required this.transactionIndex,
    required this.staleTransactionIndex,
    required this.rentCollector,
    required this.bump,
    required this.members,
  }) : discriminator = Uint8List.fromList([
         0xe0,
         0x74,
         0x79,
         0xba,
         0x44,
         0xa1,
         0x4f,
         0xec,
       ]);

  final Uint8List discriminator;
  final Address createKey;
  final Address configAuthority;
  final int threshold;
  final int timeLock;
  final BigInt transactionIndex;
  final BigInt staleTransactionIndex;
  final Address? rentCollector;
  final int bump;
  final List<Member> members;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Multisig &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          createKey == other.createKey &&
          configAuthority == other.configAuthority &&
          threshold == other.threshold &&
          timeLock == other.timeLock &&
          transactionIndex == other.transactionIndex &&
          staleTransactionIndex == other.staleTransactionIndex &&
          rentCollector == other.rentCollector &&
          bump == other.bump &&
          members == other.members;

  @override
  int get hashCode => Object.hash(
    discriminator,
    createKey,
    configAuthority,
    threshold,
    timeLock,
    transactionIndex,
    staleTransactionIndex,
    rentCollector,
    bump,
    members,
  );

  @override
  String toString() =>
      'Multisig(discriminator: $discriminator, createKey: $createKey, configAuthority: $configAuthority, threshold: $threshold, timeLock: $timeLock, transactionIndex: $transactionIndex, staleTransactionIndex: $staleTransactionIndex, rentCollector: $rentCollector, bump: $bump, members: $members)';
}

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<Multisig> getMultisigEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('createKey', getAddressEncoder()),
    ('configAuthority', getAddressEncoder()),
    ('threshold', getU16Encoder()),
    ('timeLock', getU32Encoder()),
    ('transactionIndex', getU64Encoder()),
    ('staleTransactionIndex', getU64Encoder()),
    (
      'rentCollector',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    ('bump', getU8Encoder()),
    (
      'members',
      getArrayEncoder(
        transformEncoder(getMemberEncoder(), (Member value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Multisig value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xe0,
        0x74,
        0x79,
        0xba,
        0x44,
        0xa1,
        0x4f,
        0xec,
      ]),
      'createKey': value.createKey,
      'configAuthority': value.configAuthority,
      'threshold': value.threshold,
      'timeLock': value.timeLock,
      'transactionIndex': value.transactionIndex,
      'staleTransactionIndex': value.staleTransactionIndex,
      'rentCollector': value.rentCollector,
      'bump': value.bump,
      'members': value.members,
    },
  );
}

Decoder<Multisig> getMultisigDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('createKey', getAddressDecoder()),
    ('configAuthority', getAddressDecoder()),
    ('threshold', getU16Decoder()),
    ('timeLock', getU32Decoder()),
    ('transactionIndex', getU64Decoder()),
    ('staleTransactionIndex', getU64Decoder()),
    ('rentCollector', getNullableDecoder<Address>(getAddressDecoder())),
    ('bump', getU8Decoder()),
    ('members', getArrayDecoder(getMemberDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'multisig account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (Multisig, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xe0, 0x74, 0x79, 0xba, 0x44, 0xa1, 0x4f, 0xec]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      Multisig(
        createKey: map['createKey']! as Address,
        configAuthority: map['configAuthority']! as Address,
        threshold: map['threshold']! as int,
        timeLock: map['timeLock']! as int,
        transactionIndex: map['transactionIndex']! as BigInt,
        staleTransactionIndex: map['staleTransactionIndex']! as BigInt,
        rentCollector: map['rentCollector'] as Address?,
        bump: map['bump']! as int,
        members: map['members']! as List<Member>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<Multisig>(
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
      VariableSizeDecoder<Multisig>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<Multisig, Multisig> getMultisigCodec() {
  return combineCodec(getMultisigEncoder(), getMultisigDecoder());
}

Account<Multisig> decodeMultisig(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getMultisigDecoder());
}
