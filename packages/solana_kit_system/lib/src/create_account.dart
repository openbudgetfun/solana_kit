import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The address of the System Program.
const systemProgramAddress = Address('11111111111111111111111111111111');

/// System Program instruction discriminators.
enum SystemInstruction {
  createAccount,
}

/// Data payload for the System Program `CreateAccount` instruction.
@immutable
class CreateAccountInstructionData {
  const CreateAccountInstructionData({
    required this.lamports,
    required this.space,
    required this.programOwner,
    this.discriminator = 0,
  });

  final int discriminator;
  final BigInt lamports;
  final BigInt space;
  final Address programOwner;
}

Encoder<CreateAccountInstructionData> getCreateAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('lamports', getU64Encoder()),
    ('space', getU64Encoder()),
    ('programOwner', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'lamports': value.lamports,
      'space': value.space,
      'programOwner': value.programOwner,
    },
  );
}

Decoder<CreateAccountInstructionData> getCreateAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('lamports', getU64Decoder()),
    ('space', getU64Decoder()),
    ('programOwner', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CreateAccountInstructionData(
          discriminator: map['discriminator']! as int,
          lamports: map['lamports']! as BigInt,
          space: map['space']! as BigInt,
          programOwner: map['programOwner']! as Address,
        ),
  );
}

Codec<CreateAccountInstructionData, CreateAccountInstructionData>
getCreateAccountInstructionDataCodec() {
  return combineCodec(
    getCreateAccountInstructionDataEncoder(),
    getCreateAccountInstructionDataDecoder(),
  );
}

/// Builds a System Program `CreateAccount` instruction.
Instruction getCreateAccountInstruction({
  required Address payer,
  required Address newAccount,
  required BigInt lamports,
  required BigInt space,
  required Address programOwner,
  Address programAddress = systemProgramAddress,
}) {
  final instructionData = CreateAccountInstructionData(
    lamports: lamports,
    space: space,
    programOwner: programOwner,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: newAccount, role: AccountRole.writableSigner),
    ],
    data: getCreateAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a System Program `CreateAccount` instruction.
CreateAccountInstructionData parseCreateAccountInstruction(
  Instruction instruction,
) {
  return getCreateAccountInstructionDataDecoder().decode(instruction.data!);
}
