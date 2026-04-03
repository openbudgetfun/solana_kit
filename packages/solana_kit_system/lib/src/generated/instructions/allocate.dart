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
class AllocateInstructionData {
  const AllocateInstructionData({
    this.discriminator = 8,
    required this.space,
  });

  final int discriminator;
  final BigInt space;
}

Encoder<AllocateInstructionData> getAllocateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('space', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AllocateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'space': value.space,
    },
  );
}

Decoder<AllocateInstructionData> getAllocateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('space', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AllocateInstructionData(
      discriminator: map['discriminator']! as int,
      space: map['space']! as BigInt,
    ),
  );
}

Codec<AllocateInstructionData, AllocateInstructionData> getAllocateInstructionDataCodec() {
  return combineCodec(getAllocateInstructionDataEncoder(), getAllocateInstructionDataDecoder());
}

/// Creates a [Allocate] instruction.
Instruction getAllocateInstruction({
  required Address programAddress,
  required Address newAccount,
  required BigInt space,
}) {
  final instructionData = AllocateInstructionData(
      space: space,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: newAccount, role: AccountRole.writableSigner),
    ],
    data: getAllocateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Allocate] instruction from raw instruction data.
AllocateInstructionData parseAllocateInstruction(Instruction instruction) {
  return getAllocateInstructionDataDecoder().decode(instruction.data!);
}
