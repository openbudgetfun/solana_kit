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
class CollectionAuthorityRecord {
  const CollectionAuthorityRecord({
    required this.key,
    required this.bump,
    required this.newUpdateAuthority,
  });

  final Key key;
  final int bump;
  final Address? newUpdateAuthority;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionAuthorityRecord &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          bump == other.bump &&
          newUpdateAuthority == other.newUpdateAuthority;

  @override
  int get hashCode => Object.hash(key, bump, newUpdateAuthority);

  @override
  String toString() =>
      'CollectionAuthorityRecord(key: $key, bump: $bump, newUpdateAuthority: $newUpdateAuthority)';
}

Encoder<CollectionAuthorityRecord> getCollectionAuthorityRecordEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('bump', getU8Encoder()),
    (
      'newUpdateAuthority',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CollectionAuthorityRecord value) => <String, Object?>{
      'key': value.key,
      'bump': value.bump,
      'newUpdateAuthority': value.newUpdateAuthority,
    },
  );
}

Decoder<CollectionAuthorityRecord> getCollectionAuthorityRecordDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('bump', getU8Decoder()),
    ('newUpdateAuthority', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'collectionAuthorityRecord account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CollectionAuthorityRecord, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      CollectionAuthorityRecord(
        key: map['key']! as Key,
        bump: map['bump']! as int,
        newUpdateAuthority: map['newUpdateAuthority'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CollectionAuthorityRecord>(
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
      VariableSizeDecoder<CollectionAuthorityRecord>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CollectionAuthorityRecord, CollectionAuthorityRecord>
getCollectionAuthorityRecordCodec() {
  return combineCodec(
    getCollectionAuthorityRecordEncoder(),
    getCollectionAuthorityRecordDecoder(),
  );
}

Account<CollectionAuthorityRecord> decodeCollectionAuthorityRecord(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getCollectionAuthorityRecordDecoder());
}
