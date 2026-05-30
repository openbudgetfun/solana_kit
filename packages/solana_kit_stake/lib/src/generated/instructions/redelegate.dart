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
class RedelegateInstructionData {
  const RedelegateInstructionData({this.discriminator = 15});

  final int discriminator;
}

Encoder<RedelegateInstructionData> getRedelegateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RedelegateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<RedelegateInstructionData> getRedelegateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RedelegateInstructionData(discriminator: map['discriminator']! as int),
  );
}

Codec<RedelegateInstructionData, RedelegateInstructionData>
getRedelegateInstructionDataCodec() {
  return combineCodec(
    getRedelegateInstructionDataEncoder(),
    getRedelegateInstructionDataDecoder(),
  );
}

/// Creates a [Redelegate] instruction.
Instruction getRedelegateInstruction({required Address programAddress}) {
  final instructionData = RedelegateInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [],
    data: getRedelegateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Redelegate] instruction from raw instruction data.
RedelegateInstructionData parseRedelegateInstruction(Instruction instruction) {
  return getRedelegateInstructionDataDecoder().decode(instruction.data!);
}
