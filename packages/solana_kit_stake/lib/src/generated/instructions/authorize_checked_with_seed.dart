// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/authorize_checked_with_seed_params.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class AuthorizeCheckedWithSeedInstructionData {
  const AuthorizeCheckedWithSeedInstructionData({
    this.discriminator = 11,
    required this.arg0,
  });

  final int discriminator;
  final AuthorizeCheckedWithSeedParams arg0;
}

Encoder<AuthorizeCheckedWithSeedInstructionData>
getAuthorizeCheckedWithSeedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('arg0', getAuthorizeCheckedWithSeedParamsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizeCheckedWithSeedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'arg0': value.arg0,
    },
  );
}

Decoder<AuthorizeCheckedWithSeedInstructionData>
getAuthorizeCheckedWithSeedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('arg0', getAuthorizeCheckedWithSeedParamsDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AuthorizeCheckedWithSeedInstructionData(
          discriminator: map['discriminator']! as int,
          arg0: map['arg0']! as AuthorizeCheckedWithSeedParams,
        ),
  );
}

Codec<
  AuthorizeCheckedWithSeedInstructionData,
  AuthorizeCheckedWithSeedInstructionData
>
getAuthorizeCheckedWithSeedInstructionDataCodec() {
  return combineCodec(
    getAuthorizeCheckedWithSeedInstructionDataEncoder(),
    getAuthorizeCheckedWithSeedInstructionDataDecoder(),
  );
}

/// Creates a [AuthorizeCheckedWithSeed] instruction.
Instruction getAuthorizeCheckedWithSeedInstruction({
  required Address programAddress,
  required Address stake,
  required Address base,
  required Address clockSysvar,
  required Address newAuthority,
  Address? lockupAuthority,
  required AuthorizeCheckedWithSeedParams arg0,
}) {
  final instructionData = AuthorizeCheckedWithSeedInstructionData(arg0: arg0);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: base, role: AccountRole.readonlySigner),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      AccountMeta(address: newAuthority, role: AccountRole.readonlySigner),
      if (lockupAuthority != null)
        AccountMeta(address: lockupAuthority, role: AccountRole.readonlySigner),
    ],
    data: getAuthorizeCheckedWithSeedInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [AuthorizeCheckedWithSeed] instruction from raw instruction data.
AuthorizeCheckedWithSeedInstructionData
parseAuthorizeCheckedWithSeedInstruction(Instruction instruction) {
  return getAuthorizeCheckedWithSeedInstructionDataDecoder().decode(
    instruction.data!,
  );
}
