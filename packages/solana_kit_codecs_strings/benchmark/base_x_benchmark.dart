// Benchmark scripts intentionally print timing summaries.
// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

/// Benchmarks the base-X codecs on realistic inputs.
///
/// The address benchmark in `solana_kit_addresses` uses the all-ones System
/// Program address, which is base58's leading-zero fast path: it exercises none
/// of the base conversion and so hid a real regression in the conversion itself.
/// This benchmark uses a typical address so the conversion is measured.
void main() {
  const typicalAddress = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';
  const systemAddress = '11111111111111111111111111111111';

  final encoder = getBase58Encoder();
  final decoder = getBase58Decoder();

  final addressBytes = encoder.encode(typicalAddress);
  final signatureBytes = encoder.encode(
    '5VERv8NMvzbJMEkV8xnrLkEaWRtSz9CosKDYjCJjBRnbJLgp8uirBgmQpjKhoR4tjF3ZpRzrFmBV6UjKdiSZkQUW',
  );
  final signature = decoder.decode(signatureBytes);
  final largePayload = Uint8List.fromList(
    List<int>.generate(1024, (index) => (index * 31) & 0xff),
  );
  final largePayloadChars = decoder.decode(largePayload);

  _runBenchmark(
    name: 'base58 encode (typical address, 32B)',
    iterations: 20000,
    body: () => encoder.encode(typicalAddress),
  );
  _runBenchmark(
    name: 'base58 encode (all-zero address, 32B)',
    iterations: 20000,
    body: () => encoder.encode(systemAddress),
  );
  _runBenchmark(
    name: 'base58 decode (32B address)',
    iterations: 20000,
    body: () => decoder.decode(addressBytes),
  );
  _runBenchmark(
    name: 'base58 decode (64B signature)',
    iterations: 10000,
    body: () => decoder.decode(signatureBytes),
  );
  _runBenchmark(
    name: 'base58 encode (64B signature text)',
    iterations: 10000,
    body: () => encoder.encode(signature),
  );
  _runBenchmark(
    name: 'base58 encode (1024B payload)',
    iterations: 1000,
    body: () => encoder.encode(largePayloadChars),
  );
  _runBenchmark(
    name: 'base58 decode (1024B payload)',
    iterations: 1000,
    body: () => decoder.decode(largePayload),
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
