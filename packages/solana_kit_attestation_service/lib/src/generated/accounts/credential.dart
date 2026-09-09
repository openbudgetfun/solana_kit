// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

@immutable
class Credential {
  const Credential({
    required this.discriminator,
    required this.authority,
    required this.name,
    required this.authorizedSigners,
  });

  final int discriminator;
  final Address authority;
  final Uint8List name;
  final List<Address> authorizedSigners;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Credential &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          authority == other.authority &&
          name == other.name &&
          authorizedSigners == other.authorizedSigners;

  @override
  int get hashCode =>
      Object.hash(discriminator, authority, name, authorizedSigners);

  @override
  String toString() =>
      'Credential(discriminator: $discriminator, authority: $authority, name: $name, authorizedSigners: $authorizedSigners)';
}

Encoder<Credential> getCredentialEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('authority', getAddressEncoder()),
    ('name', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
    (
      'authorizedSigners',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Credential value) => <String, Object?>{
      'discriminator': value.discriminator,
      'authority': value.authority,
      'name': value.name,
      'authorizedSigners': value.authorizedSigners,
    },
  );
}

Decoder<Credential> getCredentialDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('authority', getAddressDecoder()),
    ('name', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ('authorizedSigners', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'credential account decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (Credential, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      Credential(
        discriminator: map['discriminator']! as int,
        authority: map['authority']! as Address,
        name: map['name']! as Uint8List,
        authorizedSigners: map['authorizedSigners']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<Credential>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<Credential>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<Credential, Credential> getCredentialCodec() {
  return combineCodec(getCredentialEncoder(), getCredentialDecoder());
}

Account<Credential> decodeCredential(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getCredentialDecoder());
}
