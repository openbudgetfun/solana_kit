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
class AddAssetsToGroupV1InstructionData {
  const AddAssetsToGroupV1InstructionData() : discriminator = 35;

  final int discriminator;
}

Encoder<AddAssetsToGroupV1InstructionData>
getAddAssetsToGroupV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AddAssetsToGroupV1InstructionData value) => <String, Object?>{
      'discriminator': 35,
    },
  );
}

Decoder<AddAssetsToGroupV1InstructionData>
getAddAssetsToGroupV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'addAssetsToGroupV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AddAssetsToGroupV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(35),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      AddAssetsToGroupV1InstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<AddAssetsToGroupV1InstructionData>(
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
      VariableSizeDecoder<AddAssetsToGroupV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<AddAssetsToGroupV1InstructionData, AddAssetsToGroupV1InstructionData>
getAddAssetsToGroupV1InstructionDataCodec() {
  return combineCodec(
    getAddAssetsToGroupV1InstructionDataEncoder(),
    getAddAssetsToGroupV1InstructionDataDecoder(),
  );
}

/// Creates a [AddAssetsToGroupV1] instruction.
Instruction getAddAssetsToGroupV1Instruction({
  required Address programAddress,
  required Address group,
  required Address payer,
  Address? authority,
  required Address systemProgram,
}) {
  final instructionData = AddAssetsToGroupV1InstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: group, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getAddAssetsToGroupV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AddAssetsToGroupV1] instruction from raw instruction data.
AddAssetsToGroupV1InstructionData parseAddAssetsToGroupV1Instruction(
  Instruction instruction,
) {
  return getAddAssetsToGroupV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
