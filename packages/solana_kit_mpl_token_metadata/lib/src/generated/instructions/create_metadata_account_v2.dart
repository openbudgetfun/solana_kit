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
class CreateMetadataAccountV2InstructionData {
  const CreateMetadataAccountV2InstructionData() : discriminator = 16;

  final int discriminator;
}

Encoder<CreateMetadataAccountV2InstructionData>
getCreateMetadataAccountV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateMetadataAccountV2InstructionData value) => <String, Object?>{
      'discriminator': 16,
    },
  );
}

Decoder<CreateMetadataAccountV2InstructionData>
getCreateMetadataAccountV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createMetadataAccountV2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateMetadataAccountV2InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(16),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateMetadataAccountV2InstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateMetadataAccountV2InstructionData>(
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
      VariableSizeDecoder<CreateMetadataAccountV2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  CreateMetadataAccountV2InstructionData,
  CreateMetadataAccountV2InstructionData
>
getCreateMetadataAccountV2InstructionDataCodec() {
  return combineCodec(
    getCreateMetadataAccountV2InstructionDataEncoder(),
    getCreateMetadataAccountV2InstructionDataDecoder(),
  );
}

/// Creates a [CreateMetadataAccountV2] instruction.
Instruction getCreateMetadataAccountV2Instruction({
  required Address programAddress,
  required Address metadata,
  required Address mint,
  required Address mintAuthority,
  required Address payer,
  required Address updateAuthority,
  required Address systemProgram,
  Address? rent,
}) {
  final instructionData = CreateMetadataAccountV2InstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: updateAuthority, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (rent != null) AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getCreateMetadataAccountV2InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateMetadataAccountV2] instruction from raw instruction data.
CreateMetadataAccountV2InstructionData parseCreateMetadataAccountV2Instruction(
  Instruction instruction,
) {
  return getCreateMetadataAccountV2InstructionDataDecoder().decode(
    instruction.data!,
  );
}
