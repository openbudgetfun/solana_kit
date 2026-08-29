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
class SetTokenStandardInstructionData {
  const SetTokenStandardInstructionData() : discriminator = 35;

  final int discriminator;
}

Encoder<SetTokenStandardInstructionData>
getSetTokenStandardInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetTokenStandardInstructionData value) => <String, Object?>{
      'discriminator': 35,
    },
  );
}

Decoder<SetTokenStandardInstructionData>
getSetTokenStandardInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'setTokenStandard instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SetTokenStandardInstructionData, int) readTopLevel(
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
      SetTokenStandardInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<SetTokenStandardInstructionData>(
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
      VariableSizeDecoder<SetTokenStandardInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SetTokenStandardInstructionData, SetTokenStandardInstructionData>
getSetTokenStandardInstructionDataCodec() {
  return combineCodec(
    getSetTokenStandardInstructionDataEncoder(),
    getSetTokenStandardInstructionDataDecoder(),
  );
}

/// Creates a [SetTokenStandard] instruction.
Instruction getSetTokenStandardInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  required Address mint,
  Address? edition,
}) {
  final instructionData = SetTokenStandardInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: mint, role: AccountRole.readonly),
      if (edition != null)
        AccountMeta(address: edition, role: AccountRole.readonly),
    ],
    data: getSetTokenStandardInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetTokenStandard] instruction from raw instruction data.
SetTokenStandardInstructionData parseSetTokenStandardInstruction(
  Instruction instruction,
) {
  return getSetTokenStandardInstructionDataDecoder().decode(instruction.data!);
}
