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
class CreateAccountAllowPrefundInstructionData {
  const CreateAccountAllowPrefundInstructionData({
    this.discriminator = 13,
    required this.lamports,
    required this.space,
    required this.programAddress,
  });

  final int discriminator;
  final BigInt lamports;
  final BigInt space;
  final Address programAddress;
}

Encoder<CreateAccountAllowPrefundInstructionData> getCreateAccountAllowPrefundInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('lamports', getU64Encoder()),
    ('space', getU64Encoder()),
    ('programAddress', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAccountAllowPrefundInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'lamports': value.lamports,
      'space': value.space,
      'programAddress': value.programAddress,
    },
  );
}

Decoder<CreateAccountAllowPrefundInstructionData> getCreateAccountAllowPrefundInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('lamports', getU64Decoder()),
    ('space', getU64Decoder()),
    ('programAddress', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CreateAccountAllowPrefundInstructionData(
      discriminator: map['discriminator']! as int,
      lamports: map['lamports']! as BigInt,
      space: map['space']! as BigInt,
      programAddress: map['programAddress']! as Address,
    ),
  );
}

Codec<CreateAccountAllowPrefundInstructionData, CreateAccountAllowPrefundInstructionData> getCreateAccountAllowPrefundInstructionDataCodec() {
  return combineCodec(getCreateAccountAllowPrefundInstructionDataEncoder(), getCreateAccountAllowPrefundInstructionDataDecoder());
}

/// Creates a [CreateAccountAllowPrefund] instruction.
Instruction getCreateAccountAllowPrefundInstruction({
  required Address instructionProgramAddress,
  required Address newAccount,
  Address? payer,
  BigInt? lamports,
  required BigInt space,
  required Address programAddress,
}) {
  final instructionData = CreateAccountAllowPrefundInstructionData(
      lamports: lamports ?? BigInt.from(0),
      space: space,
      programAddress: programAddress,
  );

  return Instruction(
    programAddress: instructionProgramAddress,
    accounts: [
    AccountMeta(address: newAccount, role: AccountRole.writableSigner),
    if (payer != null) AccountMeta(address: payer, role: AccountRole.writableSigner),
    ],
    data: getCreateAccountAllowPrefundInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateAccountAllowPrefund] instruction from raw instruction data.
CreateAccountAllowPrefundInstructionData parseCreateAccountAllowPrefundInstruction(Instruction instruction) {
  return getCreateAccountAllowPrefundInstructionDataDecoder().decode(instruction.data!);
}
