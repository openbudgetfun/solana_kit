// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class TransactionBufferCloseInstructionData {
  TransactionBufferCloseInstructionData()
    : discriminator = Uint8List.fromList([
        0x11,
        0xb6,
        0xd0,
        0xe4,
        0x88,
        0x18,
        0xb2,
        0x66,
      ]);

  final Uint8List discriminator;
}

Encoder<TransactionBufferCloseInstructionData>
getTransactionBufferCloseInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (TransactionBufferCloseInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x11,
        0xb6,
        0xd0,
        0xe4,
        0x88,
        0x18,
        0xb2,
        0x66,
      ]),
    },
  );
}

Decoder<TransactionBufferCloseInstructionData>
getTransactionBufferCloseInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'transactionBufferClose instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TransactionBufferCloseInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x11, 0xb6, 0xd0, 0xe4, 0x88, 0x18, 0xb2, 0x66]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      TransactionBufferCloseInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TransactionBufferCloseInstructionData>(
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
      VariableSizeDecoder<TransactionBufferCloseInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  TransactionBufferCloseInstructionData,
  TransactionBufferCloseInstructionData
>
getTransactionBufferCloseInstructionDataCodec() {
  return combineCodec(
    getTransactionBufferCloseInstructionDataEncoder(),
    getTransactionBufferCloseInstructionDataDecoder(),
  );
}

/// Creates a [TransactionBufferClose] instruction.
Instruction getTransactionBufferCloseInstruction({
  required Address programAddress,
  required Address multisig,
  required Address transactionBuffer,
  required Address creator,
}) {
  final instructionData = TransactionBufferCloseInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: transactionBuffer, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
    ],
    data: getTransactionBufferCloseInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [TransactionBufferClose] instruction from raw instruction data.
TransactionBufferCloseInstructionData parseTransactionBufferCloseInstruction(
  Instruction instruction,
) {
  return getTransactionBufferCloseInstructionDataDecoder().decode(
    instruction.data!,
  );
}
