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
class UnwrapLamportsInstructionData {
  const UnwrapLamportsInstructionData({
    required this.amount,
  }) : discriminator = 45;

  final int discriminator;
  final BigInt? amount;
}

Encoder<UnwrapLamportsInstructionData>
getUnwrapLamportsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'amount',
      getNullableEncoder<BigInt>(
        transformEncoder(getU64Encoder(), (BigInt value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UnwrapLamportsInstructionData value) => <String, Object?>{
      'discriminator': 45,
      'amount': value.amount,
    },
  );
}

Decoder<UnwrapLamportsInstructionData>
getUnwrapLamportsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getNullableDecoder<BigInt>(getU64Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'unwrapLamports instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UnwrapLamportsInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(45),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UnwrapLamportsInstructionData(
        amount: map['amount'] as BigInt?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UnwrapLamportsInstructionData>(
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
      VariableSizeDecoder<UnwrapLamportsInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UnwrapLamportsInstructionData, UnwrapLamportsInstructionData>
getUnwrapLamportsInstructionDataCodec() {
  return combineCodec(
    getUnwrapLamportsInstructionDataEncoder(),
    getUnwrapLamportsInstructionDataDecoder(),
  );
}

/// Creates a [UnwrapLamports] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getUnwrapLamportsInstruction({
  required Address programAddress,
  required Address source,
  required Address destination,
  required Address authority,
  required BigInt? amount,
  bool authorityIsSigner = true,
}) {
  final instructionData = UnwrapLamportsInstructionData(
    amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: source, role: AccountRole.writable),
      AccountMeta(address: destination, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getUnwrapLamportsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UnwrapLamports] instruction from raw instruction data.
UnwrapLamportsInstructionData parseUnwrapLamportsInstruction(
  Instruction instruction,
) {
  return getUnwrapLamportsInstructionDataDecoder().decode(instruction.data!);
}
