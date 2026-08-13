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

final class StakeStateUninitialized extends StakeState {
  const StakeStateUninitialized();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StakeStateUninitialized;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StakeState.Uninitialized()';
}

final class StakeStateInitialized extends StakeState {
  const StakeStateInitialized(this.value);

  final Meta value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeStateInitialized && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'StakeState.Initialized($value)';
}

final class StakeStateRewardsPool extends StakeState {
  const StakeStateRewardsPool();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StakeStateRewardsPool;

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
    ], size: getU32Encoder()),
    (StakeState value) => switch (value) {
      StakeStateUninitialized() => <String, Object?>{'__kind': 0},
      StakeStateInitialized(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      StakeStateRewardsPool() => <String, Object?>{'__kind': 3},
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
    ], size: getU32Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const StakeStateUninitialized();
        case 1:
          return StakeStateInitialized(map['value']! as Meta);
        case 3:
          return const StakeStateRewardsPool();
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
