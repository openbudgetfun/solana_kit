// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

@immutable
class AutographSignature {
  const AutographSignature({
    required this.address,
    required this.message,
  });

  final Address address;
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutographSignature &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          message == other.message;

  @override
  int get hashCode => Object.hash(address, message);

  @override
  String toString() =>
      'AutographSignature(address: $address, message: $message)';
}

Encoder<AutographSignature> getAutographSignatureEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('address', getAddressEncoder()),
    ('message', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (AutographSignature value) => <String, Object?>{
      'address': value.address,
      'message': value.message,
    },
  );
}

Decoder<AutographSignature> getAutographSignatureDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('address', getAddressDecoder()),
    ('message', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AutographSignature(
          address: map['address']! as Address,
          message: map['message']! as String,
        ),
  );
}

Codec<AutographSignature, AutographSignature> getAutographSignatureCodec() {
  return combineCodec(
    getAutographSignatureEncoder(),
    getAutographSignatureDecoder(),
  );
}
