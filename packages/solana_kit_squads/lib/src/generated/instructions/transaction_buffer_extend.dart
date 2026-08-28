// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class TransactionBufferExtendInstructionData {
  TransactionBufferExtendInstructionData({
    required this.buffer,
  }) : discriminator = Uint8List.fromList([
         0xe6,
         0x9d,
         0x43,
         0x38,
         0x05,
         0xee,
         0xf5,
         0x92,
       ]);

  final Uint8List discriminator;
  final Uint8List buffer;
}

Encoder<TransactionBufferExtendInstructionData>
getTransactionBufferExtendInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('buffer', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (TransactionBufferExtendInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xe6,
        0x9d,
        0x43,
        0x38,
        0x05,
        0xee,
        0xf5,
        0x92,
      ]),
      'buffer': value.buffer,
    },
  );
}

Decoder<TransactionBufferExtendInstructionData>
getTransactionBufferExtendInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('buffer', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'transactionBufferExtend instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TransactionBufferExtendInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xe6, 0x9d, 0x43, 0x38, 0x05, 0xee, 0xf5, 0x92]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      TransactionBufferExtendInstructionData(
        buffer: map['buffer']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TransactionBufferExtendInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<TransactionBufferExtendInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  TransactionBufferExtendInstructionData,
  TransactionBufferExtendInstructionData
>
getTransactionBufferExtendInstructionDataCodec() {
  return combineCodec(
    getTransactionBufferExtendInstructionDataEncoder(),
    getTransactionBufferExtendInstructionDataDecoder(),
  );
}

/// Creates a [TransactionBufferExtend] instruction.
Instruction getTransactionBufferExtendInstruction({
  required Address programAddress,
  required Address multisig,
  required Address transactionBuffer,
  required Address creator,
  required Uint8List buffer,
}) {
  final instructionData = TransactionBufferExtendInstructionData(
    buffer: buffer,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: transactionBuffer, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
    ],
    data: getTransactionBufferExtendInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [TransactionBufferExtend] instruction from raw instruction data.
TransactionBufferExtendInstructionData parseTransactionBufferExtendInstruction(
  Instruction instruction,
) {
  return getTransactionBufferExtendInstructionDataDecoder().decode(
    instruction.data!,
  );
}
