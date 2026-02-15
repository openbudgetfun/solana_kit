import 'dart:convert';
import 'dart:io';

import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:test/test.dart';

/// Resolves the path to the test fixtures directory.
///
/// When running tests, the current directory may vary, so we locate the
/// package root by finding the pubspec.yaml file.
String _findTestDir() {
  final dir = Directory.current;
  // If we're in the workspace root, the test file is under the package dir.
  final packageTestDir = Directory(
    '${dir.path}/packages/solana_kit_rpc_spec_types/test',
  );
  if (packageTestDir.existsSync()) {
    return packageTestDir.path;
  }
  // Otherwise we're likely in the package directory already.
  return '${dir.path}/test';
}

/// JavaScript's Number.MAX_SAFE_INTEGER equivalent.
final _maxSafeInteger = BigInt.from(9007199254740991);
final _maxSafeIntegerPlusOne = _maxSafeInteger + BigInt.one;

void main() {
  group('parseJsonWithBigInts', () {
    group('parses integers as BigInt', () {
      final intTestCases = <(String, BigInt)>[
        ('0', BigInt.zero),
        ('-0', -BigInt.zero),
        ('1', BigInt.one),
        ('-1', -BigInt.one),
        ('42', BigInt.from(42)),
        ('-42', BigInt.from(-42)),
        ('1e5', BigInt.from(100000)),
        ('-1e5', BigInt.from(-100000)),
        ('1E5', BigInt.from(100000)),
        ('-1E5', BigInt.from(-100000)),
        ('123e+32', BigInt.from(123) * BigInt.from(10).pow(32)),
        ('-123e+32', BigInt.from(-123) * BigInt.from(10).pow(32)),
        ('123E+32', BigInt.from(123) * BigInt.from(10).pow(32)),
        ('-123E+32', BigInt.from(-123) * BigInt.from(10).pow(32)),
        (_maxSafeInteger.toString(), _maxSafeInteger),
        (_maxSafeIntegerPlusOne.toString(), _maxSafeIntegerPlusOne),
      ];

      for (final (input, expectedBigInt) in intTestCases) {
        test('parses $input as a BigInt', () {
          expect(parseJsonWithBigInts(input), expectedBigInt);
        });
      }
    });

    test('parses BigInts within nested structures', () {
      const input =
          '{ "alice": 42, "bob": [3.14, 3e+8, '
          '{ "baz": 1234567890123456789012345678901234567890 }] }';
      final result = parseJsonWithBigInts(input);
      expect(result, {
        'alice': BigInt.from(42),
        'bob': [
          3.14,
          BigInt.from(300000000),
          {'baz': BigInt.parse('1234567890123456789012345678901234567890')},
        ],
      });
    });

    group('parses floats as double', () {
      final floatTestCases = <(String, double)>[
        ('0.5', 0.5),
        ('-0.5', -0.5),
        ('3.14159265', 3.14159265),
        ('-3.14159265', -3.14159265),
        ('1e-5', 1e-5),
        ('-1e-5', -1e-5),
        ('1E-5', 1e-5),
        ('-1E-5', -1e-5),
        ('1e-32', 1e-32),
        ('-1189e-32', -1189e-32),
      ];

      for (final (input, expectedNumber) in floatTestCases) {
        test('parses $input as a number', () {
          expect(parseJsonWithBigInts(input), expectedNumber);
        });
      }
    });

    group('does not alter non-numeric values', () {
      // These JSON strings must be valid JSON. Dart raw strings and
      // regular strings handle backslashes differently from JS template
      // literals, so we construct them carefully.
      //
      // The TS tests use JS string literals where \\ becomes \.
      // In Dart, raw strings r'...' treat \ as literal.
      // The JSON string "\\base64" encodes the value \base64.
      final passThroughTestCases = <String>[
        'null',
        'false',
        'true',
        '[]',
        '[null, true, false]',
        '{}',
        '{ "foo": "bar" }',
        '""',
        '"Hello World"',
        '"42 apples"',
        '"base64"',
        // JSON: "\base64" -> \base64 (\b = backspace in JSON)
        r'"\\base64"',
        // JSON: "\"base64" -> "base64
        r'"\"base64"',
        // JSON: "\\base64" -> \base64
        r'"\\\\base64"',
        // JSON: "\"\"base64" -> ""base64
        r'"\"\"base64"',
        // JSON: "\\\"base64" -> \"base64
        r'"\\\\\"base64"',
        // JSON: "\\\"\"base64" -> \""base64
        r'"\\\\\"\"base64"',
        // JSON: "He said: \"I will eat 3 bananas\""
        r'"He said: \"I will eat 3 bananas\""',
        '{ "message_100": "Hello to the 1st World" }',
        r'{ "message_200": "Hello to the \"2nd World\"" }',
        '{"data":["","base64"]}',
      ];

      for (final input in passThroughTestCases) {
        test('does not alter the value of $input', () {
          expect(parseJsonWithBigInts(input), jsonDecode(input));
        });
      }
    });

    test('can parse complex JSON files', () {
      final testDir = _findTestDir();
      final largeJsonPath = '$testDir/large_json_file.json';
      final largeJsonString = File(largeJsonPath).readAsStringSync();
      final expectedResult = jsonDecode(largeJsonString);

      // The expected result should have lamports as BigInt and all integers
      // as BigInt.
      final expectedList = (expectedResult as List).map((item) {
        final map = item as Map<String, Object?>;
        final friends = (map['friends']! as List).map((friend) {
          final friendMap = friend as Map<String, Object?>;
          return <String, Object?>{
            ...friendMap,
            'id': BigInt.from(friendMap['id']! as int),
          };
        }).toList();
        return <String, Object?>{
          ...map,
          'index': BigInt.from(map['index']! as int),
          'lamports': BigInt.parse('142302234983644260'),
          'age': BigInt.from(map['age']! as int),
          'friends': friends,
        };
      }).toList();

      expect(parseJsonWithBigInts(largeJsonString), expectedList);
    });
  });

  group('stringifyJsonWithBigInts', () {
    group('stringifies BigInt as numerical value', () {
      final bigIntTestCases = <(BigInt, String)>[
        (BigInt.zero, '0'),
        (-BigInt.zero, '0'),
        (BigInt.one, '1'),
        (-BigInt.one, '-1'),
        (BigInt.from(42), '42'),
        (BigInt.from(-42), '-42'),
        (BigInt.from(100000), '100000'),
        (BigInt.from(-100000), '-100000'),
        (
          BigInt.from(123) * BigInt.from(10).pow(32),
          '12300000000000000000000000000000000',
        ),
        (
          BigInt.from(-123) * BigInt.from(10).pow(32),
          '-12300000000000000000000000000000000',
        ),
        (_maxSafeInteger, _maxSafeInteger.toString()),
        (_maxSafeIntegerPlusOne, _maxSafeIntegerPlusOne.toString()),
      ];

      for (final (input, expectedString) in bigIntTestCases) {
        test('stringifies BigInt $input as a numerical value', () {
          expect(stringifyJsonWithBigInts(input), expectedString);
        });
      }
    });

    test('stringifies BigInts within nested structures', () {
      final input = {
        'alice': BigInt.from(42),
        'bob': [
          3.14,
          BigInt.from(300000000),
          {'baz': BigInt.parse('1234567890123456789012345678901234567890')},
        ],
      };
      expect(
        stringifyJsonWithBigInts(input),
        '{"alice":42,"bob":[3.14,300000000,'
        '{"baz":1234567890123456789012345678901234567890}]}',
      );
    });

    group('stringifies numbers as numerical value', () {
      final numberTestCases = <(double, String)>[
        (0.5, '0.5'),
        (-0.5, '-0.5'),
        (3.14159265, '3.14159265'),
        (-3.14159265, '-3.14159265'),
        (1e-5, '0.00001'),
        (-1e-5, '-0.00001'),
        (1e-32, '1e-32'),
        (-1189e-32, '-1.189e-29'),
      ];

      for (final (input, expectedString) in numberTestCases) {
        test('stringifies number $input as a numerical value', () {
          expect(stringifyJsonWithBigInts(input), expectedString);
        });
      }
    });

    group('does not alter non-BigInt values', () {
      final passThroughTestCases = <Object?>[
        null,
        false,
        true,
        <Object?>[],
        <Object?>[null, true, false],
        <String, Object?>{},
        {'foo': 'bar'},
        '',
        'Hello World',
        '42 apples',
        'base64',
        '"base64',
        '""base64',
        r'\base64',
        r'\"base64',
        r'\""base64',
        r'\\base64',
        r'\\"base64',
        r'\\""base64',
        'He said: "I will eat 3 bananas"',
        {'message_100': 'Hello to the 1st World'},
        {'message_200': 'Hello to the "2nd World"'},
        {
          'data': ['', 'base64'],
        },
      ];

      for (final input in passThroughTestCases) {
        test('does not alter the value of $input', () {
          expect(stringifyJsonWithBigInts(input), jsonEncode(input));
        });
      }
    });
  });
}
