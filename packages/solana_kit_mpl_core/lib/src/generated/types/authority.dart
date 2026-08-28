// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class Authority {
  const Authority();
}

final class AuthorityNone extends Authority {
  const AuthorityNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthorityNone;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Authority.None()';
}

final class AuthorityOwner extends Authority {
  const AuthorityOwner();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthorityOwner;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Authority.Owner()';
}

final class AuthorityUpdateAuthority extends Authority {
  const AuthorityUpdateAuthority();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthorityUpdateAuthority;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Authority.UpdateAuthority()';
}

final class AuthorityAddress extends Authority {
  const AuthorityAddress({
    required this.address,
  });

  final Address address;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorityAddress && address == other.address;

  @override
  int get hashCode => address.hashCode;

  @override
  String toString() => 'Authority.Address(address: $address)';
}

Encoder<Authority> getAuthorityEncoder() {
  return transformEncoder<Map<String, Object?>, Authority>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (1, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (2, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (3, getStructEncoder([('address', getAddressEncoder())])),
    ], size: getU8Encoder()),
    (Authority value) => switch (value) {
      AuthorityNone() => <String, Object?>{'__kind': 0},
      AuthorityOwner() => <String, Object?>{'__kind': 1},
      AuthorityUpdateAuthority() => <String, Object?>{'__kind': 2},
      AuthorityAddress(address: final address) => <String, Object?>{
        '__kind': 3,
        'address': address,
      },
    },
  );
}

Decoder<Authority> getAuthorityDecoder() {
  return transformDecoder<Map<String, Object?>, Authority>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        2,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        3,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('address', getAddressDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const AuthorityNone();
        case 1:
          return const AuthorityOwner();
        case 2:
          return const AuthorityUpdateAuthority();
        case 3:
          return AuthorityAddress(address: map['address']! as Address);
      }
      throw StateError('Unsupported Authority discriminator: ${map['__kind']}');
    },
  );
}

Codec<Authority, Authority> getAuthorityCodec() {
  return combineCodec(getAuthorityEncoder(), getAuthorityDecoder());
}
