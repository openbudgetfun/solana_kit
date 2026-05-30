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
class SplitInstructionData {
  const SplitInstructionData({this.discriminator = 3, required this.args});

  final int discriminator;
  final BigInt args;
}

Encoder<SplitInstructionData> getSplitInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('args', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SplitInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'args': value.args,
    },
  );
}

Decoder<SplitInstructionData> getSplitInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('args', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SplitInstructionData(
          discriminator: map['discriminator']! as int,
          args: map['args']! as BigInt,
        ),
  );
}

Codec<SplitInstructionData, SplitInstructionData>
getSplitInstructionDataCodec() {
  return combineCodec(
    getSplitInstructionDataEncoder(),
    getSplitInstructionDataDecoder(),
  );
}

/// Creates a [Split] instruction.
Instruction getSplitInstruction({
  required Address programAddress,
  required Address stake,
  required Address splitStake,
  required Address stakeAuthority,
  required BigInt args,
}) {
  final instructionData = SplitInstructionData(args: args);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: splitStake, role: AccountRole.writable),
      AccountMeta(address: stakeAuthority, role: AccountRole.readonlySigner),
    ],
    data: getSplitInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Split] instruction from raw instruction data.
SplitInstructionData parseSplitInstruction(Instruction instruction) {
  return getSplitInstructionDataDecoder().decode(instruction.data!);
}
