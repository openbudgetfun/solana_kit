// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class ValidationResultsOffset {
  const ValidationResultsOffset();
}

final class ValidationResultsOffsetNoOffset extends ValidationResultsOffset {
  const ValidationResultsOffsetNoOffset();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ValidationResultsOffsetNoOffset;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ValidationResultsOffset.NoOffset()';
}

final class ValidationResultsOffsetAnchor extends ValidationResultsOffset {
  const ValidationResultsOffsetAnchor();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ValidationResultsOffsetAnchor;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ValidationResultsOffset.Anchor()';
}

final class ValidationResultsOffsetCustom extends ValidationResultsOffset {
  const ValidationResultsOffsetCustom(this.value);

  final BigInt value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationResultsOffsetCustom && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ValidationResultsOffset.Custom($value)';
}

Encoder<ValidationResultsOffset> getValidationResultsOffsetEncoder() {
  return transformEncoder<Map<String, Object?>, ValidationResultsOffset>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (1, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        2,
        transformEncoder<BigInt, Map<String, Object?>>(
          getU64Encoder(),
          (Map<String, Object?> map) => map['value']! as BigInt,
        ),
      ),
    ], size: getU8Encoder()),
    (ValidationResultsOffset value) => switch (value) {
      ValidationResultsOffsetNoOffset() => <String, Object?>{'__kind': 0},
      ValidationResultsOffsetAnchor() => <String, Object?>{'__kind': 1},
      ValidationResultsOffsetCustom(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
    },
  );
}

Decoder<ValidationResultsOffset> getValidationResultsOffsetDecoder() {
  return transformDecoder<Map<String, Object?>, ValidationResultsOffset>(
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
        transformDecoder<BigInt, Map<String, Object?>>(
          getU64Decoder(),
          (BigInt value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const ValidationResultsOffsetNoOffset();
        case 1:
          return const ValidationResultsOffsetAnchor();
        case 2:
          return ValidationResultsOffsetCustom(map['value']! as BigInt);
      }
      throw StateError(
        'Unsupported ValidationResultsOffset discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ValidationResultsOffset, ValidationResultsOffset>
getValidationResultsOffsetCodec() {
  return combineCodec(
    getValidationResultsOffsetEncoder(),
    getValidationResultsOffsetDecoder(),
  );
}
