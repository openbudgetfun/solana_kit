// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './collection_details.dart';

sealed class CollectionDetailsToggle {
  const CollectionDetailsToggle();
}

final class CollectionDetailsToggleNone extends CollectionDetailsToggle {
  const CollectionDetailsToggleNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CollectionDetailsToggleNone;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CollectionDetailsToggle.None()';
}

final class CollectionDetailsToggleClear extends CollectionDetailsToggle {
  const CollectionDetailsToggleClear();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CollectionDetailsToggleClear;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CollectionDetailsToggle.Clear()';
}

final class CollectionDetailsToggleSet extends CollectionDetailsToggle {
  const CollectionDetailsToggleSet(this.value);

  final CollectionDetails value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionDetailsToggleSet && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CollectionDetailsToggle.Set($value)';
}

Encoder<CollectionDetailsToggle> getCollectionDetailsToggleEncoder() {
  return transformEncoder<Map<String, Object?>, CollectionDetailsToggle>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (1, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        2,
        transformEncoder<CollectionDetails, Map<String, Object?>>(
          getCollectionDetailsEncoder(),
          (Map<String, Object?> map) => map['value']! as CollectionDetails,
        ),
      ),
    ], size: getU8Encoder()),
    (CollectionDetailsToggle value) => switch (value) {
      CollectionDetailsToggleNone() => <String, Object?>{'__kind': 0},
      CollectionDetailsToggleClear() => <String, Object?>{'__kind': 1},
      CollectionDetailsToggleSet(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
    },
  );
}

Decoder<CollectionDetailsToggle> getCollectionDetailsToggleDecoder() {
  return transformDecoder<Map<String, Object?>, CollectionDetailsToggle>(
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
        transformDecoder<CollectionDetails, Map<String, Object?>>(
          getCollectionDetailsDecoder(),
          (CollectionDetails value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const CollectionDetailsToggleNone();
        case 1:
          return const CollectionDetailsToggleClear();
        case 2:
          return CollectionDetailsToggleSet(map['value']! as CollectionDetails);
      }
      throw StateError(
        'Unsupported CollectionDetailsToggle discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<CollectionDetailsToggle, CollectionDetailsToggle>
getCollectionDetailsToggleCodec() {
  return combineCodec(
    getCollectionDetailsToggleEncoder(),
    getCollectionDetailsToggleDecoder(),
  );
}
