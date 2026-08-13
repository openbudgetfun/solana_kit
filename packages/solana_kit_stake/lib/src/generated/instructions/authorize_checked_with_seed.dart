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

import '../types/stake_authorize.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class AuthorizeCheckedWithSeedInstructionData {
  const AuthorizeCheckedWithSeedInstructionData({
    this.discriminator = 11,
    required this.stakeAuthorize,
    required this.authoritySeed,
    required this.authorityOwner,
  });

  final int discriminator;
  final StakeAuthorize stakeAuthorize;
  final String authoritySeed;
  final Address authorityOwner;
}

Encoder<AuthorizeCheckedWithSeedInstructionData>
getAuthorizeCheckedWithSeedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('stakeAuthorize', getStakeAuthorizeEncoder()),
    ('authoritySeed', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('authorityOwner', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizeCheckedWithSeedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'stakeAuthorize': value.stakeAuthorize,
      'authoritySeed': value.authoritySeed,
      'authorityOwner': value.authorityOwner,
    },
  );
}

Decoder<AuthorizeCheckedWithSeedInstructionData>
getAuthorizeCheckedWithSeedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('stakeAuthorize', getStakeAuthorizeDecoder()),
    ('authoritySeed', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('authorityOwner', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AuthorizeCheckedWithSeedInstructionData(
          discriminator: map['discriminator']! as int,
          stakeAuthorize: map['stakeAuthorize']! as StakeAuthorize,
          authoritySeed: map['authoritySeed']! as String,
          authorityOwner: map['authorityOwner']! as Address,
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
  required StakeAuthorize stakeAuthorize,
  required String authoritySeed,
  required Address authorityOwner,
}) {
  final instructionData = AuthorizeCheckedWithSeedInstructionData(
    stakeAuthorize: stakeAuthorize,
    authoritySeed: authoritySeed,
    authorityOwner: authorityOwner,
  );

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
