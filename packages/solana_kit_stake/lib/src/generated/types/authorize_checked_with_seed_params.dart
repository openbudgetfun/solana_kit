// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './stake_authorize.dart';

Encoder<num> _getU64SizePrefixEncoder() =>
    transformEncoder<BigInt, num>(getU64Encoder(), BigInt.from);

Decoder<num> _getU64SizePrefixDecoder() => transformDecoder<BigInt, num>(
  getU64Decoder(),
  (value, _, _) => value.toInt(),
);

@immutable
class AuthorizeCheckedWithSeedParams {
  const AuthorizeCheckedWithSeedParams({
    required this.stakeAuthorize,
    required this.authoritySeed,
    required this.authorityOwner,
  });

  final StakeAuthorize stakeAuthorize;
  final String authoritySeed;
  final Address authorityOwner;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizeCheckedWithSeedParams &&
          runtimeType == other.runtimeType &&
          stakeAuthorize == other.stakeAuthorize &&
          authoritySeed == other.authoritySeed &&
          authorityOwner == other.authorityOwner;

  @override
  int get hashCode =>
      Object.hash(stakeAuthorize, authoritySeed, authorityOwner);

  @override
  String toString() =>
      'AuthorizeCheckedWithSeedParams(stakeAuthorize: $stakeAuthorize, authoritySeed: $authoritySeed, authorityOwner: $authorityOwner)';
}

Encoder<AuthorizeCheckedWithSeedParams>
getAuthorizeCheckedWithSeedParamsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('stakeAuthorize', getStakeAuthorizeEncoder()),
    (
      'authoritySeed',
      addEncoderSizePrefix(getUtf8Encoder(), _getU64SizePrefixEncoder()),
    ),
    ('authorityOwner', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AuthorizeCheckedWithSeedParams value) => <String, Object?>{
      'stakeAuthorize': value.stakeAuthorize,
      'authoritySeed': value.authoritySeed,
      'authorityOwner': value.authorityOwner,
    },
  );
}

Decoder<AuthorizeCheckedWithSeedParams>
getAuthorizeCheckedWithSeedParamsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('stakeAuthorize', getStakeAuthorizeDecoder()),
    (
      'authoritySeed',
      addDecoderSizePrefix(getUtf8Decoder(), _getU64SizePrefixDecoder()),
    ),
    ('authorityOwner', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AuthorizeCheckedWithSeedParams(
          stakeAuthorize: map['stakeAuthorize']! as StakeAuthorize,
          authoritySeed: map['authoritySeed']! as String,
          authorityOwner: map['authorityOwner']! as Address,
        ),
  );
}

Codec<AuthorizeCheckedWithSeedParams, AuthorizeCheckedWithSeedParams>
getAuthorizeCheckedWithSeedParamsCodec() {
  return combineCodec(
    getAuthorizeCheckedWithSeedParamsEncoder(),
    getAuthorizeCheckedWithSeedParamsDecoder(),
  );
}
