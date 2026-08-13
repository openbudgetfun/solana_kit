// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import '../types/extension.dart';


@immutable
class Mint {
  const Mint({
    required this.mintAuthority,
    required this.supply,
    required this.decimals,
    required this.isInitialized,
    required this.freezeAuthority,
    required this.extensions,
  });

  final Address? mintAuthority;
  final BigInt supply;
  final int decimals;
  final bool isInitialized;
  final Address? freezeAuthority;
  final List<Extension>? extensions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mint &&
          runtimeType == other.runtimeType &&
          mintAuthority == other.mintAuthority &&
          supply == other.supply &&
          decimals == other.decimals &&
          isInitialized == other.isInitialized &&
          freezeAuthority == other.freezeAuthority &&
          extensions == other.extensions;

  @override
  int get hashCode => Object.hash(mintAuthority, supply, decimals, isInitialized, freezeAuthority, extensions);

  @override
  String toString() => 'Mint(mintAuthority: $mintAuthority, supply: $supply, decimals: $decimals, isInitialized: $isInitialized, freezeAuthority: $freezeAuthority, extensions: $extensions)';
}

/// This account has a size discriminator of 82 bytes.


Encoder<Mint> getMintEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('mintAuthority', getNullableEncoder<Address>(getAddressEncoder(), prefix: getU32Encoder(), noneValue: const ZeroesNoneValue())),
    ('supply', getU64Encoder()),
    ('decimals', getU8Encoder()),
    ('isInitialized', getBooleanEncoder()),
    ('freezeAuthority', getNullableEncoder<Address>(getAddressEncoder(), prefix: getU32Encoder(), noneValue: const ZeroesNoneValue())),
    ('extensions', getNullableEncoder<List<Extension>>(getHiddenPrefixEncoder(getArrayEncoder(getExtensionEncoder(), size: RemainderArraySize()), [getConstantEncoder(padLeftEncoder(getU8Encoder(), 83).encode(1))]), hasPrefix: false)),
  ]);

  return transformEncoder(
    structEncoder,
    (Mint value) => <String, Object?>{
      'mintAuthority': value.mintAuthority,
      'supply': value.supply,
      'decimals': value.decimals,
      'isInitialized': value.isInitialized,
      'freezeAuthority': value.freezeAuthority,
      'extensions': value.extensions,
    },
  );
}

Decoder<Mint> getMintDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('mintAuthority', getNullableDecoder<Address>(getAddressDecoder(), prefix: getU32Decoder(), noneValue: const ZeroesNoneValue())),
    ('supply', getU64Decoder()),
    ('decimals', getU8Decoder()),
    ('isInitialized', getBooleanDecoder()),
    ('freezeAuthority', getNullableDecoder<Address>(getAddressDecoder(), prefix: getU32Decoder(), noneValue: const ZeroesNoneValue())),
    ('extensions', getNullableDecoder<List<Extension>>(getHiddenPrefixDecoder(getArrayDecoder(getExtensionDecoder(), size: RemainderArraySize()), [getConstantDecoder(padLeftEncoder(getU8Encoder(), 83).encode(1))]), hasPrefix: false)),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Mint(
      mintAuthority: map['mintAuthority'] as Address?,
      supply: map['supply']! as BigInt,
      decimals: map['decimals']! as int,
      isInitialized: map['isInitialized']! as bool,
      freezeAuthority: map['freezeAuthority'] as Address?,
      extensions: map['extensions'] as List<Extension>?,
    ),
  );
}

Codec<Mint, Mint> getMintCodec() {
  return combineCodec(getMintEncoder(), getMintDecoder());
}

Account<Mint> decodeMint(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getMintDecoder());
}
