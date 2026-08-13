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
class AuthorizeWithSeedInstructionData {
  const AuthorizeWithSeedInstructionData({
    this.discriminator = 8,
    required this.newAuthorizedPubkey,
    required this.stakeAuthorize,
    required this.authoritySeed,
    required this.authorityOwner,
  });

  final int discriminator;
  final Address newAuthorizedPubkey;
  final StakeAuthorize stakeAuthorize;
  final String authoritySeed;
  final Address authorityOwner;
}

Encoder<AuthorizeWithSeedInstructionData>
getAuthorizeWithSeedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('newAuthorizedPubkey', getAddressEncoder()),
    ('stakeAuthorize', getStakeAuthorizeEncoder()),
    ('authoritySeed', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('authorityOwner', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizeWithSeedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'newAuthorizedPubkey': value.newAuthorizedPubkey,
      'stakeAuthorize': value.stakeAuthorize,
      'authoritySeed': value.authoritySeed,
      'authorityOwner': value.authorityOwner,
    },
  );
}

Decoder<AuthorizeWithSeedInstructionData>
getAuthorizeWithSeedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('newAuthorizedPubkey', getAddressDecoder()),
    ('stakeAuthorize', getStakeAuthorizeDecoder()),
    ('authoritySeed', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('authorityOwner', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AuthorizeWithSeedInstructionData(
          discriminator: map['discriminator']! as int,
          newAuthorizedPubkey: map['newAuthorizedPubkey']! as Address,
          stakeAuthorize: map['stakeAuthorize']! as StakeAuthorize,
          authoritySeed: map['authoritySeed']! as String,
          authorityOwner: map['authorityOwner']! as Address,
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
  required Address newAuthorizedPubkey,
  required StakeAuthorize stakeAuthorize,
  required String authoritySeed,
  required Address authorityOwner,
}) {
  final instructionData = AuthorizeWithSeedInstructionData(
    newAuthorizedPubkey: newAuthorizedPubkey,
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
