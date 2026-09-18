// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UiAmountToAmountInstructionData {
  const UiAmountToAmountInstructionData({
    required this.uiAmount,
  }) : discriminator = 24;

  final int discriminator;
  final String uiAmount;
}

Encoder<UiAmountToAmountInstructionData>
getUiAmountToAmountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('uiAmount', getUtf8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UiAmountToAmountInstructionData value) => <String, Object?>{
      'discriminator': 24,
      'uiAmount': value.uiAmount,
    },
  );
}

Decoder<UiAmountToAmountInstructionData>
getUiAmountToAmountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('uiAmount', getUtf8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'uiAmountToAmount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UiAmountToAmountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(24),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UiAmountToAmountInstructionData(
        uiAmount: map['uiAmount']! as String,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UiAmountToAmountInstructionData>(
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
      VariableSizeDecoder<UiAmountToAmountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UiAmountToAmountInstructionData, UiAmountToAmountInstructionData>
getUiAmountToAmountInstructionDataCodec() {
  return combineCodec(
    getUiAmountToAmountInstructionDataEncoder(),
    getUiAmountToAmountInstructionDataDecoder(),
  );
}

/// Creates a [UiAmountToAmount] instruction.
Instruction getUiAmountToAmountInstruction({
  required Address programAddress,
  required Address mint,
  required String uiAmount,
}) {
  final instructionData = UiAmountToAmountInstructionData(
    uiAmount: uiAmount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.readonly),
    ],
    data: getUiAmountToAmountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UiAmountToAmount] instruction from raw instruction data.
UiAmountToAmountInstructionData parseUiAmountToAmountInstruction(
  Instruction instruction,
) {
  return getUiAmountToAmountInstructionDataDecoder().decode(instruction.data!);
}
