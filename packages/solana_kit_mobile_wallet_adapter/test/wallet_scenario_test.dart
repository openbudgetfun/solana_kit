import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solana_kit_mobile_wallet_adapter/src/pigeon/wallet_api.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_config.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_request_types.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_scenario.dart';

/// A mock [MwaWalletHostApi] that captures method calls.
class MockWalletHostApi extends MwaWalletHostApi {
  MockWalletHostApi() : super(binaryMessenger: _MockBinaryMessenger());

  final calls = <String, List<Map<String, Object?>>>{};

  String nextSessionId = 'test-session-123';
  Future<Object?> Function(MethodCall)? _handler;

  @override
  Future<String> createScenario({
    required String walletName,
    required String configJson,
  }) async {
    _recordCall('createScenario', {
      'walletName': walletName,
      'configJson': configJson,
    });
    return nextSessionId;
  }

  @override
  Future<void> startScenario({required String sessionId}) async {
    _recordCall('startScenario', {'sessionId': sessionId});
  }

  @override
  Future<void> closeScenario({required String sessionId}) async {
    _recordCall('closeScenario', {'sessionId': sessionId});
  }

  @override
  Future<void> resolveRequest({
    required String sessionId,
    required String requestId,
    required String resultJson,
  }) async {
    _recordCall('resolveRequest', {
      'sessionId': sessionId,
      'requestId': requestId,
      'resultJson': resultJson,
    });
  }

  @override
  void setMethodCallHandler(
    Future<Object?> Function(MethodCall call)? handler,
  ) {
    _handler = handler;
  }

  /// Simulates a native method call to the Dart handler.
  Future<Object?> simulateNativeCall(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    if (_handler == null) {
      throw StateError('No handler registered');
    }
    return _handler!(MethodCall(method, arguments));
  }

  void _recordCall(String method, Map<String, Object?> args) {
    calls.putIfAbsent(method, () => []).add(args);
  }
}

/// Minimal mock BinaryMessenger for testing.
class _MockBinaryMessenger implements BinaryMessenger {
  @override
  Future<ByteData?> send(String channel, ByteData? message) async => null;

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {}

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) async {}
}

/// Tracking implementation of [WalletScenarioCallbacks].
class TrackingCallbacks implements WalletScenarioCallbacks {
  final events = <String>[];
  AuthorizeDappRequest? lastAuthorizeRequest;
  ReauthorizeDappRequest? lastReauthorizeRequest;
  SignTransactionsRequest? lastSignTransactionsRequest;
  SignMessagesRequest? lastSignMessagesRequest;
  SignAndSendTransactionsRequest? lastSignAndSendRequest;
  DeauthorizedEvent? lastDeauthorizedEvent;
  Object? lastError;

  @override
  void onScenarioReady() => events.add('ready');

  @override
  void onScenarioServingClients() => events.add('servingClients');

  @override
  void onScenarioServingComplete() => events.add('servingComplete');

  @override
  void onScenarioComplete() => events.add('complete');

  @override
  void onScenarioError(Object? error) {
    events.add('error');
    lastError = error;
  }

  @override
  void onScenarioTeardownComplete() => events.add('teardownComplete');

  @override
  void onAuthorizeRequest(AuthorizeDappRequest request) {
    events.add('authorize');
    lastAuthorizeRequest = request;
  }

  @override
  void onReauthorizeRequest(ReauthorizeDappRequest request) {
    events.add('reauthorize');
    lastReauthorizeRequest = request;
  }

  @override
  void onSignTransactionsRequest(SignTransactionsRequest request) {
    events.add('signTransactions');
    lastSignTransactionsRequest = request;
  }

  @override
  void onSignMessagesRequest(SignMessagesRequest request) {
    events.add('signMessages');
    lastSignMessagesRequest = request;
  }

  @override
  void onSignAndSendTransactionsRequest(
    SignAndSendTransactionsRequest request,
  ) {
    events.add('signAndSendTransactions');
    lastSignAndSendRequest = request;
  }

  @override
  void onDeauthorizedEvent(DeauthorizedEvent event) {
    events.add('deauthorized');
    lastDeauthorizedEvent = event;
  }
}

void main() {
  group('WalletScenario', () {
    late MockWalletHostApi mockApi;
    late TrackingCallbacks callbacks;
    late WalletScenario scenario;

    setUp(() {
      mockApi = MockWalletHostApi();
      callbacks = TrackingCallbacks();
      scenario = WalletScenario(
        walletName: 'Test Wallet',
        config: const MobileWalletAdapterConfig(
          maxTransactionsPerSigningRequest: 10,
          maxMessagesPerSigningRequest: 5,
          optionalFeatures: ['solana:signTransactions'],
        ),
        callbacks: callbacks,
        walletApi: mockApi,
      );
    });

    test('start creates and starts scenario', () async {
      await scenario.start();

      expect(scenario.sessionId, 'test-session-123');
      expect(scenario.isClosed, isFalse);
      expect(mockApi.calls['createScenario'], hasLength(1));
      expect(mockApi.calls['startScenario'], hasLength(1));
      expect(
        mockApi.calls['createScenario']!.first['walletName'],
        'Test Wallet',
      );
    });

    test('close calls closeScenario', () async {
      await scenario.start();
      await scenario.close();

      expect(scenario.isClosed, isTrue);
      expect(mockApi.calls['closeScenario'], hasLength(1));
    });

    test('close is idempotent', () async {
      await scenario.start();
      await scenario.close();
      await scenario.close();

      expect(mockApi.calls['closeScenario'], hasLength(1));
    });

    test('lifecycle events are forwarded to callbacks', () async {
      await scenario.start();

      await mockApi.simulateNativeCall('onScenarioReady');
      await mockApi.simulateNativeCall('onScenarioServingClients');
      await mockApi.simulateNativeCall('onScenarioServingComplete');
      await mockApi.simulateNativeCall('onScenarioComplete');
      await mockApi.simulateNativeCall('onScenarioTeardownComplete');

      expect(callbacks.events, [
        'ready',
        'servingClients',
        'servingComplete',
        'complete',
        'teardownComplete',
      ]);
    });

    test('error event is forwarded with error data', () async {
      await scenario.start();

      await mockApi.simulateNativeCall('onScenarioError', {
        'error': 'connection failed',
      });

      expect(callbacks.events, ['error']);
      expect(callbacks.lastError, 'connection failed');
    });

    test('authorize request is forwarded and resolved', () async {
      await scenario.start();

      // Simulate an authorize request from native.
      final nativeFuture = mockApi.simulateNativeCall('onAuthorizeRequest', {
        'requestId': 'req-1',
        'paramsJson': jsonEncode({
          'identity': {'name': 'Test dApp'},
          'chain': 'solana:mainnet',
        }),
      });

      // Let the microtask queue process.
      await Future<void>.delayed(Duration.zero);

      // The callback should have received the request.
      expect(callbacks.events, ['authorize']);
      expect(callbacks.lastAuthorizeRequest!.identityName, 'Test dApp');
      expect(callbacks.lastAuthorizeRequest!.chain, 'solana:mainnet');

      // Complete the request from the wallet side.
      callbacks.lastAuthorizeRequest!.completeWithAuthorize(
        accounts: [const AuthorizedAccount(address: 'dGVzdA==')],
        authToken: 'new-token',
      );

      await nativeFuture;

      // The result should have been forwarded to the native side.
      expect(mockApi.calls['resolveRequest'], hasLength(1));
      final resolveCall = mockApi.calls['resolveRequest']!.first;
      expect(resolveCall['requestId'], 'req-1');
      final resultJson =
          jsonDecode(resolveCall['resultJson']! as String)
              as Map<String, Object?>;
      expect(resultJson['auth_token'], 'new-token');
    });

    test('authorize decline is forwarded as error', () async {
      await scenario.start();

      final nativeFuture = mockApi.simulateNativeCall('onAuthorizeRequest', {
        'requestId': 'req-1',
        'paramsJson': jsonEncode({'chain': 'solana:mainnet'}),
      });

      await Future<void>.delayed(Duration.zero);

      callbacks.lastAuthorizeRequest!.completeWithDecline();

      await nativeFuture;

      expect(mockApi.calls['resolveRequest'], hasLength(1));
      final resultJson =
          jsonDecode(
                mockApi.calls['resolveRequest']!.first['resultJson']! as String,
              )
              as Map<String, Object?>;
      expect(resultJson.containsKey('error'), isTrue);
    });

    test('signTransactions request is forwarded and resolved', () async {
      await scenario.start();

      final nativeFuture = mockApi.simulateNativeCall(
        'onSignTransactionsRequest',
        {
          'requestId': 'req-2',
          'paramsJson': jsonEncode({
            'payloads': ['dHgx', 'dHgy'],
            'chain': 'solana:mainnet',
          }),
        },
      );

      await Future<void>.delayed(Duration.zero);

      expect(callbacks.events, ['signTransactions']);
      expect(callbacks.lastSignTransactionsRequest!.payloads, ['dHgx', 'dHgy']);

      callbacks.lastSignTransactionsRequest!.completeWithSignedPayloads([
        'c2lnMQ==',
        'c2lnMg==',
      ]);

      await nativeFuture;

      final resultJson =
          jsonDecode(
                mockApi.calls['resolveRequest']!.first['resultJson']! as String,
              )
              as Map<String, Object?>;
      expect(resultJson['signed_payloads'], ['c2lnMQ==', 'c2lnMg==']);
    });

    test('signMessages request is forwarded', () async {
      await scenario.start();

      final nativeFuture = mockApi.simulateNativeCall('onSignMessagesRequest', {
        'requestId': 'req-3',
        'paramsJson': jsonEncode({
          'payloads': ['bXNn'],
          'addresses': ['addr1'],
        }),
      });

      await Future<void>.delayed(Duration.zero);

      expect(callbacks.events, ['signMessages']);
      expect(callbacks.lastSignMessagesRequest!.addresses, ['addr1']);

      callbacks.lastSignMessagesRequest!.completeWithSignedPayloads(['c2ln']);
      await nativeFuture;
    });

    test('signAndSendTransactions request is forwarded', () async {
      await scenario.start();

      final nativeFuture = mockApi.simulateNativeCall(
        'onSignAndSendTransactionsRequest',
        {
          'requestId': 'req-4',
          'paramsJson': jsonEncode({
            'payloads': ['dHgx'],
            'options': {'commitment': 'confirmed', 'skip_preflight': true},
          }),
        },
      );

      await Future<void>.delayed(Duration.zero);

      expect(callbacks.events, ['signAndSendTransactions']);
      expect(callbacks.lastSignAndSendRequest!.commitment, 'confirmed');
      expect(callbacks.lastSignAndSendRequest!.skipPreflight, isTrue);

      callbacks.lastSignAndSendRequest!.completeWithSignatures(['sig1']);
      await nativeFuture;
    });

    test('deauthorized event is forwarded', () async {
      await scenario.start();

      final nativeFuture = mockApi.simulateNativeCall('onDeauthorizedEvent', {
        'requestId': 'req-5',
        'paramsJson': jsonEncode({
          'auth_token': 'revoked-token',
          'chain': 'solana:mainnet',
        }),
      });

      await Future<void>.delayed(Duration.zero);

      expect(callbacks.events, ['deauthorized']);
      expect(
        callbacks.lastDeauthorizedEvent!.authorizationScope,
        'revoked-token',
      );

      callbacks.lastDeauthorizedEvent!.complete();
      await nativeFuture;
    });

    test('reauthorize request is forwarded', () async {
      await scenario.start();

      final nativeFuture = mockApi.simulateNativeCall('onReauthorizeRequest', {
        'requestId': 'req-6',
        'paramsJson': jsonEncode({
          'auth_token': 'old-token',
          'chain': 'solana:devnet',
        }),
      });

      await Future<void>.delayed(Duration.zero);

      expect(callbacks.events, ['reauthorize']);
      expect(callbacks.lastReauthorizeRequest!.authorizationScope, 'old-token');
      expect(callbacks.lastReauthorizeRequest!.chain, 'solana:devnet');

      callbacks.lastReauthorizeRequest!.completeWithReauthorize(
        accounts: [const AuthorizedAccount(address: 'dGVzdA==')],
        authToken: 'new-token',
      );

      await nativeFuture;
    });
  });

  group('MobileWalletAdapterConfig', () {
    test('toCapabilitiesJson includes all fields', () {
      const config = MobileWalletAdapterConfig(
        maxTransactionsPerSigningRequest: 10,
        maxMessagesPerSigningRequest: 5,
        supportedTransactionVersions: ['legacy', '0'],
        optionalFeatures: ['solana:signTransactions'],
      );

      final json = config.toCapabilitiesJson();
      expect(json['max_transactions_per_request'], 10);
      expect(json['max_messages_per_request'], 5);
      expect(json['supported_transaction_versions'], ['legacy', '0']);
      expect(json['features'], ['solana:signTransactions']);
    });

    test('default config has sensible defaults', () {
      const config = MobileWalletAdapterConfig();
      expect(config.maxTransactionsPerSigningRequest, 0);
      expect(config.maxMessagesPerSigningRequest, 0);
      expect(config.supportedTransactionVersions, ['legacy']);
      expect(config.noConnectionWarningTimeoutMs, 0);
      expect(config.optionalFeatures, isEmpty);
    });
  });

  group('AuthIssuerConfig', () {
    test('has sensible defaults', () {
      const config = AuthIssuerConfig(name: 'Test Wallet');
      expect(config.name, 'Test Wallet');
      expect(config.maxOutstandingTokensPerIdentity, 50);
      expect(config.authorizationValidityMs, 3600000);
      expect(config.reauthorizationValidityMs, 2592000000);
      expect(config.reauthorizationNopDurationMs, 600000);
    });
  });
}
