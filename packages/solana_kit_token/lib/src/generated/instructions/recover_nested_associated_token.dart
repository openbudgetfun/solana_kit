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
class RecoverNestedAssociatedTokenInstructionData {
  const RecoverNestedAssociatedTokenInstructionData({
    this.discriminator = 2,
  });

  final int discriminator;
}

Encoder<RecoverNestedAssociatedTokenInstructionData> getRecoverNestedAssociatedTokenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RecoverNestedAssociatedTokenInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<RecoverNestedAssociatedTokenInstructionData> getRecoverNestedAssociatedTokenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => RecoverNestedAssociatedTokenInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<RecoverNestedAssociatedTokenInstructionData, RecoverNestedAssociatedTokenInstructionData> getRecoverNestedAssociatedTokenInstructionDataCodec() {
  return combineCodec(getRecoverNestedAssociatedTokenInstructionDataEncoder(), getRecoverNestedAssociatedTokenInstructionDataDecoder());
}

/// Creates a [RecoverNestedAssociatedToken] instruction.
Instruction getRecoverNestedAssociatedTokenInstruction({
  required Address programAddress,
  required Address nestedAssociatedAccountAddress,
  required Address nestedTokenMintAddress,
  required Address destinationAssociatedAccountAddress,
  required Address ownerAssociatedAccountAddress,
  required Address ownerTokenMintAddress,
  required Address walletAddress,
  required Address tokenProgram,

}) {
  final instructionData = RecoverNestedAssociatedTokenInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: nestedAssociatedAccountAddress, role: AccountRole.writable),
    AccountMeta(address: nestedTokenMintAddress, role: AccountRole.readonly),
    AccountMeta(address: destinationAssociatedAccountAddress, role: AccountRole.writable),
    AccountMeta(address: ownerAssociatedAccountAddress, role: AccountRole.readonly),
    AccountMeta(address: ownerTokenMintAddress, role: AccountRole.readonly),
    AccountMeta(address: walletAddress, role: AccountRole.writableSigner),
    AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getRecoverNestedAssociatedTokenInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [RecoverNestedAssociatedToken] instruction from raw instruction data.
RecoverNestedAssociatedTokenInstructionData parseRecoverNestedAssociatedTokenInstruction(Instruction instruction) {
  return getRecoverNestedAssociatedTokenInstructionDataDecoder().decode(instruction.data!);
}
