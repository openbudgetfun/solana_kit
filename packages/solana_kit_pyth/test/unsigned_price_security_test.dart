import 'dart:typed_data';

import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

void main() {
  final maximumU64 = (BigInt.one << 64) - BigInt.one;

  test('unsigned oracle confidence cannot bypass an upper-bound check', () {
    final bytes = Uint8List(32)..fillRange(8, 16, 255);
    final decoded = PythPriceInfo.fromBytes(bytes, 0);

    expect(decoded.confidenceComponent < BigInt.from(1000), isFalse);
    expect(decoded.confidenceComponent, maximumU64);
  });

  test('unsigned oracle slots preserve all 64 bits', () {
    final bytes = Uint8List(32)..fillRange(24, 32, 255);
    final decoded = PythPriceInfo.fromBytes(bytes, 0);

    expect(decoded.publishSlot, maximumU64);
  });

  test('receiver confidence and slot fields preserve all 64 bits', () {
    final bytes = Uint8List(134)
      ..setAll(0, priceUpdateV2Discriminator)
      ..[40] = 1
      ..fillRange(81, 89, 255)
      ..fillRange(117, 125, 255)
      ..fillRange(125, 133, 255);
    final decoded = decodePriceUpdateV2Account(bytes);

    expect(decoded.conf, maximumU64);
    expect(decoded.emaConf, maximumU64);
    expect(decoded.postedSlot, maximumU64);
  });
}
