// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/decryptable_balance.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'confidentialMintBurnDiscriminator'.
/// Offset: 1.

@immutable
class UpdateConfidentialMintBurnDecryptableSupplyInstructionData {
  const UpdateConfidentialMintBurnDecryptableSupplyInstructionData({
    this.discriminator = 42,
    this.confidentialMintBurnDiscriminator = 2,
    required this.newDecryptableSupply,
  });

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
  final DecryptableBalance newDecryptableSupply;
}

Encoder<UpdateConfidentialMintBurnDecryptableSupplyInstructionData>
getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
    ('newDecryptableSupply', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateConfidentialMintBurnDecryptableSupplyInstructionData value) =>
        <String, Object?>{
          'discriminator': value.discriminator,
          'confidentialMintBurnDiscriminator':
              value.confidentialMintBurnDiscriminator,
          'newDecryptableSupply': value.newDecryptableSupply,
        },
  );
}

Decoder<UpdateConfidentialMintBurnDecryptableSupplyInstructionData>
getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
    ('newDecryptableSupply', getDecryptableBalanceDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        UpdateConfidentialMintBurnDecryptableSupplyInstructionData(
          discriminator: map['discriminator']! as int,
          confidentialMintBurnDiscriminator:
              map['confidentialMintBurnDiscriminator']! as int,
          newDecryptableSupply:
              map['newDecryptableSupply']! as DecryptableBalance,
        ),
  );
}

Codec<
  UpdateConfidentialMintBurnDecryptableSupplyInstructionData,
  UpdateConfidentialMintBurnDecryptableSupplyInstructionData
>
getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataCodec() {
  return combineCodec(
    getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataEncoder(),
    getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataDecoder(),
  );
}

/// Creates a [UpdateConfidentialMintBurnDecryptableSupply] instruction.
Instruction getUpdateConfidentialMintBurnDecryptableSupplyInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
  required DecryptableBalance newDecryptableSupply,
}) {
  final instructionData =
      UpdateConfidentialMintBurnDecryptableSupplyInstructionData(
        newDecryptableSupply: newDecryptableSupply,
      );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [UpdateConfidentialMintBurnDecryptableSupply] instruction from raw instruction data.
UpdateConfidentialMintBurnDecryptableSupplyInstructionData
parseUpdateConfidentialMintBurnDecryptableSupplyInstruction(
  Instruction instruction,
) {
  return getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataDecoder()
      .decode(instruction.data!);
}
