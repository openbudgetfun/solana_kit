// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class PrintArgs {
  const PrintArgs();
}

final class PrintArgsV1 extends PrintArgs {
  const PrintArgsV1({
    required this.edition,
  });

  final BigInt edition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintArgsV1 && edition == other.edition;

  @override
  int get hashCode => edition.hashCode;

  @override
  String toString() => 'PrintArgs.V1(edition: $edition)';
}

final class PrintArgsV2 extends PrintArgs {
  const PrintArgsV2({
    required this.edition,
  });

  final BigInt edition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintArgsV2 && edition == other.edition;

  @override
  int get hashCode => edition.hashCode;

  @override
  String toString() => 'PrintArgs.V2(edition: $edition)';
}

Encoder<PrintArgs> getPrintArgsEncoder() {
  return transformEncoder<Map<String, Object?>, PrintArgs>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder([('edition', getU64Encoder())])),
      (1, getStructEncoder([('edition', getU64Encoder())])),
    ], size: getU8Encoder()),
    (PrintArgs value) => switch (value) {
      PrintArgsV1(edition: final edition) => <String, Object?>{
        '__kind': 0,
        'edition': edition,
      },
      PrintArgsV2(edition: final edition) => <String, Object?>{
        '__kind': 1,
        'edition': edition,
      },
    },
  );
}

Decoder<PrintArgs> getPrintArgsDecoder() {
  return transformDecoder<Map<String, Object?>, PrintArgs>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('edition', getU64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('edition', getU64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return PrintArgsV1(edition: map['edition']! as BigInt);
        case 1:
          return PrintArgsV2(edition: map['edition']! as BigInt);
      }
      throw StateError('Unsupported PrintArgs discriminator: ${map['__kind']}');
    },
  );
}

Codec<PrintArgs, PrintArgs> getPrintArgsCodec() {
  return combineCodec(getPrintArgsEncoder(), getPrintArgsDecoder());
}
