import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_request_types.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

void main() {
  group('AuthorizeDappRequest', () {
    test('fromParams parses identity', () {
      final request = AuthorizeDappRequest.fromParams(
        requestId: 'req-1',
        sessionId: 'sess-1',
        params: {
          'identity': {
            'name': 'Test dApp',
            'uri': 'https://example.com',
            'icon': '/icon.png',
          },
          'chain': 'solana:mainnet',
          'features': ['solana:signTransactions'],
          'addresses': ['addr1'],
        },
      );

      expect(request.requestId, 'req-1');
      expect(request.sessionId, 'sess-1');
      expect(request.identityName, 'Test dApp');
      expect(request.identityUri, 'https://example.com');
      expect(request.iconRelativeUri, '/icon.png');
      expect(request.chain, 'solana:mainnet');
      expect(request.features, ['solana:signTransactions']);
      expect(request.addresses, ['addr1']);
      expect(request.signInPayload, isNull);
    });

    test('fromParams handles null identity', () {
      final request = AuthorizeDappRequest.fromParams(
        requestId: 'req-2',
        sessionId: 'sess-1',
        params: {'chain': 'solana:devnet'},
      );

      expect(request.identityName, isNull);
      expect(request.identityUri, isNull);
      expect(request.chain, 'solana:devnet');
    });

    test('completeWithAuthorize resolves future', () async {
      final request = AuthorizeDappRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
      )..completeWithAuthorize(
          accounts: [
            const AuthorizedAccount(
              address: 'dGVzdA==',
              label: 'Test Account',
            ),
          ],
          authToken: 'token123',
        );

      final result = await request.future;
      expect(result['auth_token'], 'token123');
      final accounts = result['accounts']! as List<Object?>;
      expect(accounts, hasLength(1));
    });

    test('completeWithDecline produces error', () async {
      final request = AuthorizeDappRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
      )..completeWithDecline();

      expect(
        request.future,
        throwsA(isA<WalletRequestError>().having(
          (e) => e.code,
          'code',
          MwaProtocolErrorCode.authorizationFailed,
        )),
      );
    });

    test('completeWithClusterNotSupported produces error', () async {
      final request = AuthorizeDappRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
      )..completeWithClusterNotSupported();

      expect(
        request.future,
        throwsA(isA<WalletRequestError>()),
      );
    });

    test('cannot complete twice', () async {
      final request = AuthorizeDappRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
      )
        ..completeWithAuthorize(
          accounts: [const AuthorizedAccount(address: 'dGVzdA==')],
          authToken: 'first',
        )
        // Second complete should be a no-op.
        ..completeWithDecline();

      final result = await request.future;
      expect(result['auth_token'], 'first');
    });
  });

  group('AuthorizedAccount', () {
    test('toJson includes only non-null fields', () {
      const account = AuthorizedAccount(
        address: 'dGVzdA==',
        label: 'Test',
      );

      final json = account.toJson();
      expect(json['address'], 'dGVzdA==');
      expect(json['label'], 'Test');
      expect(json.containsKey('display_address'), isFalse);
      expect(json.containsKey('chains'), isFalse);
    });

    test('toJson includes all fields', () {
      const account = AuthorizedAccount(
        address: 'dGVzdA==',
        displayAddress: 'Test1...xyz',
        displayAddressFormat: 'base58',
        label: 'My Account',
        icon: 'data:image/png;base64,...',
        chains: ['solana:mainnet'],
        features: ['solana:signTransactions'],
      );

      final json = account.toJson();
      expect(json['display_address'], 'Test1...xyz');
      expect(json['display_address_format'], 'base58');
      expect(json['icon'], 'data:image/png;base64,...');
      expect(json['chains'], ['solana:mainnet']);
      expect(json['features'], ['solana:signTransactions']);
    });
  });

  group('ReauthorizeDappRequest', () {
    test('completeWithReauthorize resolves future', () async {
      final request = ReauthorizeDappRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        authorizationScope: 'old-token',
      )..completeWithReauthorize(
          accounts: [const AuthorizedAccount(address: 'dGVzdA==')],
          authToken: 'new-token',
        );

      final result = await request.future;
      expect(result['auth_token'], 'new-token');
    });

    test('completeWithDecline produces error', () async {
      final request = ReauthorizeDappRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        authorizationScope: 'token',
      )..completeWithDecline();

      expect(
        request.future,
        throwsA(isA<WalletRequestError>()),
      );
    });
  });

  group('DeauthorizedEvent', () {
    test('complete resolves with empty map', () async {
      final event = DeauthorizedEvent(
        requestId: 'req-1',
        sessionId: 'sess-1',
        authorizationScope: 'token',
      )..complete();

      final result = await event.future;
      expect(result, isEmpty);
    });
  });

  group('SignTransactionsRequest', () {
    test('fromParams parses payloads', () {
      final request = SignTransactionsRequest.fromParams(
        requestId: 'req-1',
        sessionId: 'sess-1',
        params: {
          'payloads': ['dHgx', 'dHgy'],
          'chain': 'solana:mainnet',
          'auth_token': 'token',
        },
      );

      expect(request.payloads, ['dHgx', 'dHgy']);
      expect(request.chain, 'solana:mainnet');
      expect(request.authorizationScope, 'token');
    });

    test('completeWithSignedPayloads resolves', () async {
      final request = SignTransactionsRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['dHgx'],
      )..completeWithSignedPayloads(['c2lnbmVk']);

      final result = await request.future;
      expect(result['signed_payloads'], ['c2lnbmVk']);
    });

    test('completeWithDecline produces error', () async {
      final request = SignTransactionsRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['dHgx'],
      )..completeWithDecline();

      expect(
        request.future,
        throwsA(isA<WalletRequestError>().having(
          (e) => e.code,
          'code',
          MwaProtocolErrorCode.notSigned,
        )),
      );
    });

    test('completeWithInvalidPayloads includes valid list', () async {
      final request = SignTransactionsRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['dHgx', 'dHgy'],
      )..completeWithInvalidPayloads([true, false]);

      expect(
        request.future,
        throwsA(isA<WalletRequestError>().having(
          (e) => e.code,
          'code',
          MwaProtocolErrorCode.invalidPayloads,
        )),
      );
    });

    test('completeWithTooManyPayloads', () async {
      final request = SignTransactionsRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['dHgx'],
      )..completeWithTooManyPayloads();

      expect(
        request.future,
        throwsA(isA<WalletRequestError>().having(
          (e) => e.code,
          'code',
          MwaProtocolErrorCode.tooManyPayloads,
        )),
      );
    });

    test('completeWithAuthorizationNotValid', () async {
      final request = SignTransactionsRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['dHgx'],
      )..completeWithAuthorizationNotValid();

      expect(
        request.future,
        throwsA(isA<WalletRequestError>().having(
          (e) => e.code,
          'code',
          MwaProtocolErrorCode.authorizationFailed,
        )),
      );
    });
  });

  group('SignMessagesRequest', () {
    test('fromParams parses payloads and addresses', () {
      final request = SignMessagesRequest.fromParams(
        requestId: 'req-1',
        sessionId: 'sess-1',
        params: {
          'payloads': ['bXNn'],
          'addresses': ['addr1'],
          'chain': 'solana:devnet',
        },
      );

      expect(request.payloads, ['bXNn']);
      expect(request.addresses, ['addr1']);
      expect(request.chain, 'solana:devnet');
    });

    test('completeWithSignedPayloads resolves', () async {
      final request = SignMessagesRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['bXNn'],
        addresses: ['addr1'],
      )..completeWithSignedPayloads(['c2lnbmVk']);

      final result = await request.future;
      expect(result['signed_payloads'], ['c2lnbmVk']);
    });
  });

  group('SignAndSendTransactionsRequest', () {
    test('fromParams parses options', () {
      final request = SignAndSendTransactionsRequest.fromParams(
        requestId: 'req-1',
        sessionId: 'sess-1',
        params: {
          'payloads': ['dHgx'],
          'chain': 'solana:mainnet',
          'auth_token': 'token',
          'options': {
            'min_context_slot': 42,
            'commitment': 'confirmed',
            'skip_preflight': true,
            'max_retries': 3,
            'wait_for_commitment_to_send_next_transaction': false,
          },
        },
      );

      expect(request.payloads, ['dHgx']);
      expect(request.minContextSlot, 42);
      expect(request.commitment, 'confirmed');
      expect(request.skipPreflight, isTrue);
      expect(request.maxRetries, 3);
      expect(request.waitForCommitmentToSendNextTransaction, isFalse);
    });

    test('fromParams handles missing options', () {
      final request = SignAndSendTransactionsRequest.fromParams(
        requestId: 'req-1',
        sessionId: 'sess-1',
        params: {
          'payloads': ['dHgx'],
        },
      );

      expect(request.minContextSlot, isNull);
      expect(request.commitment, isNull);
    });

    test('completeWithSignatures resolves', () async {
      final request = SignAndSendTransactionsRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['dHgx'],
      )..completeWithSignatures(['sig1', 'sig2']);

      final result = await request.future;
      expect(result['signatures'], ['sig1', 'sig2']);
    });

    test('completeWithNotSubmitted includes partial signatures', () async {
      final request = SignAndSendTransactionsRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['dHgx', 'dHgy'],
      )..completeWithNotSubmitted(['sig1', null]);

      expect(
        request.future,
        throwsA(isA<WalletRequestError>().having(
          (e) => e.code,
          'code',
          MwaProtocolErrorCode.notSubmitted,
        )),
      );
    });
  });

  group('WalletRequest.cancel', () {
    test('cancel produces error', () async {
      final request = SignTransactionsRequest(
        requestId: 'req-1',
        sessionId: 'sess-1',
        payloads: ['dHgx'],
      )..cancel();

      expect(
        request.future,
        throwsA(isA<WalletRequestError>()),
      );
    });
  });
}
