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
class CreateMasterEditionInstructionData {
  const CreateMasterEditionInstructionData() : discriminator = 10;

  final int discriminator;
}

Encoder<CreateMasterEditionInstructionData>
getCreateMasterEditionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateMasterEditionInstructionData value) => <String, Object?>{
      'discriminator': 10,
    },
  );
}

Decoder<CreateMasterEditionInstructionData>
getCreateMasterEditionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createMasterEdition instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateMasterEditionInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(10),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateMasterEditionInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateMasterEditionInstructionData>(
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
      VariableSizeDecoder<CreateMasterEditionInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateMasterEditionInstructionData, CreateMasterEditionInstructionData>
getCreateMasterEditionInstructionDataCodec() {
  return combineCodec(
    getCreateMasterEditionInstructionDataEncoder(),
    getCreateMasterEditionInstructionDataDecoder(),
  );
}

/// Creates a [CreateMasterEdition] instruction.
Instruction getCreateMasterEditionInstruction({
  required Address programAddress,
  required Address edition,
  required Address mint,
  required Address updateAuthority,
  required Address mintAuthority,
  required Address payer,
  required Address metadata,
  required Address tokenProgram,
  required Address systemProgram,
  required Address rent,
}) {
  final instructionData = CreateMasterEditionInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: edition, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getCreateMasterEditionInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateMasterEdition] instruction from raw instruction data.
CreateMasterEditionInstructionData parseCreateMasterEditionInstruction(
  Instruction instruction,
) {
  return getCreateMasterEditionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
