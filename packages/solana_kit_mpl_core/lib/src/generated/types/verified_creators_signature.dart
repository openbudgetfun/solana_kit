// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class VerifiedCreatorsSignature {
  const VerifiedCreatorsSignature({
    required this.address,
    required this.verified,
  });

  final Address address;
  final bool verified;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifiedCreatorsSignature &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          verified == other.verified;

  @override
  int get hashCode => Object.hash(address, verified);

  @override
  String toString() =>
      'VerifiedCreatorsSignature(address: $address, verified: $verified)';
}

Encoder<VerifiedCreatorsSignature> getVerifiedCreatorsSignatureEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('address', getAddressEncoder()),
    ('verified', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VerifiedCreatorsSignature value) => <String, Object?>{
      'address': value.address,
      'verified': value.verified,
    },
  );
}

Decoder<VerifiedCreatorsSignature> getVerifiedCreatorsSignatureDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('address', getAddressDecoder()),
    ('verified', getBooleanDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        VerifiedCreatorsSignature(
          address: map['address']! as Address,
          verified: map['verified']! as bool,
        ),
  );
}

Codec<VerifiedCreatorsSignature, VerifiedCreatorsSignature>
getVerifiedCreatorsSignatureCodec() {
  return combineCodec(
    getVerifiedCreatorsSignatureEncoder(),
    getVerifiedCreatorsSignatureDecoder(),
  );
}
