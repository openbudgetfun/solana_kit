import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('resizeCodec', () {
    test('resizes fixed-size codecs', () {
      final codec = FixedSizeCodec<Object?, String>(
        fixedSize: 42,
        write: (_, __, offset) => offset + 42,
        read: (_, offset) => ('', offset + 42),
      );

      expect(
        (resizeCodec(codec, (size) => size + 1) as FixedSizeCodec).fixedSize,
        equals(43),
      );
      expect(
        (resizeCodec(codec, (size) => size * 2) as FixedSizeCodec).fixedSize,
        equals(84),
      );
      expect(
        (resizeCodec(codec, (_) => 0) as FixedSizeCodec).fixedSize,
        equals(0),
      );
    });

    test('resizes variable-size codecs', () {
      final codec = VariableSizeCodec<Object?, String>(
        getSizeFromValue: (_) => 42,
        write: (_, __, offset) => offset,
        read: (_, offset) => ('', offset),
      );

      expect(
        (resizeCodec(codec, (size) => size + 1) as VariableSizeCodec)
            .getSizeFromValue(null),
        equals(43),
      );
      expect(
        (resizeCodec(codec, (size) => size * 2) as VariableSizeCodec)
            .getSizeFromValue(null),
        equals(84),
      );
      expect(
        (resizeCodec(codec, (_) => 0) as VariableSizeCodec).getSizeFromValue(
          null,
        ),
        equals(0),
      );
    });

    test('throws when fixed-size codecs have negative sizes', () {
      final codec = FixedSizeCodec<Object?, String>(
        fixedSize: 42,
        write: (_, __, offset) => offset + 42,
        read: (_, offset) => ('', offset + 42),
      );

      expect(
        () => resizeCodec(codec, (size) => size - 100),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsExpectedPositiveByteLength,
          ),
        ),
      );
    });

    test('throws when variable-size codecs have negative sizes', () {
      final codec = VariableSizeCodec<Object?, String>(
        getSizeFromValue: (_) => 42,
        write: (_, __, offset) => offset,
        read: (_, offset) => ('', offset),
      );

      // The error is thrown lazily when getSizeFromValue is called.
      final resized = resizeCodec(codec, (size) => size - 100);
      expect(
        () => (resized as VariableSizeCodec).getSizeFromValue(null),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsExpectedPositiveByteLength,
          ),
        ),
      );
    });
  });

  group('resizeEncoder', () {
    test('resizes fixed-size encoders', () {
      final encoder = FixedSizeEncoder<int>(
        fixedSize: 10,
        write: (_, __, offset) => offset + 10,
      );

      final resized = resizeEncoder(encoder, (size) => size + 5);
      expect(resized, isA<FixedSizeEncoder<int>>());
      expect((resized as FixedSizeEncoder).fixedSize, equals(15));
    });

    test('resizes variable-size encoders', () {
      final encoder = VariableSizeEncoder<int>(
        getSizeFromValue: (value) => value,
        write: (_, __, offset) => offset,
      );

      final resized = resizeEncoder(encoder, (size) => size * 2);
      expect(resized, isA<VariableSizeEncoder<int>>());
      expect(
        (resized as VariableSizeEncoder<int>).getSizeFromValue(5),
        equals(10),
      );
    });
  });

  group('resizeDecoder', () {
    test('resizes fixed-size decoders', () {
      final decoder = FixedSizeDecoder<int>(
        fixedSize: 10,
        read: (_, offset) => (0, offset + 10),
      );

      final resized = resizeDecoder(decoder, (size) => size + 5);
      expect(resized, isA<FixedSizeDecoder<int>>());
      expect((resized as FixedSizeDecoder).fixedSize, equals(15));
    });

    test('returns variable-size decoders unchanged', () {
      final decoder = VariableSizeDecoder<int>(
        read: (_, offset) => (0, offset + 10),
        maxSize: 20,
      );

      final resized = resizeDecoder(decoder, (size) => size + 5);
      // Variable-size decoders are returned unchanged.
      expect(identical(resized, decoder), isTrue);
    });
  });
}
