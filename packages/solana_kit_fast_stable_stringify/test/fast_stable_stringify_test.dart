import 'dart:convert';

import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';
import 'package:test/test.dart';

/// Helper that produces the same output as `json-stable-stringify` from npm.
/// This sorts object keys and stringifies values using standard JSON rules.
String? jsonStableStringify(Object? value) {
  if (value == null) return 'null';
  if (value is bool) return jsonEncode(value);
  if (value is num) {
    if (value.isNaN || value.isInfinite) return 'null';
    return jsonEncode(value);
  }
  if (value is String) return jsonEncode(value);
  if (value is List) {
    final items = value.map((e) => jsonStableStringify(e) ?? 'null').join(',');
    return '[$items]';
  }
  if (value is Map<String, Object?>) {
    final keys = value.keys.toList()..sort();
    final pairs = <String>[];
    for (final key in keys) {
      final v = value[key];
      final stringified = jsonStableStringify(v);
      if (stringified != null) {
        pairs.add('${jsonEncode(key)}:$stringified');
      }
    }
    return '{${pairs.join(',')}}';
  }
  return null;
}

class _ImplementingToJson with ToJsonable {
  @override
  Object? toJson() => 'dummy!';
}

void main() {
  group('fastStableStringify', () {
    test('matches json-stable-stringify for strings', () {
      final input = <String, Object?>{
        'BACKSPACE': '\b',
        'CARRIAGE_RETURN': '\r',
        'EMPTY_STRING': '',
        'ESCAPE_RANGE': '\u0000\u001F',
        'FORM_FEED': '\f',
        'LINE_FEED': '\n',
        'LOWERCASE': 'abc',
        'MIXED': 'Aa1 Bb2 Cc3 \u0000\u001F\u0020\uFFFF\u2603"\\/\f\n\r\t\b',
        'NON_ESCAPE_RANGE': '\u0020\uFFFF',
        'NUMBER_ONLY': '123',
        'QUOTATION_MARK': '"',
        'REVERSE_SOLIDUS': r'\',
        'SOLIDUS': '/',
        'TAB': '\t',
        'UPPERCASE': 'ABC',
        'UTF16': '\u2603',
        'VALUES_WITH_SPACES': 'a b c',
      };
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('matches json-stable-stringify for object keys', () {
      final input = <String, Object?>{
        '': 'EMPTY_STRING',
        '\u0000\u001F': 'ESCAPE_RANGE',
        '\b': 'BACKSPACE',
        '\t': 'TAB',
        '\n': 'LINE_FEED',
        '\f': 'FORM_FEED',
        '\r': 'CARRIAGE_RETURN',
        '\u0020\uFFFF': 'NON_ESCAPE_RANGE',
        '"': 'QUOTATION_MARK',
        '/': 'SOLIDUS',
        'ABC': 'UPPERCASE',
        'Aa1 Bb2 Cc3 \u0000\u001F\u0020\uFFFF\u2603"\\/\f\n\r\t\b': 'MIXED',
        'NUMBER_ONLY': '123',
        r'\': 'REVERSE_SOLIDUS',
        'a b c': 'VALUES_WITH_SPACES',
        'abc': 'LOWERCASE',
        '\u2603': 'UTF16',
      };
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('matches json-stable-stringify for numbers', () {
      final input = <String, Object?>{
        'FALSY': 0,
        'FLOAT': 0.1234567,
        'INFINITY': double.infinity,
        'MAX_SAFE_INTEGER': 9007199254740991,
        'MAX_VALUE': 1.7976931348623157e308,
        'MIN_SAFE_INTEGER': -9007199254740991,
        'MIN_VALUE': 5e-324,
        'NAN': double.nan,
        'NEGATIVE': -1,
        'NEGATIVE_FLOAT': -0.9876543,
        'NEGATIVE_MAX_VALUE': -1.7976931348623157e308,
        'NEGATIVE_MIN_VALUE': -5e-324,
        'NEG_INFINITY': double.negativeInfinity,
      };
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('matches json-stable-stringify for true', () {
      expect(fastStableStringify(true), equals('true'));
    });

    test('matches json-stable-stringify for false', () {
      expect(fastStableStringify(false), equals('false'));
    });

    test('matches json-stable-stringify for null', () {
      expect(fastStableStringify(null), equals('null'));
    });

    test('matches json-stable-stringify for objects of null', () {
      final input = <String, Object?>{'NULL': null};
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('handles object that implements toJson', () {
      expect(fastStableStringify(_ImplementingToJson()), equals('"dummy!"'));
    });

    test('matches json-stable-stringify for objects of mixed values', () {
      final input = <String, Object?>{
        'Aa1 Bb2 Cc3 \u0000\u001F\u0020\uFFFF\u2603"\\/\f\n\r\t\b': 'MIXED',
        'FALSE': false,
        'MAX_VALUE': 1.7976931348623157e308,
        'MIN_VALUE': 5e-324,
        'MIXED': 'Aa1 Bb2 Cc3 \u0000\u001F\u0020\uFFFF\u2603"\\/\f\n\r\t\b',
        'NEGATIVE_MAX_VALUE': -1.7976931348623157e308,
        'NEGATIVE_MIN_VALUE': -5e-324,
        'NULL': null,
        'TRUE': true,
        'zzz': 'ending',
      };
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('matches json-stable-stringify for arrays of numbers', () {
      final input = <Object?>[
        9007199254740991,
        -9007199254740991,
        0,
        -1,
        0.1234567,
        -0.9876543,
        1.7976931348623157e308,
        5e-324,
        -1.7976931348623157e308,
        -5e-324,
        double.infinity,
        double.negativeInfinity,
        double.nan,
      ];
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('matches json-stable-stringify for arrays of strings', () {
      final input = <Object?>[
        'a b c',
        'abc',
        'ABC',
        'NUMBER_ONLY',
        '',
        '\u0000\u001F',
        '\u0020\uFFFF',
        '\u2603',
        '"',
        r'\',
        '/',
        '\f',
        '\n',
        '\r',
        '\t',
        '\b',
        'Aa1 Bb2 Cc3 \u0000\u001F\u0020\uFFFF\u2603"\\/\f\n\r\t\b',
      ];
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('matches json-stable-stringify for arrays of booleans', () {
      final input = <Object?>[true, false];
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('matches json-stable-stringify for arrays of null', () {
      final input = <Object?>[null];
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('matches json-stable-stringify for arrays of mixed values', () {
      final input = <Object?>[
        -1.7976931348623157e308,
        -5e-324,
        'Aa1 Bb2 Cc3 \u0000\u001F\u0020\uFFFF\u2603"\\/\f\n\r\t\b',
        true,
        false,
        null,
      ];
      expect(fastStableStringify(input), equals(jsonStableStringify(input)));
    });

    test('hashes bigints', () {
      expect(fastStableStringify(BigInt.from(200)), equals('200n'));
      expect(
        fastStableStringify(<String, Object?>{
          'foo': BigInt.from(100),
          'goo': '100n',
        }),
        equals('{"foo":100n,"goo":"100n"}'),
      );
      expect(
        fastStableStringify(<String, Object?>{
          'age': BigInt.from(100),
          'name': 'Hrushi',
        }),
        equals('{"age":100n,"name":"Hrushi"}'),
      );
      expect(
        fastStableStringify(<String, Object?>{
          'age': <Object?>[
            BigInt.from(100),
            BigInt.from(200),
            BigInt.from(300),
          ],
        }),
        equals('{"age":[100n,200n,300n]}'),
      );
    });
  });
}
