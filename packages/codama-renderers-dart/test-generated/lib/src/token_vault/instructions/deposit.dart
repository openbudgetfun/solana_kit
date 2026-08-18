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
class DepositInstructionData {
  const DepositInstructionData({
    required this.amount,
  }) : discriminator = 1;

  final int discriminator;
  final BigInt amount;
}

Encoder<DepositInstructionData> getDepositInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DepositInstructionData value) => <String, Object?>{
      'discriminator': 1,
      'amount': value.amount,
    },
  );
}

Decoder<DepositInstructionData> getDepositInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'deposit instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DepositInstructionData, int) readExact(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }
    return (
      DepositInstructionData(
        amount: map['amount']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DepositInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readExact(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<DepositInstructionData>(
        read: readExact,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<DepositInstructionData, DepositInstructionData>
getDepositInstructionDataCodec() {
  return combineCodec(
    getDepositInstructionDataEncoder(),
    getDepositInstructionDataDecoder(),
  );
}

/// Creates a [Deposit] instruction.
Instruction getDepositInstruction({
  required Address programAddress,
  required Address vault,
  required Address depositor,
  required Address depositorTokenAccount,
  required Address vaultTokenAccount,
  required Address tokenProgram,
  required BigInt amount,
}) {
  final instructionData = DepositInstructionData(
    amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: vault, role: AccountRole.writable),
      AccountMeta(address: depositor, role: AccountRole.writableSigner),
      AccountMeta(address: depositorTokenAccount, role: AccountRole.writable),
      AccountMeta(address: vaultTokenAccount, role: AccountRole.writable),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getDepositInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Deposit] instruction from raw instruction data.
DepositInstructionData parseDepositInstruction(Instruction instruction) {
  return getDepositInstructionDataDecoder().decode(instruction.data!);
}
