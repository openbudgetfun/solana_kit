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
class CreateAccountInstructionData {
  const CreateAccountInstructionData({
    this.discriminator = 0,
    required this.lamports,
    required this.space,
    required this.programAddress,
  });

  final int discriminator;
  final BigInt lamports;
  final BigInt space;
  final Address programAddress;
}

Encoder<CreateAccountInstructionData> getCreateAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('lamports', getU64Encoder()),
    ('space', getU64Encoder()),
    ('programAddress', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'lamports': value.lamports,
      'space': value.space,
      'programAddress': value.programAddress,
    },
  );
}

Decoder<CreateAccountInstructionData> getCreateAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('lamports', getU64Decoder()),
    ('space', getU64Decoder()),
    ('programAddress', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CreateAccountInstructionData(
      discriminator: map['discriminator']! as int,
      lamports: map['lamports']! as BigInt,
      space: map['space']! as BigInt,
      programAddress: map['programAddress']! as Address,
    ),
  );
}

Codec<CreateAccountInstructionData, CreateAccountInstructionData> getCreateAccountInstructionDataCodec() {
  return combineCodec(getCreateAccountInstructionDataEncoder(), getCreateAccountInstructionDataDecoder());
}

/// Creates a [CreateAccount] instruction.
Instruction getCreateAccountInstruction({
  required Address instructionProgramAddress,
  required Address payer,
  required Address newAccount,
  required BigInt lamports,
  required BigInt space,
  required Address programAddress,
}) {
  final instructionData = CreateAccountInstructionData(
      lamports: lamports,
      space: space,
      programAddress: programAddress,
  );

  return Instruction(
    programAddress: instructionProgramAddress,
    accounts: [
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: newAccount, role: AccountRole.writableSigner),
    ],
    data: getCreateAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateAccount] instruction from raw instruction data.
CreateAccountInstructionData parseCreateAccountInstruction(Instruction instruction) {
  return getCreateAccountInstructionDataDecoder().decode(instruction.data!);
}
