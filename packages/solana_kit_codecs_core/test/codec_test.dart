import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('Encoder', () {
    test('can define FixedSizeEncoder instances', () {
      final myEncoder = FixedSizeEncoder<String>(
        fixedSize: 32,
        write: (value, bytes, offset) {
          final charCodes =
              value
                  .substring(0, value.length > 32 ? 32 : value.length)
                  .codeUnits
                  .map((c) => c > 255 ? 255 : c)
                  .toList();
          bytes.setAll(offset, charCodes);
          return offset + 32;
        },
      );

      expect(myEncoder.fixedSize, equals(32));

      // Test encode.
      final expectedBytes = Uint8List(32)
        ..setAll(0, [104, 101, 108, 108, 111]);
      expect(myEncoder.encode('hello'), equals(expectedBytes));

      // Test write.
      final writtenBytes = Uint8List(32);
      expect(myEncoder.write('hello', writtenBytes, 0), equals(32));
      expect(writtenBytes, equals(expectedBytes));
    });

    test('can define VariableSizeEncoder instances', () {
      final myEncoder = VariableSizeEncoder<String>(
        getSizeFromValue: (value) => value.length,
        write: (value, bytes, offset) {
          final charCodes =
              value.codeUnits.map((c) => c > 255 ? 255 : c).toList();
          bytes.setAll(offset, charCodes);
          return offset + charCodes.length;
        },
      );

      expect(myEncoder.getSizeFromValue('hello'), equals(5));
      expect(
        myEncoder.encode('hello'),
        equals(Uint8List.fromList([104, 101, 108, 108, 111])),
      );
    });
  });

  group('Decoder', () {
    test('can define FixedSizeDecoder instances', () {
      final myDecoder = FixedSizeDecoder<String>(
        fixedSize: 32,
        read: (bytes, offset) {
          final slice = bytes.sublist(
            offset,
            offset + 32 > bytes.length ? bytes.length : offset + 32,
          );
          final str = slice.map(String.fromCharCode).join();
          return (str, offset + 32);
        },
      );

      expect(myDecoder.fixedSize, equals(32));

      expect(
        myDecoder.decode(Uint8List.fromList([104, 101, 108, 108, 111])),
        equals('hello'),
      );
      expect(
        myDecoder.read(Uint8List.fromList([104, 101, 108, 108, 111]), 0),
        equals(('hello', 32)),
      );
    });
  });

  group('Codec', () {
    test('can define FixedSizeCodec instances', () {
      final myCodec = FixedSizeCodec<String, String>(
        fixedSize: 32,
        read: (bytes, offset) {
          final slice = bytes.sublist(
            offset,
            offset + 32 > bytes.length ? bytes.length : offset + 32,
          );
          final str = slice.map(String.fromCharCode).join();
          return (str, offset + 32);
        },
        write: (value, bytes, offset) {
          final charCodes =
              value
                  .substring(0, value.length > 32 ? 32 : value.length)
                  .codeUnits
                  .map((c) => c > 255 ? 255 : c)
                  .toList();
          bytes.setAll(offset, charCodes);
          return offset + 32;
        },
      );

      expect(myCodec.fixedSize, equals(32));

      // Test encode.
      final expectedBytes = Uint8List(32)
        ..setAll(0, [104, 101, 108, 108, 111]);
      expect(myCodec.encode('hello'), equals(expectedBytes));

      // Test write.
      final writtenBytes = Uint8List(32);
      expect(myCodec.write('hello', writtenBytes, 0), equals(32));
      expect(writtenBytes, equals(expectedBytes));

      // Test decode.
      expect(
        myCodec.decode(Uint8List.fromList([104, 101, 108, 108, 111])),
        equals('hello'),
      );

      // Test read.
      expect(
        myCodec.read(Uint8List.fromList([104, 101, 108, 108, 111]), 0),
        equals(('hello', 32)),
      );
    });
  });

  group('getEncodedSize', () {
    test('returns fixedSize for fixed-size encoders', () {
      final encoder = FixedSizeEncoder<String>(
        fixedSize: 10,
        write: (_, __, offset) => offset + 10,
      );
      expect(getEncodedSize('anything', encoder), equals(10));
    });

    test('returns getSizeFromValue for variable-size encoders', () {
      final encoder = VariableSizeEncoder<String>(
        getSizeFromValue: (value) => value.length,
        write: (_, __, offset) => offset,
      );
      expect(getEncodedSize('hello', encoder), equals(5));
      expect(getEncodedSize('helloworld', encoder), equals(10));
    });
  });

  group('isFixedSize / isVariableSize', () {
    test('identifies fixed-size encoder', () {
      final encoder = FixedSizeEncoder<int>(
        fixedSize: 4,
        write: (_, __, offset) => offset + 4,
      );
      expect(isFixedSize(encoder), isTrue);
      expect(isVariableSize(encoder), isFalse);
    });

    test('identifies variable-size encoder', () {
      final encoder = VariableSizeEncoder<int>(
        getSizeFromValue: (_) => 4,
        write: (_, __, offset) => offset + 4,
      );
      expect(isFixedSize(encoder), isFalse);
      expect(isVariableSize(encoder), isTrue);
    });

    test('identifies fixed-size decoder', () {
      final decoder = FixedSizeDecoder<int>(
        fixedSize: 4,
        read: (_, offset) => (0, offset + 4),
      );
      expect(isFixedSize(decoder), isTrue);
      expect(isVariableSize(decoder), isFalse);
    });

    test('identifies variable-size decoder', () {
      final decoder = VariableSizeDecoder<int>(
        read: (_, offset) => (0, offset + 4),
      );
      expect(isFixedSize(decoder), isFalse);
      expect(isVariableSize(decoder), isTrue);
    });

    test('identifies fixed-size codec', () {
      final codec = FixedSizeCodec<int, int>(
        fixedSize: 4,
        write: (_, __, offset) => offset + 4,
        read: (_, offset) => (0, offset + 4),
      );
      expect(isFixedSize(codec), isTrue);
      expect(isVariableSize(codec), isFalse);
    });

    test('identifies variable-size codec', () {
      final codec = VariableSizeCodec<int, int>(
        getSizeFromValue: (_) => 4,
        write: (_, __, offset) => offset + 4,
        read: (_, offset) => (0, offset + 4),
      );
      expect(isFixedSize(codec), isFalse);
      expect(isVariableSize(codec), isTrue);
    });
  });

  group('assertIsFixedSize / assertIsVariableSize', () {
    test('assertIsFixedSize passes for fixed-size', () {
      final encoder = FixedSizeEncoder<int>(
        fixedSize: 4,
        write: (_, __, offset) => offset + 4,
      );
      expect(() => assertIsFixedSize(encoder), returnsNormally);
    });

    test('assertIsFixedSize throws for variable-size', () {
      final encoder = VariableSizeEncoder<int>(
        getSizeFromValue: (_) => 4,
        write: (_, __, offset) => offset + 4,
      );
      expect(
        () => assertIsFixedSize(encoder),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsExpectedFixedLength,
          ),
        ),
      );
    });

    test('assertIsVariableSize passes for variable-size', () {
      final encoder = VariableSizeEncoder<int>(
        getSizeFromValue: (_) => 4,
        write: (_, __, offset) => offset + 4,
      );
      expect(() => assertIsVariableSize(encoder), returnsNormally);
    });

    test('assertIsVariableSize throws for fixed-size', () {
      final encoder = FixedSizeEncoder<int>(
        fixedSize: 4,
        write: (_, __, offset) => offset + 4,
      );
      expect(
        () => assertIsVariableSize(encoder),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsExpectedVariableLength,
          ),
        ),
      );
    });
  });
}
