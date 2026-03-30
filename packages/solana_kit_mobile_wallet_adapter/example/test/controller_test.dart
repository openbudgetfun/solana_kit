import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_mobile_wallet_adapter_example/main.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

void main() {
  group('MwaExampleController', () {
    test('tracks unsupported platforms without hitting wallet session flows', () async {
      final controller = MwaExampleController(
        platformService: const _FakePlatformSupportService(
          isSupported: false,
          walletEndpointAvailable: false,
        ),
        sessionService: _FakeSessionService(),
      );

      await controller.initialize();

      expect(controller.isSupported, isFalse);
      expect(controller.walletEndpointAvailable, isFalse);
      expect(controller.logs.first, contains('unavailable on this platform'));
    });

    test('drives authorize, capabilities, sign, send, and deauthorize flows', () async {
      final sessionService = _FakeSessionService();
      final controller = MwaExampleController(
        platformService: const _FakePlatformSupportService(
          isSupported: true,
          walletEndpointAvailable: true,
        ),
        sessionService: sessionService,
        initialTransactionDraft: 'dGVzdC10cmFuc2FjdGlvbg==',
      );

      await controller.initialize();
      expect(controller.walletEndpointAvailable, isTrue);

      await controller.authorize();
      expect(controller.hasAuthorization, isTrue);
      expect(controller.activeAccountLabel, 'Demo Wallet Account');

      await controller.loadCapabilities();
      expect(
        controller.capabilities?.features,
        containsAll(<String>[
          'solana:signMessages',
          'solana:signAndSendTransactions',
        ]),
      );

      controller.setMessageDraft('Hello integration test');
      await controller.signMessage();
      expect(controller.lastSignedPayload, sessionService.signedPayload);

      await controller.signAndSendTransaction();
      expect(controller.lastSubmittedSignatures, const <String>['demo-signature-1']);

      await controller.deauthorize();
      expect(controller.hasAuthorization, isFalse);
      expect(sessionService.deauthorizedAuthTokens, contains('auth-token-1'));
      expect(controller.logs.first, contains('Deauthorize succeeded.'));
    });
  });
}

class _FakePlatformSupportService implements MwaPlatformSupportService {
  const _FakePlatformSupportService({
    required this.isSupported,
    required this.walletEndpointAvailable,
  });

  @override
  final bool isSupported;

  final bool walletEndpointAvailable;

  @override
  Future<bool> isWalletEndpointAvailable() async => walletEndpointAvailable;
}

class _FakeSessionService implements MwaSessionService {
  static const AuthorizationResult authorization = AuthorizationResult(
    accounts: <MwaAccount>[
      MwaAccount(
        address: 'ZGVtby1hZGRyZXNz',
        displayAddress: 'Demo Wallet Account',
      ),
    ],
    authToken: 'auth-token-1',
  );

  final List<String> deauthorizedAuthTokens = <String>[];

  String get signedPayload => base64Encode(utf8.encode('signed-message'));

  @override
  Future<AuthorizationResult> authorize() async => authorization;

  @override
  Future<void> deauthorize(String authToken) async {
    deauthorizedAuthTokens.add(authToken);
  }

  @override
  Future<(AuthorizationResult, WalletCapabilities)> loadCapabilities(
    String authToken,
  ) async {
    return (
      authorization,
      const WalletCapabilities(
        maxTransactionsPerRequest: 1,
        maxMessagesPerRequest: 1,
        features: <String>[
          'solana:signMessages',
          'solana:signAndSendTransactions',
        ],
      ),
    );
  }

  @override
  Future<(AuthorizationResult, List<String>)> signAndSendTransactions({
    required String authToken,
    required List<String> payloads,
  }) async {
    return (authorization, const <String>['demo-signature-1']);
  }

  @override
  Future<(AuthorizationResult, List<String>)> signMessage({
    required String authToken,
    required String message,
  }) async {
    return (authorization, <String>[signedPayload]);
  }
}
