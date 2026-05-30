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
class DeactivateDelinquentInstructionData {
  const DeactivateDelinquentInstructionData({this.discriminator = 14});

  final int discriminator;
}

Encoder<DeactivateDelinquentInstructionData>
getDeactivateDelinquentInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeactivateDelinquentInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<DeactivateDelinquentInstructionData>
getDeactivateDelinquentInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        DeactivateDelinquentInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<DeactivateDelinquentInstructionData, DeactivateDelinquentInstructionData>
getDeactivateDelinquentInstructionDataCodec() {
  return combineCodec(
    getDeactivateDelinquentInstructionDataEncoder(),
    getDeactivateDelinquentInstructionDataDecoder(),
  );
}

/// Creates a [DeactivateDelinquent] instruction.
Instruction getDeactivateDelinquentInstruction({
  required Address programAddress,
  required Address stake,
  required Address delinquentVote,
  required Address referenceVote,
}) {
  final instructionData = DeactivateDelinquentInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: delinquentVote, role: AccountRole.readonly),
      AccountMeta(address: referenceVote, role: AccountRole.readonly),
    ],
    data: getDeactivateDelinquentInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DeactivateDelinquent] instruction from raw instruction data.
DeactivateDelinquentInstructionData parseDeactivateDelinquentInstruction(
  Instruction instruction,
) {
  return getDeactivateDelinquentInstructionDataDecoder().decode(
    instruction.data!,
  );
}
