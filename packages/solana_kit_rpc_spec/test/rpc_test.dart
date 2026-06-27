import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('JSON-RPC 2.0', () {
    late RpcTransport makeHttpRequest;
    late List<RpcTransportConfig> transportCalls;

    setUp(() {
      transportCalls = [];
      makeHttpRequest = (config) {
        transportCalls.add(config);
        // Never resolve, like the TS test.
        return Future<Object?>.delayed(const Duration(days: 1));
      };
    });

    group('when no API plan is available for a method', () {
      late Rpc rpc;

      setUp(() {
        // Create an Rpc with an empty API (no methods).
        rpc = createRpc(
          RpcConfig(api: MapRpcApi({}), transport: makeHttpRequest),
        );
      });

      test('throws an error', () {
        expect(
          () => rpc.request('someMethod', ['some', 'params', 123]),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.rpcApiPlanMissingForRpcMethod,
            ),
          ),
        );
      });
    });

    group('when using a simple RPC API via JsonRpcApi', () {
      late Rpc rpc;

      setUp(() {
        rpc = createRpc(
          RpcConfig(api: _ProxyRpcApi(), transport: makeHttpRequest),
        );
      });

      test('sends a request to the transport', () {
        rpc.request('someMethod', [123]).send().ignore();
        expect(transportCalls, hasLength(1));
        final payload = transportCalls.first.payload! as Map<String, Object?>;
        expect(payload['jsonrpc'], '2.0');
        expect(payload['method'], 'someMethod');
        expect(payload['params'], [123]);
        expect(payload['id'], isA<String>());
      });

      test('returns results from the transport', () async {
        makeHttpRequest = (config) async => 123;
        rpc = createRpc(
          RpcConfig(api: _ProxyRpcApi(), transport: makeHttpRequest),
        );
        final result = await rpc.request('someMethod').send();
        expect(result, 123);
      });

      test('supports typed requests', () async {
        makeHttpRequest = (config) async => 123;
        rpc = createRpc(
          RpcConfig(api: _ProxyRpcApi(), transport: makeHttpRequest),
        );
        final result = await rpc.request<int>('someMethod').send();
        expect(result, 123);
      });

      test('throws when typed request cast is invalid', () async {
        makeHttpRequest = (config) async => 123;
        rpc = createRpc(
          RpcConfig(api: _ProxyRpcApi(), transport: makeHttpRequest),
        );
        final sendFuture = rpc.request<String>('someMethod').send();
        await expectLater(sendFuture, throwsA(isA<TypeError>()));
      });

      test('throws errors from the transport', () async {
        final transportError = Exception('o no');
        makeHttpRequest = (config) async => throw transportError;
        rpc = createRpc(
          RpcConfig(api: _ProxyRpcApi(), transport: makeHttpRequest),
        );
        final sendFuture = rpc.request('someMethod').send();
        await expectLater(sendFuture, throwsA(transportError));
      });
    });

    group('when calling a method having a concrete implementation', () {
      late Rpc rpc;

      setUp(() {
        rpc = createRpc(
          RpcConfig(
            api: MapRpcApi({
              'someMethod': (List<Object?> params) {
                final payload = createRpcMessage(
                  RpcRequest<List<Object?>>(
                    methodName: 'someMethodAugmented',
                    params: [...params, 'augmented', 'params'],
                  ),
                );
                return RpcPlan<Object?>(
                  execute: (config) => config.transport(
                    RpcTransportConfig(payload: payload, signal: config.signal),
                  ),
                );
              },
            }),
            transport: makeHttpRequest,
          ),
        );
      });

      test('converts the returned request to a JSON-RPC 2.0 message and sends '
          'it to the transport', () {
        rpc.request('someMethod', [123]).send().ignore();
        expect(transportCalls, hasLength(1));
        final payload = transportCalls.first.payload! as Map<String, Object?>;
        expect(payload['jsonrpc'], '2.0');
        expect(payload['method'], 'someMethodAugmented');
        expect(payload['params'], [123, 'augmented', 'params']);
        expect(payload['id'], isA<String>());
      });
    });
  });

  group('RpcSendOptions', () {
    test('can be created without arguments', () {
      const options = RpcSendOptions();
      expect(options.abortSignal, isNull);
    });

    test('can be created with an abort signal', () {
      final completer = Completer<void>();
      final options = RpcSendOptions(abortSignal: completer.future);
      expect(options.abortSignal, isNotNull);
    });
  });

  group('PendingRpcRequest.reactiveStore', () {
    late List<RpcTransportConfig> transportCalls;

    setUp(() {
      transportCalls = [];
    });

    test('returns a ReactiveActionStore in the idle state', () {
      Future<Object?> transport(RpcTransportConfig config) async => null;
      final request = PendingRpcRequest<int>(
        plan: RpcPlan<int>(
          execute: (config) async {
            final response = await config.transport(
              RpcTransportConfig(payload: null, signal: config.signal),
            );
            return response! as int;
          },
        ),
        transport: transport,
      );

      final store = request.reactiveStore();

      expect(store, isA<ReactiveActionStore<List<Object?>, int>>());
      expect(store.getState().status, ReactiveActionState.idle);
      expect(store.getState().isIdle, isTrue);
    });

    test(
      'dispatchAsync triggers send() and returns the transport response',
      () async {
        Future<Object?> transport(RpcTransportConfig config) async {
          transportCalls.add(config);
          return 42;
        }

        final request = PendingRpcRequest<int>(
          plan: RpcPlan<int>(
            execute: (config) async {
              final response = await config.transport(
                RpcTransportConfig(payload: null, signal: config.signal),
              );
              return response! as int;
            },
          ),
          transport: transport,
        );

        final store = request.reactiveStore();
        final result = await store.dispatchAsync([]);

        expect(result, 42);
        expect(transportCalls, hasLength(1));
        expect(store.getState().status, ReactiveActionState.success);
        expect(store.getState().result, 42);
      },
    );

    test('propagates errors from send() to the store', () async {
      final error = Exception('boom');
      Future<Object?> transport(RpcTransportConfig config) async => throw error;
      final request = PendingRpcRequest<int>(
        plan: RpcPlan<int>(
          execute: (config) async {
            final response = await config.transport(
              RpcTransportConfig(payload: null, signal: config.signal),
            );
            return response! as int;
          },
        ),
        transport: transport,
      );

      final store = request.reactiveStore();

      await expectLater(store.dispatchAsync([]), throwsA(error));

      expect(store.getState().status, ReactiveActionState.error);
      expect(store.getState().error, error);
    });
  });

  group('JsonRpcApiAdapter', () {
    test('delegates getPlan to the wrapped JsonRpcApi', () {
      final jsonRpcApi = createJsonRpcApi();
      final adapter = JsonRpcApiAdapter(jsonRpcApi);
      final plan = adapter.getPlan('someMethod', [1, 'two']);
      expect(plan, isNotNull);
      expect(plan.execute, isA<Function>());
    });

    test('returns a plan that can be executed', () async {
      late RpcTransportConfig capturedConfig;
      Future<Object?> transport(RpcTransportConfig config) async {
        capturedConfig = config;
        return null;
      }

      final jsonRpcApi = createJsonRpcApi();
      final adapter = JsonRpcApiAdapter(jsonRpcApi);
      final plan = adapter.getPlan('testMethod', ['param1']);

      await plan.execute(RpcPlanExecuteConfig(transport: transport));
      final payload = capturedConfig.payload! as Map<String, Object?>;
      expect(payload['method'], 'testMethod');
      expect(payload['params'], ['param1']);
    });
  });
}

/// A proxy-like RPC API that creates JSON-RPC plans for any method name,
/// similar to the JavaScript Proxy approach used in the TS tests.
class _ProxyRpcApi extends RpcApi {
  @override
  RpcPlan<Object?> getPlan(String methodName, List<Object?> params) {
    return RpcPlan<Object?>(
      execute: (config) => config.transport(
        RpcTransportConfig(
          payload: createRpcMessage(
            RpcRequest<List<Object?>>(methodName: methodName, params: params),
          ),
          signal: config.signal,
        ),
      ),
    );
  }
}
