// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import '../types/vault_status.dart';


@immutable
class Vault {
  const Vault({
    required this.discriminator,
    required this.authority,
    required this.tokenMint,
    required this.totalDeposited,
    required this.maxCapacity,
    required this.status,
    required this.createdAt,
    required this.bumpSeed,
  });

  final Uint8List discriminator;
  final Address authority;
  final Address tokenMint;
  final BigInt totalDeposited;
  final BigInt maxCapacity;
  final VaultStatus status;
  final BigInt createdAt;
  final int bumpSeed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vault &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          authority == other.authority &&
          tokenMint == other.tokenMint &&
          totalDeposited == other.totalDeposited &&
          maxCapacity == other.maxCapacity &&
          status == other.status &&
          createdAt == other.createdAt &&
          bumpSeed == other.bumpSeed;

  @override
  int get hashCode => Object.hash(discriminator, authority, tokenMint, totalDeposited, maxCapacity, status, createdAt, bumpSeed);

  @override
  String toString() => 'Vault(discriminator: $discriminator, authority: $authority, tokenMint: $tokenMint, totalDeposited: $totalDeposited, maxCapacity: $maxCapacity, status: $status, createdAt: $createdAt, bumpSeed: $bumpSeed)';
}


/// The size of the [Vault] account data in bytes.
const int vaultSize = 98;

/// The discriminator field name: 'discriminator'.
/// Offset: 0.


Encoder<Vault> getVaultEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', fixEncoderSize(getBytesEncoder(), 8)),
    ('authority', getAddressEncoder()),
    ('tokenMint', getAddressEncoder()),
    ('totalDeposited', getU64Encoder()),
    ('maxCapacity', getU64Encoder()),
    ('status', getVaultStatusEncoder()),
    ('createdAt', getI64Encoder()),
    ('bumpSeed', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Vault value) => <String, Object?>{
      'discriminator': value.discriminator,
      'authority': value.authority,
      'tokenMint': value.tokenMint,
      'totalDeposited': value.totalDeposited,
      'maxCapacity': value.maxCapacity,
      'status': value.status,
      'createdAt': value.createdAt,
      'bumpSeed': value.bumpSeed,
    },
  );
}

Decoder<Vault> getVaultDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('authority', getAddressDecoder()),
    ('tokenMint', getAddressDecoder()),
    ('totalDeposited', getU64Decoder()),
    ('maxCapacity', getU64Decoder()),
    ('status', getVaultStatusDecoder()),
    ('createdAt', getI64Decoder()),
    ('bumpSeed', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Vault(
      discriminator: map['discriminator']! as Uint8List,
      authority: map['authority']! as Address,
      tokenMint: map['tokenMint']! as Address,
      totalDeposited: map['totalDeposited']! as BigInt,
      maxCapacity: map['maxCapacity']! as BigInt,
      status: map['status']! as VaultStatus,
      createdAt: map['createdAt']! as BigInt,
      bumpSeed: map['bumpSeed']! as int,
    ),
  );
}

Codec<Vault, Vault> getVaultCodec() {
  return combineCodec(getVaultEncoder(), getVaultDecoder());
}

Account<Vault> decodeVault(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getVaultDecoder());
}
