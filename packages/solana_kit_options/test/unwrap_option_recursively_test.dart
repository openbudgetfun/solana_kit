import 'dart:typed_data';

import 'package:solana_kit_options/solana_kit_options.dart';
import 'package:test/test.dart';

void main() {
  group('unwrapOptionRecursively', () {
    test('unwraps Some values', () {
      expect(unwrapOptionRecursively(some<int?>(null)), isNull);
      expect(unwrapOptionRecursively(some(42)), equals(42));
      expect(unwrapOptionRecursively(some('hello')), equals('hello'));
    });

    test('unwraps None values to null', () {
      expect(unwrapOptionRecursively(none<int>()), isNull);
      expect(unwrapOptionRecursively(none<String>()), isNull);
    });

    test('unwraps nested Some and None values', () {
      expect(unwrapOptionRecursively(some(some(some(false)))), equals(false));
      expect(unwrapOptionRecursively(some(some(none<int>()))), isNull);
    });

    test('passes through scalars', () {
      expect(unwrapOptionRecursively(1), equals(1));
      expect(unwrapOptionRecursively('hello'), equals('hello'));
      expect(unwrapOptionRecursively(true), equals(true));
      expect(unwrapOptionRecursively(false), equals(false));
      expect(unwrapOptionRecursively(null), isNull);
    });

    test('passes through TypedData', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(unwrapOptionRecursively(bytes), equals(bytes));
    });

    test('passes through functions', () {
      int fn() => 42;
      expect(unwrapOptionRecursively(fn), equals(fn));
    });

    test('unwraps options inside Maps', () {
      expect(
        unwrapOptionRecursively({'foo': 'hello'}),
        equals({'foo': 'hello'}),
      );
      expect(
        unwrapOptionRecursively({'foo': none<String>()}),
        equals({'foo': null}),
      );
      expect(
        unwrapOptionRecursively({'foo': some(none<String>())}),
        equals({'foo': null}),
      );
      expect(
        unwrapOptionRecursively(some({'baz': none<int>(), 'foo': some('bar')})),
        equals({'baz': null, 'foo': 'bar'}),
      );
    });

    test('unwraps options inside Lists', () {
      expect(unwrapOptionRecursively([1, true, '3']), equals([1, true, '3']));
      expect(
        unwrapOptionRecursively([some('a'), none<bool>(), some(some(3)), 'b']),
        equals(['a', null, 3, 'b']),
      );
    });

    test('unwraps complex nested structure', () {
      final person = {
        'name': 'Roo',
        'age': 42,
        'gender': none<String>(),
        'address': {
          'street': '11215 104 Ave NW',
          'city': 'Edmonton',
          'region': some('Alberta'),
          'country': 'Canada',
          'zipcode': 'T5K 2S1',
          'phone': none<String>(),
        },
        'interests': [
          {'name': 'Programming', 'category': some('IT')},
          {'name': 'Modular Synths', 'category': some('Music')},
          {'name': 'Popping bubble wrap', 'category': none<String>()},
        ],
      };

      expect(
        unwrapOptionRecursively(person),
        equals({
          'name': 'Roo',
          'age': 42,
          'gender': null,
          'address': {
            'street': '11215 104 Ave NW',
            'city': 'Edmonton',
            'region': 'Alberta',
            'country': 'Canada',
            'zipcode': 'T5K 2S1',
            'phone': null,
          },
          'interests': [
            {'name': 'Programming', 'category': 'IT'},
            {'name': 'Modular Synths', 'category': 'Music'},
            {'name': 'Popping bubble wrap', 'category': null},
          ],
        }),
      );
    });

    test('uses custom fallback for None', () {
      Object? fallback() => 42;

      expect(unwrapOptionRecursively(some<int?>(null), fallback), isNull);
      expect(unwrapOptionRecursively(some(100), fallback), equals(100));
      expect(unwrapOptionRecursively(none<int>(), fallback), equals(42));
      expect(
        unwrapOptionRecursively(some(some(none<int>())), fallback),
        equals(42),
      );
    });

    test('uses custom fallback in complex structures', () {
      Object? fallback() => 42;

      final person = {
        'name': 'Roo',
        'age': 42,
        'gender': none<String>(),
        'address': {
          'street': '11215 104 Ave NW',
          'city': 'Edmonton',
          'region': some('Alberta'),
          'country': 'Canada',
          'zipcode': 'T5K 2S1',
          'phone': none<String>(),
        },
        'interests': [
          {'name': 'Programming', 'category': some('IT')},
          {'name': 'Modular Synths', 'category': some('Music')},
          {'name': 'Popping bubble wrap', 'category': none<String>()},
        ],
      };

      expect(
        unwrapOptionRecursively(person, fallback),
        equals({
          'name': 'Roo',
          'age': 42,
          'gender': 42,
          'address': {
            'street': '11215 104 Ave NW',
            'city': 'Edmonton',
            'region': 'Alberta',
            'country': 'Canada',
            'zipcode': 'T5K 2S1',
            'phone': 42,
          },
          'interests': [
            {'name': 'Programming', 'category': 'IT'},
            {'name': 'Modular Synths', 'category': 'Music'},
            {'name': 'Popping bubble wrap', 'category': 42},
          ],
        }),
      );
    });
  });
}
