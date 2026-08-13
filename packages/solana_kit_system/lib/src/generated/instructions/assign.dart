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
class AssignInstructionData {
  const AssignInstructionData({
    this.discriminator = 1,
    required this.programAddress,
  });

  final int discriminator;
  final Address programAddress;
}

Encoder<AssignInstructionData> getAssignInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('programAddress', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AssignInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'programAddress': value.programAddress,
    },
  );
}

Decoder<AssignInstructionData> getAssignInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('programAddress', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AssignInstructionData(
      discriminator: map['discriminator']! as int,
      programAddress: map['programAddress']! as Address,
    ),
  );
}

Codec<AssignInstructionData, AssignInstructionData> getAssignInstructionDataCodec() {
  return combineCodec(getAssignInstructionDataEncoder(), getAssignInstructionDataDecoder());
}

/// Creates a [Assign] instruction.
Instruction getAssignInstruction({
  required Address instructionProgramAddress,
  required Address account,
  required Address programAddress,
}) {
  final instructionData = AssignInstructionData(
      programAddress: programAddress,
  );

  return Instruction(
    programAddress: instructionProgramAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writableSigner),
    ],
    data: getAssignInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Assign] instruction from raw instruction data.
AssignInstructionData parseAssignInstruction(Instruction instruction) {
  return getAssignInstructionDataDecoder().decode(instruction.data!);
}
