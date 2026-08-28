// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class Seed {
  const Seed();
}

final class SeedCollection extends Seed {
  const SeedCollection();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SeedCollection;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Seed.Collection()';
}

final class SeedOwner extends Seed {
  const SeedOwner();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SeedOwner;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Seed.Owner()';
}

final class SeedRecipient extends Seed {
  const SeedRecipient();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SeedRecipient;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Seed.Recipient()';
}

final class SeedAsset extends Seed {
  const SeedAsset();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SeedAsset;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Seed.Asset()';
}

final class SeedAddress extends Seed {
  const SeedAddress(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SeedAddress && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Seed.Address($value)';
}

final class SeedBytes extends Seed {
  const SeedBytes(this.value);

  final Uint8List value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SeedBytes && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Seed.Bytes($value)';
}

Encoder<Seed> getSeedEncoder() {
  return transformEncoder<Map<String, Object?>, Seed>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (1, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (2, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (3, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        4,
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
      (
        5,
        transformEncoder<Uint8List, Map<String, Object?>>(
          addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
          (Map<String, Object?> map) => map['value']! as Uint8List,
        ),
      ),
    ], size: getU8Encoder()),
    (Seed value) => switch (value) {
      SeedCollection() => <String, Object?>{'__kind': 0},
      SeedOwner() => <String, Object?>{'__kind': 1},
      SeedRecipient() => <String, Object?>{'__kind': 2},
      SeedAsset() => <String, Object?>{'__kind': 3},
      SeedAddress(value: final value) => <String, Object?>{
        '__kind': 4,
        'value': value,
      },
      SeedBytes(value: final value) => <String, Object?>{
        '__kind': 5,
        'value': value,
      },
    },
  );
}

Decoder<Seed> getSeedDecoder() {
  return transformDecoder<Map<String, Object?>, Seed>(
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
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
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
      (
        4,
        transformDecoder<Address, Map<String, Object?>>(
          getAddressDecoder(),
          (Address value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        5,
        transformDecoder<Uint8List, Map<String, Object?>>(
          addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
          (Uint8List value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const SeedCollection();
        case 1:
          return const SeedOwner();
        case 2:
          return const SeedRecipient();
        case 3:
          return const SeedAsset();
        case 4:
          return SeedAddress(map['value']! as Address);
        case 5:
          return SeedBytes(map['value']! as Uint8List);
      }
      throw StateError('Unsupported Seed discriminator: ${map['__kind']}');
    },
  );
}

Codec<Seed, Seed> getSeedCodec() {
  return combineCodec(getSeedEncoder(), getSeedDecoder());
}
