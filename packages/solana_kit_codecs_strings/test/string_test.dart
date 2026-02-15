import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('sized string encodings', () {
    test('encodes prefixed strings', () {
      final u32PrefixedString = addCodecSizePrefix(
        getUtf8Codec(),
        getU32Codec(),
      );

      // Empty string.
      expect(u32PrefixedString.encode(''), equals(b('00000000')));
      expect(u32PrefixedString.decode(b('00000000')), equals(''));

      // Hello World!
      expect(
        u32PrefixedString.encode('Hello World!'),
        equals(b('0c00000048656c6c6f20576f726c6421')),
      );
      expect(
        u32PrefixedString.decode(b('0c00000048656c6c6f20576f726c6421')),
        equals('Hello World!'),
      );

      // Characters with different byte lengths.
      expect(u32PrefixedString.encode('\u8a9e'), equals(b('03000000e8aa9e')));
      expect(
        u32PrefixedString.read(b('03000000e8aa9e'), 0),
        equals(('\u8a9e', 7)),
      );
      expect(
        u32PrefixedString.read(b('ff03000000e8aa9e'), 1),
        equals(('\u8a9e', 8)),
      );

      // Different prefix lengths.
      final u8PrefixedString = addCodecSizePrefix(getUtf8Codec(), getU8Codec());
      expect(u8PrefixedString.encode('ABC'), equals(b('03414243')));
      expect(u8PrefixedString.decode(b('03414243')), equals('ABC'));

      // Not enough bytes.
      expect(() => u8PrefixedString.decode(b('0341')), throwsA(anything));
    });

    test('encodes fixed strings', () {
      final string5 = fixCodecSize(getUtf8Codec(), 5);
      final string12 = fixCodecSize(getUtf8Codec(), 12);

      // Hello World! (exact size).
      expect(
        string12.encode('Hello World!'),
        equals(b('48656c6c6f20576f726c6421')),
      );
      expect(
        string12.read(b('48656c6c6f20576f726c6421'), 0),
        equals(('Hello World!', 12)),
      );

      // Empty string (padded).
      expect(string5.encode(''), equals(b('0000000000')));
      expect(string5.read(b('0000000000'), 0), equals(('', 5)));

      // Characters with different byte lengths (padded).
      expect(string5.encode('\u8a9e'), equals(b('e8aa9e0000')));
      expect(string5.read(b('e8aa9e0000'), 0), equals(('\u8a9e', 5)));

      // Hello World! (truncated).
      expect(string5.encode('Hello World!'), equals(b('48656c6c6f')));
      expect(string5.read(b('48656c6c6f'), 0), equals(('Hello', 5)));
    });

    test('encodes variable strings', () {
      final variableString = getUtf8Codec();

      // Empty string.
      expect(variableString.encode(''), equals(b('')));
      expect(variableString.decode(b('')), equals(''));

      // Hello World!
      expect(
        variableString.encode('Hello World!'),
        equals(b('48656c6c6f20576f726c6421')),
      );
      expect(
        variableString.decode(b('48656c6c6f20576f726c6421')),
        equals('Hello World!'),
      );

      // Characters with different byte lengths.
      expect(variableString.encode('\u8a9e'), equals(b('e8aa9e')));
      expect(variableString.decode(b('e8aa9e')), equals('\u8a9e'));
    });

    test('encodes strings using custom encodings', () {
      // Prefixed.
      final prefixedString = addCodecSizePrefix(getBase58Codec(), getU8Codec());
      expect(prefixedString.encode('ABC'), equals(b('027893')));
      expect(prefixedString.decode(b('027893')), equals('ABC'));

      // Fixed.
      final fixedString = fixCodecSize(getBase58Codec(), 5);
      expect(fixedString.encode('ABC'), equals(b('7893000000')));
      expect(
        fixedString.decode(b('7893000000')),
        equals('EbzinYo'),
      ); // <- Base58 expects left padding.
      expect(
        fixedString.decode(b('0000007893')),
        equals('111ABC'),
      ); // <- And uses 1s for padding.

      // Variable.
      final variableString = getBase58Codec();
      expect(variableString.encode('ABC'), equals(b('7893')));
      expect(variableString.decode(b('7893')), equals('ABC'));
    });

    test('has the right sizes', () {
      expect(
        (addCodecSizePrefix(getUtf8Codec(), getU8Codec())
                as VariableSizeCodec<String, String>)
            .getSizeFromValue('ABC'),
        equals(1 + 3),
      );
      expect(
        (addCodecSizePrefix(getUtf8Codec(), getU8Codec())
                as VariableSizeCodec<String, String>)
            .maxSize,
        isNull,
      );
      expect(getUtf8Codec().getSizeFromValue('ABC'), equals(3));
      expect(getUtf8Codec().maxSize, isNull);
      expect(fixCodecSize(getUtf8Codec(), 42).fixedSize, equals(42));
    });

    test('offsets prefixed strings', () {
      final codec = addCodecSizePrefix(
        getUtf8Codec(),
        offsetCodec(
          getU8Codec(),
          OffsetConfig(
            postOffset: (scope) => 0,
            preOffset: (scope) => scope.wrapBytes(-1),
          ),
        ),
      );
      expect(codec.encode('ABC'), equals(b('41424303')));
      expect(codec.decode(b('41424303')), equals('ABC'));
    });
  });
}
