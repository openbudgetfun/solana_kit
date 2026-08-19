// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';
import 'package:test_generated/src/wide_enums/types/status_u8.dart';
import 'package:test_generated/src/wide_enums/types/status_u16.dart';
import 'package:test_generated/src/wide_enums/types/status_u32.dart';
import 'package:test_generated/src/wide_enums/types/status_u64.dart';

void expectScalarEnumCodec<T>({
  required Codec<T, T> codec,
  required T active,
  required List<int> activeBytes,
  required List<int> invalidBytes,
}) {
  expect(codec.encode(active), orderedEquals(activeBytes));
  expect(codec.decode(Uint8List.fromList(activeBytes)), active);
  expect(
    () => codec.decode(Uint8List.fromList(invalidBytes)),
    throwsA(isA<RangeError>()),
  );
}

void main() {
  group('wide scalar enum codecs', () {
    test('u8 uses an int-backed one-byte discriminator', () {
      expectScalarEnumCodec(
        codec: getStatusU8Codec(),
        active: StatusU8.active,
        activeBytes: const [1],
        invalidBytes: const [2],
      );
    });

    test('u16 uses an int-backed two-byte discriminator', () {
      expectScalarEnumCodec(
        codec: getStatusU16Codec(),
        active: StatusU16.active,
        activeBytes: const [1, 0],
        invalidBytes: const [2, 0],
      );
    });

    test('u32 uses an int-backed four-byte discriminator', () {
      expectScalarEnumCodec(
        codec: getStatusU32Codec(),
        active: StatusU32.active,
        activeBytes: const [1, 0, 0, 0],
        invalidBytes: const [2, 0, 0, 0],
      );
    });

    test('u64 uses a BigInt-backed eight-byte discriminator', () {
      expectScalarEnumCodec(
        codec: getStatusU64Codec(),
        active: StatusU64.active,
        activeBytes: const [1, 0, 0, 0, 0, 0, 0, 0],
        invalidBytes: const [255, 255, 255, 255, 255, 255, 255, 255],
      );
    });
  });
}
