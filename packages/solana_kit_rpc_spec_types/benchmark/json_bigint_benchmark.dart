// Benchmark scripts intentionally print timing summaries.
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

void main() {
  final payload = _buildPayload();
  final largePayload = _buildLargePayload();

  _runBenchmark(
    name: 'parseJsonWithBigInts() (${payload.length} chars)',
    iterations: 2000,
    body: () {
      parseJsonWithBigInts(payload);
    },
  );

  _runBenchmark(
    name: 'jsonDecode() baseline (${payload.length} chars)',
    iterations: 2000,
    body: () {
      jsonDecode(payload);
    },
  );

  // A getProgramAccounts-style response: many accounts, many numbers each.
  _runBenchmark(
    name: 'parseJsonWithBigInts() large (${largePayload.length} chars)',
    iterations: 200,
    body: () {
      parseJsonWithBigInts(largePayload);
    },
  );

  _runBenchmark(
    name: 'jsonDecode() baseline large (${largePayload.length} chars)',
    iterations: 200,
    body: () {
      jsonDecode(largePayload);
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

String _buildLargePayload() {
  final entries = List<String>.generate(1500, (index) {
    return '{"pubkey":"${_fakeBase58Key(index)}",'
        '"account":{"lamports":${1000000000000 + index},'
        '"data":["${_fakeBase58Key(index + 7)}","base64"],'
        '"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",'
        '"executable":false,"rentEpoch":${9223372036854775807 - index},'
        '"space":165}}';
  }, growable: false);

  return '{"jsonrpc":"2.0","result":{"context":{"apiVersion":"2.0.0",'
      '"slot":${9007199254740991 + 3}},"value":[${entries.join(',')}]},"id":1}';
}

/// Builds a deterministic base58-looking string, used only as payload filler.
String _fakeBase58Key(int seed) {
  const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  final buffer = StringBuffer();
  var state = seed + 1;

  for (var i = 0; i < 43; i++) {
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    buffer.write(alphabet[state % alphabet.length]);
  }
  return buffer.toString();
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
