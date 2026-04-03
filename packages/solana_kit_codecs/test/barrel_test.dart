import 'dart:typed_data';

import 'package:solana_kit_codecs/solana_kit_codecs.dart';
import 'package:test/test.dart';

void main() {
  group('solana_kit_codecs barrel', () {
    test('re-exports core codec types', () {
      final codec = getU8Codec();
      expect(codec, isA<FixedSizeCodec<num, int>>());
    });

    test('re-exports number codecs', () {
      final bytes = getU16Codec().encode(513);
      expect(bytes, Uint8List.fromList([1, 2]));
    });

    test('re-exports string codecs', () {
      final bytes = getUtf8Codec().encode('hi');
      expect(bytes, Uint8List.fromList([104, 105]));
    });

    test('re-exports data structure codecs', () {
      final codec = getArrayCodec(
        getU8Codec(),
        size: const FixedArraySize(2),
      );
      expect(codec.decode(Uint8List.fromList([1, 2])), [1, 2]);
    });

    test('re-exports option helpers', () {
      final option = some(42);
      expect(option, const Some(42));
    });
  });
}
