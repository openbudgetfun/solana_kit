// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class CollectionDetails {
  const CollectionDetails();
}

final class CollectionDetailsV1 extends CollectionDetails {
  const CollectionDetailsV1({
    required this.size,
  });

  final BigInt size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionDetailsV1 && size == other.size;

  @override
  int get hashCode => size.hashCode;

  @override
  String toString() => 'CollectionDetails.V1(size: $size)';
}

final class CollectionDetailsV2 extends CollectionDetails {
  const CollectionDetailsV2({
    required this.padding,
  });

  final Uint8List padding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionDetailsV2 && _listEquals(padding, other.padding);

  @override
  int get hashCode => _listHashCode(padding);

  @override
  String toString() => 'CollectionDetails.V2(padding: $padding)';
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

Encoder<CollectionDetails> getCollectionDetailsEncoder() {
  return transformEncoder<Map<String, Object?>, CollectionDetails>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder([('size', getU64Encoder())])),
      (
        1,
        getStructEncoder([
          (
            'padding',
            fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
          ),
        ]),
      ),
    ], size: getU8Encoder()),
    (CollectionDetails value) => switch (value) {
      CollectionDetailsV1(size: final size) => <String, Object?>{
        '__kind': 0,
        'size': size,
      },
      CollectionDetailsV2(padding: final padding) => <String, Object?>{
        '__kind': 1,
        'padding': padding,
      },
    },
  );
}

Decoder<CollectionDetails> getCollectionDetailsDecoder() {
  return transformDecoder<Map<String, Object?>, CollectionDetails>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('size', getU64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('padding', fixDecoderSize(getBytesDecoder(), 8))]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return CollectionDetailsV1(size: map['size']! as BigInt);
        case 1:
          return CollectionDetailsV2(padding: map['padding']! as Uint8List);
      }
      throw StateError(
        'Unsupported CollectionDetails discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<CollectionDetails, CollectionDetails> getCollectionDetailsCodec() {
  return combineCodec(
    getCollectionDetailsEncoder(),
    getCollectionDetailsDecoder(),
  );
}
