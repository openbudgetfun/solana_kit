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
class GetAccountDataSizeInstructionData {
  const GetAccountDataSizeInstructionData() : discriminator = 21;

  final int discriminator;
}

Encoder<GetAccountDataSizeInstructionData>
getGetAccountDataSizeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (GetAccountDataSizeInstructionData value) => <String, Object?>{
      'discriminator': 21,
    },
  );
}

Decoder<GetAccountDataSizeInstructionData>
getGetAccountDataSizeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'getAccountDataSize instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (GetAccountDataSizeInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(21),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      GetAccountDataSizeInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<GetAccountDataSizeInstructionData>(
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
      VariableSizeDecoder<GetAccountDataSizeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<GetAccountDataSizeInstructionData, GetAccountDataSizeInstructionData>
getGetAccountDataSizeInstructionDataCodec() {
  return combineCodec(
    getGetAccountDataSizeInstructionDataEncoder(),
    getGetAccountDataSizeInstructionDataDecoder(),
  );
}

/// Creates a [GetAccountDataSize] instruction.
Instruction getGetAccountDataSizeInstruction({
  required Address programAddress,
  required Address mint,
}) {
  final instructionData = GetAccountDataSizeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.readonly),
    ],
    data: getGetAccountDataSizeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [GetAccountDataSize] instruction from raw instruction data.
GetAccountDataSizeInstructionData parseGetAccountDataSizeInstruction(
  Instruction instruction,
) {
  return getGetAccountDataSizeInstructionDataDecoder().decode(
    instruction.data!,
  );
}
