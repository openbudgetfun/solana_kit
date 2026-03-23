// Benchmark scripts intentionally print timing summaries.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

void main() {
  final payload = _buildPayload();

  _runBenchmark(
    name: 'parseJsonWithBigInts()',
    iterations: 2000,
    body: () {
      parseJsonWithBigInts(payload);
    },
  );
}

String _buildPayload() {
  final entries = List<String>.generate(
    200,
    (index) =>
        '{"slot":${9007199254740991 + index},"lamports":${1000000000000 + index},"vote":$index}',
    growable: false,
  );

  return '{"value":[${entries.join(',')}],"context":{"slot":9007199254740999}}';
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
