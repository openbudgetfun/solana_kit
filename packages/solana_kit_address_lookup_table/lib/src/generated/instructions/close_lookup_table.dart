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
class CloseLookupTableInstructionData {
  const CloseLookupTableInstructionData({
    this.discriminator = 4,
  });

  final int discriminator;
}

Encoder<CloseLookupTableInstructionData>
getCloseLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CloseLookupTableInstructionData>
getCloseLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CloseLookupTableInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<CloseLookupTableInstructionData, CloseLookupTableInstructionData>
getCloseLookupTableInstructionDataCodec() {
  return combineCodec(
    getCloseLookupTableInstructionDataEncoder(),
    getCloseLookupTableInstructionDataDecoder(),
  );
}

/// Creates a [CloseLookupTable] instruction.
Instruction getCloseLookupTableInstruction({
  required Address programAddress,
  required Address address,
  required Address authority,
  required Address recipient,
}) {
  final instructionData = CloseLookupTableInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: recipient, role: AccountRole.writable),
    ],
    data: getCloseLookupTableInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseLookupTable] instruction from raw instruction data.
CloseLookupTableInstructionData parseCloseLookupTableInstruction(
  Instruction instruction,
) {
  return getCloseLookupTableInstructionDataDecoder().decode(instruction.data!);
}
