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
class InitializeCheckedInstructionData {
  const InitializeCheckedInstructionData({this.discriminator = 9});

  final int discriminator;
}

Encoder<InitializeCheckedInstructionData>
getInitializeCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<InitializeCheckedInstructionData>
getInitializeCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        InitializeCheckedInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<InitializeCheckedInstructionData, InitializeCheckedInstructionData>
getInitializeCheckedInstructionDataCodec() {
  return combineCodec(
    getInitializeCheckedInstructionDataEncoder(),
    getInitializeCheckedInstructionDataDecoder(),
  );
}

/// Creates a [InitializeChecked] instruction.
Instruction getInitializeCheckedInstruction({
  required Address programAddress,
  required Address stake,
  required Address rentSysvar,
  required Address stakeAuthority,
  required Address withdrawAuthority,
}) {
  final instructionData = InitializeCheckedInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: rentSysvar, role: AccountRole.readonly),
      AccountMeta(address: stakeAuthority, role: AccountRole.readonly),
      AccountMeta(address: withdrawAuthority, role: AccountRole.readonlySigner),
    ],
    data: getInitializeCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeChecked] instruction from raw instruction data.
InitializeCheckedInstructionData parseInitializeCheckedInstruction(
  Instruction instruction,
) {
  return getInitializeCheckedInstructionDataDecoder().decode(instruction.data!);
}
