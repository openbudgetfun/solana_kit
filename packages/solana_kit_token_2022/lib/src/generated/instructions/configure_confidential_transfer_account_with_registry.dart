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

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class ConfigureConfidentialTransferAccountWithRegistryInstructionData {
  const ConfigureConfidentialTransferAccountWithRegistryInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 14,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<ConfigureConfidentialTransferAccountWithRegistryInstructionData>
getConfigureConfidentialTransferAccountWithRegistryInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfigureConfidentialTransferAccountWithRegistryInstructionData value) =>
        <String, Object?>{
          'discriminator': value.discriminator,
          'confidentialTransferDiscriminator':
              value.confidentialTransferDiscriminator,
        },
  );
}

Decoder<ConfigureConfidentialTransferAccountWithRegistryInstructionData>
getConfigureConfidentialTransferAccountWithRegistryInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ConfigureConfidentialTransferAccountWithRegistryInstructionData(
          discriminator: map['discriminator']! as int,
          confidentialTransferDiscriminator:
              map['confidentialTransferDiscriminator']! as int,
        ),
  );
}

Codec<
  ConfigureConfidentialTransferAccountWithRegistryInstructionData,
  ConfigureConfidentialTransferAccountWithRegistryInstructionData
>
getConfigureConfidentialTransferAccountWithRegistryInstructionDataCodec() {
  return combineCodec(
    getConfigureConfidentialTransferAccountWithRegistryInstructionDataEncoder(),
    getConfigureConfidentialTransferAccountWithRegistryInstructionDataDecoder(),
  );
}

/// Creates a [ConfigureConfidentialTransferAccountWithRegistry] instruction.
Instruction getConfigureConfidentialTransferAccountWithRegistryInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  required Address elgamalRegistry,
  Address? payer,
  Address? systemProgram,
}) {
  final instructionData =
      ConfigureConfidentialTransferAccountWithRegistryInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: elgamalRegistry, role: AccountRole.readonly),
      if (payer != null)
        AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (systemProgram != null)
        AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data:
        getConfigureConfidentialTransferAccountWithRegistryInstructionDataEncoder()
            .encode(instructionData),
  );
}

/// Parses a [ConfigureConfidentialTransferAccountWithRegistry] instruction from raw instruction data.
ConfigureConfidentialTransferAccountWithRegistryInstructionData
parseConfigureConfidentialTransferAccountWithRegistryInstruction(
  Instruction instruction,
) {
  return getConfigureConfidentialTransferAccountWithRegistryInstructionDataDecoder()
      .decode(instruction.data!);
}
