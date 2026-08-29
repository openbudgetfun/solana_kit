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

import '../types/key.dart';

@immutable
class Edition {
  const Edition({
    required this.key,
    required this.parent,
    required this.edition,
  });

  final Key key;
  final Address parent;
  final BigInt edition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edition &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          parent == other.parent &&
          edition == other.edition;

  @override
  int get hashCode => Object.hash(key, parent, edition);

  @override
  String toString() => 'Edition(key: $key, parent: $parent, edition: $edition)';
}

/// The size of the [Edition] account data in bytes.
const int editionSize = 41;

Encoder<Edition> getEditionEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('parent', getAddressEncoder()),
    ('edition', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Edition value) => <String, Object?>{
      'key': value.key,
      'parent': value.parent,
      'edition': value.edition,
    },
  );
}

Decoder<Edition> getEditionDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('parent', getAddressDecoder()),
    ('edition', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'edition account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (Edition, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      Edition(
        key: map['key']! as Key,
        parent: map['parent']! as Address,
        edition: map['edition']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<Edition>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() => VariableSizeDecoder<Edition>(
      read: readTopLevel,
      maxSize: structDecoder.maxSize,
    ),
  };
}

Codec<Edition, Edition> getEditionCodec() {
  return combineCodec(getEditionEncoder(), getEditionDecoder());
}

Account<Edition> decodeEdition(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getEditionDecoder());
}
