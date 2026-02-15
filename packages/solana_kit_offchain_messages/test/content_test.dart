import 'dart:convert';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax()', () {
    for (final format in [
      OffchainMessageContentFormat.utf81232BytesMax,
      OffchainMessageContentFormat.utf865535BytesMax,
    ]) {
      test('throws a format mismatch error when the format is $format', () {
        expect(
          () => assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(
            OffchainMessageContent(format: format, text: 'Hello world'),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageMessageFormatMismatch,
            ),
          ),
        );
      });
    }
    test(
      'throws a length exceeded error when content is over 1232 characters',
      () {
        expect(
          () => assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
              text: '!' * (1232 + 1),
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageMaximumLengthExceeded,
            ),
          ),
        );
      },
    );
    test('does not throw when content is exactly 1232 characters', () {
      expect(
        () => assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(
          OffchainMessageContent(
            format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
            text: '!' * 1232,
          ),
        ),
        returnsNormally,
      );
    });
    test('throws a non-empty error when the content is empty', () {
      expect(
        () => assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(
          const OffchainMessageContent(
            format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
            text: '',
          ),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageMessageMustBeNonEmpty,
          ),
        ),
      );
    });
    for (final char in ['\x19', '\x7f']) {
      test('throws when the content contains out of range character '
          '${char.codeUnitAt(0)}', () {
        expect(
          () => assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
              text: char,
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .offchainMessageRestrictedAsciiBodyCharacterOutOfRange,
            ),
          ),
        );
      });
    }
    for (var code = 0x20; code <= 0x7e; code++) {
      final char = String.fromCharCode(code);
      test('does not throw when the content contains allowed character '
          '"$char" (0x${code.toRadixString(16)})', () {
        expect(
          () => assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
              text: char,
            ),
          ),
          returnsNormally,
        );
      });
    }
  });

  group('isOffchainMessageContentRestrictedAsciiOf1232BytesMax()', () {
    for (final format in [
      OffchainMessageContentFormat.utf81232BytesMax,
      OffchainMessageContentFormat.utf865535BytesMax,
    ]) {
      test('returns false when the format is $format', () {
        expect(
          isOffchainMessageContentRestrictedAsciiOf1232BytesMax(
            OffchainMessageContent(format: format, text: 'Hello world'),
          ),
          isFalse,
        );
      });
    }
    test('returns false when the content exceeds 1232 characters', () {
      expect(
        isOffchainMessageContentRestrictedAsciiOf1232BytesMax(
          OffchainMessageContent(
            format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
            text: '!' * (1232 + 1),
          ),
        ),
        isFalse,
      );
    });
    test('returns true when the content is exactly 1232 characters', () {
      expect(
        isOffchainMessageContentRestrictedAsciiOf1232BytesMax(
          OffchainMessageContent(
            format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
            text: '!' * 1232,
          ),
        ),
        isTrue,
      );
    });
    test('returns false when the content is empty', () {
      expect(
        isOffchainMessageContentRestrictedAsciiOf1232BytesMax(
          const OffchainMessageContent(
            format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
            text: '',
          ),
        ),
        isFalse,
      );
    });
    for (final char in ['\x19', '\x7f']) {
      test('returns false when the content contains out of range character '
          '${char.codeUnitAt(0)}', () {
        expect(
          isOffchainMessageContentRestrictedAsciiOf1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
              text: char,
            ),
          ),
          isFalse,
        );
      });
    }
    for (var code = 0x20; code <= 0x7e; code++) {
      final char = String.fromCharCode(code);
      test('returns true when the content contains allowed character '
          '"$char" (0x${code.toRadixString(16)})', () {
        expect(
          isOffchainMessageContentRestrictedAsciiOf1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
              text: char,
            ),
          ),
          isTrue,
        );
      });
    }
  });

  group('assertIsOffchainMessageContentUtf8Of1232BytesMax()', () {
    for (final format in [
      OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      OffchainMessageContentFormat.utf865535BytesMax,
    ]) {
      test('throws a format mismatch error when the format is $format', () {
        expect(
          () => assertIsOffchainMessageContentUtf8Of1232BytesMax(
            OffchainMessageContent(format: format, text: 'Hello world'),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageMessageFormatMismatch,
            ),
          ),
        );
      });
    }

    // UTF-8 strings longer than 1232 bytes.
    final utf8LongerThan1232 = [
      '!' * (1232 + 1),
      '\u{1f618}' * (308 + 1), // kiss emoji, 4 bytes each
      '\u{20ac}' * (410 + 1), // euro sign, 3 bytes each
      '\u{270c}\u{1f3ff}' * (176 + 1), // victory hand + skin tone
    ];
    for (final text in utf8LongerThan1232) {
      final byteLen = utf8.encode(text).length;
      test('throws a length exceeded error when content is $byteLen bytes', () {
        expect(
          () => assertIsOffchainMessageContentUtf8Of1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.utf81232BytesMax,
              text: text,
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageMaximumLengthExceeded,
            ),
          ),
        );
      });
    }
    test('throws a non-empty error when the content is empty', () {
      expect(
        () => assertIsOffchainMessageContentUtf8Of1232BytesMax(
          const OffchainMessageContent(
            format: OffchainMessageContentFormat.utf81232BytesMax,
            text: '',
          ),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageMessageMustBeNonEmpty,
          ),
        ),
      );
    });
    // UTF-8 strings within 1232 bytes.
    final utf8Within1232 = [
      '!' * 1232,
      '\u{1f618}' * 308,
      '\u{20ac}' * 410,
      '\u{270c}\u{1f3ff}' * 176,
    ];
    for (final text in utf8Within1232) {
      final byteLen = utf8.encode(text).length;
      test('does not throw when content is $byteLen bytes', () {
        expect(
          () => assertIsOffchainMessageContentUtf8Of1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.utf81232BytesMax,
              text: text,
            ),
          ),
          returnsNormally,
        );
      });
    }
  });

  group('isOffchainMessageContentUtf8Of1232BytesMax()', () {
    for (final format in [
      OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      OffchainMessageContentFormat.utf865535BytesMax,
    ]) {
      test('returns false when the format is $format', () {
        expect(
          isOffchainMessageContentUtf8Of1232BytesMax(
            OffchainMessageContent(format: format, text: 'Hello world'),
          ),
          isFalse,
        );
      });
    }
    final utf8LongerThan1232 = [
      '!' * (1232 + 1),
      '\u{1f618}' * (308 + 1),
      '\u{20ac}' * (410 + 1),
      '\u{270c}\u{1f3ff}' * (176 + 1),
    ];
    for (final text in utf8LongerThan1232) {
      test('returns false when the content exceeds 1232 bytes', () {
        expect(
          isOffchainMessageContentUtf8Of1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.utf81232BytesMax,
              text: text,
            ),
          ),
          isFalse,
        );
      });
    }
    test('returns false when the content is empty', () {
      expect(
        isOffchainMessageContentUtf8Of1232BytesMax(
          const OffchainMessageContent(
            format: OffchainMessageContentFormat.utf81232BytesMax,
            text: '',
          ),
        ),
        isFalse,
      );
    });
    final utf8Within1232 = [
      '!' * 1232,
      '\u{1f618}' * 308,
      '\u{20ac}' * 410,
      '\u{270c}\u{1f3ff}' * 176,
    ];
    for (final text in utf8Within1232) {
      test('returns true when the content is within 1232 bytes', () {
        expect(
          isOffchainMessageContentUtf8Of1232BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.utf81232BytesMax,
              text: text,
            ),
          ),
          isTrue,
        );
      });
    }
  });

  group('assertIsOffchainMessageContentUtf8Of65535BytesMax()', () {
    for (final format in [
      OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      OffchainMessageContentFormat.utf81232BytesMax,
    ]) {
      test('throws a format mismatch error when the format is $format', () {
        expect(
          () => assertIsOffchainMessageContentUtf8Of65535BytesMax(
            OffchainMessageContent(format: format, text: 'Hello world'),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageMessageFormatMismatch,
            ),
          ),
        );
      });
    }
    final utf8LongerThan65535 = [
      '!' * (65535 + 1),
      '\u{1f618}' * (16383 + 1),
      '\u{20ac}' * (21845 + 1),
      '\u{270c}\u{1f3ff}' * (9362 + 1),
    ];
    for (final text in utf8LongerThan65535) {
      final byteLen = utf8.encode(text).length;
      test('throws a length exceeded error when content is $byteLen bytes', () {
        expect(
          () => assertIsOffchainMessageContentUtf8Of65535BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.utf865535BytesMax,
              text: text,
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageMaximumLengthExceeded,
            ),
          ),
        );
      });
    }
    test('throws a non-empty error when the content is empty', () {
      expect(
        () => assertIsOffchainMessageContentUtf8Of65535BytesMax(
          const OffchainMessageContent(
            format: OffchainMessageContentFormat.utf865535BytesMax,
            text: '',
          ),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageMessageMustBeNonEmpty,
          ),
        ),
      );
    });
    final utf8Within65535 = [
      '!' * 65535,
      '\u{1f618}' * 16383,
      '\u{20ac}' * 21845,
      '\u{270c}\u{1f3ff}' * 9362,
    ];
    for (final text in utf8Within65535) {
      final byteLen = utf8.encode(text).length;
      test('does not throw when content is $byteLen bytes', () {
        expect(
          () => assertIsOffchainMessageContentUtf8Of65535BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.utf865535BytesMax,
              text: text,
            ),
          ),
          returnsNormally,
        );
      });
    }
  });

  group('isOffchainMessageContentUtf8Of65535BytesMax()', () {
    for (final format in [
      OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      OffchainMessageContentFormat.utf81232BytesMax,
    ]) {
      test('returns false when the format is $format', () {
        expect(
          isOffchainMessageContentUtf8Of65535BytesMax(
            OffchainMessageContent(format: format, text: 'Hello world'),
          ),
          isFalse,
        );
      });
    }
    final utf8LongerThan65535 = [
      '!' * (65535 + 1),
      '\u{1f618}' * (16383 + 1),
      '\u{20ac}' * (21845 + 1),
      '\u{270c}\u{1f3ff}' * (9362 + 1),
    ];
    for (final text in utf8LongerThan65535) {
      test('returns false when the content exceeds 65535 bytes', () {
        expect(
          isOffchainMessageContentUtf8Of65535BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.utf865535BytesMax,
              text: text,
            ),
          ),
          isFalse,
        );
      });
    }
    test('returns false when the content is empty', () {
      expect(
        isOffchainMessageContentUtf8Of65535BytesMax(
          const OffchainMessageContent(
            format: OffchainMessageContentFormat.utf865535BytesMax,
            text: '',
          ),
        ),
        isFalse,
      );
    });
    final utf8Within65535 = [
      '!' * 65535,
      '\u{1f618}' * 16383,
      '\u{20ac}' * 21845,
      '\u{270c}\u{1f3ff}' * 9362,
    ];
    for (final text in utf8Within65535) {
      test('returns true when the content is within 65535 bytes', () {
        expect(
          isOffchainMessageContentUtf8Of65535BytesMax(
            OffchainMessageContent(
              format: OffchainMessageContentFormat.utf865535BytesMax,
              text: text,
            ),
          ),
          isTrue,
        );
      });
    }
  });
}
