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

/// The discriminator field name: 'cpiGuardDiscriminator'.
/// Offset: 1.

@immutable
class EnableCpiGuardInstructionData {
  const EnableCpiGuardInstructionData({
    this.discriminator = 34,
    this.cpiGuardDiscriminator = 0,
  });

  final int discriminator;
  final int cpiGuardDiscriminator;
}

Encoder<EnableCpiGuardInstructionData> getEnableCpiGuardInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('cpiGuardDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EnableCpiGuardInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'cpiGuardDiscriminator': value.cpiGuardDiscriminator,
    },
  );
}

Decoder<EnableCpiGuardInstructionData> getEnableCpiGuardInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('cpiGuardDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => EnableCpiGuardInstructionData(
      discriminator: map['discriminator']! as int,
      cpiGuardDiscriminator: map['cpiGuardDiscriminator']! as int,
    ),
  );
}

Codec<EnableCpiGuardInstructionData, EnableCpiGuardInstructionData> getEnableCpiGuardInstructionDataCodec() {
  return combineCodec(getEnableCpiGuardInstructionDataEncoder(), getEnableCpiGuardInstructionDataDecoder());
}

/// Creates a [EnableCpiGuard] instruction.
Instruction getEnableCpiGuardInstruction({
  required Address programAddress,
  required Address token,
  required Address owner,

}) {
  final instructionData = EnableCpiGuardInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getEnableCpiGuardInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [EnableCpiGuard] instruction from raw instruction data.
EnableCpiGuardInstructionData parseEnableCpiGuardInstruction(Instruction instruction) {
  return getEnableCpiGuardInstructionDataDecoder().decode(instruction.data!);
}
