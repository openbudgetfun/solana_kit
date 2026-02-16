import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:test/test.dart';

void main() {
  group('getSolanaRpcPayloadDeduplicationKey', () {
    test('produces no key for null payloads', () {
      expect(getSolanaRpcPayloadDeduplicationKey(null), isNull);
    });

    test('produces no key for array payloads', () {
      expect(getSolanaRpcPayloadDeduplicationKey(<Object>[]), isNull);
    });

    test('produces no key for string payloads', () {
      expect(getSolanaRpcPayloadDeduplicationKey('o hai'), isNull);
    });

    test('produces no key for numeric payloads', () {
      expect(getSolanaRpcPayloadDeduplicationKey(123), isNull);
    });

    test('produces no key for bigint payloads', () {
      expect(getSolanaRpcPayloadDeduplicationKey(BigInt.from(123)), isNull);
    });

    test(
      'produces no key for object payloads that are not JSON-RPC payloads',
      () {
        expect(
          getSolanaRpcPayloadDeduplicationKey(<String, Object?>{}),
          isNull,
        );
      },
    );

    test('produces a key for a JSON-RPC payload', () {
      final key = getSolanaRpcPayloadDeduplicationKey({
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'getFoo',
        'params': 'foo',
      });
      expect(key, isNotNull);
      expect(key, '["getFoo","foo"]');
    });

    test('produces identical keys for two materially identical JSON-RPC '
        'payloads', () {
      final keyA = getSolanaRpcPayloadDeduplicationKey({
        'id': 1,
        'jsonrpc': '2.0',
        'method': 'getFoo',
        'params': <String, Object?>{
          'a': 1,
          'b': <String, Object?>{
            'c': [2, 3],
            'd': 4,
          },
        },
      });

      final keyB = getSolanaRpcPayloadDeduplicationKey({
        'jsonrpc': '2.0',
        'method': 'getFoo',
        'params': <String, Object?>{
          'b': <String, Object?>{
            'd': 4,
            'c': [2, 3],
          },
          'a': 1,
        },
        'id': 2,
      });

      expect(keyA, equals(keyB));
    });
  });
}
