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
class RequestUnitsInstructionData {
  const RequestUnitsInstructionData({
    this.discriminator = 0,
    required this.units,
    required this.additionalFee,
  });

  final int discriminator;
  final int units;
  final int additionalFee;
}

Encoder<RequestUnitsInstructionData> getRequestUnitsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('units', getU32Encoder()),
    ('additionalFee', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RequestUnitsInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'units': value.units,
      'additionalFee': value.additionalFee,
    },
  );
}

Decoder<RequestUnitsInstructionData> getRequestUnitsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('units', getU32Decoder()),
    ('additionalFee', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => RequestUnitsInstructionData(
      discriminator: map['discriminator']! as int,
      units: map['units']! as int,
      additionalFee: map['additionalFee']! as int,
    ),
  );
}

Codec<RequestUnitsInstructionData, RequestUnitsInstructionData> getRequestUnitsInstructionDataCodec() {
  return combineCodec(getRequestUnitsInstructionDataEncoder(), getRequestUnitsInstructionDataDecoder());
}

/// Creates a [RequestUnits] instruction.
Instruction getRequestUnitsInstruction({
  required Address programAddress,

  required int units,
  required int additionalFee,
}) {
  final instructionData = RequestUnitsInstructionData(
      units: units,
      additionalFee: additionalFee,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [

    ],
    data: getRequestUnitsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [RequestUnits] instruction from raw instruction data.
RequestUnitsInstructionData parseRequestUnitsInstruction(Instruction instruction) {
  return getRequestUnitsInstructionDataDecoder().decode(instruction.data!);
}
