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
class ExtendProgramInstructionData {
  const ExtendProgramInstructionData({
    this.discriminator = 6,
    required this.additionalBytes,
  });

  final int discriminator;
  final int additionalBytes;
}

Encoder<ExtendProgramInstructionData> getExtendProgramInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('additionalBytes', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ExtendProgramInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'additionalBytes': value.additionalBytes,
    },
  );
}

Decoder<ExtendProgramInstructionData> getExtendProgramInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('additionalBytes', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ExtendProgramInstructionData(
      discriminator: map['discriminator']! as int,
      additionalBytes: map['additionalBytes']! as int,
    ),
  );
}

Codec<ExtendProgramInstructionData, ExtendProgramInstructionData> getExtendProgramInstructionDataCodec() {
  return combineCodec(getExtendProgramInstructionDataEncoder(), getExtendProgramInstructionDataDecoder());
}

/// Creates a [ExtendProgram] instruction.
Instruction getExtendProgramInstruction({
  required Address programAddress,
  required Address programDataAccount,
  required Address programAccount,
  Address? systemProgram,
  Address? payer,
  required int additionalBytes,
}) {
  final instructionData = ExtendProgramInstructionData(
      additionalBytes: additionalBytes,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: programDataAccount, role: AccountRole.writable),
    AccountMeta(address: programAccount, role: AccountRole.writable),
    if (systemProgram != null) AccountMeta(address: systemProgram, role: AccountRole.readonly),
    if (payer != null) AccountMeta(address: payer, role: AccountRole.writableSigner),
    ],
    data: getExtendProgramInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ExtendProgram] instruction from raw instruction data.
ExtendProgramInstructionData parseExtendProgramInstruction(Instruction instruction) {
  return getExtendProgramInstructionDataDecoder().decode(instruction.data!);
}
