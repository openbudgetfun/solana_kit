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
class UpgradeInstructionData {
  const UpgradeInstructionData({
    this.discriminator = 3,
  });

  final int discriminator;
}

Encoder<UpgradeInstructionData> getUpgradeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpgradeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<UpgradeInstructionData> getUpgradeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        UpgradeInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<UpgradeInstructionData, UpgradeInstructionData>
getUpgradeInstructionDataCodec() {
  return combineCodec(
    getUpgradeInstructionDataEncoder(),
    getUpgradeInstructionDataDecoder(),
  );
}

/// Creates a [Upgrade] instruction.
Instruction getUpgradeInstruction({
  required Address programAddress,
  required Address programDataAccount,
  required Address programAccount,
  required Address bufferAccount,
  required Address spillAccount,
  required Address rentSysvar,
  required Address clockSysvar,
  required Address authority,
}) {
  final instructionData = UpgradeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: programDataAccount, role: AccountRole.writable),
      AccountMeta(address: programAccount, role: AccountRole.writable),
      AccountMeta(address: bufferAccount, role: AccountRole.writable),
      AccountMeta(address: spillAccount, role: AccountRole.writable),
      AccountMeta(address: rentSysvar, role: AccountRole.readonly),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getUpgradeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Upgrade] instruction from raw instruction data.
UpgradeInstructionData parseUpgradeInstruction(Instruction instruction) {
  return getUpgradeInstructionDataDecoder().decode(instruction.data!);
}
