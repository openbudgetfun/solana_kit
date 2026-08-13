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
class SetComputeUnitLimitInstructionData {
  const SetComputeUnitLimitInstructionData({
    this.discriminator = 2,
    required this.units,
  });

  final int discriminator;
  final int units;
}

Encoder<SetComputeUnitLimitInstructionData> getSetComputeUnitLimitInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('units', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetComputeUnitLimitInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'units': value.units,
    },
  );
}

Decoder<SetComputeUnitLimitInstructionData> getSetComputeUnitLimitInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('units', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SetComputeUnitLimitInstructionData(
      discriminator: map['discriminator']! as int,
      units: map['units']! as int,
    ),
  );
}

Codec<SetComputeUnitLimitInstructionData, SetComputeUnitLimitInstructionData> getSetComputeUnitLimitInstructionDataCodec() {
  return combineCodec(getSetComputeUnitLimitInstructionDataEncoder(), getSetComputeUnitLimitInstructionDataDecoder());
}

/// Creates a [SetComputeUnitLimit] instruction.
Instruction getSetComputeUnitLimitInstruction({
  required Address programAddress,

  required int units,
}) {
  final instructionData = SetComputeUnitLimitInstructionData(
      units: units,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [

    ],
    data: getSetComputeUnitLimitInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetComputeUnitLimit] instruction from raw instruction data.
SetComputeUnitLimitInstructionData parseSetComputeUnitLimitInstruction(Instruction instruction) {
  return getSetComputeUnitLimitInstructionDataDecoder().decode(instruction.data!);
}
