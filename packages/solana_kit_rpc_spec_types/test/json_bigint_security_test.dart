import 'dart:convert';

import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:test/test.dart';

void main() {
  group('BigInt JSON security boundaries', () {
    test('does not reinterpret an attacker-controlled response object', () {
      const input = r'{"jsonrpc":"2.0","result":{"$n":"7"}}';

      expect(parseJsonWithBigInts(input), jsonDecode(input));
    });

    test('does not execute an exponent hidden inside a string field', () {
      const input = r'{"result":{"$n":"1e10001"}}';

      expect(parseJsonWithBigInts(input), jsonDecode(input));
    });

    test('does not reinterpret user-supplied request objects', () {
      final input = {
        'params': [
          {r'$n': '7'},
          BigInt.from(8),
          {r'$n': '-09'},
        ],
      };

      expect(
        stringifyJsonWithBigInts(input),
        r'{"params":[{"$n":"7"},8,{"$n":"-09"}]}',
      );
    });

    test('bounds expansion of compact untrusted positive exponents', () {
      expect(
        () => parseJsonWithBigInts('{"result":1e10001}'),
        throwsFormatException,
      );
    });

    test('enforces the expansion limit in the asynchronous parser', () async {
      await expectLater(
        parseJsonWithBigIntsAsync('{"result":1e10001}'),
        throwsFormatException,
      );
    });

    test('enforces the expansion limit inside an isolate', () async {
      await expectLater(
        parseJsonWithBigIntsAsync(
          '{"result":1e10001}',
          runInIsolate: true,
          isolateThreshold: 0,
        ),
        throwsFormatException,
      );
    });

    test('rejects exponents too large to fit in a native integer', () {
      expect(
        () => parseJsonWithBigInts('1e99999999999999999999999999'),
        throwsFormatException,
      );
    });

    test('allows the maximum positive exponent without losing precision', () {
      final result = parseJsonWithBigInts('-3e+10000')! as BigInt;

      expect(result.toString(), '-3${'0' * 10000}');
    });

    test('preserves escaped keys and marker-like string content', () {
      const input = r'{"\u0024n":"not a number","nested":[{"$n":"7"}]}';

      expect(parseJsonWithBigInts(input), jsonDecode(input));
      expect(
        stringifyJsonWithBigInts(jsonDecode(input)),
        jsonEncode(jsonDecode(input)),
      );
    });

    test('keeps floating-point zero exponents as doubles', () {
      final result = parseJsonWithBigInts('[1e-0,2.0,3]')! as List<Object?>;

      expect(result, [1.0, 2.0, BigInt.from(3)]);
      expect(result[0], isA<double>());
    });

    for (final input in [
      '[1,01]',
      '1e2.3',
      '[1,1e2.3]',
      '-01',
      '-',
      '--1',
      '[--1]',
      '[0,--1]',
      '{"x":--1}',
    ]) {
      test('rejects malformed number syntax in $input', () {
        expect(() => parseJsonWithBigInts(input), throwsFormatException);
      });
    }

    test('rejects unsupported objects instead of invoking toJson', () {
      expect(
        () => stringifyJsonWithBigInts(Object()),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });

    test('rejects map keys that are not strings', () {
      expect(
        () => stringifyJsonWithBigInts({1: BigInt.one}),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });

    test('rejects non-finite doubles', () {
      expect(
        () => stringifyJsonWithBigInts(double.infinity),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });

    test('rejects cyclic lists', () {
      final input = <Object?>[];
      input.add(input);

      expect(
        () => stringifyJsonWithBigInts(input),
        throwsA(isA<JsonCyclicError>()),
      );
    });

    test('rejects cyclic maps', () {
      final input = <String, Object?>{};
      input['self'] = input;

      expect(
        () => stringifyJsonWithBigInts(input),
        throwsA(isA<JsonCyclicError>()),
      );
    });

    test('allows shared containers that are not cycles', () {
      final shared = {'value': BigInt.one};

      expect(
        stringifyJsonWithBigInts([shared, shared]),
        '[{"value":1},{"value":1}]',
      );
    });
  });
}
