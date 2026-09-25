import 'dart:convert';

import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:test/test.dart';

/// Property tests for the number-indexing scan in [parseJsonWithBigInts].
///
/// The scan was rewritten to walk code units and copy literal runs instead of
/// rebuilding the document one character at a time. These properties pin the
/// behavior that rewrite could plausibly break: recognizing quoted regions,
/// handling backslash escapes, and leaving string content untouched while
/// still converting every real number.
void main() {
  /// Parses [input] and asserts the result is a JSON object.
  Map<Object?, Object?> parseObject(String input) {
    final parsed = parseJsonWithBigInts(input);
    expect(parsed, isA<Map<Object?, Object?>>());
    return parsed! as Map<Object?, Object?>;
  }

  group('number indexing', () {
    test('every integer in a document becomes a BigInt', () {
      final parsed = parseObject(
        '{"a":1,"b":[2,{"c":3}],"d":{"e":[4,5,6]},"f":"7"}',
      );

      expect(parsed['a'], BigInt.from(1));
      final listB = parsed['b']! as List<Object?>;
      expect(listB[0], BigInt.from(2));
      expect((listB[1]! as Map<Object?, Object?>)['c'], BigInt.from(3));
      expect(parsed['f'], '7', reason: 'string content stays a string');
    });

    test('digits inside strings are never converted', () {
      const cases = [
        '{"s":"123"}',
        '{"s":"9007199254740993"}',
        '{"s":"1e10000"}',
        '{"s":"[1,2,3]"}',
        r'{"s":"{\"n\":42}"}',
        '{"s":"-5.5e10"}',
        '{"s":"has 1 digit and 2 more"}',
      ];
      for (final input in cases) {
        expect(parseObject(input)['s'], isA<String>(), reason: input);
      }
    });

    test('escapes do not end string context early', () {
      // An escaped quote is data; treating it as the string terminator would
      // expose the following digits to the number scan.
      final parsed = parseObject(r'{"s":"a\"42","n":7}');
      expect(parsed['s'], 'a"42');
      expect(parsed['n'], BigInt.from(7));
    });

    test('an escaped backslash before a quote still closes the string', () {
      // `"a\\"` is a string containing one backslash, so the following `42`
      // is a real number.
      final parsed = parseObject(r'{"s":"a\\","n":42}');
      expect(parsed['s'], r'a\');
      expect(parsed['n'], BigInt.from(42));
    });

    test('numbers after escaped keys and values are still converted', () {
      final parsed = parseObject(r'{"k\n1":"v\"2","n":3}');
      expect(parsed.containsKey('k\n1'), isTrue);
      expect(parsed['n'], BigInt.from(3));
    });

    test('a quote inside an object key does not desynchronize the scan', () {
      final parsed = parseObject(r'{"\"":1,"b":2}');
      expect(parsed['"'], BigInt.from(1));
      expect(parsed['b'], BigInt.from(2));
    });

    test('deeply nested numbers all convert', () {
      final input =
          '{"a":[${List.generate(200, (i) => '{"n":$i}').join(',')}]}';
      final list = parseObject(input)['a']! as List<Object?>;
      expect(list.length, 200);
      for (var i = 0; i < 200; i++) {
        expect((list[i]! as Map<Object?, Object?>)['n'], BigInt.from(i));
      }
    });

    test('converted output round-trips through the stringifier', () {
      const input =
          '{"slot":9007199254740993,"lamports":1000000000000,'
          '"tag":"not-a-number-7","nested":{"n":[-1,-2,-3]}}';
      final parsed = parseObject(input);
      final reparsed = jsonDecode(stringifyJsonWithBigInts(parsed));
      final map = reparsed! as Map<Object?, Object?>;
      expect(
        map['slot'],
        isA<int>(),
        reason: 'the stringifier writes BigInts as bare numerals',
      );
      expect(map['tag'], 'not-a-number-7');
      expect(map['lamports'], 1000000000000);
    });

    test('integers beyond 64 bits survive the round trip', () {
      // 2^63 + 1 exceeds signed 64-bit range, so this only round-trips if the
      // value stays a BigInt through both parse and stringify.
      const beyondInt64 = '9223372036854775809';
      final parsed = parseObject('{"n":$beyondInt64}');
      expect(parsed['n'], BigInt.parse(beyondInt64));
      expect(stringifyJsonWithBigInts(parsed), '{"n":$beyondInt64}');
    });

    test('floats stay doubles while integers become BigInts', () {
      final parsed = parseObject('{"f":1.5,"g":1e-3,"h":2e3,"i":4}');
      expect(parsed['f'], 1.5);
      expect(parsed['g'], 0.001);
      expect(parsed['h'], BigInt.from(2000));
      expect(parsed['i'], BigInt.from(4));
    });

    test('whitespace and separators around numbers are preserved', () {
      final parsed = parseObject('{\n  "a" : 1 ,\n  "b" :\t[ 2 , 3 ]\n}');
      expect(parsed['a'], BigInt.from(1));
      expect(parsed['b'], [BigInt.from(2), BigInt.from(3)]);
    });
  });
}
