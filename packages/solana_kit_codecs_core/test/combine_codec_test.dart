import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('combineCodec', () {
    test('can join encoders and decoders with the same type', () {
      final u8Encoder = FixedSizeEncoder<int>(
        fixedSize: 1,
        write: (value, buffer, offset) {
          buffer[offset] = value;
          return offset + 1;
        },
      );

      final u8Decoder = FixedSizeDecoder<int>(
        fixedSize: 1,
        read: (bytes, offset) => (bytes[offset], offset + 1),
      );

      final u8Codec = combineCodec(u8Encoder, u8Decoder);

      expect(u8Codec, isA<FixedSizeCodec<int, int>>());
      expect((u8Codec as FixedSizeCodec).fixedSize, equals(1));
      expect(u8Codec.encode(42), equals(Uint8List.fromList([42])));
      expect(u8Codec.decode(Uint8List.fromList([42])), equals(42));
    });

    test(
      'can join encoders and decoders with different but matching types',
      () {
        // Encoder accepts num, decoder returns double (simulating different
        // types for TFrom and TTo).
        final numEncoder = FixedSizeEncoder<num>(
          fixedSize: 1,
          write: (value, buffer, offset) {
            buffer[offset] = value.toInt();
            return offset + 1;
          },
        );

        final doubleDecoder = FixedSizeDecoder<double>(
          fixedSize: 1,
          read: (bytes, offset) => (bytes[offset].toDouble(), offset + 1),
        );

        final codec = combineCodec(numEncoder, doubleDecoder);

        expect(codec, isA<FixedSizeCodec<num, double>>());
        expect((codec as FixedSizeCodec).fixedSize, equals(1));
        expect(codec.encode(42), equals(Uint8List.fromList([42])));
        expect(codec.decode(Uint8List.fromList([42])), equals(42.0));
      },
    );

    test('can join variable-size encoders and decoders', () {
      final encoder = VariableSizeEncoder<String>(
        getSizeFromValue: (value) => value.length,
        write: (value, bytes, offset) {
          bytes.setAll(offset, value.codeUnits);
          return offset + value.length;
        },
        maxSize: 100,
      );

      final decoder = VariableSizeDecoder<String>(
        read: (bytes, offset) {
          final str = String.fromCharCodes(bytes.sublist(offset));
          return (str, bytes.length);
        },
        maxSize: 100,
      );

      final codec = combineCodec(encoder, decoder);

      expect(codec, isA<VariableSizeCodec<String, String>>());
      final varCodec = codec as VariableSizeCodec<String, String>;
      expect(varCodec.maxSize, equals(100));
      expect(varCodec.getSizeFromValue('hello'), equals(5));
    });

    test('throws on mismatched fixed sizes', () {
      final encoder = FixedSizeEncoder<int>(
        fixedSize: 1,
        write: (_, __, offset) => offset + 1,
      );

      final decoder = FixedSizeDecoder<int>(
        fixedSize: 2,
        read: (_, offset) => (0, offset + 2),
      );

      expect(
        () => combineCodec(encoder, decoder),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsEncoderDecoderFixedSizeMismatch,
          ),
        ),
      );
    });

    test('throws on mismatched max sizes', () {
      final encoder = VariableSizeEncoder<int>(
        getSizeFromValue: (_) => 0,
        write: (_, __, offset) => offset,
        maxSize: 1,
      );

      final decoder = VariableSizeDecoder<int>(
        read: (_, offset) => (0, offset),
      );

      expect(
        () => combineCodec(encoder, decoder),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsEncoderDecoderMaxSizeMismatch,
          ),
        ),
      );
    });

    test('throws on mixed fixed/variable size', () {
      final fixedEncoder = FixedSizeEncoder<int>(
        fixedSize: 1,
        write: (_, __, offset) => offset + 1,
      );

      final variableDecoder = VariableSizeDecoder<int>(
        read: (_, offset) => (0, offset),
      );

      expect(
        () => combineCodec(fixedEncoder, variableDecoder),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsEncoderDecoderSizeCompatibilityMismatch,
          ),
        ),
      );
    });
  });
}
