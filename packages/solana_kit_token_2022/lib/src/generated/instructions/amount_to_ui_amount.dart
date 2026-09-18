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
class AmountToUiAmountInstructionData {
  const AmountToUiAmountInstructionData({
    required this.amount,
  }) : discriminator = 23;

  final int discriminator;
  final BigInt amount;
}

Encoder<AmountToUiAmountInstructionData>
getAmountToUiAmountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AmountToUiAmountInstructionData value) => <String, Object?>{
      'discriminator': 23,
      'amount': value.amount,
    },
  );
}

Decoder<AmountToUiAmountInstructionData>
getAmountToUiAmountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'amountToUiAmount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AmountToUiAmountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(23),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      AmountToUiAmountInstructionData(
        amount: map['amount']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<AmountToUiAmountInstructionData>(
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
      VariableSizeDecoder<AmountToUiAmountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<AmountToUiAmountInstructionData, AmountToUiAmountInstructionData>
getAmountToUiAmountInstructionDataCodec() {
  return combineCodec(
    getAmountToUiAmountInstructionDataEncoder(),
    getAmountToUiAmountInstructionDataDecoder(),
  );
}

/// Creates a [AmountToUiAmount] instruction.
Instruction getAmountToUiAmountInstruction({
  required Address programAddress,
  required Address mint,
  required BigInt amount,
}) {
  final instructionData = AmountToUiAmountInstructionData(
    amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.readonly),
    ],
    data: getAmountToUiAmountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AmountToUiAmount] instruction from raw instruction data.
AmountToUiAmountInstructionData parseAmountToUiAmountInstruction(
  Instruction instruction,
) {
  return getAmountToUiAmountInstructionDataDecoder().decode(instruction.data!);
}
