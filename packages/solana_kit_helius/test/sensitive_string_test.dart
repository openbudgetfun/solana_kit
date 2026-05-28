import 'package:solana_kit_helius/src/sensitive_string.dart';
import 'package:test/test.dart';

void main() {
  group('SensitiveString', () {
    test('stores the original value', () {
      const sensitive = SensitiveString('sk_live_abc123');
      expect(sensitive.value, 'sk_live_abc123');
    });

    test('redacts the value in toString()', () {
      const sensitive = SensitiveString('sk_live_abc123');
      expect(sensitive.toString(), 'SensitiveString(****123)');
    });

    test('shows only last 3 characters by default', () {
      const sensitive = SensitiveString('abcdefghijklmnop');
      expect(sensitive.redacted(), '****nop');
    });

    test('redacts with custom visible characters', () {
      const sensitive = SensitiveString('sk_live_abc123');
      expect(sensitive.redacted(visibleChars: 5), '****bc123');
    });

    test('returns **** for short strings', () {
      const sensitive = SensitiveString('ab');
      expect(sensitive.redacted(), '****');
    });

    test('returns **** for empty strings', () {
      const sensitive = SensitiveString('');
      expect(sensitive.redacted(), '****');
    });

    test('equality is based on value', () {
      const a = SensitiveString('key123');
      const b = SensitiveString('key123');
      const c = SensitiveString('key456');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is based on value', () {
      const a = SensitiveString('key123');
      const b = SensitiveString('key123');

      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
