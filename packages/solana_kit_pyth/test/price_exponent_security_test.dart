import 'dart:isolate';

import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

void _convertHermesPrice((SendPort, int) input) {
  final (port, exponent) = input;
  final price = HermesPrice.fromJson({
    'price': '1',
    'conf': '0',
    'expo': exponent,
    'publish_time': 1,
  });
  port.send(price.asDouble);
}

Future<Object?> _boundedConversion(int exponent) async {
  final result = ReceivePort();
  final isolate = await Isolate.spawn(
    _convertHermesPrice,
    (result.sendPort, exponent),
  );

  try {
    return await result.first.timeout(const Duration(seconds: 2));
  } finally {
    isolate.kill(priority: Isolate.immediate);
    result.close();
  }
}

void main() {
  group('untrusted Hermes exponent resource bounds', () {
    test(
      'maximum i32 exponent does not block the application isolate',
      () async {
        expect(await _boundedConversion(2147483647), double.infinity);
      },
    );

    test(
      'minimum i32 exponent does not block the application isolate',
      () async {
        expect(await _boundedConversion(-2147483648), 0.0);
      },
    );
  });
}
