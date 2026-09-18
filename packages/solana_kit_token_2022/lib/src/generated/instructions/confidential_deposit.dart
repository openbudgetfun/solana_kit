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

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class ConfidentialDepositInstructionData {
  const ConfidentialDepositInstructionData({
    required this.amount,
    required this.decimals,
  }) : discriminator = 27,
       confidentialTransferDiscriminator = 5;

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<ConfidentialDepositInstructionData>
getConfidentialDepositInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfidentialDepositInstructionData value) => <String, Object?>{
      'discriminator': 27,
      'confidentialTransferDiscriminator': 5,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<ConfidentialDepositInstructionData>
getConfidentialDepositInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'confidentialDeposit instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConfidentialDepositInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(5),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ConfidentialDepositInstructionData(
        amount: map['amount']! as BigInt,
        decimals: map['decimals']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ConfidentialDepositInstructionData>(
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
      VariableSizeDecoder<ConfidentialDepositInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ConfidentialDepositInstructionData, ConfidentialDepositInstructionData>
getConfidentialDepositInstructionDataCodec() {
  return combineCodec(
    getConfidentialDepositInstructionDataEncoder(),
    getConfidentialDepositInstructionDataDecoder(),
  );
}

/// Creates a [ConfidentialDeposit] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getConfidentialDepositInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  required Address authority,
  required BigInt amount,
  required int decimals,
  bool authorityIsSigner = true,
}) {
  final instructionData = ConfidentialDepositInstructionData(
    amount: amount,
    decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getConfidentialDepositInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ConfidentialDeposit] instruction from raw instruction data.
ConfidentialDepositInstructionData parseConfidentialDepositInstruction(
  Instruction instruction,
) {
  return getConfidentialDepositInstructionDataDecoder().decode(
    instruction.data!,
  );
}
