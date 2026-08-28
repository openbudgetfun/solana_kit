// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './uses.dart';

sealed class UsesToggle {
  const UsesToggle();
}

final class UsesToggleNone extends UsesToggle {
  const UsesToggleNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UsesToggleNone;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'UsesToggle.None()';
}

final class UsesToggleClear extends UsesToggle {
  const UsesToggleClear();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UsesToggleClear;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'UsesToggle.Clear()';
}

final class UsesToggleSet extends UsesToggle {
  const UsesToggleSet(this.value);

  final Uses value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UsesToggleSet && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'UsesToggle.Set($value)';
}

Encoder<UsesToggle> getUsesToggleEncoder() {
  return transformEncoder<Map<String, Object?>, UsesToggle>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (1, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        2,
        transformEncoder<Uses, Map<String, Object?>>(
          getUsesEncoder(),
          (Map<String, Object?> map) => map['value']! as Uses,
        ),
      ),
    ], size: getU8Encoder()),
    (UsesToggle value) => switch (value) {
      UsesToggleNone() => <String, Object?>{'__kind': 0},
      UsesToggleClear() => <String, Object?>{'__kind': 1},
      UsesToggleSet(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
    },
  );
}

Decoder<UsesToggle> getUsesToggleDecoder() {
  return transformDecoder<Map<String, Object?>, UsesToggle>(
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
        transformDecoder<Uses, Map<String, Object?>>(
          getUsesDecoder(),
          (Uses value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const UsesToggleNone();
        case 1:
          return const UsesToggleClear();
        case 2:
          return UsesToggleSet(map['value']! as Uses);
      }
      throw StateError(
        'Unsupported UsesToggle discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<UsesToggle, UsesToggle> getUsesToggleCodec() {
  return combineCodec(getUsesToggleEncoder(), getUsesToggleDecoder());
}
