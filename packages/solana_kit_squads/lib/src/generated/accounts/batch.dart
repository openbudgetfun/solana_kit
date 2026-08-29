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
class Batch {
  Batch({
    required this.multisig,
    required this.creator,
    required this.index,
    required this.bump,
    required this.vaultIndex,
    required this.vaultBump,
    required this.size,
    required this.executedTransactionIndex,
  }) : discriminator = Uint8List.fromList([
         0x9c,
         0xc2,
         0x46,
         0x2c,
         0x16,
         0x58,
         0x89,
         0x2c,
       ]);

  final Uint8List discriminator;
  final Address multisig;
  final Address creator;
  final BigInt index;
  final int bump;
  final int vaultIndex;
  final int vaultBump;
  final int size;
  final int executedTransactionIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Batch &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          multisig == other.multisig &&
          creator == other.creator &&
          index == other.index &&
          bump == other.bump &&
          vaultIndex == other.vaultIndex &&
          vaultBump == other.vaultBump &&
          size == other.size &&
          executedTransactionIndex == other.executedTransactionIndex;

  @override
  int get hashCode => Object.hash(
    discriminator,
    multisig,
    creator,
    index,
    bump,
    vaultIndex,
    vaultBump,
    size,
    executedTransactionIndex,
  );

  @override
  String toString() =>
      'Batch(discriminator: $discriminator, multisig: $multisig, creator: $creator, index: $index, bump: $bump, vaultIndex: $vaultIndex, vaultBump: $vaultBump, size: $size, executedTransactionIndex: $executedTransactionIndex)';
}

/// The size of the [Batch] account data in bytes.
const int batchSize = 91;

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<Batch> getBatchEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('multisig', getAddressEncoder()),
    ('creator', getAddressEncoder()),
    ('index', getU64Encoder()),
    ('bump', getU8Encoder()),
    ('vaultIndex', getU8Encoder()),
    ('vaultBump', getU8Encoder()),
    ('size', getU32Encoder()),
    ('executedTransactionIndex', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Batch value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x9c,
        0xc2,
        0x46,
        0x2c,
        0x16,
        0x58,
        0x89,
        0x2c,
      ]),
      'multisig': value.multisig,
      'creator': value.creator,
      'index': value.index,
      'bump': value.bump,
      'vaultIndex': value.vaultIndex,
      'vaultBump': value.vaultBump,
      'size': value.size,
      'executedTransactionIndex': value.executedTransactionIndex,
    },
  );
}

Decoder<Batch> getBatchDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('multisig', getAddressDecoder()),
    ('creator', getAddressDecoder()),
    ('index', getU64Decoder()),
    ('bump', getU8Decoder()),
    ('vaultIndex', getU8Decoder()),
    ('vaultBump', getU8Decoder()),
    ('size', getU32Decoder()),
    ('executedTransactionIndex', getU32Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'batch account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (Batch, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x9c, 0xc2, 0x46, 0x2c, 0x16, 0x58, 0x89, 0x2c]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      Batch(
        multisig: map['multisig']! as Address,
        creator: map['creator']! as Address,
        index: map['index']! as BigInt,
        bump: map['bump']! as int,
        vaultIndex: map['vaultIndex']! as int,
        vaultBump: map['vaultBump']! as int,
        size: map['size']! as int,
        executedTransactionIndex: map['executedTransactionIndex']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<Batch>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() => VariableSizeDecoder<Batch>(
      read: readTopLevel,
      maxSize: structDecoder.maxSize,
    ),
  };
}

Codec<Batch, Batch> getBatchCodec() {
  return combineCodec(getBatchEncoder(), getBatchDecoder());
}

Account<Batch> decodeBatch(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getBatchDecoder());
}
