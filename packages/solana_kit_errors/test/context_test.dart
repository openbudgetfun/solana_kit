import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('encodeContextObject / decodeEncodedContext', () {
    test('encodes and decodes empty context', () {
      final encoded = encodeContextObject({});
      expect(encoded, isEmpty);
      final decoded = decodeEncodedContext('');
      expect(decoded, isEmpty);
    });

    test('round-trips simple string values', () {
      final context = {'address': 'abc123', 'name': 'test'};
      final encoded = encodeContextObject(context);
      expect(encoded, isNotEmpty);
      final decoded = decodeEncodedContext(encoded);
      expect(decoded['address'], 'abc123');
      expect(decoded['name'], 'test');
    });

    test('round-trips numeric values', () {
      final context = <String, Object?>{'count': 42};
      final encoded = encodeContextObject(context);
      final decoded = decodeEncodedContext(encoded);
      expect(decoded['count'], 42);
    });

    test('handles null values', () {
      final context = <String, Object?>{'key': null};
      final encoded = encodeContextObject(context);
      final decoded = decodeEncodedContext(encoded);
      expect(decoded['key'], isNull);
    });
  });
}
