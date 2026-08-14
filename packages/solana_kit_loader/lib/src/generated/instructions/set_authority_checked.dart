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
class SetAuthorityCheckedInstructionData {
  const SetAuthorityCheckedInstructionData({
    this.discriminator = 7,
  });

  final int discriminator;
}

Encoder<SetAuthorityCheckedInstructionData>
getSetAuthorityCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetAuthorityCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<SetAuthorityCheckedInstructionData>
getSetAuthorityCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetAuthorityCheckedInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<SetAuthorityCheckedInstructionData, SetAuthorityCheckedInstructionData>
getSetAuthorityCheckedInstructionDataCodec() {
  return combineCodec(
    getSetAuthorityCheckedInstructionDataEncoder(),
    getSetAuthorityCheckedInstructionDataDecoder(),
  );
}

/// Creates a [SetAuthorityChecked] instruction.
Instruction getSetAuthorityCheckedInstruction({
  required Address programAddress,
  required Address bufferOrProgramDataAccount,
  required Address currentAuthority,
  required Address newAuthority,
}) {
  final instructionData = SetAuthorityCheckedInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(
        address: bufferOrProgramDataAccount,
        role: AccountRole.writable,
      ),
      AccountMeta(address: currentAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: newAuthority, role: AccountRole.readonlySigner),
    ],
    data: getSetAuthorityCheckedInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [SetAuthorityChecked] instruction from raw instruction data.
SetAuthorityCheckedInstructionData parseSetAuthorityCheckedInstruction(
  Instruction instruction,
) {
  return getSetAuthorityCheckedInstructionDataDecoder().decode(
    instruction.data!,
  );
}
