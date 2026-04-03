import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:test/test.dart';

void main() {
  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Wrap a flat map of key-value pairs in a [JsonReader] for convenience.
  JsonReader reader(Map<String, Object?> json) => JsonReader(json);

  // Matcher that asserts a [FormatException] whose message contains [key].
  Matcher missingKey(String key) => throwsA(
    isA<FormatException>().having(
      (e) => e.message,
      'message',
      contains('"$key"'),
    ),
  );

  // -------------------------------------------------------------------------
  // requireString
  // -------------------------------------------------------------------------
  group('requireString', () {
    test('returns value when present', () {
      expect(reader({'k': 'hello'}).requireString('k'), 'hello');
    });

    test('throws FormatException when key is absent', () {
      expect(() => reader({}).requireString('name'), missingKey('name'));
    });

    test('throws FormatException when value is null', () {
      expect(
        () => reader({'name': null}).requireString('name'),
        missingKey('name'),
      );
    });

    test('throws when value is wrong type', () {
      expect(
        () => reader({'name': 42}).requireString('name'),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // requireInt
  // -------------------------------------------------------------------------
  group('requireInt', () {
    test('returns value when present', () {
      expect(reader({'n': 7}).requireInt('n'), 7);
    });

    test('throws FormatException when key is absent', () {
      expect(() => reader({}).requireInt('count'), missingKey('count'));
    });

    test('throws FormatException when value is null', () {
      expect(
        () => reader({'count': null}).requireInt('count'),
        missingKey('count'),
      );
    });

    test('throws when value is wrong type', () {
      expect(
        () => reader({'count': 'not-int'}).requireInt('count'),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // requireBool
  // -------------------------------------------------------------------------
  group('requireBool', () {
    test('returns true', () {
      expect(reader({'flag': true}).requireBool('flag'), isTrue);
    });

    test('returns false', () {
      expect(reader({'flag': false}).requireBool('flag'), isFalse);
    });

    test('throws FormatException when key is absent', () {
      expect(() => reader({}).requireBool('flag'), missingKey('flag'));
    });

    test('throws FormatException when value is null', () {
      expect(
        () => reader({'flag': null}).requireBool('flag'),
        missingKey('flag'),
      );
    });

    test('throws when value is wrong type', () {
      expect(
        () => reader({'flag': 'yes'}).requireBool('flag'),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // requireDouble
  // -------------------------------------------------------------------------
  group('requireDouble', () {
    test('returns double when present as double', () {
      expect(reader({'d': 3.14}).requireDouble('d'), 3.14);
    });

    test('coerces int to double', () {
      expect(reader({'d': 2}).requireDouble('d'), 2.0);
    });

    test('throws FormatException when key is absent', () {
      expect(() => reader({}).requireDouble('ratio'), missingKey('ratio'));
    });

    test('throws FormatException when value is null', () {
      expect(
        () => reader({'ratio': null}).requireDouble('ratio'),
        missingKey('ratio'),
      );
    });
  });

  // -------------------------------------------------------------------------
  // requireMap
  // -------------------------------------------------------------------------
  group('requireMap', () {
    test('returns nested map when present', () {
      final data = <String, Object?>{'a': 1};
      expect(reader({'nested': data}).requireMap('nested'), data);
    });

    test('throws FormatException when key is absent', () {
      expect(() => reader({}).requireMap('nested'), missingKey('nested'));
    });

    test('throws FormatException when value is null', () {
      expect(
        () => reader({'nested': null}).requireMap('nested'),
        missingKey('nested'),
      );
    });
  });

  // -------------------------------------------------------------------------
  // requireList
  // -------------------------------------------------------------------------
  group('requireList', () {
    test('returns typed list when present', () {
      expect(
        reader({
          'items': <Object?>['a', 'b'],
        }).requireList<String>('items'),
        ['a', 'b'],
      );
    });

    test('returns empty list', () {
      expect(
        reader({'items': <Object?>[]}).requireList<String>('items'),
        isEmpty,
      );
    });

    test('throws FormatException when key is absent', () {
      expect(
        () => reader({}).requireList<String>('items'),
        missingKey('items'),
      );
    });

    test('throws FormatException when value is null', () {
      expect(
        () => reader({'items': null}).requireList<String>('items'),
        missingKey('items'),
      );
    });

    test('cast<E> throws eagerly on wrong-type element', () {
      // requireList uses List.cast which throws lazily on element access.
      final list = reader({
        'items': <Object?>[1, 2],
      }).requireList<String>('items');
      expect(() => list[0], throwsA(isA<TypeError>()));
    });
  });

  // -------------------------------------------------------------------------
  // requireMappedList
  // -------------------------------------------------------------------------
  group('requireMappedList', () {
    test('maps each element', () {
      final result = reader({
        'vals': <Object?>[1, 2, 3],
      }).requireMappedList<int>('vals', (e) => (e! as int) * 10);
      expect(result, [10, 20, 30]);
    });

    test('throws FormatException when key is absent', () {
      expect(
        () => reader({}).requireMappedList<String>('vals', (e) => '$e'),
        missingKey('vals'),
      );
    });
  });

  // -------------------------------------------------------------------------
  // requireDecodedList
  // -------------------------------------------------------------------------
  group('requireDecodedList', () {
    test('decodes each nested map', () {
      final result = reader({
        'items': <Object?>[
          <String, Object?>{'x': 1},
          <String, Object?>{'x': 2},
        ],
      }).requireDecodedList<int>('items', (m) => m['x']! as int);
      expect(result, [1, 2]);
    });

    test('throws FormatException when key is absent', () {
      expect(
        () => reader({}).requireDecodedList<int>('items', (m) => 0),
        missingKey('items'),
      );
    });

    test('throws when list element is not a Map', () {
      expect(
        () => reader({
          'items': <Object?>['not-a-map'],
        }).requireDecodedList<int>('items', (m) => 0),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // optString
  // -------------------------------------------------------------------------
  group('optString', () {
    test('returns value when present', () {
      expect(reader({'k': 'hi'}).optString('k'), 'hi');
    });

    test('returns null when key is absent', () {
      expect(reader({}).optString('k'), isNull);
    });

    test('returns null when value is null', () {
      expect(reader({'k': null}).optString('k'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // optInt
  // -------------------------------------------------------------------------
  group('optInt', () {
    test('returns value when present', () {
      expect(reader({'n': 5}).optInt('n'), 5);
    });

    test('returns null when absent', () {
      expect(reader({}).optInt('n'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // optBool
  // -------------------------------------------------------------------------
  group('optBool', () {
    test('returns value when present', () {
      expect(reader({'b': true}).optBool('b'), isTrue);
    });

    test('returns null when absent', () {
      expect(reader({}).optBool('b'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // optDouble
  // -------------------------------------------------------------------------
  group('optDouble', () {
    test('returns double when present', () {
      expect(reader({'d': 1.5}).optDouble('d'), 1.5);
    });

    test('coerces int when present', () {
      expect(reader({'d': 3}).optDouble('d'), 3.0);
    });

    test('returns null when absent', () {
      expect(reader({}).optDouble('d'), isNull);
    });

    test('returns null when value is null', () {
      expect(reader({'d': null}).optDouble('d'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // optMap
  // -------------------------------------------------------------------------
  group('optMap', () {
    test('returns map when present', () {
      final m = <String, Object?>{'a': 1};
      expect(reader({'nested': m}).optMap('nested'), m);
    });

    test('returns null when absent', () {
      expect(reader({}).optMap('nested'), isNull);
    });

    test('returns null when value is null', () {
      expect(reader({'nested': null}).optMap('nested'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // optList
  // -------------------------------------------------------------------------
  group('optList', () {
    test('returns list when present', () {
      expect(
        reader({
          'items': <Object?>['x'],
        }).optList<String>('items'),
        ['x'],
      );
    });

    test('returns null when absent', () {
      expect(reader({}).optList<String>('items'), isNull);
    });

    test('returns null when value is null', () {
      expect(reader({'items': null}).optList<String>('items'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // optMappedList
  // -------------------------------------------------------------------------
  group('optMappedList', () {
    test('maps list when present', () {
      final result = reader({
        'vals': <Object?>[10, 20],
      }).optMappedList<String>('vals', (e) => 'v${e! as int}');
      expect(result, ['v10', 'v20']);
    });

    test('returns null when absent', () {
      expect(
        reader({}).optMappedList<String>('vals', (e) => '$e'),
        isNull,
      );
    });

    test('returns null when value is null', () {
      expect(
        reader({'vals': null}).optMappedList<String>('vals', (e) => '$e'),
        isNull,
      );
    });
  });

  // -------------------------------------------------------------------------
  // optDecodedList
  // -------------------------------------------------------------------------
  group('optDecodedList', () {
    test('decodes nested maps when present', () {
      final result = reader({
        'items': <Object?>[
          <String, Object?>{'v': 'a'},
        ],
      }).optDecodedList<String>('items', (m) => m['v']! as String);
      expect(result, ['a']);
    });

    test('returns null when absent', () {
      expect(
        reader({}).optDecodedList<String>('items', (m) => ''),
        isNull,
      );
    });

    test('returns null when value is null', () {
      expect(
        reader({'items': null}).optDecodedList<String>('items', (m) => ''),
        isNull,
      );
    });
  });

  // -------------------------------------------------------------------------
  // optDecoded
  // -------------------------------------------------------------------------
  group('optDecoded', () {
    test('decodes nested map when present', () {
      final result = reader({
        'obj': <String, Object?>{'id': 'x'},
      }).optDecoded<String>('obj', (m) => m['id']! as String);
      expect(result, 'x');
    });

    test('returns null when key is absent', () {
      expect(
        reader({}).optDecoded<String>('obj', (m) => ''),
        isNull,
      );
    });

    test('returns null when value is null', () {
      expect(
        reader({'obj': null}).optDecoded<String>('obj', (m) => ''),
        isNull,
      );
    });
  });

  // -------------------------------------------------------------------------
  // optEnum
  // -------------------------------------------------------------------------
  group('optEnum', () {
    // Use a simple inline "enum" decoder for testing.
    String strictDecode(String s) {
      if (s == 'alpha' || s == 'beta') return s;
      throw ArgumentError('Unknown: $s');
    }

    test('decodes string to enum value when present', () {
      expect(reader({'e': 'alpha'}).optEnum<String>('e', strictDecode), 'alpha');
    });

    test('returns null when key is absent', () {
      expect(reader({}).optEnum<String>('e', strictDecode), isNull);
    });

    test('returns null when value is null', () {
      expect(reader({'e': null}).optEnum<String>('e', strictDecode), isNull);
    });

    test('propagates decoder exception for unrecognised value', () {
      expect(
        () => reader({'e': 'gamma'}).optEnum<String>('e', strictDecode),
        throwsArgumentError,
      );
    });
  });

  // -------------------------------------------------------------------------
  // raw
  // -------------------------------------------------------------------------
  group('raw', () {
    test('returns raw value without cast', () {
      expect(reader({'x': 99}).raw('x'), 99);
    });

    test('returns null for absent key', () {
      expect(reader({}).raw('x'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Error message quality
  // -------------------------------------------------------------------------
  group('error message quality', () {
    test('FormatException message includes the missing field name', () {
      try {
        reader({}).requireString('my_field');
        fail('expected FormatException');
      } on FormatException catch (e) {
        expect(e.message, contains('"my_field"'));
        expect(e.message, contains('absent or null'));
      }
    });

    test('FormatException for null int value includes field name', () {
      try {
        reader({'slot': null}).requireInt('slot');
        fail('expected FormatException');
      } on FormatException catch (e) {
        expect(e.message, contains('"slot"'));
      }
    });

    test('FormatException for missing list field includes field name', () {
      try {
        reader({}).requireList<String>('items');
        fail('expected FormatException');
      } on FormatException catch (e) {
        expect(e.message, contains('"items"'));
      }
    });
  });
}
