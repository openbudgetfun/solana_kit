// ignore_for_file: public_member_api_docs

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// System Program instruction discriminator for `CreateAccountAllowPrefund`.
const createAccountAllowPrefundDiscriminator = 13;

/// Data payload for the System Program `CreateAccountAllowPrefund` instruction.
@immutable
class CreateAccountAllowPrefundInstructionData {
  const CreateAccountAllowPrefundInstructionData({
    required this.lamports,
    required this.space,
    required this.programAddress,
    this.discriminator = createAccountAllowPrefundDiscriminator,
  });

  final int discriminator;
  final BigInt lamports;
  final BigInt space;
  final Address programAddress;
}

Encoder<CreateAccountAllowPrefundInstructionData>
getCreateAccountAllowPrefundInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('lamports', getU64Encoder()),
    ('space', getU64Encoder()),
    ('programAddress', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (value) => <String, Object?>{
      'discriminator': value.discriminator,
      'lamports': value.lamports,
      'space': value.space,
      'programAddress': value.programAddress,
    },
  );
}

Decoder<CreateAccountAllowPrefundInstructionData>
getCreateAccountAllowPrefundInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('lamports', getU64Decoder()),
    ('space', getU64Decoder()),
    ('programAddress', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (map, bytes, offset) => CreateAccountAllowPrefundInstructionData(
      discriminator: map['discriminator']! as int,
      lamports: map['lamports']! as BigInt,
      space: map['space']! as BigInt,
      programAddress: map['programAddress']! as Address,
    ),
  );
}

Codec<
  CreateAccountAllowPrefundInstructionData,
  CreateAccountAllowPrefundInstructionData
>
getCreateAccountAllowPrefundInstructionDataCodec() {
  return combineCodec(
    getCreateAccountAllowPrefundInstructionDataEncoder(),
    getCreateAccountAllowPrefundInstructionDataDecoder(),
  );
}

/// Builds a System Program `CreateAccountAllowPrefund` instruction.
Instruction getCreateAccountAllowPrefundInstruction({
  required Address newAccount,
  required BigInt space,
  required Address ownerProgramAddress,
  BigInt? lamports,
  Address? payer,
  Address programAddress = systemProgramAddress,
}) {
  final instructionData = CreateAccountAllowPrefundInstructionData(
    lamports: lamports ?? BigInt.zero,
    space: space,
    programAddress: ownerProgramAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: newAccount, role: AccountRole.writableSigner),
      if (payer != null)
        AccountMeta(address: payer, role: AccountRole.writableSigner),
    ],
    data: getCreateAccountAllowPrefundInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a System Program `CreateAccountAllowPrefund` instruction.
CreateAccountAllowPrefundInstructionData
parseCreateAccountAllowPrefundInstruction(
  Instruction instruction,
) {
  return getCreateAccountAllowPrefundInstructionDataDecoder().decode(
    instruction.data!,
  );
}
