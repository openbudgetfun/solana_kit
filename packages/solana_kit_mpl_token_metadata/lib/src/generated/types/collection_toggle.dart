// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './collection.dart';

sealed class CollectionToggle {
  const CollectionToggle();
}

final class CollectionToggleNone extends CollectionToggle {
  const CollectionToggleNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CollectionToggleNone;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CollectionToggle.None()';
}

final class CollectionToggleClear extends CollectionToggle {
  const CollectionToggleClear();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CollectionToggleClear;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CollectionToggle.Clear()';
}

final class CollectionToggleSet extends CollectionToggle {
  const CollectionToggleSet(this.value);

  final Collection value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionToggleSet && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CollectionToggle.Set($value)';
}

Encoder<CollectionToggle> getCollectionToggleEncoder() {
  return transformEncoder<Map<String, Object?>, CollectionToggle>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (1, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        2,
        transformEncoder<Collection, Map<String, Object?>>(
          getCollectionEncoder(),
          (Map<String, Object?> map) => map['value']! as Collection,
        ),
      ),
    ], size: getU8Encoder()),
    (CollectionToggle value) => switch (value) {
      CollectionToggleNone() => <String, Object?>{'__kind': 0},
      CollectionToggleClear() => <String, Object?>{'__kind': 1},
      CollectionToggleSet(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
    },
  );
}

Decoder<CollectionToggle> getCollectionToggleDecoder() {
  return transformDecoder<Map<String, Object?>, CollectionToggle>(
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
        transformDecoder<Collection, Map<String, Object?>>(
          getCollectionDecoder(),
          (Collection value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const CollectionToggleNone();
        case 1:
          return const CollectionToggleClear();
        case 2:
          return CollectionToggleSet(map['value']! as Collection);
      }
      throw StateError(
        'Unsupported CollectionToggle discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<CollectionToggle, CollectionToggle> getCollectionToggleCodec() {
  return combineCodec(
    getCollectionToggleEncoder(),
    getCollectionToggleDecoder(),
  );
}
