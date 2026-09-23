import 'dart:math';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

/// Adversarial invariant tests for the transaction envelope decoder.
///
/// This is the outermost untrusted-input boundary in the SDK: these bytes come
/// from an RPC response, a signer, or a peer. The contract is that any byte
/// array produces either a [Transaction] or a [SolanaError] — never a raw
/// [RangeError]. A foreign exception here means a length field in hostile input
/// reached an unchecked buffer access.
///
/// Inputs are structured rather than purely random. The envelope decoder reads
/// a signature count first, so noise rarely reaches the nested message parse;
/// truncating a real envelope walks the decoder through every field boundary.
void main() {
  final random = Random(20260919);

  void assertNoForeignExceptions(
    String label,
    Iterable<Uint8List> inputs,
    void Function(Uint8List bytes) read,
  ) {
    var handled = 0;

    for (final bytes in inputs) {
      try {
        read(bytes);
        handled++;

      } on SolanaError {
        handled++;

      } catch (error) {
        fail(
          '$label leaked ${error.runtimeType} instead of SolanaError.\n'
          '  input:  ${_hex(bytes)}\n'
          '  length: ${bytes.length}',
        );
      }
    }
    expect(handled, greaterThan(0), reason: '$label never ran any input');
  }

  group('transaction decoder never leaks a foreign exception', () {
    test('random buffers of every interesting length', () {
      final inputs = <Uint8List>[];
      for (final length in [
        0,
        1,
        2,
        3,
        4,
        5,
        8,
        16,
        63,
        64,
        65,
        100,
        128,
        200,
        300,
        500,
        1000,
      ]) {
        for (var trial = 0; trial < 12; trial++) {
          inputs.add(
            Uint8List.fromList(
              List<int>.generate(length, (_) => random.nextInt(256)),
            ),
          );
        }
      }
      assertNoForeignExceptions('random buffer', inputs, (bytes) {
        getTransactionDecoder().decode(bytes);
      });
    });

    test('envelopes claiming a signature count they cannot hold', () {
      // shortU16 signature count followed by fewer signatures than promised.
      final inputs = <Uint8List>[
        Uint8List.fromList([0x00]),
        Uint8List.fromList([0x01]),
        Uint8List.fromList([0x01, ...List<int>.filled(10, 0xaa)]),
        Uint8List.fromList([0x02, ...List<int>.filled(64, 0xaa)]),
        Uint8List.fromList([0x7f]),
        Uint8List.fromList([0xff, 0xff]),
        Uint8List.fromList([0xff, 0xff, 0x7f]),
      ];
      assertNoForeignExceptions('inflated signature count', inputs, (bytes) {
        getTransactionDecoder().decode(bytes);
      });
    });

    test('v1 envelopes truncated at every offset', () {
      // 0x81 selects the message-first v1 envelope, so the decoder commits to
      // parsing a compiled message before it can reach the signature block.
      final inputs = <Uint8List>[];
      for (var length = 0; length <= 96; length++) {
        inputs.add(
          Uint8List.fromList([
            0x81,
            ...List<int>.generate(length, (_) => random.nextInt(256)),
          ]),
        );
      }
      assertNoForeignExceptions('truncated v1 envelope', inputs, (bytes) {
        getTransactionDecoder().decode(bytes);
      });
    });

    test('v1 envelopes with every single-byte corruption', () {
      final inputs = <Uint8List>[];
      for (var length = 1; length <= 48; length++) {
        final base = Uint8List.fromList([
          0x81,
          ...List<int>.generate(length, (_) => random.nextInt(256)),
        ]);
        for (var index = 1; index < base.length; index++) {
          for (final value in [0x00, 0x7f, 0x80, 0xff]) {
            if (base[index] == value) continue;
            final corrupted = Uint8List.fromList(base);
            corrupted[index] = value;
            inputs.add(corrupted);
          }
        }
      }
      assertNoForeignExceptions('corrupted v1 envelope', inputs, (bytes) {
        getTransactionDecoder().decode(bytes);
      });
    });
  });
}

String _hex(Uint8List bytes) {
  final text = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return text.length > 240 ? '${text.substring(0, 240)}...' : text;
}
