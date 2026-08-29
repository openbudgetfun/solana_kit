// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class PrintSupply {
  const PrintSupply();
}

final class PrintSupplyZero extends PrintSupply {
  const PrintSupplyZero();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PrintSupplyZero;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'PrintSupply.Zero()';
}

final class PrintSupplyLimited extends PrintSupply {
  const PrintSupplyLimited(this.value);

  final BigInt value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintSupplyLimited && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PrintSupply.Limited($value)';
}

final class PrintSupplyUnlimited extends PrintSupply {
  const PrintSupplyUnlimited();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PrintSupplyUnlimited;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'PrintSupply.Unlimited()';
}

Encoder<PrintSupply> getPrintSupplyEncoder() {
  return transformEncoder<Map<String, Object?>, PrintSupply>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        1,
        transformEncoder<BigInt, Map<String, Object?>>(
          getU64Encoder(),
          (Map<String, Object?> map) => map['value']! as BigInt,
        ),
      ),
      (2, getStructEncoder(<(String, Encoder<Object?>)>[])),
    ], size: getU8Encoder()),
    (PrintSupply value) => switch (value) {
      PrintSupplyZero() => <String, Object?>{'__kind': 0},
      PrintSupplyLimited(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      PrintSupplyUnlimited() => <String, Object?>{'__kind': 2},
    },
  );
}

Decoder<PrintSupply> getPrintSupplyDecoder() {
  return transformDecoder<Map<String, Object?>, PrintSupply>(
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
        transformDecoder<BigInt, Map<String, Object?>>(
          getU64Decoder(),
          (BigInt value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
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
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const PrintSupplyZero();
        case 1:
          return PrintSupplyLimited(map['value']! as BigInt);
        case 2:
          return const PrintSupplyUnlimited();
      }
      throw StateError(
        'Unsupported PrintSupply discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<PrintSupply, PrintSupply> getPrintSupplyCodec() {
  return combineCodec(getPrintSupplyEncoder(), getPrintSupplyDecoder());
}
