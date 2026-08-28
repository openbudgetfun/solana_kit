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
class CloseEscrowAccountInstructionData {
  const CloseEscrowAccountInstructionData() : discriminator = 39;

  final int discriminator;
}

Encoder<CloseEscrowAccountInstructionData>
getCloseEscrowAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseEscrowAccountInstructionData value) => <String, Object?>{
      'discriminator': 39,
    },
  );
}

Decoder<CloseEscrowAccountInstructionData>
getCloseEscrowAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'closeEscrowAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CloseEscrowAccountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(39),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CloseEscrowAccountInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CloseEscrowAccountInstructionData>(
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
      VariableSizeDecoder<CloseEscrowAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CloseEscrowAccountInstructionData, CloseEscrowAccountInstructionData>
getCloseEscrowAccountInstructionDataCodec() {
  return combineCodec(
    getCloseEscrowAccountInstructionDataEncoder(),
    getCloseEscrowAccountInstructionDataDecoder(),
  );
}

/// Creates a [CloseEscrowAccount] instruction.
Instruction getCloseEscrowAccountInstruction({
  required Address programAddress,
  required Address escrow,
  required Address metadata,
  required Address mint,
  required Address tokenAccount,
  required Address edition,
  required Address payer,
  required Address systemProgram,
  required Address sysvarInstructions,
}) {
  final instructionData = CloseEscrowAccountInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: escrow, role: AccountRole.writable),
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: tokenAccount, role: AccountRole.readonly),
      AccountMeta(address: edition, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
    ],
    data: getCloseEscrowAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseEscrowAccount] instruction from raw instruction data.
CloseEscrowAccountInstructionData parseCloseEscrowAccountInstruction(
  Instruction instruction,
) {
  return getCloseEscrowAccountInstructionDataDecoder().decode(
    instruction.data!,
  );
}
