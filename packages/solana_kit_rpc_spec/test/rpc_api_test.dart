import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:test/test.dart';

void main() {
  group('createJsonRpcApi', () {
    late RpcTransport transport;
    late List<RpcTransportConfig> transportCalls;

    setUp(() {
      transportCalls = [];
      transport = (config) async {
        transportCalls.add(config);
        return null;
      };
    });

    test('returns a plan containing a function to execute the plan', () {
      // Given a dummy API.
      final api = createJsonRpcApi();

      // When we call a method on the API.
      final plan = api.call('someMethod', [
        1,
        'two',
        {
          'three': [4],
        },
      ]);

      // Then we expect the plan to contain an `execute` function.
      expect(plan.execute, isNotNull);
      expect(plan.execute, isA<Function>());
    });

    test(
      'applies the request transformer to the provided method name',
      () async {
        // Given a dummy API with a request transformer that appends
        // 'Transformed' to the method name.
        final api = createJsonRpcApi(
          config: RpcApiConfig(
            requestTransformer: (RpcRequest<Object?> request) =>
                RpcRequest<Object?>(
                  methodName: '${request.methodName}Transformed',
                  params: request.params,
                ),
          ),
        );

        // When we call a method on the API.
        final plan = api.call('someMethod', []);

        // Then we expect the plan executor to pass the transformed method name
        // to the transport.
        await plan.execute(RpcPlanExecuteConfig(transport: transport));
        expect(transportCalls, hasLength(1));
        final payload = transportCalls.first.payload! as Map<String, Object?>;
        expect(payload['method'], 'someMethodTransformed');
      },
    );

    test('applies the request transformer to the provided params', () async {
      // Given a dummy API with a request transformer that doubles the
      // provided params.
      final api = createJsonRpcApi(
        config: RpcApiConfig(
          requestTransformer: (RpcRequest<Object?> request) =>
              RpcRequest<Object?>(
                methodName: request.methodName,
                params: (request.params! as List<Object?>)
                    .cast<int>()
                    .map((x) => x * 2)
                    .toList(),
              ),
        ),
      );

      // When we call a method on the API.
      final plan = api.call('someMethod', [1, 2, 3]);

      // Then we expect the plan executor to pass the transformed params
      // to the transport.
      await plan.execute(RpcPlanExecuteConfig(transport: transport));
      expect(transportCalls, hasLength(1));
      final payload = transportCalls.first.payload! as Map<String, Object?>;
      expect(payload['params'], [2, 4, 6]);
    });

    test(
      "applies the response transformer to the transport's response",
      () async {
        // Given a dummy API with a response transformer that doubles
        // the response.
        final api = createJsonRpcApi(
          config: RpcApiConfig(
            responseTransformer:
                (Object? response, RpcRequest<Object?> request) =>
                    (response! as int) * 2,
          ),
        );

        // And given a transport that returns a mock response.
        transport = (config) async => 42;

        // When we call a method on the API.
        final plan = api.call('someMethod', [1, 2, 3]);

        // Then we expect the plan to use the response transformer.
        final response = await plan.execute(
          RpcPlanExecuteConfig(transport: transport),
        );
        expect(response, 84);
      },
    );

    test('returns a plan without a response transformer', () async {
      // Given a dummy API without a response transformer.
      final api = createJsonRpcApi();

      // And given a transport that returns a mock response.
      transport = (config) async => 42;

      // When we call a method on the API.
      final plan = api.call('someMethod', []);

      // Then we expect the plan to return the response as-is.
      final response = await plan.execute(
        RpcPlanExecuteConfig(transport: transport),
      );
      expect(response, 42);
    });

    test('creates a well-formed JSON-RPC 2.0 payload', () async {
      // Given a dummy API.
      final api = createJsonRpcApi();

      // When we call a method on the API.
      final plan = api.call('someMethod', [1, 'two']);

      // And execute it.
      await plan.execute(RpcPlanExecuteConfig(transport: transport));

      // Then we expect the transport to receive a well-formed
      // JSON-RPC 2.0 payload.
      expect(transportCalls, hasLength(1));
      final payload = transportCalls.first.payload! as Map<String, Object?>;
      expect(payload['jsonrpc'], '2.0');
      expect(payload['method'], 'someMethod');
      expect(payload['params'], [1, 'two']);
      expect(payload['id'], isA<String>());
    });

    test('also works with a request transformer', () async {
      // Given a dummy API with a request transformer.
      final api = createJsonRpcApi(
        config: RpcApiConfig(
          requestTransformer: (RpcRequest<Object?> request) =>
              RpcRequest<Object?>(
                methodName: 'transformed',
                params: request.params,
              ),
        ),
      );

      // When we call a method on the API.
      final plan = api.call('someMethod', []);

      // And execute it.
      await plan.execute(RpcPlanExecuteConfig(transport: transport));

      // Then the payload method should be 'transformed'.
      expect(transportCalls, hasLength(1));
      final payload = transportCalls.first.payload! as Map<String, Object?>;
      expect(payload['method'], 'transformed');
    });
  });
}
