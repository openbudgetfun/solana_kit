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
class InitializeConfidentialMintBurnInstructionData {
  const InitializeConfidentialMintBurnInstructionData({
    this.discriminator = 42,
    this.confidentialMintBurnDiscriminator = 0,
    required this.supplyElgamalPubkey,
    required this.decryptableSupply,
  });

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
  final Address supplyElgamalPubkey;
  final DecryptableBalance decryptableSupply;
}

Encoder<InitializeConfidentialMintBurnInstructionData>
getInitializeConfidentialMintBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
    ('supplyElgamalPubkey', getAddressEncoder()),
    ('decryptableSupply', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeConfidentialMintBurnInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialMintBurnDiscriminator':
          value.confidentialMintBurnDiscriminator,
      'supplyElgamalPubkey': value.supplyElgamalPubkey,
      'decryptableSupply': value.decryptableSupply,
    },
  );
}

Decoder<InitializeConfidentialMintBurnInstructionData>
getInitializeConfidentialMintBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
    ('supplyElgamalPubkey', getAddressDecoder()),
    ('decryptableSupply', getDecryptableBalanceDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        InitializeConfidentialMintBurnInstructionData(
          discriminator: map['discriminator']! as int,
          confidentialMintBurnDiscriminator:
              map['confidentialMintBurnDiscriminator']! as int,
          supplyElgamalPubkey: map['supplyElgamalPubkey']! as Address,
          decryptableSupply: map['decryptableSupply']! as DecryptableBalance,
        ),
  );
}

Codec<
  InitializeConfidentialMintBurnInstructionData,
  InitializeConfidentialMintBurnInstructionData
>
getInitializeConfidentialMintBurnInstructionDataCodec() {
  return combineCodec(
    getInitializeConfidentialMintBurnInstructionDataEncoder(),
    getInitializeConfidentialMintBurnInstructionDataDecoder(),
  );
}

/// Creates a [InitializeConfidentialMintBurn] instruction.
Instruction getInitializeConfidentialMintBurnInstruction({
  required Address programAddress,
  required Address mint,
  required Address supplyElgamalPubkey,
  required DecryptableBalance decryptableSupply,
}) {
  final instructionData = InitializeConfidentialMintBurnInstructionData(
    supplyElgamalPubkey: supplyElgamalPubkey,
    decryptableSupply: decryptableSupply,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeConfidentialMintBurnInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeConfidentialMintBurn] instruction from raw instruction data.
InitializeConfidentialMintBurnInstructionData
parseInitializeConfidentialMintBurnInstruction(Instruction instruction) {
  return getInitializeConfidentialMintBurnInstructionDataDecoder().decode(
    instruction.data!,
  );
}
