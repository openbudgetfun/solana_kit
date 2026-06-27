// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/plan_data.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreatePlanInstructionData {
  const CreatePlanInstructionData({
    this.discriminator = 7,
    required this.planData,
  });

  final int discriminator;
  final PlanData planData;
}

Encoder<CreatePlanInstructionData> getCreatePlanInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('planData', getPlanDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreatePlanInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'planData': value.planData,
    },
  );
}

Decoder<CreatePlanInstructionData> getCreatePlanInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('planData', getPlanDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CreatePlanInstructionData(
      discriminator: map['discriminator']! as int,
      planData: map['planData']! as PlanData,
    ),
  );
}

Codec<CreatePlanInstructionData, CreatePlanInstructionData> getCreatePlanInstructionDataCodec() {
  return combineCodec(getCreatePlanInstructionDataEncoder(), getCreatePlanInstructionDataDecoder());
}

/// Creates a [CreatePlan] instruction.
Instruction getCreatePlanInstruction({
  required Address programAddress,
  required Address merchant,
  required Address planPda,
  required Address tokenMint,
  required Address systemProgram,
  required Address tokenProgram,
  required PlanData planData,
}) {
  final instructionData = CreatePlanInstructionData(
      planData: planData,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: merchant, role: AccountRole.writableSigner),
    AccountMeta(address: planPda, role: AccountRole.writable),
    AccountMeta(address: tokenMint, role: AccountRole.readonly),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getCreatePlanInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreatePlan] instruction from raw instruction data.
CreatePlanInstructionData parseCreatePlanInstruction(Instruction instruction) {
  return getCreatePlanInstructionDataDecoder().decode(instruction.data!);
}
