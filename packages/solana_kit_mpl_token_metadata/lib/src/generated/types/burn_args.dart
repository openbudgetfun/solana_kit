// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class BurnArgs {
  const BurnArgs();
}

final class BurnArgsV1 extends BurnArgs {
  const BurnArgsV1({
    required this.amount,
  });

  final BigInt amount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BurnArgsV1 && amount == other.amount;

  @override
  int get hashCode => amount.hashCode;

  @override
  String toString() => 'BurnArgs.V1(amount: $amount)';
}

Encoder<BurnArgs> getBurnArgsEncoder() {
  return transformEncoder<Map<String, Object?>, BurnArgs>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder([('amount', getU64Encoder())])),
    ], size: getU8Encoder()),
    (BurnArgs value) => switch (value) {
      BurnArgsV1(amount: final amount) => <String, Object?>{
        '__kind': 0,
        'amount': amount,
      },
    },
  );
}

Decoder<BurnArgs> getBurnArgsDecoder() {
  return transformDecoder<Map<String, Object?>, BurnArgs>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('amount', getU64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return BurnArgsV1(amount: map['amount']! as BigInt);
      }
      throw StateError('Unsupported BurnArgs discriminator: ${map['__kind']}');
    },
  );
}

Codec<BurnArgs, BurnArgs> getBurnArgsCodec() {
  return combineCodec(getBurnArgsEncoder(), getBurnArgsDecoder());
}
