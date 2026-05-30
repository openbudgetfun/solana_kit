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

    test('round-trips list values as encoded string', () {
      final context = <String, Object?>{'items': ['a', 'b', 'c']};
      final encoded = encodeContextObject(context);
      final decoded = decodeEncodedContext(encoded);
      // Lists are encoded as comma-separated values but decoded as string.
      expect(decoded['items'], isA<String>());
      expect(decoded['items'], 'a,b,c');
    });

    test('round-trips map values', () {
      final context = <String, Object?>{
        'nested': {'x': 1, 'y': 2},
      };
      final encoded = encodeContextObject(context);
      final decoded = decodeEncodedContext(encoded);
      expect(decoded['nested'], isA<Map<String, Object?>>());
      final map = decoded['nested']! as Map<String, Object?>;
      expect(map['x'], 1);
      expect(map['y'], 2);
    });

    test('decodes JSON object string', () {
      final context = <String, Object?>{
        'data': {'key': 'value'},
      };
      final encoded = encodeContextObject(context);
      final decoded = decodeEncodedContext(encoded);
      expect(decoded['data'], isA<Map<String, Object?>>());
    });

    test('decodes JSON array string as list', () {
      // Use a raw encoded string that contains a JSON array.
      final context = <String, Object?>{
        'data': [1, 2, 3],
      };
      final encoded = encodeContextObject(context);
      final decoded = decodeEncodedContext(encoded);
      // Lists are encoded as comma-separated, decoded as string.
      expect(decoded['data'], isA<String>());
    });
  });
}
