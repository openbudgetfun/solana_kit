// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './meta.dart';

sealed class StakeState {
  const StakeState();
}

final class Uninitialized extends StakeState {
  const Uninitialized();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Uninitialized;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StakeState.Uninitialized()';
}

final class Initialized extends StakeState {
  const Initialized(this.value);

  final Meta value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Initialized && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'StakeState.Initialized($value)';
}

final class RewardsPool extends StakeState {
  const RewardsPool();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RewardsPool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StakeState.RewardsPool()';
}

Encoder<StakeState> getStakeStateEncoder() {
  return transformEncoder<Map<String, Object?>, StakeState>(
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
    (StakeState value) => switch (value) {
      Uninitialized() => <String, Object?>{'__kind': 0},
      Initialized(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      RewardsPool() => <String, Object?>{'__kind': 3},
    },
  );
}

Decoder<StakeState> getStakeStateDecoder() {
  return transformDecoder<Map<String, Object?>, StakeState>(
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
          return const Uninitialized();
        case 1:
          return Initialized(map['value']! as Meta);
        case 3:
          return const RewardsPool();
      }
      throw StateError(
        'Unsupported StakeState discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<StakeState, StakeState> getStakeStateCodec() {
  return combineCodec(getStakeStateEncoder(), getStakeStateDecoder());
}
