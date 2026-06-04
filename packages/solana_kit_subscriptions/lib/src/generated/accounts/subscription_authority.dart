// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class SubscriptionAuthority {
  const SubscriptionAuthority({
    required this.discriminator,
    required this.user,
    required this.tokenMint,
    required this.payer,
    required this.bump,
    required this.initId,
  });

  final int discriminator;
  final Address user;
  final Address tokenMint;
  final Address payer;
  final int bump;
  final BigInt initId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAuthority &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          user == other.user &&
          tokenMint == other.tokenMint &&
          payer == other.payer &&
          bump == other.bump &&
          initId == other.initId;

  @override
  int get hashCode =>
      Object.hash(discriminator, user, tokenMint, payer, bump, initId);

  @override
  String toString() =>
      'SubscriptionAuthority(discriminator: $discriminator, user: $user, tokenMint: $tokenMint, payer: $payer, bump: $bump, initId: $initId)';
}

Encoder<SubscriptionAuthority> getSubscriptionAuthorityEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('user', getAddressEncoder()),
    ('tokenMint', getAddressEncoder()),
    ('payer', getAddressEncoder()),
    ('bump', getU8Encoder()),
    ('initId', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SubscriptionAuthority value) => <String, Object?>{
      'discriminator': value.discriminator,
      'user': value.user,
      'tokenMint': value.tokenMint,
      'payer': value.payer,
      'bump': value.bump,
      'initId': value.initId,
    },
  );
}

Decoder<SubscriptionAuthority> getSubscriptionAuthorityDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('user', getAddressDecoder()),
    ('tokenMint', getAddressDecoder()),
    ('payer', getAddressDecoder()),
    ('bump', getU8Decoder()),
    ('initId', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SubscriptionAuthority(
          discriminator: map['discriminator']! as int,
          user: map['user']! as Address,
          tokenMint: map['tokenMint']! as Address,
          payer: map['payer']! as Address,
          bump: map['bump']! as int,
          initId: map['initId']! as BigInt,
        ),
  );
}

Codec<SubscriptionAuthority, SubscriptionAuthority>
getSubscriptionAuthorityCodec() {
  return combineCodec(
    getSubscriptionAuthorityEncoder(),
    getSubscriptionAuthorityDecoder(),
  );
}

Account<SubscriptionAuthority> decodeSubscriptionAuthority(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getSubscriptionAuthorityDecoder());
}
