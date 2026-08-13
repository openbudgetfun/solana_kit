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
class FreezeLookupTableInstructionData {
  const FreezeLookupTableInstructionData({
    this.discriminator = 1,
  });

  final int discriminator;
}

Encoder<FreezeLookupTableInstructionData>
getFreezeLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (FreezeLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<FreezeLookupTableInstructionData>
getFreezeLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        FreezeLookupTableInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<FreezeLookupTableInstructionData, FreezeLookupTableInstructionData>
getFreezeLookupTableInstructionDataCodec() {
  return combineCodec(
    getFreezeLookupTableInstructionDataEncoder(),
    getFreezeLookupTableInstructionDataDecoder(),
  );
}

/// Creates a [FreezeLookupTable] instruction.
Instruction getFreezeLookupTableInstruction({
  required Address programAddress,
  required Address address,
  required Address authority,
}) {
  final instructionData = FreezeLookupTableInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getFreezeLookupTableInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [FreezeLookupTable] instruction from raw instruction data.
FreezeLookupTableInstructionData parseFreezeLookupTableInstruction(
  Instruction instruction,
) {
  return getFreezeLookupTableInstructionDataDecoder().decode(instruction.data!);
}
