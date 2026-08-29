// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './collection.dart';
import './creator.dart';
import './uses.dart';

@immutable
class DataV2 {
  const DataV2({
    required this.name,
    required this.symbol,
    required this.uri,
    required this.sellerFeeBasisPoints,
    required this.creators,
    required this.collection,
    required this.uses,
  });

  final String name;
  final String symbol;
  final String uri;
  final int sellerFeeBasisPoints;
  final List<Creator>? creators;
  final Collection? collection;
  final Uses? uses;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataV2 &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          symbol == other.symbol &&
          uri == other.uri &&
          sellerFeeBasisPoints == other.sellerFeeBasisPoints &&
          _listEquals(creators, other.creators) &&
          collection == other.collection &&
          uses == other.uses;

  @override
  int get hashCode => Object.hash(
    name,
    symbol,
    uri,
    sellerFeeBasisPoints,
    _listHashCode(creators),
    collection,
    uses,
  );

  @override
  String toString() =>
      'DataV2(name: $name, symbol: $symbol, uri: $uri, sellerFeeBasisPoints: $sellerFeeBasisPoints, creators: $creators, collection: $collection, uses: $uses)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a);
}

Encoder<DataV2> getDataV2Encoder() {
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
  ]);

  return transformEncoder(
    structEncoder,
    (DataV2 value) => <String, Object?>{
      'name': value.name,
      'symbol': value.symbol,
      'uri': value.uri,
      'sellerFeeBasisPoints': value.sellerFeeBasisPoints,
      'creators': value.creators,
      'collection': value.collection,
      'uses': value.uses,
    },
  );
}

Decoder<DataV2> getDataV2Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('symbol', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('sellerFeeBasisPoints', getU16Decoder()),
    (
      'creators',
      getNullableDecoder<List<Creator>>(getArrayDecoder(getCreatorDecoder())),
    ),
    ('collection', getNullableDecoder<Collection>(getCollectionDecoder())),
    ('uses', getNullableDecoder<Uses>(getUsesDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => DataV2(
      name: map['name']! as String,
      symbol: map['symbol']! as String,
      uri: map['uri']! as String,
      sellerFeeBasisPoints: map['sellerFeeBasisPoints']! as int,
      creators: map['creators'] as List<Creator>?,
      collection: map['collection'] as Collection?,
      uses: map['uses'] as Uses?,
    ),
  );
}

Codec<DataV2, DataV2> getDataV2Codec() {
  return combineCodec(getDataV2Encoder(), getDataV2Decoder());
}
