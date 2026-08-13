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
class AuthorizeNonceAccountInstructionData {
  const AuthorizeNonceAccountInstructionData({
    this.discriminator = 7,
    required this.newNonceAuthority,
  });

  final int discriminator;
  final Address newNonceAuthority;
}

Encoder<AuthorizeNonceAccountInstructionData> getAuthorizeNonceAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('newNonceAuthority', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizeNonceAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'newNonceAuthority': value.newNonceAuthority,
    },
  );
}

Decoder<AuthorizeNonceAccountInstructionData> getAuthorizeNonceAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('newNonceAuthority', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AuthorizeNonceAccountInstructionData(
      discriminator: map['discriminator']! as int,
      newNonceAuthority: map['newNonceAuthority']! as Address,
    ),
  );
}

Codec<AuthorizeNonceAccountInstructionData, AuthorizeNonceAccountInstructionData> getAuthorizeNonceAccountInstructionDataCodec() {
  return combineCodec(getAuthorizeNonceAccountInstructionDataEncoder(), getAuthorizeNonceAccountInstructionDataDecoder());
}

/// Creates a [AuthorizeNonceAccount] instruction.
Instruction getAuthorizeNonceAccountInstruction({
  required Address programAddress,
  required Address nonceAccount,
  required Address nonceAuthority,
  required Address newNonceAuthority,
}) {
  final instructionData = AuthorizeNonceAccountInstructionData(
      newNonceAuthority: newNonceAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: nonceAccount, role: AccountRole.writable),
    AccountMeta(address: nonceAuthority, role: AccountRole.readonlySigner),
    ],
    data: getAuthorizeNonceAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AuthorizeNonceAccount] instruction from raw instruction data.
AuthorizeNonceAccountInstructionData parseAuthorizeNonceAccountInstruction(Instruction instruction) {
  return getAuthorizeNonceAccountInstructionDataDecoder().decode(instruction.data!);
}
