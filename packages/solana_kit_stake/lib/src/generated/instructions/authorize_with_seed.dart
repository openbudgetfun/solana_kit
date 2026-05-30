// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/authorize_with_seed_params.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class AuthorizeWithSeedInstructionData {
  const AuthorizeWithSeedInstructionData({
    this.discriminator = 8,
    required this.arg0,
  });

  final int discriminator;
  final AuthorizeWithSeedParams arg0;
}

Encoder<AuthorizeWithSeedInstructionData>
getAuthorizeWithSeedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('arg0', getAuthorizeWithSeedParamsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizeWithSeedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'arg0': value.arg0,
    },
  );
}

Decoder<AuthorizeWithSeedInstructionData>
getAuthorizeWithSeedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('arg0', getAuthorizeWithSeedParamsDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AuthorizeWithSeedInstructionData(
          discriminator: map['discriminator']! as int,
          arg0: map['arg0']! as AuthorizeWithSeedParams,
        ),
  );
}

Codec<AuthorizeWithSeedInstructionData, AuthorizeWithSeedInstructionData>
getAuthorizeWithSeedInstructionDataCodec() {
  return combineCodec(
    getAuthorizeWithSeedInstructionDataEncoder(),
    getAuthorizeWithSeedInstructionDataDecoder(),
  );
}

/// Creates a [AuthorizeWithSeed] instruction.
Instruction getAuthorizeWithSeedInstruction({
  required Address programAddress,
  required Address stake,
  required Address base,
  required Address clockSysvar,
  Address? lockupAuthority,
  required AuthorizeWithSeedParams arg0,
}) {
  final instructionData = AuthorizeWithSeedInstructionData(arg0: arg0);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: base, role: AccountRole.readonlySigner),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      if (lockupAuthority != null)
        AccountMeta(address: lockupAuthority, role: AccountRole.readonlySigner),
    ],
    data: getAuthorizeWithSeedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AuthorizeWithSeed] instruction from raw instruction data.
AuthorizeWithSeedInstructionData parseAuthorizeWithSeedInstruction(
  Instruction instruction,
) {
  return getAuthorizeWithSeedInstructionDataDecoder().decode(instruction.data!);
}
