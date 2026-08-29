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
class CreateMetadataAccountInstructionData {
  const CreateMetadataAccountInstructionData() : discriminator = 0;

  final int discriminator;
}

Encoder<CreateMetadataAccountInstructionData>
getCreateMetadataAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateMetadataAccountInstructionData value) => <String, Object?>{
      'discriminator': 0,
    },
  );
}

Decoder<CreateMetadataAccountInstructionData>
getCreateMetadataAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createMetadataAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateMetadataAccountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateMetadataAccountInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateMetadataAccountInstructionData>(
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
      VariableSizeDecoder<CreateMetadataAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  CreateMetadataAccountInstructionData,
  CreateMetadataAccountInstructionData
>
getCreateMetadataAccountInstructionDataCodec() {
  return combineCodec(
    getCreateMetadataAccountInstructionDataEncoder(),
    getCreateMetadataAccountInstructionDataDecoder(),
  );
}

/// Creates a [CreateMetadataAccount] instruction.
Instruction getCreateMetadataAccountInstruction({
  required Address programAddress,
  required Address metadata,
  required Address mint,
  required Address mintAuthority,
  required Address payer,
  required Address updateAuthority,
  required Address systemProgram,
  required Address rent,
}) {
  final instructionData = CreateMetadataAccountInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: updateAuthority, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getCreateMetadataAccountInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateMetadataAccount] instruction from raw instruction data.
CreateMetadataAccountInstructionData parseCreateMetadataAccountInstruction(
  Instruction instruction,
) {
  return getCreateMetadataAccountInstructionDataDecoder().decode(
    instruction.data!,
  );
}
