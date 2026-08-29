// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './collection_details.dart';
import './collection.dart';
import './creator.dart';
import './token_standard.dart';
import './uses.dart';

@immutable
class AssetData {
  const AssetData({
    required this.name,
    required this.symbol,
    required this.uri,
    required this.sellerFeeBasisPoints,
    required this.creators,
    required this.primarySaleHappened,
    required this.isMutable,
    required this.tokenStandard,
    required this.collection,
    required this.uses,
    required this.collectionDetails,
    required this.ruleSet,
  });

  final String name;
  final String symbol;
  final String uri;
  final int sellerFeeBasisPoints;
  final List<Creator>? creators;
  final bool primarySaleHappened;
  final bool isMutable;
  final TokenStandard tokenStandard;
  final Collection? collection;
  final Uses? uses;
  final CollectionDetails? collectionDetails;
  final Address? ruleSet;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetData &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          symbol == other.symbol &&
          uri == other.uri &&
          sellerFeeBasisPoints == other.sellerFeeBasisPoints &&
          _listEquals(creators, other.creators) &&
          primarySaleHappened == other.primarySaleHappened &&
          isMutable == other.isMutable &&
          tokenStandard == other.tokenStandard &&
          collection == other.collection &&
          uses == other.uses &&
          collectionDetails == other.collectionDetails &&
          ruleSet == other.ruleSet;

  @override
  int get hashCode => Object.hash(
    name,
    symbol,
    uri,
    sellerFeeBasisPoints,
    _listHashCode(creators),
    primarySaleHappened,
    isMutable,
    tokenStandard,
    collection,
    uses,
    collectionDetails,
    ruleSet,
  );

  @override
  String toString() =>
      'AssetData(name: $name, symbol: $symbol, uri: $uri, sellerFeeBasisPoints: $sellerFeeBasisPoints, creators: $creators, primarySaleHappened: $primarySaleHappened, isMutable: $isMutable, tokenStandard: $tokenStandard, collection: $collection, uses: $uses, collectionDetails: $collectionDetails, ruleSet: $ruleSet)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left is List<Object?> && right is List<Object?>) {
      if (!_listEquals(left, right)) return false;
    } else if (left != right) {
      return false;
    }
  }
  return true;
}

Object? _deepHash(Object? value) {
  if (value is List<Object?>) {
    return Object.hashAll(value.map(_deepHash));
  }
  return value;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a.map(_deepHash));
}

Encoder<AssetData> getAssetDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('symbol', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('sellerFeeBasisPoints', getU16Encoder()),
    (
      'creators',
      getNullableEncoder<List<Creator>>(
        transformEncoder(
          getArrayEncoder(
            transformEncoder(getCreatorEncoder(), (Creator value) => value),
          ),
          (List<Creator> value) => value,
        ),
      ),
    ),
    ('primarySaleHappened', getBooleanEncoder()),
    ('isMutable', getBooleanEncoder()),
    ('tokenStandard', getTokenStandardEncoder()),
    (
      'collection',
      getNullableEncoder<Collection>(
        transformEncoder(getCollectionEncoder(), (Collection value) => value),
      ),
    ),
    (
      'uses',
      getNullableEncoder<Uses>(
        transformEncoder(getUsesEncoder(), (Uses value) => value),
      ),
    ),
    (
      'collectionDetails',
      getNullableEncoder<CollectionDetails>(
        transformEncoder(
          getCollectionDetailsEncoder(),
          (CollectionDetails value) => value,
        ),
      ),
    ),
    (
      'ruleSet',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (AssetData value) => <String, Object?>{
      'name': value.name,
      'symbol': value.symbol,
      'uri': value.uri,
      'sellerFeeBasisPoints': value.sellerFeeBasisPoints,
      'creators': value.creators,
      'primarySaleHappened': value.primarySaleHappened,
      'isMutable': value.isMutable,
      'tokenStandard': value.tokenStandard,
      'collection': value.collection,
      'uses': value.uses,
      'collectionDetails': value.collectionDetails,
      'ruleSet': value.ruleSet,
    },
  );
}

Decoder<AssetData> getAssetDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('symbol', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('sellerFeeBasisPoints', getU16Decoder()),
    (
      'creators',
      getNullableDecoder<List<Creator>>(getArrayDecoder(getCreatorDecoder())),
    ),
    ('primarySaleHappened', getBooleanDecoder()),
    ('isMutable', getBooleanDecoder()),
    ('tokenStandard', getTokenStandardDecoder()),
    ('collection', getNullableDecoder<Collection>(getCollectionDecoder())),
    ('uses', getNullableDecoder<Uses>(getUsesDecoder())),
    (
      'collectionDetails',
      getNullableDecoder<CollectionDetails>(getCollectionDetailsDecoder()),
    ),
    ('ruleSet', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AssetData(
      name: map['name']! as String,
      symbol: map['symbol']! as String,
      uri: map['uri']! as String,
      sellerFeeBasisPoints: map['sellerFeeBasisPoints']! as int,
      creators: map['creators'] as List<Creator>?,
      primarySaleHappened: map['primarySaleHappened']! as bool,
      isMutable: map['isMutable']! as bool,
      tokenStandard: map['tokenStandard']! as TokenStandard,
      collection: map['collection'] as Collection?,
      uses: map['uses'] as Uses?,
      collectionDetails: map['collectionDetails'] as CollectionDetails?,
      ruleSet: map['ruleSet'] as Address?,
    ),
  );
}

Codec<AssetData, AssetData> getAssetDataCodec() {
  return combineCodec(getAssetDataEncoder(), getAssetDataDecoder());
}
