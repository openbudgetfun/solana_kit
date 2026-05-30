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
class MoveLamportsInstructionData {
  const MoveLamportsInstructionData({
    this.discriminator = 17,
    required this.args,
  });

  final int discriminator;
  final BigInt args;
}

Encoder<MoveLamportsInstructionData> getMoveLamportsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('args', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MoveLamportsInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'args': value.args,
    },
  );
}

Decoder<MoveLamportsInstructionData> getMoveLamportsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('args', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        MoveLamportsInstructionData(
          discriminator: map['discriminator']! as int,
          args: map['args']! as BigInt,
        ),
  );
}

Codec<MoveLamportsInstructionData, MoveLamportsInstructionData>
getMoveLamportsInstructionDataCodec() {
  return combineCodec(
    getMoveLamportsInstructionDataEncoder(),
    getMoveLamportsInstructionDataDecoder(),
  );
}

/// Creates a [MoveLamports] instruction.
Instruction getMoveLamportsInstruction({
  required Address programAddress,
  required Address sourceStake,
  required Address destinationStake,
  required Address stakeAuthority,
  required BigInt args,
}) {
  final instructionData = MoveLamportsInstructionData(args: args);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: sourceStake, role: AccountRole.writable),
      AccountMeta(address: destinationStake, role: AccountRole.writable),
      AccountMeta(address: stakeAuthority, role: AccountRole.readonlySigner),
    ],
    data: getMoveLamportsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [MoveLamports] instruction from raw instruction data.
MoveLamportsInstructionData parseMoveLamportsInstruction(
  Instruction instruction,
) {
  return getMoveLamportsInstructionDataDecoder().decode(instruction.data!);
}
