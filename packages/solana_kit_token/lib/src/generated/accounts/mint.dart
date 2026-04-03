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
class Mint {
  const Mint({
    required this.mintAuthority,
    required this.supply,
    required this.decimals,
    required this.isInitialized,
    required this.freezeAuthority,
  });

  final Address? mintAuthority;
  final BigInt supply;
  final int decimals;
  final bool isInitialized;
  final Address? freezeAuthority;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mint &&
          runtimeType == other.runtimeType &&
          mintAuthority == other.mintAuthority &&
          supply == other.supply &&
          decimals == other.decimals &&
          isInitialized == other.isInitialized &&
          freezeAuthority == other.freezeAuthority;

  @override
  int get hashCode => Object.hash(mintAuthority, supply, decimals, isInitialized, freezeAuthority);

  @override
  String toString() => 'Mint(mintAuthority: $mintAuthority, supply: $supply, decimals: $decimals, isInitialized: $isInitialized, freezeAuthority: $freezeAuthority)';
}


/// The size of the [Mint] account data in bytes.
const int mintSize = 82;

/// This account has a size discriminator of 82 bytes.


Encoder<Mint> getMintEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('mintAuthority', getNullableEncoder<Address>(getAddressEncoder(), prefix: getU32Encoder())),
    ('supply', getU64Encoder()),
    ('decimals', getU8Encoder()),
    ('isInitialized', getBooleanEncoder()),
    ('freezeAuthority', getNullableEncoder<Address>(getAddressEncoder(), prefix: getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (Mint value) => <String, Object?>{
      'mintAuthority': value.mintAuthority,
      'supply': value.supply,
      'decimals': value.decimals,
      'isInitialized': value.isInitialized,
      'freezeAuthority': value.freezeAuthority,
    },
  );
}

Decoder<Mint> getMintDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('mintAuthority', getNullableDecoder<Address>(getAddressDecoder(), prefix: getU32Decoder())),
    ('supply', getU64Decoder()),
    ('decimals', getU8Decoder()),
    ('isInitialized', getBooleanDecoder()),
    ('freezeAuthority', getNullableDecoder<Address>(getAddressDecoder(), prefix: getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Mint(
      mintAuthority: map['mintAuthority'] as Address?,
      supply: map['supply']! as BigInt,
      decimals: map['decimals']! as int,
      isInitialized: map['isInitialized']! as bool,
      freezeAuthority: map['freezeAuthority'] as Address?,
    ),
  );
}

Codec<Mint, Mint> getMintCodec() {
  return combineCodec(getMintEncoder(), getMintDecoder());
}

Account<Mint> decodeMint(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getMintDecoder());
}
