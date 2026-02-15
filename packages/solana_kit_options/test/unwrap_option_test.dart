import 'package:solana_kit_options/solana_kit_options.dart';
import 'package:test/test.dart';

void main() {
  group('unwrapOption', () {
    test('unwraps Some to its value', () {
      expect(unwrapOption(some(42)), equals(42));
      expect(unwrapOption(some('hello')), equals('hello'));
    });

    test('unwraps Some(null) to null', () {
      expect(unwrapOption(some<int?>(null)), isNull);
    });

    test('unwraps None to null', () {
      expect(unwrapOption(none<int>()), isNull);
      expect(unwrapOption(none<String>()), isNull);
    });
  });

  group('unwrapOptionOr', () {
    test('unwraps Some to its value', () {
      expect(unwrapOptionOr(some(1), () => 42), equals(1));
      expect(unwrapOptionOr(some('A'), () => 'fallback'), equals('A'));
    });

    test('returns fallback for None', () {
      expect(unwrapOptionOr(none<int>(), () => 42), equals(42));
      expect(
        unwrapOptionOr(none<String>(), () => 'fallback'),
        equals('fallback'),
      );
    });

    test('fallback can throw', () {
      expect(unwrapOptionOr(some(1), () => throw Exception('fail')), equals(1));
      expect(
        () => unwrapOptionOr(none<int>(), () => throw Exception('fail')),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('wrapNullable', () {
    test('wraps non-null to Some', () {
      expect(wrapNullable(42), equals(some(42)));
      expect(wrapNullable('hello'), equals(some('hello')));
      expect(wrapNullable(false), equals(some(false)));
    });

    test('wraps null to None', () {
      expect(wrapNullable<String>(null), equals(none<String>()));
      expect(wrapNullable<int>(null), equals(none<int>()));
    });
  });
}
