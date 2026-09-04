import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('numeric codec buffer isolation', () {
    for (final endian in [Endian.little, Endian.big]) {
      final config = NumberCodecConfig(endian: endian);
      _testViewBoundaries('u8 $endian', getU8Codec(), 42);
      _testViewBoundaries('i8 $endian', getI8Codec(), -42);
      _testViewBoundaries('u16 $endian', getU16Codec(config), 12345);
      _testViewBoundaries('i16 $endian', getI16Codec(config), -12345);
      _testViewBoundaries('u32 $endian', getU32Codec(config), 123456789);
      _testViewBoundaries('i32 $endian', getI32Codec(config), -123456789);
      _testViewBoundaries('f32 $endian', getF32Codec(config), 42.5);
      _testViewBoundaries('f64 $endian', getF64Codec(config), 42.5);
    }
  });

  group('shortU16 canonical wire encoding', () {
    final decoder = getShortU16Decoder();

    for (final bytes in [
      [0x80, 0x00],
      [0xff, 0x00],
      [0x80, 0x80, 0x00],
      [0x80, 0x81, 0x00],
      [0xff, 0xff, 0x00],
    ]) {
      test('rejects overlong alias $bytes before consuming another field', () {
        final message = Uint8List.fromList([0xaa, ...bytes, 0x55]);
        expect(
          () => decoder.read(message, 1),
          throwsA(isA<SolanaError>()),
        );
      });
    }

    test('rejects every terminal third byte that overflows u16', () {
      for (var terminal = 4; terminal <= 0x7f; terminal++) {
        expect(
          () => decoder.decode(Uint8List.fromList([0x80, 0x80, terminal])),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode.codecsNumberOutOfRange,
            ),
          ),
          reason: 'The third byte may carry only two value bits.',
        );
      }
    });
  });
}

void _testViewBoundaries<T extends num>(
  String name,
  FixedSizeCodec<T, num> codec,
  T value,
) {
  group(name, () {
    test('cannot decode bytes outside a truncated input view', () {
      final encoded = codec.encode(value);
      final backing = Uint8List.fromList([0xaa, ...encoded, 0xbb]);
      final truncated = Uint8List.sublistView(backing, 1, codec.fixedSize);
      expect(() => codec.decode(truncated), throwsRangeError);
      expect(() => codec.read(truncated, 0), throwsRangeError);
    });

    test('cannot overwrite bytes outside a truncated output view', () {
      final backing = Uint8List(codec.fixedSize + 2)
        ..fillRange(0, codec.fixedSize + 2, 0xaa);
      final before = Uint8List.fromList(backing);
      final truncated = Uint8List.sublistView(backing, 1, codec.fixedSize);
      expect(() => codec.write(value, truncated, 0), throwsRangeError);
      expect(backing, before);
    });

    test('honors an offset at the end of a bounded view', () {
      final backing = Uint8List(codec.fixedSize * 2 + 2);
      final view = Uint8List.sublistView(backing, 1, codec.fixedSize + 1);
      expect(() => codec.decode(view, 1), throwsRangeError);
      expect(() => codec.write(value, view, 1), throwsRangeError);
      expect(backing, everyElement(0));
    });

    test('reads and writes complete nonzero-offset views', () {
      final backing = Uint8List(codec.fixedSize + 3)
        ..fillRange(0, codec.fixedSize + 3, 0xaa);
      final view = Uint8List.sublistView(backing, 1, codec.fixedSize + 2);
      expect(codec.write(value, view, 1), codec.fixedSize + 1);
      expect(codec.read(view, 1), (value, codec.fixedSize + 1));
      expect(backing[0], 0xaa);
      expect(backing[1], 0xaa);
      expect(backing.last, 0xaa);
    });
  });
}
