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

import '../types/collection_details.dart';
import '../types/collection.dart';
import '../types/data.dart';
import '../types/key.dart';
import '../types/programmable_config.dart';
import '../types/token_standard.dart';
import '../types/uses.dart';

@immutable
class Metadata {
  const Metadata({
    required this.key,
    required this.updateAuthority,
    required this.mint,
    required this.data,
    required this.primarySaleHappened,
    required this.isMutable,
    required this.editionNonce,
    required this.tokenStandard,
    required this.collection,
    required this.uses,
    required this.collectionDetails,
    required this.programmableConfig,
  });

  final Key key;
  final Address updateAuthority;
  final Address mint;
  final Data data;
  final bool primarySaleHappened;
  final bool isMutable;
  final int? editionNonce;
  final TokenStandard? tokenStandard;
  final Collection? collection;
  final Uses? uses;
  final CollectionDetails? collectionDetails;
  final ProgrammableConfig? programmableConfig;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Metadata &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          updateAuthority == other.updateAuthority &&
          mint == other.mint &&
          data == other.data &&
          primarySaleHappened == other.primarySaleHappened &&
          isMutable == other.isMutable &&
          editionNonce == other.editionNonce &&
          tokenStandard == other.tokenStandard &&
          collection == other.collection &&
          uses == other.uses &&
          collectionDetails == other.collectionDetails &&
          programmableConfig == other.programmableConfig;

  @override
  int get hashCode => Object.hash(
    key,
    updateAuthority,
    mint,
    data,
    primarySaleHappened,
    isMutable,
    editionNonce,
    tokenStandard,
    collection,
    uses,
    collectionDetails,
    programmableConfig,
  );

  @override
  String toString() =>
      'Metadata(key: $key, updateAuthority: $updateAuthority, mint: $mint, data: $data, primarySaleHappened: $primarySaleHappened, isMutable: $isMutable, editionNonce: $editionNonce, tokenStandard: $tokenStandard, collection: $collection, uses: $uses, collectionDetails: $collectionDetails, programmableConfig: $programmableConfig)';
}

Encoder<Metadata> getMetadataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('updateAuthority', getAddressEncoder()),
    ('mint', getAddressEncoder()),
    ('data', getDataEncoder()),
    ('primarySaleHappened', getBooleanEncoder()),
    ('isMutable', getBooleanEncoder()),
    ('editionNonce', getNullableEncoder<int>(getU8Encoder())),
    (
      'tokenStandard',
      getNullableEncoder<TokenStandard>(getTokenStandardEncoder()),
    ),
    ('collection', getNullableEncoder<Collection>(getCollectionEncoder())),
    ('uses', getNullableEncoder<Uses>(getUsesEncoder())),
    (
      'collectionDetails',
      getNullableEncoder<CollectionDetails>(getCollectionDetailsEncoder()),
    ),
    (
      'programmableConfig',
      getNullableEncoder<ProgrammableConfig>(getProgrammableConfigEncoder()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Metadata value) => <String, Object?>{
      'key': value.key,
      'updateAuthority': value.updateAuthority,
      'mint': value.mint,
      'data': value.data,
      'primarySaleHappened': value.primarySaleHappened,
      'isMutable': value.isMutable,
      'editionNonce': value.editionNonce,
      'tokenStandard': value.tokenStandard,
      'collection': value.collection,
      'uses': value.uses,
      'collectionDetails': value.collectionDetails,
      'programmableConfig': value.programmableConfig,
    },
  );
}

Decoder<Metadata> getMetadataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('updateAuthority', getAddressDecoder()),
    ('mint', getAddressDecoder()),
    ('data', getDataDecoder()),
    ('primarySaleHappened', getBooleanDecoder()),
    ('isMutable', getBooleanDecoder()),
    ('editionNonce', getNullableDecoder<int>(getU8Decoder())),
    (
      'tokenStandard',
      getNullableDecoder<TokenStandard>(getTokenStandardDecoder()),
    ),
    ('collection', getNullableDecoder<Collection>(getCollectionDecoder())),
    ('uses', getNullableDecoder<Uses>(getUsesDecoder())),
    (
      'collectionDetails',
      getNullableDecoder<CollectionDetails>(getCollectionDetailsDecoder()),
    ),
    (
      'programmableConfig',
      getNullableDecoder<ProgrammableConfig>(getProgrammableConfigDecoder()),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'metadata account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (Metadata, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      Metadata(
        key: map['key']! as Key,
        updateAuthority: map['updateAuthority']! as Address,
        mint: map['mint']! as Address,
        data: map['data']! as Data,
        primarySaleHappened: map['primarySaleHappened']! as bool,
        isMutable: map['isMutable']! as bool,
        editionNonce: map['editionNonce'] as int?,
        tokenStandard: map['tokenStandard'] as TokenStandard?,
        collection: map['collection'] as Collection?,
        uses: map['uses'] as Uses?,
        collectionDetails: map['collectionDetails'] as CollectionDetails?,
        programmableConfig: map['programmableConfig'] as ProgrammableConfig?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<Metadata>(
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
      VariableSizeDecoder<Metadata>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<Metadata, Metadata> getMetadataCodec() {
  return combineCodec(getMetadataEncoder(), getMetadataDecoder());
}

Account<Metadata> decodeMetadata(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getMetadataDecoder());
}
