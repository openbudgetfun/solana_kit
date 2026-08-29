import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

String hex(Uint8List bytes) => bytes
    .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
    .join()
    .toUpperCase();

void main() {
  group('sha256', () {
    test('empty input', () {
      expect(
        hex(sha256([])),
        'E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855',
      );
    });

    test("'abc'", () {
      expect(
        hex(sha256(utf8.encode('abc'))),
        'BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD',
      );
    });

    test('multi-block input spanning padding boundaries', () {
      // 55 bytes: the 0x80 marker fills the message block exactly.
      expect(
        hex(sha256(utf8.encode('a' * 55))),
        '9F4390F8D30C2DD92EC9F095B65E2B9AE9B0A925A5258E241C9F1E910F734318',
      );
      // 64 bytes: forces an extra padding block.
      expect(
        hex(sha256(utf8.encode('a' * 64))),
        'FFE054FE7AE0CB6DC65C3AF9B61D5209F439851DB43D0BA5997337DF154668EB',
      );
      // 100 bytes: multiple chunks through the message schedule.
      expect(
        hex(sha256(utf8.encode('solana kit ' * 10))),
        '52312302AB22EEE240AEABD5113935F58A602A8BDDBE71EC5C20B8F17D6352C4',
      );
    });

    test('rejects out-of-range bytes', () {
      expect(() => sha256([0, 256]), throwsArgumentError);
      expect(() => sha256([0, -1]), throwsArgumentError);
    });
  });

  group('anchor sighash', () {
    test('instruction discriminators use the global namespace', () {
      expect(
        instructionDiscriminator('initialize'),
        [175, 175, 109, 31, 13, 152, 155, 237],
      );
      expect(
        anchorSighash('global', 'account_and_event_arg_and_field'),
        [42, 50, 168, 74, 160, 93, 226, 83],
      );
    });

    test('account and event discriminators use their namespaces', () {
      expect(accountDiscriminator('MyAccount'), [
        246,
        28,
        6,
        87,
        251,
        45,
        50,
        42,
      ]);
      expect(eventDiscriminator('MyEvent'), [
        96,
        184,
        197,
        243,
        139,
        2,
        90,
        148,
      ]);
    });

    test('hasDiscriminator checks prefixes', () {
      expect(hasDiscriminator([1, 2, 3], [1, 2]), isTrue);
      expect(hasDiscriminator([1, 2, 3], [1, 3]), isFalse);
      expect(hasDiscriminator([1], [1, 2]), isFalse);
    });
  });
}
