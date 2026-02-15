import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:test/test.dart';

void main() {
  group('isJsonRpcPayload', () {
    test('recognizes JSON RPC payloads', () {
      expect(
        isJsonRpcPayload({
          'jsonrpc': '2.0',
          'method': 'getFoo',
          'params': [123],
        }),
        isTrue,
      );
    });

    test('returns false if the payload is null', () {
      expect(isJsonRpcPayload(null), isFalse);
    });

    test('returns false if the payload is a bool (true)', () {
      expect(isJsonRpcPayload(true), isFalse);
    });

    test('returns false if the payload is a bool (false)', () {
      expect(isJsonRpcPayload(false), isFalse);
    });

    test('returns false if the payload is a list', () {
      expect(isJsonRpcPayload(<Object?>[]), isFalse);
    });

    test('returns false if the payload is a string', () {
      expect(isJsonRpcPayload('o hai'), isFalse);
    });

    test('returns false if the payload is a number', () {
      expect(isJsonRpcPayload(123), isFalse);
    });

    test('returns false if the payload is an empty map', () {
      expect(isJsonRpcPayload(<String, Object?>{}), isFalse);
    });

    test('returns false if the payload is not a JSON RPC v2', () {
      expect(
        isJsonRpcPayload({
          'jsonrpc': '42.0',
          'method': 'getFoo',
          'params': [123],
        }),
        isFalse,
      );
    });

    test('returns false if the method name is missing', () {
      expect(
        isJsonRpcPayload({
          'jsonrpc': '2.0',
          'params': [123],
        }),
        isFalse,
      );
    });

    test('returns false if the parameters are missing', () {
      expect(isJsonRpcPayload({'jsonrpc': '2.0', 'method': 'getFoo'}), isFalse);
    });
  });
}
