// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './meta.dart';

sealed class StakeStateV2 {
  const StakeStateV2();
}

final class StakeStateV2Uninitialized extends StakeStateV2 {
  const StakeStateV2Uninitialized();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StakeStateV2Uninitialized;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StakeStateV2.StakeStateV2Uninitialized()';
}

final class StakeStateV2Initialized extends StakeStateV2 {
  const StakeStateV2Initialized(this.value);

  final Meta value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeStateV2Initialized && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'StakeStateV2.StakeStateV2Initialized($value)';
}

final class StakeStateV2RewardsPool extends StakeStateV2 {
  const StakeStateV2RewardsPool();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StakeStateV2RewardsPool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StakeStateV2.StakeStateV2RewardsPool()';
}

Encoder<StakeStateV2> getStakeStateV2Encoder() {
  return transformEncoder<Map<String, Object?>, StakeStateV2>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        1,
        transformEncoder<Meta, Map<String, Object?>>(
          getMetaEncoder(),
          (Map<String, Object?> map) => map['value']! as Meta,
        ),
      ),
      (3, getStructEncoder(<(String, Encoder<Object?>)>[])),
    ], size: getU8Encoder()),
    (StakeStateV2 value) => switch (value) {
      StakeStateV2Uninitialized() => <String, Object?>{'__kind': 0},
      StakeStateV2Initialized(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      StakeStateV2RewardsPool() => <String, Object?>{'__kind': 3},
    },
  );
}

Decoder<StakeStateV2> getStakeStateV2Decoder() {
  return transformDecoder<Map<String, Object?>, StakeStateV2>(
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
        transformDecoder<Meta, Map<String, Object?>>(
          getMetaDecoder(),
          (Meta value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        3,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const StakeStateV2Uninitialized();
        case 1:
          return StakeStateV2Initialized(map['value']! as Meta);
        case 3:
          return const StakeStateV2RewardsPool();
      }
      throw StateError(
        'Unsupported StakeStateV2 discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<StakeStateV2, StakeStateV2> getStakeStateV2Codec() {
  return combineCodec(getStakeStateV2Encoder(), getStakeStateV2Decoder());
}
