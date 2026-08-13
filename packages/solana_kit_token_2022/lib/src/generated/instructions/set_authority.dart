// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/authority_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class SetAuthorityInstructionData {
  const SetAuthorityInstructionData({
    this.discriminator = 6,
    required this.authorityType,
    required this.newAuthority,
  });

  final int discriminator;
  final AuthorityType authorityType;
  final Address? newAuthority;
}

Encoder<SetAuthorityInstructionData> getSetAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('authorityType', getAuthorityTypeEncoder()),
    ('newAuthority', getNullableEncoder<Address>(getAddressEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (SetAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'authorityType': value.authorityType,
      'newAuthority': value.newAuthority,
    },
  );
}

Decoder<SetAuthorityInstructionData> getSetAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('authorityType', getAuthorityTypeDecoder()),
    ('newAuthority', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SetAuthorityInstructionData(
      discriminator: map['discriminator']! as int,
      authorityType: map['authorityType']! as AuthorityType,
      newAuthority: map['newAuthority'] as Address?,
    ),
  );
}

Codec<SetAuthorityInstructionData, SetAuthorityInstructionData> getSetAuthorityInstructionDataCodec() {
  return combineCodec(getSetAuthorityInstructionDataEncoder(), getSetAuthorityInstructionDataDecoder());
}

/// Creates a [SetAuthority] instruction.
Instruction getSetAuthorityInstruction({
  required Address programAddress,
  required Address owned,
  required Address owner,
  required AuthorityType authorityType,
  required Address? newAuthority,
}) {
  final instructionData = SetAuthorityInstructionData(
      authorityType: authorityType,
      newAuthority: newAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: owned, role: AccountRole.writable),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getSetAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetAuthority] instruction from raw instruction data.
SetAuthorityInstructionData parseSetAuthorityInstruction(Instruction instruction) {
  return getSetAuthorityInstructionDataDecoder().decode(instruction.data!);
}
