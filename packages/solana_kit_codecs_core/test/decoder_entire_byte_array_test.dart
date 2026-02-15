import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  // A decoder that consumes exactly 4 bytes.
  const outputNumber = 1234;
  final innerDecoder = FixedSizeDecoder<int>(
    fixedSize: 4,
    read: (bytes, offset) => (outputNumber, offset + 4),
  );

  group('createDecoderThatConsumesEntireByteArray', () {
    group('decode function', () {
      group('with no offset', () {
        test('returns the same value as the inner decoder when the entire '
            'byte array is consumed', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(4);
          final value = decoder.decode(bytes);
          expect(value, equals(outputNumber));
        });

        test('throws when the inner decoder does not consume the entire '
            'byte array', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(5);
          expect(
            () => decoder.decode(bytes),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.codecsExpectedDecoderToConsumeEntireByteArray,
              ),
            ),
          );
        });
      });

      group('with an offset', () {
        test('returns the same value as the inner decoder when the entire '
            'byte array is consumed', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(6);
          final value = decoder.decode(bytes, 2);
          expect(value, equals(outputNumber));
        });

        test('throws when the inner decoder does not consume the entire '
            'byte array', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(7);
          expect(
            () => decoder.decode(bytes, 2),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.codecsExpectedDecoderToConsumeEntireByteArray,
              ),
            ),
          );
        });
      });
    });

    group('read function', () {
      group('with no offset', () {
        test('returns the same value as the inner decoder when the entire '
            'byte array is consumed', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(4);
          final (value, _) = decoder.read(bytes, 0);
          expect(value, equals(outputNumber));
        });

        test('returns the same offset as the inner decoder when the entire '
            'byte array is consumed', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(4);
          final (_, offset) = decoder.read(bytes, 0);
          expect(offset, equals(4));
        });

        test('throws when the inner decoder does not consume the entire '
            'byte array', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(5);
          expect(
            () => decoder.read(bytes, 0),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.codecsExpectedDecoderToConsumeEntireByteArray,
              ),
            ),
          );
        });
      });

      group('with an offset', () {
        test('returns the same value as the inner decoder when the entire '
            'byte array is consumed', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(6);
          final (value, _) = decoder.read(bytes, 2);
          expect(value, equals(outputNumber));
        });

        test('returns the same offset as the inner decoder when the entire '
            'byte array is consumed', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(6);
          final (_, offset) = decoder.read(bytes, 2);
          expect(offset, equals(6));
        });

        test('throws when the inner decoder does not consume the entire '
            'byte array', () {
          final decoder = createDecoderThatConsumesEntireByteArray(
            innerDecoder,
          );
          final bytes = Uint8List(7);
          expect(
            () => decoder.read(bytes, 2),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.codecsExpectedDecoderToConsumeEntireByteArray,
              ),
            ),
          );
        });
      });
    });

    test('works with variable-size decoders', () {
      final varDecoder = VariableSizeDecoder<int>(
        read: (bytes, offset) => (outputNumber, offset + 4),
        maxSize: 10,
      );

      final decoder = createDecoderThatConsumesEntireByteArray(varDecoder);
      expect(decoder, isA<VariableSizeDecoder<int>>());
      expect((decoder as VariableSizeDecoder).maxSize, equals(10));

      // Should pass: exactly consumed.
      expect(decoder.decode(Uint8List(4)), equals(outputNumber));

      // Should throw: not fully consumed.
      expect(
        () => decoder.decode(Uint8List(5)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsExpectedDecoderToConsumeEntireByteArray,
          ),
        ),
      );
    });
  });
}
