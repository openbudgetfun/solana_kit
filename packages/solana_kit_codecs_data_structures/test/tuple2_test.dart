import 'dart:typed_data';

import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

void main() {
  group('getTuple2', () {
    final encoder = getTuple2Encoder<int, bool>(
      getU8Encoder(),
      getBooleanEncoder(),
    );
    final decoder = getTuple2Decoder<int, bool>(
      getU8Decoder(),
      getBooleanDecoder(),
    );

    test('encodes records positionally', () {
      final bytes = encoder.encode((7, true));
      expect(bytes, [7, 1]);
    });

    test('decodes bytes into a record', () {
      final (value, offset) = decoder.read(Uint8List.fromList([9, 0]), 0);
      expect(value, (9, false));
      expect(offset, 2);
    });

    test('round-trips through the pair', () {
      final encoded = encoder.encode((255, false));
      expect(decoder.decode(encoded), (255, false));
    });
  });
}
