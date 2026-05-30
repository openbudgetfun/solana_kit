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
class AuthorizeCheckedInstructionData {
  const AuthorizeCheckedInstructionData({
    this.discriminator = 10,
    required this.stakeAuthorize,
  });

  final int discriminator;
  final StakeAuthorize stakeAuthorize;
}

Encoder<AuthorizeCheckedInstructionData>
getAuthorizeCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('stakeAuthorize', getStakeAuthorizeEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizeCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'stakeAuthorize': value.stakeAuthorize,
    },
  );
}

Decoder<AuthorizeCheckedInstructionData>
getAuthorizeCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('stakeAuthorize', getStakeAuthorizeDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AuthorizeCheckedInstructionData(
          discriminator: map['discriminator']! as int,
          stakeAuthorize: map['stakeAuthorize']! as StakeAuthorize,
        ),
  );
}

Codec<AuthorizeCheckedInstructionData, AuthorizeCheckedInstructionData>
getAuthorizeCheckedInstructionDataCodec() {
  return combineCodec(
    getAuthorizeCheckedInstructionDataEncoder(),
    getAuthorizeCheckedInstructionDataDecoder(),
  );
}

/// Creates a [AuthorizeChecked] instruction.
Instruction getAuthorizeCheckedInstruction({
  required Address programAddress,
  required Address stake,
  required Address clockSysvar,
  required Address authority,
  required Address newAuthority,
  Address? lockupAuthority,
  required StakeAuthorize stakeAuthorize,
}) {
  final instructionData = AuthorizeCheckedInstructionData(
    stakeAuthorize: stakeAuthorize,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: newAuthority, role: AccountRole.readonlySigner),
      if (lockupAuthority != null)
        AccountMeta(address: lockupAuthority, role: AccountRole.readonlySigner),
    ],
    data: getAuthorizeCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AuthorizeChecked] instruction from raw instruction data.
AuthorizeCheckedInstructionData parseAuthorizeCheckedInstruction(
  Instruction instruction,
) {
  return getAuthorizeCheckedInstructionDataDecoder().decode(instruction.data!);
}
