import 'package:solana_kit_options/solana_kit_options.dart';
import 'package:test/test.dart';

void main() {
  group('Option', () {
    test('can create Some options', () {
      final option = some(42);
      expect(option, isA<Some<int>>());
      expect((option as Some<int>).value, equals(42));
    });

    test('can create None options', () {
      final option = none<int>();
      expect(option, isA<None<int>>());
    });

    test('Some with null value is allowed', () {
      final option = some<int?>(null);
      expect(option, isA<Some<int?>>());
      expect((option as Some<int?>).value, isNull);
    });

    test('Some equality', () {
      expect(some(42), equals(some(42)));
      expect(some(42), isNot(equals(some(43))));
      expect(some('hello'), equals(some('hello')));
    });

    test('None equality', () {
      expect(none<int>(), equals(none<int>()));
    });

    test('Some and None are not equal', () {
      expect(some(42), isNot(equals(none<int>())));
    });

    test('Some hashCode', () {
      expect(some(42).hashCode, equals(some(42).hashCode));
    });

    test('Some toString', () {
      expect(some(42).toString(), equals('Some(42)'));
      expect(some('hello').toString(), equals('Some(hello)'));
    });

    test('None toString', () {
      expect(none<int>().toString(), equals('None'));
    });

    test('isSome returns true for Some', () {
      expect(isSome(some(42)), isTrue);
      expect(isSome(none<int>()), isFalse);
    });

    test('isNone returns true for None', () {
      expect(isNone(some(42)), isFalse);
      expect(isNone(none<int>()), isTrue);
    });

    test('isOption returns true for Option types', () {
      expect(isOption(some(42)), isTrue);
      expect(isOption(none<int>()), isTrue);
      expect(isOption(42), isFalse);
      expect(isOption(null), isFalse);
      expect(isOption('anything'), isFalse);
    });

    test('pattern matching with switch', () {
      Option<int> makeOption() => some(42);
      final option = makeOption();
      final result = switch (option) {
        Some<int>(:final value) => 'Some($value)',
        None<int>() => 'None',
      };
      expect(result, equals('Some(42)'));

      Option<int> makeNone() => none<int>();
      final noneOption = makeNone();
      final noneResult = switch (noneOption) {
        Some<int>(:final value) => 'Some($value)',
        None<int>() => 'None',
      };
      expect(noneResult, equals('None'));
    });
  });
}
