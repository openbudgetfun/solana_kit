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
class Multisig {
  const Multisig({
    required this.m,
    required this.n,
    required this.isInitialized,
    required this.signers,
  });

  final int m;
  final int n;
  final bool isInitialized;
  final List<Address> signers;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Multisig &&
          runtimeType == other.runtimeType &&
          m == other.m &&
          n == other.n &&
          isInitialized == other.isInitialized &&
          signers == other.signers;

  @override
  int get hashCode => Object.hash(m, n, isInitialized, signers);

  @override
  String toString() => 'Multisig(m: $m, n: $n, isInitialized: $isInitialized, signers: $signers)';
}


/// The size of the [Multisig] account data in bytes.
const int multisigSize = 355;

/// This account has a size discriminator of 355 bytes.


Encoder<Multisig> getMultisigEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('m', getU8Encoder()),
    ('n', getU8Encoder()),
    ('isInitialized', getBooleanEncoder()),
    ('signers', getArrayEncoder(getAddressEncoder(), size: FixedArraySize(11))),
  ]);

  return transformEncoder(
    structEncoder,
    (Multisig value) => <String, Object?>{
      'm': value.m,
      'n': value.n,
      'isInitialized': value.isInitialized,
      'signers': value.signers,
    },
  );
}

Decoder<Multisig> getMultisigDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('m', getU8Decoder()),
    ('n', getU8Decoder()),
    ('isInitialized', getBooleanDecoder()),
    ('signers', getArrayDecoder(getAddressDecoder(), size: FixedArraySize(11))),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Multisig(
      m: map['m']! as int,
      n: map['n']! as int,
      isInitialized: map['isInitialized']! as bool,
      signers: map['signers']! as List<Address>,
    ),
  );
}

Codec<Multisig, Multisig> getMultisigCodec() {
  return combineCodec(getMultisigEncoder(), getMultisigDecoder());
}

Account<Multisig> decodeMultisig(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getMultisigDecoder());
}
