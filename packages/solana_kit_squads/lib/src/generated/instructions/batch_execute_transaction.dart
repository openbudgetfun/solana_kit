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
class BatchExecuteTransactionInstructionData {
  BatchExecuteTransactionInstructionData()
    : discriminator = Uint8List.fromList([
        0xac,
        0x2c,
        0xb3,
        0x98,
        0x15,
        0x7f,
        0xea,
        0xb4,
      ]);

  final Uint8List discriminator;
}

Encoder<BatchExecuteTransactionInstructionData>
getBatchExecuteTransactionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (BatchExecuteTransactionInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xac,
        0x2c,
        0xb3,
        0x98,
        0x15,
        0x7f,
        0xea,
        0xb4,
      ]),
    },
  );
}

Decoder<BatchExecuteTransactionInstructionData>
getBatchExecuteTransactionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'batchExecuteTransaction instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BatchExecuteTransactionInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xac, 0x2c, 0xb3, 0x98, 0x15, 0x7f, 0xea, 0xb4]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BatchExecuteTransactionInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BatchExecuteTransactionInstructionData>(
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
      VariableSizeDecoder<BatchExecuteTransactionInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  BatchExecuteTransactionInstructionData,
  BatchExecuteTransactionInstructionData
>
getBatchExecuteTransactionInstructionDataCodec() {
  return combineCodec(
    getBatchExecuteTransactionInstructionDataEncoder(),
    getBatchExecuteTransactionInstructionDataDecoder(),
  );
}

/// Creates a [BatchExecuteTransaction] instruction.
Instruction getBatchExecuteTransactionInstruction({
  required Address programAddress,
  required Address multisig,
  required Address member,
  required Address proposal,
  required Address batch,
  required Address transaction,
}) {
  final instructionData = BatchExecuteTransactionInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: member, role: AccountRole.readonlySigner),
      AccountMeta(address: proposal, role: AccountRole.writable),
      AccountMeta(address: batch, role: AccountRole.writable),
      AccountMeta(address: transaction, role: AccountRole.readonly),
    ],
    data: getBatchExecuteTransactionInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [BatchExecuteTransaction] instruction from raw instruction data.
BatchExecuteTransactionInstructionData parseBatchExecuteTransactionInstruction(
  Instruction instruction,
) {
  return getBatchExecuteTransactionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
