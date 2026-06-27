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
class DeletePlanInstructionData {
  const DeletePlanInstructionData({
    this.discriminator = 9,
  });

  final int discriminator;
}

Encoder<DeletePlanInstructionData> getDeletePlanInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeletePlanInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<DeletePlanInstructionData> getDeletePlanInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => DeletePlanInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<DeletePlanInstructionData, DeletePlanInstructionData> getDeletePlanInstructionDataCodec() {
  return combineCodec(getDeletePlanInstructionDataEncoder(), getDeletePlanInstructionDataDecoder());
}

/// Creates a [DeletePlan] instruction.
Instruction getDeletePlanInstruction({
  required Address programAddress,
  required Address owner,
  required Address planPda,

}) {
  final instructionData = DeletePlanInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: owner, role: AccountRole.writableSigner),
    AccountMeta(address: planPda, role: AccountRole.writable),
    ],
    data: getDeletePlanInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [DeletePlan] instruction from raw instruction data.
DeletePlanInstructionData parseDeletePlanInstruction(Instruction instruction) {
  return getDeletePlanInstructionDataDecoder().decode(instruction.data!);
}
