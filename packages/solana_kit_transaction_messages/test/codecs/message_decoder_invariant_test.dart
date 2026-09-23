import 'dart:math';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

/// Adversarial invariant tests for the compiled-message wire decoder.
///
/// This decoder is the boundary where bytes from a validator, an RPC response,
/// or another wallet's payload become structured data. Its contract is absolute:
/// for any byte array, it returns a message or throws [SolanaError]. A raw
/// [RangeError] escaping here means a length prefix in hostile input reached an
/// unchecked buffer access.
///
/// The inputs below are not random noise alone. A random buffer almost never
/// reaches the deep v1 payload path, because the version byte, config mask, and
/// instruction counts have to be plausible first. Each case therefore takes a
/// real encoded message, then truncates or corrupts it, which is what a
/// malicious peer actually sends: something well-formed up to the point it
/// wants to break.
void main() {
  final random = Random(20260919);

  /// Encodes a minimal but structurally complete v1 message.
  Uint8List encodeV1Message({int instructionDataBytes = 8}) {
    final message = CompiledTransactionMessage(
      version: TransactionVersion.v1,
      header: const MessageHeader(
        numSignerAccounts: 1,
        numReadonlyNonSignerAccounts: 0,
        numReadonlySignerAccounts: 0,
      ),
      staticAccounts: const [
        Address('7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK'),
      ],
      lifetimeToken: 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
      instructions: const [],
      instructionHeaders: [
        V1InstructionHeader(
          programAccountIndex: 0,
          numInstructionAccounts: 1,
          numInstructionDataBytes: instructionDataBytes,
        ),
      ],
      instructionPayloads: [
        V1InstructionPayload(
          instructionAccountIndices: const [0],
          instructionData: Uint8List.fromList(
            List<int>.generate(instructionDataBytes, (i) => i % 256),
          ),
        ),
      ],
      numInstructions: 1,
      numStaticAccounts: 1,
    );
    return getCompiledTransactionMessageEncoder().encode(message);
  }

  /// Asserts that [read] fails only with [SolanaError] for every given input.
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
    expect(
      handled,
      greaterThan(0),
      reason: '$label never ran any input',
    );
  }

  group('compiled message decoder never leaks a foreign exception', () {
    test('random buffers of every interesting length', () {
      final inputs = <Uint8List>[];
      for (final length in [
        0,
        1,
        2,
        3,
        4,
        5,
        7,
        8,
        9,
        16,
        31,
        32,
        33,
        40,
        63,
        64,
        65,
        128,
        255,
      ]) {
        for (var trial = 0; trial < 20; trial++) {
          inputs.add(
            Uint8List.fromList(
              List<int>.generate(length, (_) => random.nextInt(256)),
            ),
          );
        }
      }
      assertNoForeignExceptions('random buffer', inputs, (bytes) {
        getCompiledTransactionMessageDecoder().decode(bytes);
      });
    });

    test('version-prefixed buffers that enter the v1 path', () {
      // 0x81 selects the v1 envelope; the remainder is arbitrary, so the
      // decoder commits to the v1 layout and then runs out of fields.
      final inputs = <Uint8List>[];
      for (var length = 0; length <= 80; length++) {
        for (var trial = 0; trial < 8; trial++) {
          inputs.add(
            Uint8List.fromList([
              0x81,
              ...List<int>.generate(length, (_) => random.nextInt(256)),
            ]),
          );
        }
      }
      assertNoForeignExceptions('v1-prefixed buffer', inputs, (bytes) {
        getCompiledTransactionMessageDecoder().decode(bytes);
      });
    });

    test('a valid v1 message truncated at every offset', () {
      final encoded = encodeV1Message();
      final inputs = <Uint8List>[
        for (var end = 0; end <= encoded.length; end++)
          Uint8List.fromList(encoded.sublist(0, end)),
      ];
      assertNoForeignExceptions('truncated valid v1 message', inputs, (bytes) {
        getCompiledTransactionMessageDecoder().decode(bytes);
      });
    });

    test('a valid v1 message with the payload length prefix inflated', () {
      // Claim far more instruction data than the buffer holds. This is the
      // shape that previously produced a raw RangeError from the payload
      // slice rather than a SolanaError.
      final encoded = encodeV1Message();
      final inputs = <Uint8List>[];
      for (final claimed in [9, 16, 255, 1024, 65535]) {
        final corrupted = Uint8List.fromList(encoded);
        // The u16 data-length prefix is the last two bytes of the instruction
        // header, immediately before the account indices and payload.
        corrupted
          ..[corrupted.length - 8 - 2] = claimed & 0xff
          ..[corrupted.length - 8 - 1] = (claimed >> 8) & 0xff;
        // Also try the same corruption with the payload removed entirely, so
        // the buffer is short by exactly the claimed amount.
        inputs
          ..add(corrupted)
          ..add(
            Uint8List.fromList(corrupted.sublist(0, corrupted.length - 8)),
          );
      }
      assertNoForeignExceptions('inflated payload length', inputs, (bytes) {
        getCompiledTransactionMessageDecoder().decode(bytes);
      });
    });

    test('a valid v1 message with single-byte corruption', () {
      final encoded = encodeV1Message();
      final inputs = <Uint8List>[];
      for (var index = 0; index < encoded.length; index++) {
        for (final value in [0x00, 0x7f, 0x80, 0xff]) {
          if (encoded[index] == value) continue;
          final corrupted = Uint8List.fromList(encoded);
          corrupted[index] = value;
          inputs.add(corrupted);
        }
      }
      assertNoForeignExceptions('single-byte corruption', inputs, (bytes) {
        getCompiledTransactionMessageDecoder().decode(bytes);
      });
    });
  });
}

String _hex(Uint8List bytes) {
  final text = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return text.length > 240 ? '${text.substring(0, 240)}...' : text;
}
