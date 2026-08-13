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
class InitializeMultisig2InstructionData {
  const InitializeMultisig2InstructionData({
    this.discriminator = 19,
    required this.m,
  });

  final int discriminator;
  final int m;
}

Encoder<InitializeMultisig2InstructionData> getInitializeMultisig2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('m', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMultisig2InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'm': value.m,
    },
  );
}

Decoder<InitializeMultisig2InstructionData> getInitializeMultisig2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('m', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeMultisig2InstructionData(
      discriminator: map['discriminator']! as int,
      m: map['m']! as int,
    ),
  );
}

Codec<InitializeMultisig2InstructionData, InitializeMultisig2InstructionData> getInitializeMultisig2InstructionDataCodec() {
  return combineCodec(getInitializeMultisig2InstructionDataEncoder(), getInitializeMultisig2InstructionDataDecoder());
}

/// Creates a [InitializeMultisig2] instruction.
Instruction getInitializeMultisig2Instruction({
  required Address programAddress,
  required Address multisig,
  required int m,
}) {
  final instructionData = InitializeMultisig2InstructionData(
      m: m,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: multisig, role: AccountRole.writable),
    ],
    data: getInitializeMultisig2InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeMultisig2] instruction from raw instruction data.
InitializeMultisig2InstructionData parseInitializeMultisig2Instruction(Instruction instruction) {
  return getInitializeMultisig2InstructionDataDecoder().decode(instruction.data!);
}
