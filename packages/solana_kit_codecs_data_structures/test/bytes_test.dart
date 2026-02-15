import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('bytes codec', () {
    test('encodes bytes as-is', () {
      final encoder = getBytesEncoder();
      expect(hex(encoder.encode(b('010203'))), equals('010203'));
    });

    test('decodes bytes as-is', () {
      final decoder = getBytesDecoder();
      expect(hex(decoder.decode(b('010203'))), equals('010203'));
    });

    test('roundtrips', () {
      final codec = getBytesCodec();
      final original = b('ff007f');
      expect(hex(codec.decode(codec.encode(original))), equals('ff007f'));
    });

    test('is variable size', () {
      final codec = getBytesCodec();
      expect(isVariableSize(codec), isTrue);
    });

    test('works with fixCodecSize', () {
      final codec = fixCodecSize(getBytesCodec(), 3);
      expect(hex(codec.encode(b('0102'))), equals('010200'));
      expect(hex(codec.decode(b('010203'))), equals('010203'));
    });
  });
}
