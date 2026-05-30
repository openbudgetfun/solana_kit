// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/stake_authorize.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class AuthorizeInstructionData {
  const AuthorizeInstructionData({
    this.discriminator = 1,
    required this.arg0,
    required this.arg1,
  });

  final int discriminator;
  final Address arg0;
  final StakeAuthorize arg1;
}

Encoder<AuthorizeInstructionData> getAuthorizeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('arg0', getAddressEncoder()),
    ('arg1', getStakeAuthorizeEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'arg0': value.arg0,
      'arg1': value.arg1,
    },
  );
}

Decoder<AuthorizeInstructionData> getAuthorizeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('arg0', getAddressDecoder()),
    ('arg1', getStakeAuthorizeDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AuthorizeInstructionData(
          discriminator: map['discriminator']! as int,
          arg0: map['arg0']! as Address,
          arg1: map['arg1']! as StakeAuthorize,
        ),
  );
}

Codec<AuthorizeInstructionData, AuthorizeInstructionData>
getAuthorizeInstructionDataCodec() {
  return combineCodec(
    getAuthorizeInstructionDataEncoder(),
    getAuthorizeInstructionDataDecoder(),
  );
}

/// Creates a [Authorize] instruction.
Instruction getAuthorizeInstruction({
  required Address programAddress,
  required Address stake,
  required Address clockSysvar,
  required Address authority,
  Address? lockupAuthority,
  required Address arg0,
  required StakeAuthorize arg1,
}) {
  final instructionData = AuthorizeInstructionData(arg0: arg0, arg1: arg1);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      if (lockupAuthority != null)
        AccountMeta(address: lockupAuthority, role: AccountRole.readonlySigner),
    ],
    data: getAuthorizeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Authorize] instruction from raw instruction data.
AuthorizeInstructionData parseAuthorizeInstruction(Instruction instruction) {
  return getAuthorizeInstructionDataDecoder().decode(instruction.data!);
}
