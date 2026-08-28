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
class BatchAccountsCloseInstructionData {
  BatchAccountsCloseInstructionData()
    : discriminator = Uint8List.fromList([
        0xda,
        0xc4,
        0x07,
        0xaf,
        0x82,
        0x66,
        0x0b,
        0xff,
      ]);

  final Uint8List discriminator;
}

Encoder<BatchAccountsCloseInstructionData>
getBatchAccountsCloseInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (BatchAccountsCloseInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xda,
        0xc4,
        0x07,
        0xaf,
        0x82,
        0x66,
        0x0b,
        0xff,
      ]),
    },
  );
}

Decoder<BatchAccountsCloseInstructionData>
getBatchAccountsCloseInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'batchAccountsClose instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BatchAccountsCloseInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xda, 0xc4, 0x07, 0xaf, 0x82, 0x66, 0x0b, 0xff]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BatchAccountsCloseInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BatchAccountsCloseInstructionData>(
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
      VariableSizeDecoder<BatchAccountsCloseInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<BatchAccountsCloseInstructionData, BatchAccountsCloseInstructionData>
getBatchAccountsCloseInstructionDataCodec() {
  return combineCodec(
    getBatchAccountsCloseInstructionDataEncoder(),
    getBatchAccountsCloseInstructionDataDecoder(),
  );
}

/// Creates a [BatchAccountsClose] instruction.
Instruction getBatchAccountsCloseInstruction({
  required Address programAddress,
  required Address multisig,
  required Address proposal,
  required Address batch,
  required Address rentCollector,
  required Address systemProgram,
}) {
  final instructionData = BatchAccountsCloseInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: proposal, role: AccountRole.writable),
      AccountMeta(address: batch, role: AccountRole.writable),
      AccountMeta(address: rentCollector, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getBatchAccountsCloseInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [BatchAccountsClose] instruction from raw instruction data.
BatchAccountsCloseInstructionData parseBatchAccountsCloseInstruction(
  Instruction instruction,
) {
  return getBatchAccountsCloseInstructionDataDecoder().decode(
    instruction.data!,
  );
}
