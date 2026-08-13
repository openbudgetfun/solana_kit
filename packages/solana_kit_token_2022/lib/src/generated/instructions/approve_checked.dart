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

@immutable
class ApproveCheckedInstructionData {
  const ApproveCheckedInstructionData({
    this.discriminator = 13,
    required this.amount,
    required this.decimals,
  });

  final int discriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<ApproveCheckedInstructionData> getApproveCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApproveCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<ApproveCheckedInstructionData> getApproveCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ApproveCheckedInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
      decimals: map['decimals']! as int,
    ),
  );
}

Codec<ApproveCheckedInstructionData, ApproveCheckedInstructionData> getApproveCheckedInstructionDataCodec() {
  return combineCodec(getApproveCheckedInstructionDataEncoder(), getApproveCheckedInstructionDataDecoder());
}

/// Creates a [ApproveChecked] instruction.
Instruction getApproveCheckedInstruction({
  required Address programAddress,
  required Address source,
  required Address mint,
  required Address delegate,
  required Address owner,
  required BigInt amount,
  required int decimals,
}) {
  final instructionData = ApproveCheckedInstructionData(
      amount: amount,
      decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: delegate, role: AccountRole.readonly),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getApproveCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ApproveChecked] instruction from raw instruction data.
ApproveCheckedInstructionData parseApproveCheckedInstruction(Instruction instruction) {
  return getApproveCheckedInstructionDataDecoder().decode(instruction.data!);
}
