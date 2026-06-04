// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/update_plan_data.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdatePlanInstructionData {
  const UpdatePlanInstructionData({
    this.discriminator = 8,
    required this.updatePlanData,
  });

  final int discriminator;
  final UpdatePlanData updatePlanData;
}

Encoder<UpdatePlanInstructionData> getUpdatePlanInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('updatePlanData', getUpdatePlanDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdatePlanInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'updatePlanData': value.updatePlanData,
    },
  );
}

Decoder<UpdatePlanInstructionData> getUpdatePlanInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('updatePlanData', getUpdatePlanDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        UpdatePlanInstructionData(
          discriminator: map['discriminator']! as int,
          updatePlanData: map['updatePlanData']! as UpdatePlanData,
        ),
  );
}

Codec<UpdatePlanInstructionData, UpdatePlanInstructionData>
getUpdatePlanInstructionDataCodec() {
  return combineCodec(
    getUpdatePlanInstructionDataEncoder(),
    getUpdatePlanInstructionDataDecoder(),
  );
}

/// Creates a [UpdatePlan] instruction.
Instruction getUpdatePlanInstruction({
  required Address programAddress,
  required Address owner,
  required Address planPda,
  required UpdatePlanData updatePlanData,
}) {
  final instructionData = UpdatePlanInstructionData(
    updatePlanData: updatePlanData,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: owner, role: AccountRole.readonlySigner),
      AccountMeta(address: planPda, role: AccountRole.writable),
    ],
    data: getUpdatePlanInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdatePlan] instruction from raw instruction data.
UpdatePlanInstructionData parseUpdatePlanInstruction(Instruction instruction) {
  return getUpdatePlanInstructionDataDecoder().decode(instruction.data!);
}
