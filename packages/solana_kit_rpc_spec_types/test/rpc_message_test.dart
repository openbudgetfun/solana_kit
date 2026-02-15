import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:test/test.dart';

void main() {
  group('createRpcMessage', () {
    test('auto-increments ids with each new message', () {
      const request = RpcRequest<String>(methodName: 'foo', params: 'bar');
      final firstMessage = createRpcMessage(request);
      final secondMessage = createRpcMessage(request);
      final firstId = int.parse(firstMessage['id']! as String);
      final secondId = int.parse(secondMessage['id']! as String);
      expect(secondId - firstId, 1);
    });

    test('returns a well-formed JSON-RPC 2.0 message', () {
      const request = RpcRequest<List<int>>(
        methodName: 'someMethod',
        params: [1, 2, 3],
      );
      final message = createRpcMessage(request);
      expect(message['id'], isA<String>());
      expect(message['jsonrpc'], '2.0');
      expect(message['method'], 'someMethod');
      expect(message['params'], [1, 2, 3]);
    });

    test('returns an unmodifiable map', () {
      const request = RpcRequest<String>(methodName: 'foo', params: 'bar');
      final message = createRpcMessage(request);
      expect(
        () => message['extra'] = 'value',
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
