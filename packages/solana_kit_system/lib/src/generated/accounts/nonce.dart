// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import '../types/nonce_state.dart';
import '../types/nonce_version.dart';


@immutable
class Nonce {
  const Nonce({
    required this.version,
    required this.state,
    required this.authority,
    required this.blockhash,
    required this.lamportsPerSignature,
  });

  final NonceVersion version;
  final NonceState state;
  final Address authority;
  final Address blockhash;
  final BigInt lamportsPerSignature;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Nonce &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          state == other.state &&
          authority == other.authority &&
          blockhash == other.blockhash &&
          lamportsPerSignature == other.lamportsPerSignature;

  @override
  int get hashCode => Object.hash(version, state, authority, blockhash, lamportsPerSignature);

  @override
  String toString() => 'Nonce(version: $version, state: $state, authority: $authority, blockhash: $blockhash, lamportsPerSignature: $lamportsPerSignature)';
}


/// The size of the [Nonce] account data in bytes.
const int nonceSize = 80;


Encoder<Nonce> getNonceEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('version', getNonceVersionEncoder()),
    ('state', getNonceStateEncoder()),
    ('authority', getAddressEncoder()),
    ('blockhash', getAddressEncoder()),
    ('lamportsPerSignature', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Nonce value) => <String, Object?>{
      'version': value.version,
      'state': value.state,
      'authority': value.authority,
      'blockhash': value.blockhash,
      'lamportsPerSignature': value.lamportsPerSignature,
    },
  );
}

Decoder<Nonce> getNonceDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('version', getNonceVersionDecoder()),
    ('state', getNonceStateDecoder()),
    ('authority', getAddressDecoder()),
    ('blockhash', getAddressDecoder()),
    ('lamportsPerSignature', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Nonce(
      version: map['version']! as NonceVersion,
      state: map['state']! as NonceState,
      authority: map['authority']! as Address,
      blockhash: map['blockhash']! as Address,
      lamportsPerSignature: map['lamportsPerSignature']! as BigInt,
    ),
  );
}

Codec<Nonce, Nonce> getNonceCodec() {
  return combineCodec(getNonceEncoder(), getNonceDecoder());
}

Account<Nonce> decodeNonce(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getNonceDecoder());
}
