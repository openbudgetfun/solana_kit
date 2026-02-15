import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('unit codec', () {
    test('encodes void as empty bytes', () {
      final encoder = getUnitEncoder();
      expect(hex(encoder.encode(null)), equals(''));
    });

    test('decodes void from any bytes', () {
      // decode returns void; we just verify it does not throw.
      getUnitDecoder().decode(b('ff'));
    });

    test('has fixed size of 0', () {
      final codec = getUnitCodec();
      expect(isFixedSize(codec), isTrue);
      expect(codec.fixedSize, equals(0));
    });

    test('roundtrips', () {
      final codec = getUnitCodec();
      final encoded = codec.encode(null);
      expect(encoded.length, equals(0));
    });
  });
}
