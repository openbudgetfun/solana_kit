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
class RevokeDelegationInstructionData {
  const RevokeDelegationInstructionData({
    this.discriminator = 3,
  });

  final int discriminator;
}

Encoder<RevokeDelegationInstructionData>
getRevokeDelegationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeDelegationInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<RevokeDelegationInstructionData>
getRevokeDelegationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RevokeDelegationInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<RevokeDelegationInstructionData, RevokeDelegationInstructionData>
getRevokeDelegationInstructionDataCodec() {
  return combineCodec(
    getRevokeDelegationInstructionDataEncoder(),
    getRevokeDelegationInstructionDataDecoder(),
  );
}

/// Creates a [RevokeDelegation] instruction.
Instruction getRevokeDelegationInstruction({
  required Address programAddress,
  required Address authority,
  required Address delegationAccount,
}) {
  final instructionData = RevokeDelegationInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.writableSigner),
      AccountMeta(address: delegationAccount, role: AccountRole.writable),
    ],
    data: getRevokeDelegationInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [RevokeDelegation] instruction from raw instruction data.
RevokeDelegationInstructionData parseRevokeDelegationInstruction(
  Instruction instruction,
) {
  return getRevokeDelegationInstructionDataDecoder().decode(instruction.data!);
}
