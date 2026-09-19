import 'dart:math';
import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:test/test.dart';

/// Property tests for the base-X codecs.
///
/// These pin the invariants the optimized conversion must preserve. The
/// implementation replaced a big-integer conversion with word-sized arithmetic,
/// so the interesting failures are silent ones: a truncated buffer, an
/// off-by-one in the carry loop, or mishandled leading zeroes. Every property
/// below is checked over random data across the full range of byte lengths an
/// address, signature, or account payload can take.
void main() {
  final random = Random(5190184);

  group('base58 round trips', () {
    for (final length in [0, 1, 2, 3, 31, 32, 33, 63, 64, 65, 128, 256, 512]) {
      test('byte length $length survives decode then encode', () {
        for (var trial = 0; trial < 40; trial++) {
          final bytes = Uint8List.fromList(
            List<int>.generate(length, (_) => random.nextInt(256)),
          );
          final encoded = getBase58Decoder().decode(bytes);
          final decoded = getBase58Encoder().encode(encoded);
          expect(decoded, orderedEquals(bytes), reason: 'length $length');
        }
      });
    }

    test('leading zero bytes encode as leading zero characters', () {
      for (final zeroCount in [1, 2, 5, 31, 32, 33, 64]) {
        final bytes = Uint8List(zeroCount);
        final encoded = getBase58Decoder().decode(bytes);
        expect(encoded, '1' * zeroCount);
        expect(getBase58Encoder().encode(encoded), orderedEquals(bytes));
      }
    });

    test('leading zeroes combine with a significant tail', () {
      for (final zeroCount in [0, 1, 3, 8]) {
        final bytes = Uint8List.fromList([
          ...List<int>.filled(zeroCount, 0),
          ...List<int>.generate(32, (_) => random.nextInt(256)),
        ]);
        final encoded = getBase58Decoder().decode(bytes);
        expect(encoded.startsWith('1' * zeroCount), isTrue);
        expect(encoded.length, greaterThan(zeroCount));
        expect(getBase58Encoder().encode(encoded), orderedEquals(bytes));
      }
    });

    test('decoded size matches the encoder size for the same text', () {
      final encoder = getBase58Encoder();
      for (var trial = 0; trial < 200; trial++) {
        final length = random.nextInt(64);
        final bytes = Uint8List.fromList(
          List<int>.generate(length, (_) => random.nextInt(256)),
        );
        final encoded = getBase58Decoder().decode(bytes);
        expect(
          encoder.getSizeFromValue(encoded),
          encoder.encode(encoded).length,
        );
      }
    });

    test(
      'values that need only part of the conversion buffer trim cleanly',
      () {
        // Characters are folded into a buffer sized for the worst case, so most
        // inputs leave unused leading zero bytes. Those must be trimmed to the
        // minimal big-endian representation rather than emitted as padding.
        final encoder = getBase58Encoder();
        final cases = <String, List<int>>{
          '2': [1],
          'j': [42],
          'LUv': [255, 255],
          // A high digit followed by zeroes exercises the low end of the range.
          '1z': [0, 57],
          '111z': [0, 0, 0, 57],
        };
        for (final entry in cases.entries) {
          expect(
            encoder.encode(entry.key),
            orderedEquals(entry.value),
            reason: entry.key,
          );
        }
      },
    );
  });

  group('base10 round trips', () {
    test('random byte strings survive decode then encode', () {
      final codec = getBase10Codec();
      for (var trial = 0; trial < 100; trial++) {
        final length = random.nextInt(32);
        final bytes = Uint8List.fromList(
          List<int>.generate(length, (_) => random.nextInt(256)),
        );
        expect(codec.encode(codec.decode(bytes)), orderedEquals(bytes));
      }
    });

    test('arbitrary precision digit strings exceed 64 bits', () {
      // 20 digits is far beyond a signed 64-bit integer, so this fails if the
      // conversion ever narrows to a machine word.
      const digits = '18446744073709551616';
      final bytes = getBase10Encoder().encode(digits);
      expect(
        bytes,
        orderedEquals(Uint8List.fromList([1, 0, 0, 0, 0, 0, 0, 0, 0])),
      );
      expect(getBase10Decoder().decode(bytes), digits);
    });
  });

  group('custom alphabets', () {
    test('a non-power-of-two alphabet round trips', () {
      const alphabet = 'abcdefghij';
      final codec = getBaseXCodec(alphabet);
      for (var trial = 0; trial < 100; trial++) {
        final length = random.nextInt(24);
        final bytes = Uint8List.fromList(
          List<int>.generate(length, (_) => random.nextInt(256)),
        );
        expect(codec.encode(codec.decode(bytes)), orderedEquals(bytes));
      }
    });

    test('an alphabet wider than the byte range round trips', () {
      // 300 symbols means a character can carry more than eight bits, which is
      // what the per-character buffer sizing has to account for.
      final alphabet = String.fromCharCodes(
        List<int>.generate(300, (index) => 0x100 + index),
      );
      final codec = getBaseXCodec(alphabet);
      for (var trial = 0; trial < 50; trial++) {
        final length = random.nextInt(24);
        final bytes = Uint8List.fromList(
          List<int>.generate(length, (_) => random.nextInt(256)),
        );
        expect(codec.encode(codec.decode(bytes)), orderedEquals(bytes));
      }
    });

    test('a degenerate alphabet is rejected instead of looping', () {
      expect(() => getBaseXEncoder('x'), throwsArgumentError);
      expect(() => getBaseXDecoder('x'), throwsArgumentError);
      expect(() => getBaseXEncoder(''), throwsArgumentError);
    });

    test('an alphabet with characters outside ASCII round trips', () {
      // A wide alphabet takes the sparse lookup path rather than the dense
      // code-unit table.
      final alphabet = String.fromCharCodes(
        List<int>.generate(120, (index) => 0x4E00 + index),
      );
      final codec = getBaseXCodec(alphabet);
      for (var trial = 0; trial < 30; trial++) {
        final length = random.nextInt(16);
        final bytes = Uint8List.fromList(
          List<int>.generate(length, (_) => random.nextInt(256)),
        );
        expect(codec.encode(codec.decode(bytes)), orderedEquals(bytes));
      }
    });

    test('many distinct alphabets stay correct as the lookup cache cycles', () {
      // The shared lookup cache evicts once it reaches its cap. Building more
      // alphabets than that cap must not corrupt later conversions. Each
      // rotation is a distinct alphabet, and characters stay unique because a
      // repeated symbol would make the encoding ambiguous by construction.
      final symbols = [
        for (var code = 33; code <= 126; code++) String.fromCharCode(code),
      ];
      expect(symbols.length, greaterThan(80));
      for (var variant = 0; variant < symbols.length; variant++) {
        final alphabet = [
          for (var i = 0; i < symbols.length; i++)
            symbols[(i + variant) % symbols.length],
        ].join();
        final codec = getBaseXCodec(alphabet);
        final bytes = Uint8List.fromList([
          variant & 0xff,
          (variant * 7) & 0xff,
          0,
          (variant * 13) & 0xff,
        ]);
        expect(
          codec.encode(codec.decode(bytes)),
          orderedEquals(bytes),
          reason: 'alphabet variant $variant',
        );
      }
    });
  });

  group('invalid input', () {
    test('characters outside the alphabet are rejected', () {
      expect(
        () => getBase58Encoder().encode('0OIl'),
        throwsA(isA<Object>()),
      );
    });

    test('validation still accepts every alphabet character', () {
      final alphabet = getBase58Encoder();
      // Every valid base58 character alone must validate and encode.
      const valid =
          '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
      for (final char in valid.split('')) {
        expect(() => alphabet.encode(char), returnsNormally);
      }
    });
  });

  group('decoder offsets', () {
    test('reading at a nonzero offset ignores earlier bytes', () {
      final decoder = getBase58Decoder();
      final payload = Uint8List.fromList([9, 9, 9, 1, 2, 3]);
      final (value, next) = decoder.read(payload, 3);
      expect(next, payload.length);
      expect(value, decoder.decode(Uint8List.fromList([1, 2, 3])));
    });

    test('reading an exhausted buffer reports the buffer end', () {
      final decoder = getBase58Decoder();
      expect(decoder.read(Uint8List.fromList([255]), 1), equals(('', 1)));
    });
  });
}
