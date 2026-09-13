import 'dart:typed_data';

import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

/// An empty byte array: the "size prefix is absent" case.
final _exhausted = Uint8List(0);

void main() {
  group('requireSizePrefix on arrays', () {
    test('throws by default when the size prefix is absent', () {
      final decoder = getArrayDecoder(getU8Decoder());
      expect(() => decoder.decode(_exhausted), throwsA(anything));
    });

    test('decodes an empty list when the option is disabled', () {
      final decoder = getArrayDecoder(
        getU8Decoder(),
        requireSizePrefix: false,
      );
      expect(decoder.decode(_exhausted), isEmpty);
    });

    test('still decodes a present prefix when the option is disabled', () {
      final decoder = getArrayDecoder(
        getU8Decoder(),
        size: PrefixedArraySize(getU8Decoder()),
        requireSizePrefix: false,
      );
      expect(decoder.decode(b('020102')), equals([1, 2]));
    });

    test('the codec forwards the option to its decoder', () {
      expect(
        () => getArrayCodec(getU8Codec()).decode(_exhausted),
        throwsA(anything),
      );
      expect(
        getArrayCodec(
          getU8Codec(),
          requireSizePrefix: false,
        ).decode(_exhausted),
        isEmpty,
      );
    });

    test('does not affect fixed-size or remainder sizes', () {
      // A remainder array over no bytes is legitimately empty either way.
      expect(
        getArrayDecoder(
          getU8Decoder(),
          size: const RemainderArraySize(),
        ).decode(_exhausted),
        isEmpty,
      );
      expect(
        getArrayDecoder(getU8Decoder(), size: const FixedArraySize(0)).decode(
          _exhausted,
        ),
        isEmpty,
      );
    });
  });

  group('requireSizePrefix on sets', () {
    test('throws by default and decodes empty when disabled', () {
      expect(
        () => getSetDecoder(getU8Decoder()).decode(_exhausted),
        throwsA(anything),
      );
      expect(
        getSetDecoder(getU8Decoder(), requireSizePrefix: false).decode(
          _exhausted,
        ),
        isEmpty,
      );
    });

    test('the codec forwards the option to its decoder', () {
      expect(
        () => getSetCodec(getU8Codec()).decode(_exhausted),
        throwsA(anything),
      );
      expect(
        getSetCodec(getU8Codec(), requireSizePrefix: false).decode(_exhausted),
        isEmpty,
      );
    });
  });

  group('requireSizePrefix on maps', () {
    test('throws by default and decodes empty when disabled', () {
      expect(
        () => getMapDecoder(getU8Decoder(), getU8Decoder()).decode(_exhausted),
        throwsA(anything),
      );
      expect(
        getMapDecoder(
          getU8Decoder(),
          getU8Decoder(),
          requireSizePrefix: false,
        ).decode(_exhausted),
        isEmpty,
      );
    });

    test('the codec forwards the option to its decoder', () {
      expect(
        () => getMapCodec(getU8Codec(), getU8Codec()).decode(_exhausted),
        throwsA(anything),
      );
      expect(
        getMapCodec(
          getU8Codec(),
          getU8Codec(),
          requireSizePrefix: false,
        ).decode(_exhausted),
        isEmpty,
      );
    });
  });
}
