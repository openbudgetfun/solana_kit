// Benchmark scripts intentionally print timing summaries.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  const addressValue = '11111111111111111111111111111111';

  _runBenchmark(
    name: 'address()',
    iterations: 50000,
    body: () {
      address(addressValue);
    },
  );

  _runBenchmark(
    name: 'isAddress()',
    iterations: 50000,
    body: () {
      isAddress(addressValue);
    },
  );
}

void _runBenchmark({
  required String name,
  required int iterations,
  required void Function() body,
}) {
  final warmupIterations = iterations ~/ 10;
  for (var i = 0; i < warmupIterations; i++) {
    body();
  }

  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    body();
  }
  stopwatch.stop();

  final microsecondsPerIteration = stopwatch.elapsedMicroseconds / iterations;

  print(
    '$name: ${stopwatch.elapsedMilliseconds} ms total '
    '(${microsecondsPerIteration.toStringAsFixed(3)} µs/op over '
    '$iterations iterations)',
  );
}
