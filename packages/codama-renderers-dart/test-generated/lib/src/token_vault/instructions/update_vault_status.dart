// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/vault_status.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateVaultStatusInstructionData {
  const UpdateVaultStatusInstructionData({
    this.discriminator = 3,
    required this.newStatus,
  });

  final int discriminator;
  final VaultStatus newStatus;
}

Encoder<UpdateVaultStatusInstructionData> getUpdateVaultStatusInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('newStatus', getVaultStatusEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateVaultStatusInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'newStatus': value.newStatus,
    },
  );
}

Decoder<UpdateVaultStatusInstructionData> getUpdateVaultStatusInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('newStatus', getVaultStatusDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateVaultStatusInstructionData(
      discriminator: map['discriminator']! as int,
      newStatus: map['newStatus']! as VaultStatus,
    ),
  );
}

Codec<UpdateVaultStatusInstructionData, UpdateVaultStatusInstructionData> getUpdateVaultStatusInstructionDataCodec() {
  return combineCodec(getUpdateVaultStatusInstructionDataEncoder(), getUpdateVaultStatusInstructionDataDecoder());
}

/// Creates a [UpdateVaultStatus] instruction.
Instruction getUpdateVaultStatusInstruction({
  required Address programAddress,
  required Address vault,
  required Address authority,
  required VaultStatus newStatus,
}) {
  final instructionData = UpdateVaultStatusInstructionData(
      newStatus: newStatus,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: vault, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateVaultStatusInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateVaultStatus] instruction from raw instruction data.
UpdateVaultStatusInstructionData parseUpdateVaultStatusInstruction(Instruction instruction) {
  return getUpdateVaultStatusInstructionDataDecoder().decode(instruction.data!);
}
