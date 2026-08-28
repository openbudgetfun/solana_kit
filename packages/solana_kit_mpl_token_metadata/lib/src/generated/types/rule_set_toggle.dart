// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class RuleSetToggle {
  const RuleSetToggle();
}

final class RuleSetToggleNone extends RuleSetToggle {
  const RuleSetToggleNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RuleSetToggleNone;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'RuleSetToggle.None()';
}

final class RuleSetToggleClear extends RuleSetToggle {
  const RuleSetToggleClear();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RuleSetToggleClear;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'RuleSetToggle.Clear()';
}

final class RuleSetToggleSet extends RuleSetToggle {
  const RuleSetToggleSet(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleSetToggleSet && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RuleSetToggle.Set($value)';
}

Encoder<RuleSetToggle> getRuleSetToggleEncoder() {
  return transformEncoder<Map<String, Object?>, RuleSetToggle>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (1, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        2,
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
    ], size: getU8Encoder()),
    (RuleSetToggle value) => switch (value) {
      RuleSetToggleNone() => <String, Object?>{'__kind': 0},
      RuleSetToggleClear() => <String, Object?>{'__kind': 1},
      RuleSetToggleSet(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
    },
  );
}

Decoder<RuleSetToggle> getRuleSetToggleDecoder() {
  return transformDecoder<Map<String, Object?>, RuleSetToggle>(
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
        transformDecoder<Address, Map<String, Object?>>(
          getAddressDecoder(),
          (Address value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const RuleSetToggleNone();
        case 1:
          return const RuleSetToggleClear();
        case 2:
          return RuleSetToggleSet(map['value']! as Address);
      }
      throw StateError(
        'Unsupported RuleSetToggle discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<RuleSetToggle, RuleSetToggle> getRuleSetToggleCodec() {
  return combineCodec(getRuleSetToggleEncoder(), getRuleSetToggleDecoder());
}
