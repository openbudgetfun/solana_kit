import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_config.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_request_types.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_scenario.dart';

import 'wallet_scenario_test.dart' show MockWalletHostApi, TrackingCallbacks;

class _CompletingCallbacks extends TrackingCallbacks {
  int submittedTransactions = 0;

  @override
  void onAuthorizeRequest(AuthorizeDappRequest request) {
    super.onAuthorizeRequest(request);
    request.completeWithDecline();
  }

  @override
  void onReauthorizeRequest(ReauthorizeDappRequest request) {
    super.onReauthorizeRequest(request);
    request.completeWithDecline();
  }

  @override
  void onSignTransactionsRequest(SignTransactionsRequest request) {
    super.onSignTransactionsRequest(request);
    request.completeWithDecline();
  }

  @override
  void onSignMessagesRequest(SignMessagesRequest request) {
    super.onSignMessagesRequest(request);
    request.completeWithDecline();
  }

  @override
  void onSignAndSendTransactionsRequest(
    SignAndSendTransactionsRequest request,
  ) {
    super.onSignAndSendTransactionsRequest(request);
    submittedTransactions += request.payloads.length;
    request.completeWithSignatures(['signed-transaction']);
  }

  @override
  void onDeauthorizedEvent(DeauthorizedEvent event) {
    super.onDeauthorizedEvent(event);
    event.complete();
  }
}

class _CapturingWalletHostApi extends MockWalletHostApi {
  Future<Object?> Function(MethodCall)? registeredHandler;

  @override
  void setMethodCallHandler(Future<Object?> Function(MethodCall)? handler) {
    registeredHandler = handler;
    super.setMethodCallHandler(handler);
  }
}

class _DelayedCreationWalletHostApi extends _CapturingWalletHostApi {
  final creationAllowed = Completer<void>();

  @override
  Future<String> createScenario({
    required String walletName,
    required String configJson,
  }) async {
    final sessionId = await super.createScenario(
      walletName: walletName,
      configJson: configJson,
    );
    await creationAllowed.future;
    return sessionId;
  }
}

void main() {
  test(
    'close during creation cannot leave a running native scenario',
    () async {
      final api = _DelayedCreationWalletHostApi();
      final scenario = WalletScenario(
        walletName: 'Closing Wallet',
        config: const MobileWalletAdapterConfig(),
        callbacks: _CompletingCallbacks(),
        walletApi: api,
      );

      final starting = scenario.start();
      await scenario.close();
      api.creationAllowed.complete();
      await starting;

      expect(scenario.isClosed, isTrue);
      expect(api.calls['startScenario'], isNull);
      expect(api.calls['closeScenario'], [
        {'sessionId': api.nextSessionId},
      ]);
      expect(api.registeredHandler, isNull);
    },
  );

  group('wallet session isolation', () {
    late _CapturingWalletHostApi api;
    late _CompletingCallbacks callbacks;
    late WalletScenario scenario;

    setUp(() async {
      api = _CapturingWalletHostApi();
      callbacks = _CompletingCallbacks();
      scenario = WalletScenario(
        walletName: 'Isolated Wallet',
        config: const MobileWalletAdapterConfig(),
        callbacks: callbacks,
        walletApi: api,
      );
      await scenario.start();
    });

    tearDown(() async {
      await scenario.close();
    });

    for (final method in [
      'onAuthorizeRequest',
      'onReauthorizeRequest',
      'onSignTransactionsRequest',
      'onSignMessagesRequest',
      'onSignAndSendTransactionsRequest',
      'onDeauthorizedEvent',
    ]) {
      for (final sessionId in <String?>['another-session', null]) {
        test('$method rejects session $sessionId before callbacks', () async {
          await api.simulateNativeCall(method, {
            'sessionId': sessionId,
            'requestId': 'foreign-request',
            'paramsJson': jsonEncode({
              'payloads': ['dHg='],
              'addresses': ['YWRkcmVzcw=='],
            }),
          });

          expect(callbacks.submittedTransactions, 0);
          expect(callbacks.events, isEmpty);
          expect(api.calls['resolveRequest'], isNull);
        });
      }
    }

    test(
      'foreign lifecycle events cannot affect the current session',
      () async {
        await api.simulateNativeCall('onScenarioError', {
          'sessionId': 'another-session',
          'error': 'foreign session failed',
        });

        expect(callbacks.events, isEmpty);
      },
    );

    test('queued callbacks cannot submit after the scenario closes', () async {
      final queuedHandler = api.registeredHandler!;
      await scenario.close();
      await queuedHandler(
        MethodCall('onSignAndSendTransactionsRequest', {
          'sessionId': scenario.sessionId,
          'requestId': 'queued-request',
          'paramsJson': jsonEncode({
            'payloads': ['dHg='],
          }),
        }),
      );

      expect(callbacks.submittedTransactions, 0);
      expect(callbacks.events, isEmpty);
      expect(api.calls['resolveRequest'], isNull);
    });

    test('a scenario cannot replace its active native session', () async {
      await expectLater(scenario.start(), throwsStateError);
      expect(api.calls['createScenario'], hasLength(1));
    });

    test('a closed scenario cannot start a new native session', () async {
      await scenario.close();
      await expectLater(scenario.start(), throwsStateError);
      expect(api.calls['createScenario'], hasLength(1));
    });

    test('matching session still invokes the signing callback', () async {
      await api.simulateNativeCall('onSignAndSendTransactionsRequest', {
        'requestId': 'matching-request',
        'paramsJson': jsonEncode({
          'payloads': ['dHg='],
        }),
      });

      expect(callbacks.submittedTransactions, 1);
      expect(api.calls['resolveRequest'], hasLength(1));
    });
  });
}
