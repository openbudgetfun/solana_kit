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
class DeactivateLookupTableInstructionData {
  const DeactivateLookupTableInstructionData({
    this.discriminator = 3,
  });

  final int discriminator;
}

Encoder<DeactivateLookupTableInstructionData>
getDeactivateLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeactivateLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<DeactivateLookupTableInstructionData>
getDeactivateLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        DeactivateLookupTableInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<
  DeactivateLookupTableInstructionData,
  DeactivateLookupTableInstructionData
>
getDeactivateLookupTableInstructionDataCodec() {
  return combineCodec(
    getDeactivateLookupTableInstructionDataEncoder(),
    getDeactivateLookupTableInstructionDataDecoder(),
  );
}

/// Creates a [DeactivateLookupTable] instruction.
Instruction getDeactivateLookupTableInstruction({
  required Address programAddress,
  required Address address,
  required Address authority,
}) {
  final instructionData = DeactivateLookupTableInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getDeactivateLookupTableInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DeactivateLookupTable] instruction from raw instruction data.
DeactivateLookupTableInstructionData parseDeactivateLookupTableInstruction(
  Instruction instruction,
) {
  return getDeactivateLookupTableInstructionDataDecoder().decode(
    instruction.data!,
  );
}
