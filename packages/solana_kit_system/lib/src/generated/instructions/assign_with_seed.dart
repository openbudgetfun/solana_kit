// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class AssignWithSeedInstructionData {
  const AssignWithSeedInstructionData({
    this.discriminator = 10,
    required this.base,
    required this.seed,
    required this.programAddress,
  });

  final int discriminator;
  final Address base;
  final String seed;
  final Address programAddress;
}

Encoder<AssignWithSeedInstructionData> getAssignWithSeedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('base', getAddressEncoder()),
    ('seed', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('programAddress', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AssignWithSeedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'base': value.base,
      'seed': value.seed,
      'programAddress': value.programAddress,
    },
  );
}

Decoder<AssignWithSeedInstructionData> getAssignWithSeedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('base', getAddressDecoder()),
    ('seed', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('programAddress', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AssignWithSeedInstructionData(
      discriminator: map['discriminator']! as int,
      base: map['base']! as Address,
      seed: map['seed']! as String,
      programAddress: map['programAddress']! as Address,
    ),
  );
}

Codec<AssignWithSeedInstructionData, AssignWithSeedInstructionData> getAssignWithSeedInstructionDataCodec() {
  return combineCodec(getAssignWithSeedInstructionDataEncoder(), getAssignWithSeedInstructionDataDecoder());
}

/// Creates a [AssignWithSeed] instruction.
Instruction getAssignWithSeedInstruction({
  required Address instructionProgramAddress,
  required Address account,
  required Address baseAccount,
  required Address base,
  required String seed,
  required Address programAddress,
}) {
  final instructionData = AssignWithSeedInstructionData(
      base: base,
      seed: seed,
      programAddress: programAddress,
  );

  return Instruction(
    programAddress: instructionProgramAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: baseAccount, role: AccountRole.readonlySigner),
    ],
    data: getAssignWithSeedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AssignWithSeed] instruction from raw instruction data.
AssignWithSeedInstructionData parseAssignWithSeedInstruction(Instruction instruction) {
  return getAssignWithSeedInstructionDataDecoder().decode(instruction.data!);
}
