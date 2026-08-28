// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class RuleSet {
  const RuleSet();
}

final class RuleSetNone extends RuleSet {
  const RuleSetNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RuleSetNone;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'RuleSet.None()';
}

final class RuleSetProgramAllowList extends RuleSet {
  const RuleSetProgramAllowList(this.value);

  final List<Address> value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleSetProgramAllowList && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RuleSet.ProgramAllowList($value)';
}

final class RuleSetProgramDenyList extends RuleSet {
  const RuleSetProgramDenyList(this.value);

  final List<Address> value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleSetProgramDenyList && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RuleSet.ProgramDenyList($value)';
}

Encoder<RuleSet> getRuleSetEncoder() {
  return transformEncoder<Map<String, Object?>, RuleSet>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        1,
        transformEncoder<List<Address>, Map<String, Object?>>(
          getArrayEncoder<Address>(
            transformEncoder(getAddressEncoder(), (Address value) => value),
          ),
          (Map<String, Object?> map) => map['value']! as List<Address>,
        ),
      ),
      (
        2,
        transformEncoder<List<Address>, Map<String, Object?>>(
          getArrayEncoder<Address>(
            transformEncoder(getAddressEncoder(), (Address value) => value),
          ),
          (Map<String, Object?> map) => map['value']! as List<Address>,
        ),
      ),
    ], size: getU8Encoder()),
    (RuleSet value) => switch (value) {
      RuleSetNone() => <String, Object?>{'__kind': 0},
      RuleSetProgramAllowList(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      RuleSetProgramDenyList(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
    },
  );
}

Decoder<RuleSet> getRuleSetDecoder() {
  return transformDecoder<Map<String, Object?>, RuleSet>(
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
        transformDecoder<List<Address>, Map<String, Object?>>(
          getArrayDecoder(getAddressDecoder()),
          (List<Address> value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        2,
        transformDecoder<List<Address>, Map<String, Object?>>(
          getArrayDecoder(getAddressDecoder()),
          (List<Address> value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const RuleSetNone();
        case 1:
          return RuleSetProgramAllowList(map['value']! as List<Address>);
        case 2:
          return RuleSetProgramDenyList(map['value']! as List<Address>);
      }
      throw StateError('Unsupported RuleSet discriminator: ${map['__kind']}');
    },
  );
}

Codec<RuleSet, RuleSet> getRuleSetCodec() {
  return combineCodec(getRuleSetEncoder(), getRuleSetDecoder());
}
