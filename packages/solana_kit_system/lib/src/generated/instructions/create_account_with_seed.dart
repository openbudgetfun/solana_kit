// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateAccountWithSeedInstructionData {
  const CreateAccountWithSeedInstructionData({
    this.discriminator = 3,
    required this.base,
    required this.seed,
    required this.amount,
    required this.space,
    required this.programAddress,
  });

  final int discriminator;
  final Address base;
  final String seed;
  final BigInt amount;
  final BigInt space;
  final Address programAddress;
}

Encoder<CreateAccountWithSeedInstructionData> getCreateAccountWithSeedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('base', getAddressEncoder()),
    ('seed', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('amount', getU64Encoder()),
    ('space', getU64Encoder()),
    ('programAddress', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAccountWithSeedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'base': value.base,
      'seed': value.seed,
      'amount': value.amount,
      'space': value.space,
      'programAddress': value.programAddress,
    },
  );
}

Decoder<CreateAccountWithSeedInstructionData> getCreateAccountWithSeedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('base', getAddressDecoder()),
    ('seed', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('amount', getU64Decoder()),
    ('space', getU64Decoder()),
    ('programAddress', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CreateAccountWithSeedInstructionData(
      discriminator: map['discriminator']! as int,
      base: map['base']! as Address,
      seed: map['seed']! as String,
      amount: map['amount']! as BigInt,
      space: map['space']! as BigInt,
      programAddress: map['programAddress']! as Address,
    ),
  );
}

Codec<CreateAccountWithSeedInstructionData, CreateAccountWithSeedInstructionData> getCreateAccountWithSeedInstructionDataCodec() {
  return combineCodec(getCreateAccountWithSeedInstructionDataEncoder(), getCreateAccountWithSeedInstructionDataDecoder());
}

/// Creates a [CreateAccountWithSeed] instruction.
Instruction getCreateAccountWithSeedInstruction({
  required Address instructionProgramAddress,
  required Address payer,
  required Address newAccount,
  Address? baseAccount,
  required Address base,
  required String seed,
  required BigInt amount,
  required BigInt space,
  required Address programAddress,
}) {
  final instructionData = CreateAccountWithSeedInstructionData(
      base: base,
      seed: seed,
      amount: amount,
      space: space,
      programAddress: programAddress,
  );

  return Instruction(
    programAddress: instructionProgramAddress,
    accounts: [
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: newAccount, role: AccountRole.writable),
    if (baseAccount != null) AccountMeta(address: baseAccount, role: AccountRole.readonlySigner),
    ],
    data: getCreateAccountWithSeedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateAccountWithSeed] instruction from raw instruction data.
CreateAccountWithSeedInstructionData parseCreateAccountWithSeedInstruction(Instruction instruction) {
  return getCreateAccountWithSeedInstructionDataDecoder().decode(instruction.data!);
}
