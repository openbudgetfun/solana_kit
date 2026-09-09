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
class Attestation {
  const Attestation({
    required this.discriminator,
    required this.nonce,
    required this.credential,
    required this.schema,
    required this.data,
    required this.signer,
    required this.expiry,
    required this.tokenAccount,
  });

  final int discriminator;
  final Address nonce;
  final Address credential;
  final Address schema;
  final Uint8List data;
  final Address signer;
  final BigInt expiry;
  final Address tokenAccount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attestation &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          nonce == other.nonce &&
          credential == other.credential &&
          schema == other.schema &&
          data == other.data &&
          signer == other.signer &&
          expiry == other.expiry &&
          tokenAccount == other.tokenAccount;

  @override
  int get hashCode => Object.hash(
    discriminator,
    nonce,
    credential,
    schema,
    data,
    signer,
    expiry,
    tokenAccount,
  );

  @override
  String toString() =>
      'Attestation(discriminator: $discriminator, nonce: $nonce, credential: $credential, schema: $schema, data: $data, signer: $signer, expiry: $expiry, tokenAccount: $tokenAccount)';
}

Encoder<Attestation> getAttestationEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('nonce', getAddressEncoder()),
    ('credential', getAddressEncoder()),
    ('schema', getAddressEncoder()),
    ('data', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
    ('signer', getAddressEncoder()),
    ('expiry', getI64Encoder()),
    ('tokenAccount', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Attestation value) => <String, Object?>{
      'discriminator': value.discriminator,
      'nonce': value.nonce,
      'credential': value.credential,
      'schema': value.schema,
      'data': value.data,
      'signer': value.signer,
      'expiry': value.expiry,
      'tokenAccount': value.tokenAccount,
    },
  );
}

Decoder<Attestation> getAttestationDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('nonce', getAddressDecoder()),
    ('credential', getAddressDecoder()),
    ('schema', getAddressDecoder()),
    ('data', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ('signer', getAddressDecoder()),
    ('expiry', getI64Decoder()),
    ('tokenAccount', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'attestation account decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (Attestation, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      Attestation(
        discriminator: map['discriminator']! as int,
        nonce: map['nonce']! as Address,
        credential: map['credential']! as Address,
        schema: map['schema']! as Address,
        data: map['data']! as Uint8List,
        signer: map['signer']! as Address,
        expiry: map['expiry']! as BigInt,
        tokenAccount: map['tokenAccount']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<Attestation>(
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
      VariableSizeDecoder<Attestation>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<Attestation, Attestation> getAttestationCodec() {
  return combineCodec(getAttestationEncoder(), getAttestationDecoder());
}

Account<Attestation> decodeAttestation(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getAttestationDecoder());
}
