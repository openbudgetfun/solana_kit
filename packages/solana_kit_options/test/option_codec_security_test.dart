import 'dart:typed_data';

import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_options/solana_kit_options.dart';
import 'package:test/test.dart';

void main() {
  group('option wire validation', () {
    for (final prefix in [2, 127, 255]) {
      test('rejects noncanonical u8 presence flag $prefix', () {
        final codec = getOptionCodec(getU8Codec());
        expect(
          () => codec.decode(Uint8List.fromList([prefix, 42])),
          throwsA(_error(SolanaErrorCode.codecsInvalidBoolean)),
        );
      });
    }

    for (final prefix in [-1.0, 0.5, 1.5, double.infinity, double.nan]) {
      test('rejects custom presence flag $prefix without truncating it', () {
        final decoder = getOptionDecoder(
          getU8Decoder(),
          prefix: getF64Decoder(),
        );
        final bytes = Uint8List.fromList([
          ...getF64Encoder().encode(prefix),
          42,
        ]);
        expect(
          () => decoder.decode(bytes),
          throwsA(_error(SolanaErrorCode.codecsInvalidBoolean)),
        );
      });
    }

    test('rejects truncated fixed-size None padding at a nonzero offset', () {
      final decoder = getOptionDecoder(
        getU16Decoder(),
        noneValue: const ZeroesOptionNoneValue(),
      );
      for (final bytes in [
        Uint8List.fromList([99, 0]),
        Uint8List.fromList([99, 0, 0]),
      ]) {
        expect(
          () => decoder.read(bytes, 1),
          throwsA(_error(SolanaErrorCode.codecsInvalidByteLength)),
        );
      }
    });

    test('rejects a truncated constant None value', () {
      final decoder = getOptionDecoder(
        getU8Decoder(),
        noneValue: ConstantOptionNoneValue(Uint8List.fromList([0xaa, 0xbb])),
      );
      expect(
        () => decoder.decode(Uint8List.fromList([0, 0xaa])),
        throwsA(_error(SolanaErrorCode.codecsInvalidByteLength)),
      );
    });

    test('rejects a forged constant None marker', () {
      final decoder = getOptionDecoder(
        getU8Decoder(),
        noneValue: ConstantOptionNoneValue(Uint8List.fromList([0xaa, 0xbb])),
      );
      expect(
        () => decoder.read(Uint8List.fromList([99, 0, 0xaa, 0xcc]), 1),
        throwsA(
          _error(SolanaErrorCode.codecsInvalidConstant)
              .having((error) => error.context['hexConstant'], 'marker', 'aabb')
              .having((error) => error.context['offset'], 'offset', 2),
        ),
      );
    });

    test('accepts complete zero padding with an authoritative None flag', () {
      final decoder = getOptionDecoder(
        getU16Decoder(),
        noneValue: const ZeroesOptionNoneValue(),
      );
      // COption-style padding may contain stale data when the flag is None.
      expect(
        decoder.read(Uint8List.fromList([99, 0, 0xaa, 0xbb]), 1),
        (none<int>(), 4),
      );
    });

    test(
      'consumes complete constant None values and preserves the next field',
      () {
        final codec = getOptionCodec(
          getU8Codec(),
          noneValue: ConstantOptionNoneValue(Uint8List.fromList([0xaa, 0xbb])),
        );
        final bytes = Uint8List.fromList([99, 0, 0xaa, 0xbb, 42]);
        final (value, offset) = codec.read(bytes, 1);
        expect(value, none<int>());
        expect(getU8Decoder().read(bytes, offset), (42, 5));
        expect(codec.decode(codec.encode(some(42))), some(42));
      },
    );

    test('rejects invalid offsets even for an omitted None value', () {
      final decoder = getOptionDecoder(getU8Decoder(), hasPrefix: false);
      for (final offset in [-1, 2]) {
        expect(
          () => decoder.read(Uint8List(1), offset),
          throwsA(_error(SolanaErrorCode.codecsOffsetOutOfRange)),
        );
      }
      expect(decoder.read(Uint8List(1), 1), (none<int>(), 1));
    });
  });
}

TypeMatcher<SolanaError> _error(SolanaErrorCode code) =>
    isA<SolanaError>().having((error) => error.code, 'code', code);
