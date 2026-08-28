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
class CreateEscrowAccountInstructionData {
  const CreateEscrowAccountInstructionData() : discriminator = 38;

  final int discriminator;
}

Encoder<CreateEscrowAccountInstructionData>
getCreateEscrowAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateEscrowAccountInstructionData value) => <String, Object?>{
      'discriminator': 38,
    },
  );
}

Decoder<CreateEscrowAccountInstructionData>
getCreateEscrowAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createEscrowAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateEscrowAccountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(38),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateEscrowAccountInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateEscrowAccountInstructionData>(
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
      VariableSizeDecoder<CreateEscrowAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateEscrowAccountInstructionData, CreateEscrowAccountInstructionData>
getCreateEscrowAccountInstructionDataCodec() {
  return combineCodec(
    getCreateEscrowAccountInstructionDataEncoder(),
    getCreateEscrowAccountInstructionDataDecoder(),
  );
}

/// Creates a [CreateEscrowAccount] instruction.
Instruction getCreateEscrowAccountInstruction({
  required Address programAddress,
  required Address escrow,
  required Address metadata,
  required Address mint,
  required Address tokenAccount,
  required Address edition,
  required Address payer,
  required Address systemProgram,
  required Address sysvarInstructions,
  Address? authority,
}) {
  final instructionData = CreateEscrowAccountInstructionData();

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
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getCreateEscrowAccountInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateEscrowAccount] instruction from raw instruction data.
CreateEscrowAccountInstructionData parseCreateEscrowAccountInstruction(
  Instruction instruction,
) {
  return getCreateEscrowAccountInstructionDataDecoder().decode(
    instruction.data!,
  );
}
