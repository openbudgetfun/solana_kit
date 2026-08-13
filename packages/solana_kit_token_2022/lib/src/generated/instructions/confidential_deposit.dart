// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class ConfidentialDepositInstructionData {
  const ConfidentialDepositInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 5,
    required this.amount,
    required this.decimals,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<ConfidentialDepositInstructionData> getConfidentialDepositInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfidentialDepositInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<ConfidentialDepositInstructionData> getConfidentialDepositInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ConfidentialDepositInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
      amount: map['amount']! as BigInt,
      decimals: map['decimals']! as int,
    ),
  );
}

Codec<ConfidentialDepositInstructionData, ConfidentialDepositInstructionData> getConfidentialDepositInstructionDataCodec() {
  return combineCodec(getConfidentialDepositInstructionDataEncoder(), getConfidentialDepositInstructionDataDecoder());
}

/// Creates a [ConfidentialDeposit] instruction.
Instruction getConfidentialDepositInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  required Address authority,
  required BigInt amount,
  required int decimals,
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
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getConfidentialDepositInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ConfidentialDeposit] instruction from raw instruction data.
ConfidentialDepositInstructionData parseConfidentialDepositInstruction(Instruction instruction) {
  return getConfidentialDepositInstructionDataDecoder().decode(instruction.data!);
}
