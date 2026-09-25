import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  final prefix = FixedSizeDecoder<num>(
    fixedSize: 8,
    read: (bytes, offset) => (
      ByteData.sublistView(bytes).getFloat64(offset),
      offset + 8,
    ),
  );

  group('size prefix validation', () {
    for (final size in [
      -1.0,
      -0.5,
      0.5,
      1.5,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      1e30,
      3.0,
    ]) {
      test('rejects invalid byte count $size before decoding content', () {
        var contentRead = false;
        final decoder = addDecoderSizePrefix(
          VariableSizeDecoder<Uint8List>(
            read: (bytes, offset) {
              contentRead = true;
              return (bytes.sublist(offset), bytes.length);
            },
          ),
          prefix,
        );
        final bytes = Uint8List(10);
        ByteData.sublistView(bytes).setFloat64(0, size);

        expect(
          () => decoder.decode(bytes),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode.codecsInvalidByteLength,
            ),
          ),
        );
        expect(contentRead, isFalse);
      });
    }

    for (final size in [0.0, 1.0, 2.0]) {
      test('accepts integer byte count $size at a nonzero offset', () {
        final decoder = addDecoderSizePrefix(
          VariableSizeDecoder<Uint8List>(
            read: (bytes, offset) => (bytes.sublist(offset), bytes.length),
          ),
          prefix,
        );
        final bytes = Uint8List.fromList([0xaa, ...List.filled(8, 0), 1, 2]);
        ByteData.sublistView(bytes).setFloat64(1, size);

        final (content, offset) = decoder.read(bytes, 1);
        expect(content, [1, 2].take(size.toInt()));
        expect(offset, 9 + size.toInt());
      });
    }

    test('bounds content decoding to the declared byte length', () {
      final decoder = addDecoderSizePrefix(
        VariableSizeDecoder<int>(
          read: (bytes, offset) {
            expect(bytes.length, 1);
            return (bytes[offset], offset + 1);
          },
        ),
        prefix,
      );
      final bytes = Uint8List(16);
      ByteData.sublistView(bytes).setFloat64(0, 1);
      bytes[8] = 42;
      expect(decoder.read(bytes, 0), (42, 9));
    });

    for (final offset in [-1, 2]) {
      test('rejects invalid content offset $offset', () {
        final decoder = addDecoderSizePrefix(
          VariableSizeDecoder<int>(read: (_, offset) => (0, offset)),
          FixedSizeDecoder<num>(
            fixedSize: 1,
            read: (_, _) => (0, offset),
          ),
        );
        expect(
          () => decoder.decode(Uint8List(1)),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode.codecsOffsetOutOfRange,
            ),
          ),
        );
      });
    }
  });
}
