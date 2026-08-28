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
class TransactionBuffer {
  TransactionBuffer({
    required this.multisig,
    required this.creator,
    required this.bufferIndex,
    required this.vaultIndex,
    required this.finalBufferHash,
    required this.finalBufferSize,
    required this.buffer,
  }) : discriminator = Uint8List.fromList([
         0x5a,
         0x24,
         0x23,
         0xdb,
         0x5d,
         0xe1,
         0x6e,
         0x60,
       ]);

  final Uint8List discriminator;
  final Address multisig;
  final Address creator;
  final int bufferIndex;
  final int vaultIndex;
  final Uint8List finalBufferHash;
  final int finalBufferSize;
  final Uint8List buffer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionBuffer &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          multisig == other.multisig &&
          creator == other.creator &&
          bufferIndex == other.bufferIndex &&
          vaultIndex == other.vaultIndex &&
          finalBufferHash == other.finalBufferHash &&
          finalBufferSize == other.finalBufferSize &&
          buffer == other.buffer;

  @override
  int get hashCode => Object.hash(
    discriminator,
    multisig,
    creator,
    bufferIndex,
    vaultIndex,
    finalBufferHash,
    finalBufferSize,
    buffer,
  );

  @override
  String toString() =>
      'TransactionBuffer(discriminator: $discriminator, multisig: $multisig, creator: $creator, bufferIndex: $bufferIndex, vaultIndex: $vaultIndex, finalBufferHash: $finalBufferHash, finalBufferSize: $finalBufferSize, buffer: $buffer)';
}

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<TransactionBuffer> getTransactionBufferEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('multisig', getAddressEncoder()),
    ('creator', getAddressEncoder()),
    ('bufferIndex', getU8Encoder()),
    ('vaultIndex', getU8Encoder()),
    (
      'finalBufferHash',
      fixEncoderSize(getBytesEncoder(), 32, allowTruncation: false),
    ),
    ('finalBufferSize', getU16Encoder()),
    ('buffer', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (TransactionBuffer value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x5a,
        0x24,
        0x23,
        0xdb,
        0x5d,
        0xe1,
        0x6e,
        0x60,
      ]),
      'multisig': value.multisig,
      'creator': value.creator,
      'bufferIndex': value.bufferIndex,
      'vaultIndex': value.vaultIndex,
      'finalBufferHash': value.finalBufferHash,
      'finalBufferSize': value.finalBufferSize,
      'buffer': value.buffer,
    },
  );
}

Decoder<TransactionBuffer> getTransactionBufferDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('multisig', getAddressDecoder()),
    ('creator', getAddressDecoder()),
    ('bufferIndex', getU8Decoder()),
    ('vaultIndex', getU8Decoder()),
    ('finalBufferHash', fixDecoderSize(getBytesDecoder(), 32)),
    ('finalBufferSize', getU16Decoder()),
    ('buffer', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'transactionBuffer account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TransactionBuffer, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x5a, 0x24, 0x23, 0xdb, 0x5d, 0xe1, 0x6e, 0x60]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      TransactionBuffer(
        multisig: map['multisig']! as Address,
        creator: map['creator']! as Address,
        bufferIndex: map['bufferIndex']! as int,
        vaultIndex: map['vaultIndex']! as int,
        finalBufferHash: map['finalBufferHash']! as Uint8List,
        finalBufferSize: map['finalBufferSize']! as int,
        buffer: map['buffer']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TransactionBuffer>(
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
      VariableSizeDecoder<TransactionBuffer>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<TransactionBuffer, TransactionBuffer> getTransactionBufferCodec() {
  return combineCodec(
    getTransactionBufferEncoder(),
    getTransactionBufferDecoder(),
  );
}

Account<TransactionBuffer> decodeTransactionBuffer(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getTransactionBufferDecoder());
}
