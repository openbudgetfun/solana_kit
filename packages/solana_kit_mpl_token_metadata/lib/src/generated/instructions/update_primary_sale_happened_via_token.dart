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
class UpdatePrimarySaleHappenedViaTokenInstructionData {
  const UpdatePrimarySaleHappenedViaTokenInstructionData() : discriminator = 4;

  final int discriminator;
}

Encoder<UpdatePrimarySaleHappenedViaTokenInstructionData>
getUpdatePrimarySaleHappenedViaTokenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdatePrimarySaleHappenedViaTokenInstructionData value) =>
        <String, Object?>{
          'discriminator': 4,
        },
  );
}

Decoder<UpdatePrimarySaleHappenedViaTokenInstructionData>
getUpdatePrimarySaleHappenedViaTokenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'updatePrimarySaleHappenedViaToken instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdatePrimarySaleHappenedViaTokenInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(4),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdatePrimarySaleHappenedViaTokenInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdatePrimarySaleHappenedViaTokenInstructionData>(
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
      VariableSizeDecoder<UpdatePrimarySaleHappenedViaTokenInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdatePrimarySaleHappenedViaTokenInstructionData,
  UpdatePrimarySaleHappenedViaTokenInstructionData
>
getUpdatePrimarySaleHappenedViaTokenInstructionDataCodec() {
  return combineCodec(
    getUpdatePrimarySaleHappenedViaTokenInstructionDataEncoder(),
    getUpdatePrimarySaleHappenedViaTokenInstructionDataDecoder(),
  );
}

/// Creates a [UpdatePrimarySaleHappenedViaToken] instruction.
Instruction getUpdatePrimarySaleHappenedViaTokenInstruction({
  required Address programAddress,
  required Address metadata,
  required Address owner,
  required Address token,
}) {
  final instructionData = UpdatePrimarySaleHappenedViaTokenInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: owner, role: AccountRole.readonlySigner),
      AccountMeta(address: token, role: AccountRole.readonly),
    ],
    data: getUpdatePrimarySaleHappenedViaTokenInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdatePrimarySaleHappenedViaToken] instruction from raw instruction data.
UpdatePrimarySaleHappenedViaTokenInstructionData
parseUpdatePrimarySaleHappenedViaTokenInstruction(Instruction instruction) {
  return getUpdatePrimarySaleHappenedViaTokenInstructionDataDecoder().decode(
    instruction.data!,
  );
}
