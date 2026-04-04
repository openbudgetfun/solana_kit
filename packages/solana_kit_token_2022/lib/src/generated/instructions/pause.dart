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

/// The discriminator field name: 'pausableDiscriminator'.
/// Offset: 1.

@immutable
class PauseInstructionData {
  const PauseInstructionData({
    this.discriminator = 44,
    this.pausableDiscriminator = 1,
  });

  final int discriminator;
  final int pausableDiscriminator;
}

Encoder<PauseInstructionData> getPauseInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('pausableDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PauseInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'pausableDiscriminator': value.pausableDiscriminator,
    },
  );
}

Decoder<PauseInstructionData> getPauseInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('pausableDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => PauseInstructionData(
      discriminator: map['discriminator']! as int,
      pausableDiscriminator: map['pausableDiscriminator']! as int,
    ),
  );
}

Codec<PauseInstructionData, PauseInstructionData> getPauseInstructionDataCodec() {
  return combineCodec(getPauseInstructionDataEncoder(), getPauseInstructionDataDecoder());
}

/// Creates a [Pause] instruction.
Instruction getPauseInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,

}) {
  final instructionData = PauseInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getPauseInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Pause] instruction from raw instruction data.
PauseInstructionData parsePauseInstruction(Instruction instruction) {
  return getPauseInstructionDataDecoder().decode(instruction.data!);
}
