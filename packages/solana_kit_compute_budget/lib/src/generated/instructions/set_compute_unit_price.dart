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
class SetComputeUnitPriceInstructionData {
  const SetComputeUnitPriceInstructionData({
    this.discriminator = 3,
    required this.microLamports,
  });

  final int discriminator;
  final BigInt microLamports;
}

Encoder<SetComputeUnitPriceInstructionData> getSetComputeUnitPriceInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('microLamports', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetComputeUnitPriceInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'microLamports': value.microLamports,
    },
  );
}

Decoder<SetComputeUnitPriceInstructionData> getSetComputeUnitPriceInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('microLamports', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SetComputeUnitPriceInstructionData(
      discriminator: map['discriminator']! as int,
      microLamports: map['microLamports']! as BigInt,
    ),
  );
}

Codec<SetComputeUnitPriceInstructionData, SetComputeUnitPriceInstructionData> getSetComputeUnitPriceInstructionDataCodec() {
  return combineCodec(getSetComputeUnitPriceInstructionDataEncoder(), getSetComputeUnitPriceInstructionDataDecoder());
}

/// Creates a [SetComputeUnitPrice] instruction.
Instruction getSetComputeUnitPriceInstruction({
  required Address programAddress,

  required BigInt microLamports,
}) {
  final instructionData = SetComputeUnitPriceInstructionData(
      microLamports: microLamports,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [

    ],
    data: getSetComputeUnitPriceInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetComputeUnitPrice] instruction from raw instruction data.
SetComputeUnitPriceInstructionData parseSetComputeUnitPriceInstruction(Instruction instruction) {
  return getSetComputeUnitPriceInstructionDataDecoder().decode(instruction.data!);
}
