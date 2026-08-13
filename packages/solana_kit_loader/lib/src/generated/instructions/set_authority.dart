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
class SetAuthorityInstructionData {
  const SetAuthorityInstructionData({
    this.discriminator = 4,
  });

  final int discriminator;
}

Encoder<SetAuthorityInstructionData> getSetAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<SetAuthorityInstructionData> getSetAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetAuthorityInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<SetAuthorityInstructionData, SetAuthorityInstructionData>
getSetAuthorityInstructionDataCodec() {
  return combineCodec(
    getSetAuthorityInstructionDataEncoder(),
    getSetAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [SetAuthority] instruction.
Instruction getSetAuthorityInstruction({
  required Address programAddress,
  required Address bufferOrProgramDataAccount,
  required Address currentAuthority,
  Address? newAuthority,
}) {
  final instructionData = SetAuthorityInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(
        address: bufferOrProgramDataAccount,
        role: AccountRole.writable,
      ),
      AccountMeta(address: currentAuthority, role: AccountRole.readonlySigner),
      if (newAuthority != null)
        AccountMeta(address: newAuthority, role: AccountRole.readonly),
    ],
    data: getSetAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetAuthority] instruction from raw instruction data.
SetAuthorityInstructionData parseSetAuthorityInstruction(
  Instruction instruction,
) {
  return getSetAuthorityInstructionDataDecoder().decode(instruction.data!);
}
