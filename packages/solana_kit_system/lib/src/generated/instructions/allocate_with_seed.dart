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
class AllocateWithSeedInstructionData {
  const AllocateWithSeedInstructionData({
    this.discriminator = 9,
    required this.base,
    required this.seed,
    required this.space,
    required this.programAddress,
  });

  final int discriminator;
  final Address base;
  final String seed;
  final BigInt space;
  final Address programAddress;
}

Encoder<AllocateWithSeedInstructionData> getAllocateWithSeedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('base', getAddressEncoder()),
    ('seed', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('space', getU64Encoder()),
    ('programAddress', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AllocateWithSeedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'base': value.base,
      'seed': value.seed,
      'space': value.space,
      'programAddress': value.programAddress,
    },
  );
}

Decoder<AllocateWithSeedInstructionData> getAllocateWithSeedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('base', getAddressDecoder()),
    ('seed', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('space', getU64Decoder()),
    ('programAddress', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AllocateWithSeedInstructionData(
      discriminator: map['discriminator']! as int,
      base: map['base']! as Address,
      seed: map['seed']! as String,
      space: map['space']! as BigInt,
      programAddress: map['programAddress']! as Address,
    ),
  );
}

Codec<AllocateWithSeedInstructionData, AllocateWithSeedInstructionData> getAllocateWithSeedInstructionDataCodec() {
  return combineCodec(getAllocateWithSeedInstructionDataEncoder(), getAllocateWithSeedInstructionDataDecoder());
}

/// Creates a [AllocateWithSeed] instruction.
Instruction getAllocateWithSeedInstruction({
  required Address instructionProgramAddress,
  required Address newAccount,
  required Address baseAccount,
  required Address base,
  required String seed,
  required BigInt space,
  required Address programAddress,
}) {
  final instructionData = AllocateWithSeedInstructionData(
      base: base,
      seed: seed,
      space: space,
      programAddress: programAddress,
  );

  return Instruction(
    programAddress: instructionProgramAddress,
    accounts: [
    AccountMeta(address: newAccount, role: AccountRole.writable),
    AccountMeta(address: baseAccount, role: AccountRole.readonlySigner),
    ],
    data: getAllocateWithSeedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AllocateWithSeed] instruction from raw instruction data.
AllocateWithSeedInstructionData parseAllocateWithSeedInstruction(Instruction instruction) {
  return getAllocateWithSeedInstructionDataDecoder().decode(instruction.data!);
}
