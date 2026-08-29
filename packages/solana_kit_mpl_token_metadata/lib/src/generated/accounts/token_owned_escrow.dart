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

import '../types/escrow_authority.dart';
import '../types/key.dart';

@immutable
class TokenOwnedEscrow {
  const TokenOwnedEscrow({
    required this.key,
    required this.baseToken,
    required this.authority,
    required this.bump,
  });

  final Key key;
  final Address baseToken;
  final EscrowAuthority authority;
  final int bump;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenOwnedEscrow &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          baseToken == other.baseToken &&
          authority == other.authority &&
          bump == other.bump;

  @override
  int get hashCode => Object.hash(key, baseToken, authority, bump);

  @override
  String toString() =>
      'TokenOwnedEscrow(key: $key, baseToken: $baseToken, authority: $authority, bump: $bump)';
}

Encoder<TokenOwnedEscrow> getTokenOwnedEscrowEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('baseToken', getAddressEncoder()),
    ('authority', getEscrowAuthorityEncoder()),
    ('bump', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TokenOwnedEscrow value) => <String, Object?>{
      'key': value.key,
      'baseToken': value.baseToken,
      'authority': value.authority,
      'bump': value.bump,
    },
  );
}

Decoder<TokenOwnedEscrow> getTokenOwnedEscrowDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('baseToken', getAddressDecoder()),
    ('authority', getEscrowAuthorityDecoder()),
    ('bump', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'tokenOwnedEscrow account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TokenOwnedEscrow, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      TokenOwnedEscrow(
        key: map['key']! as Key,
        baseToken: map['baseToken']! as Address,
        authority: map['authority']! as EscrowAuthority,
        bump: map['bump']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TokenOwnedEscrow>(
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
      VariableSizeDecoder<TokenOwnedEscrow>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<TokenOwnedEscrow, TokenOwnedEscrow> getTokenOwnedEscrowCodec() {
  return combineCodec(
    getTokenOwnedEscrowEncoder(),
    getTokenOwnedEscrowDecoder(),
  );
}

Account<TokenOwnedEscrow> decodeTokenOwnedEscrow(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getTokenOwnedEscrowDecoder());
}
