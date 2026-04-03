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
class CreateAssociatedTokenInstructionData {
  const CreateAssociatedTokenInstructionData({
    this.discriminator = 0,
  });

  final int discriminator;
}

Encoder<CreateAssociatedTokenInstructionData> getCreateAssociatedTokenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAssociatedTokenInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CreateAssociatedTokenInstructionData> getCreateAssociatedTokenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CreateAssociatedTokenInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<CreateAssociatedTokenInstructionData, CreateAssociatedTokenInstructionData> getCreateAssociatedTokenInstructionDataCodec() {
  return combineCodec(getCreateAssociatedTokenInstructionDataEncoder(), getCreateAssociatedTokenInstructionDataDecoder());
}

/// Creates a [CreateAssociatedToken] instruction.
Instruction getCreateAssociatedTokenInstruction({
  required Address programAddress,
  required Address payer,
  required Address ata,
  required Address owner,
  required Address mint,
  required Address systemProgram,
  required Address tokenProgram,

}) {
  final instructionData = CreateAssociatedTokenInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: ata, role: AccountRole.writable),
    AccountMeta(address: owner, role: AccountRole.readonly),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getCreateAssociatedTokenInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateAssociatedToken] instruction from raw instruction data.
CreateAssociatedTokenInstructionData parseCreateAssociatedTokenInstruction(Instruction instruction) {
  return getCreateAssociatedTokenInstructionDataDecoder().decode(instruction.data!);
}
