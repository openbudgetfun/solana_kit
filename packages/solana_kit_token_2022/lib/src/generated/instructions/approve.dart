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
class ApproveInstructionData {
  const ApproveInstructionData({
    this.discriminator = 4,
    required this.amount,
  });

  final int discriminator;
  final BigInt amount;
}

Encoder<ApproveInstructionData> getApproveInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApproveInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
    },
  );
}

Decoder<ApproveInstructionData> getApproveInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ApproveInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
    ),
  );
}

Codec<ApproveInstructionData, ApproveInstructionData> getApproveInstructionDataCodec() {
  return combineCodec(getApproveInstructionDataEncoder(), getApproveInstructionDataDecoder());
}

/// Creates a [Approve] instruction.
Instruction getApproveInstruction({
  required Address programAddress,
  required Address source,
  required Address delegate,
  required Address owner,
  required BigInt amount,
}) {
  final instructionData = ApproveInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writable),
    AccountMeta(address: delegate, role: AccountRole.readonly),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getApproveInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Approve] instruction from raw instruction data.
ApproveInstructionData parseApproveInstruction(Instruction instruction) {
  return getApproveInstructionDataDecoder().decode(instruction.data!);
}
