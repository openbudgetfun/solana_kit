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
class MergeInstructionData {
  const MergeInstructionData({this.discriminator = 7});

  final int discriminator;
}

Encoder<MergeInstructionData> getMergeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MergeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<MergeInstructionData> getMergeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        MergeInstructionData(discriminator: map['discriminator']! as int),
  );
}

Codec<MergeInstructionData, MergeInstructionData>
getMergeInstructionDataCodec() {
  return combineCodec(
    getMergeInstructionDataEncoder(),
    getMergeInstructionDataDecoder(),
  );
}

/// Creates a [Merge] instruction.
Instruction getMergeInstruction({
  required Address programAddress,
  required Address destinationStake,
  required Address sourceStake,
  required Address clockSysvar,
  required Address stakeHistory,
  required Address stakeAuthority,
}) {
  final instructionData = MergeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: destinationStake, role: AccountRole.writable),
      AccountMeta(address: sourceStake, role: AccountRole.writable),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      AccountMeta(address: stakeHistory, role: AccountRole.readonly),
      AccountMeta(address: stakeAuthority, role: AccountRole.readonlySigner),
    ],
    data: getMergeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Merge] instruction from raw instruction data.
MergeInstructionData parseMergeInstruction(Instruction instruction) {
  return getMergeInstructionDataDecoder().decode(instruction.data!);
}
