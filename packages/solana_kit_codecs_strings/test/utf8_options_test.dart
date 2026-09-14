import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

/// The default [Utf8CodecConfig] values, named so the assertions below read as
/// statements about this port's strict defaults rather than upstream's.
const _strict = Utf8CodecConfig();

/// Upstream `@solana/kit`'s defaults, requested explicitly. `ignoreBOM` already
/// matches, so only the two divergent defaults are named here.
const _upstream = Utf8CodecConfig(
  fatal: false,
  removeNullCharacters: true,
);

void main() {
  group('Utf8CodecConfig defaults', () {
    test('keep the strict behavior where upstream is lenient', () {
      expect(_strict.fatal, isTrue);
      expect(_strict.removeNullCharacters, isFalse);

      expect(_upstream.fatal, isFalse);
      expect(_upstream.removeNullCharacters, isTrue);
    });

    test('match upstream for byte order marks', () {
      // Dart's Utf8Decoder already strips a leading mark, so this port and
      // upstream agree without opting in.
      expect(_strict.ignoreBOM, isFalse);
      expect(_strict.ignoreBOM, equals(_upstream.ignoreBOM));
    });
  });

  group('fatal', () {
    test('rejects malformed bytes by default', () {
      final decoder = getUtf8Decoder();
      expect(
        () => decoder.decode(Uint8List.fromList([0xc3, 0x28])),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            equals(SolanaErrorCode.codecsInvalidUtf8Bytes),
          ),
        ),
      );
    });

    test('replaces malformed bytes with U+FFFD when relaxed', () {
      final decoder = getUtf8Decoder(const Utf8CodecConfig(fatal: false));
      expect(
        decoder.decode(Uint8List.fromList([0xc3, 0x28])),
        equals('\ufffd('),
      );
    });

    test('rejects lone surrogates on encode by default', () {
      final encoder = getUtf8Encoder();
      expect(
        () => encoder.encode('\ud800'),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            equals(SolanaErrorCode.codecsInvalidUtf8String),
          ),
        ),
      );
      expect(
        () => encoder.encode('a\udc00b'),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            equals(SolanaErrorCode.codecsInvalidUtf8String),
          ),
        ),
      );
    });

    test('encodes lone surrogates as U+FFFD when relaxed', () {
      final encoder = getUtf8Encoder(const Utf8CodecConfig(fatal: false));
      expect(
        encoder.encode('\ud800'),
        equals(Uint8List.fromList([0xef, 0xbf, 0xbd])),
      );
    });

    test('accepts well-formed surrogate pairs when strict', () {
      final encoder = getUtf8Encoder();
      // U+1F600 GRINNING FACE is a surrogate pair in UTF-16.
      expect(
        encoder.encode('\u{1f600}'),
        equals(Uint8List.fromList([0xf0, 0x9f, 0x98, 0x80])),
      );
    });
  });

  group('ignoreBOM', () {
    final bomPrefixed = Uint8List.fromList([0xef, 0xbb, 0xbf, 0x41]);

    test('strips a leading byte order mark by default', () {
      final decoder = getUtf8Decoder();
      expect(decoder.decode(bomPrefixed), equals('A'));
    });

    test('preserves a leading byte order mark when requested', () {
      final decoder = getUtf8Decoder(const Utf8CodecConfig(ignoreBOM: true));
      expect(decoder.decode(bomPrefixed), equals('\ufeffA'));
    });

    test('leaves a mark that is not leading untouched', () {
      final decoder = getUtf8Decoder();
      expect(
        decoder.decode(Uint8List.fromList([0x41, 0xef, 0xbb, 0xbf])),
        equals('A\ufeff'),
      );
    });
  });

  group('removeNullCharacters', () {
    final padded = Uint8List.fromList([0x41, 0x00, 0x42, 0x00]);

    test('preserves null characters by default', () {
      final decoder = getUtf8Decoder();
      expect(decoder.decode(padded), equals('A\u0000B\u0000'));
    });

    test('strips null characters when requested', () {
      final decoder = getUtf8Decoder(
        const Utf8CodecConfig(removeNullCharacters: true),
      );
      expect(decoder.decode(padded), equals('AB'));
    });
  });

  group('combined configuration', () {
    test('upstream defaults round-trip a padded, BOM-prefixed payload', () {
      final codec = getUtf8Codec(_upstream);
      final bytes = Uint8List.fromList([
        0xef, 0xbb, 0xbf, // BOM
        0x41, 0x00, 0x42, 0x00, // "A\0B\0"
      ]);

      expect(codec.decode(bytes), equals('AB'));
      expect(getUtf8Codec().decode(bytes), equals('A\u0000B\u0000'));
    });
  });
}
