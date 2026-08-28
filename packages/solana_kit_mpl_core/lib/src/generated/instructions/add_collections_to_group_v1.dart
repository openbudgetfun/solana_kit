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
class AddCollectionsToGroupV1InstructionData {
  const AddCollectionsToGroupV1InstructionData() : discriminator = 33;

  final int discriminator;
}

Encoder<AddCollectionsToGroupV1InstructionData>
getAddCollectionsToGroupV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AddCollectionsToGroupV1InstructionData value) => <String, Object?>{
      'discriminator': 33,
    },
  );
}

Decoder<AddCollectionsToGroupV1InstructionData>
getAddCollectionsToGroupV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'addCollectionsToGroupV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AddCollectionsToGroupV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(33),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      AddCollectionsToGroupV1InstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<AddCollectionsToGroupV1InstructionData>(
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
      VariableSizeDecoder<AddCollectionsToGroupV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  AddCollectionsToGroupV1InstructionData,
  AddCollectionsToGroupV1InstructionData
>
getAddCollectionsToGroupV1InstructionDataCodec() {
  return combineCodec(
    getAddCollectionsToGroupV1InstructionDataEncoder(),
    getAddCollectionsToGroupV1InstructionDataDecoder(),
  );
}

/// Creates a [AddCollectionsToGroupV1] instruction.
Instruction getAddCollectionsToGroupV1Instruction({
  required Address programAddress,
  required Address group,
  required Address payer,
  Address? authority,
  required Address systemProgram,
}) {
  final instructionData = AddCollectionsToGroupV1InstructionData();

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
    data: getAddCollectionsToGroupV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [AddCollectionsToGroupV1] instruction from raw instruction data.
AddCollectionsToGroupV1InstructionData parseAddCollectionsToGroupV1Instruction(
  Instruction instruction,
) {
  return getAddCollectionsToGroupV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
