import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('constant codec', () {
    test('encodes by writing constant bytes', () {
      final encoder = getConstantEncoder(b('010203'));
      expect(hex(encoder.encode(null)), equals('010203'));
    });

    test('decodes by verifying constant bytes', () {
      // decode returns void; we just verify it does not throw.
      getConstantDecoder(b('010203')).decode(b('010203'));
    });

    test('throws on mismatched bytes during decode', () {
      final decoder = getConstantDecoder(b('010203'));
      expect(
        () => decoder.decode(b('010204')),
        throwsA(
          predicate(
            (e) => isSolanaError(e, SolanaErrorCode.codecsInvalidConstant),
          ),
        ),
      );
    });

    test('has fixed size equal to constant length', () {
      final codec = getConstantCodec(b('aabbcc'));
      expect(isFixedSize(codec), isTrue);
      expect(codec.fixedSize, equals(3));
    });

    test('empty constant has fixed size 0', () {
      final codec = getConstantCodec(b(''));
      expect(codec.fixedSize, equals(0));
    });

    test('roundtrips', () {
      final codec = getConstantCodec(b('deadbeef'));
      final encoded = codec.encode(null);
      expect(hex(encoded), equals('deadbeef'));
      // Should not throw
      codec.decode(encoded);
    });
  });
}
