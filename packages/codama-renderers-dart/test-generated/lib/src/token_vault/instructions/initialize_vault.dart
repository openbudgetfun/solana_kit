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
class InitializeVaultInstructionData {
  const InitializeVaultInstructionData({
    this.discriminator = 0,
    required this.maxCapacity,
    required this.bumpSeed,
  });

  final int discriminator;
  final BigInt maxCapacity;
  final int bumpSeed;
}

Encoder<InitializeVaultInstructionData> getInitializeVaultInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('maxCapacity', getU64Encoder()),
    ('bumpSeed', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeVaultInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'maxCapacity': value.maxCapacity,
      'bumpSeed': value.bumpSeed,
    },
  );
}

Decoder<InitializeVaultInstructionData> getInitializeVaultInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('maxCapacity', getU64Decoder()),
    ('bumpSeed', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeVaultInstructionData(
      discriminator: map['discriminator']! as int,
      maxCapacity: map['maxCapacity']! as BigInt,
      bumpSeed: map['bumpSeed']! as int,
    ),
  );
}

Codec<InitializeVaultInstructionData, InitializeVaultInstructionData> getInitializeVaultInstructionDataCodec() {
  return combineCodec(getInitializeVaultInstructionDataEncoder(), getInitializeVaultInstructionDataDecoder());
}

/// Creates a [InitializeVault] instruction.
Instruction getInitializeVaultInstruction({
  required Address programAddress,
  required Address vault,
  required Address authority,
  required Address tokenMint,
  required Address systemProgram,
  required BigInt maxCapacity,
  required int bumpSeed,
}) {
  final instructionData = InitializeVaultInstructionData(
      maxCapacity: maxCapacity,
      bumpSeed: bumpSeed,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: vault, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    AccountMeta(address: tokenMint, role: AccountRole.readonly),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getInitializeVaultInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeVault] instruction from raw instruction data.
InitializeVaultInstructionData parseInitializeVaultInstruction(Instruction instruction) {
  return getInitializeVaultInstructionDataDecoder().decode(instruction.data!);
}
