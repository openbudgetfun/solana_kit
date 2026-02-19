import 'dart:typed_data';

import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('ProtocolVersion', () {
    test('has v1 and legacy values', () {
      expect(ProtocolVersion.values, hasLength(2));
      expect(ProtocolVersion.values, contains(ProtocolVersion.v1));
      expect(ProtocolVersion.values, contains(ProtocolVersion.legacy));
    });
  });

  group('AppIdentity', () {
    test('toJson includes only non-null fields', () {
      const identity = AppIdentity(name: 'Test App');
      expect(identity.toJson(), {'name': 'Test App'});
    });

    test('toJson includes all fields when set', () {
      final identity = AppIdentity(
        uri: Uri.parse('https://example.com'),
        icon: '/icon.png',
        name: 'Test App',
      );
      expect(identity.toJson(), {
        'uri': 'https://example.com',
        'icon': '/icon.png',
        'name': 'Test App',
      });
    });
  });

  group('MwaAccount', () {
    test('fromJson parses required fields', () {
      final account = MwaAccount.fromJson({'address': 'dGVzdA=='});
      expect(account.address, 'dGVzdA==');
      expect(account.label, isNull);
    });

    test('fromJson parses all fields', () {
      final account = MwaAccount.fromJson({
        'address': 'dGVzdA==',
        'display_address': '11111111111111111111111111111111',
        'label': 'My Wallet',
        'icon': 'https://example.com/icon.png',
        'chains': ['solana:mainnet'],
        'features': ['solana:signTransactions'],
      });
      expect(account.address, 'dGVzdA==');
      expect(account.displayAddress, '11111111111111111111111111111111');
      expect(account.label, 'My Wallet');
      expect(account.chains, ['solana:mainnet']);
      expect(account.features, ['solana:signTransactions']);
    });

    test('toJson round-trips', () {
      final json = {'address': 'dGVzdA==', 'label': 'My Wallet'};
      final account = MwaAccount.fromJson(json);
      final output = account.toJson();
      expect(output['address'], 'dGVzdA==');
      expect(output['label'], 'My Wallet');
    });
  });

  group('SignInResult', () {
    test('fromJson parses all fields', () {
      final result = SignInResult.fromJson({
        'address': 'dGVzdA==',
        'signed_message': 'c2lnbmVk',
        'signature': 'c2ln',
        'signature_type': 'ed25519',
      });
      expect(result.address, 'dGVzdA==');
      expect(result.signedMessage, 'c2lnbmVk');
      expect(result.signature, 'c2ln');
      expect(result.signatureType, 'ed25519');
    });
  });

  group('AuthorizationResult', () {
    test('fromJson parses accounts and auth token', () {
      final result = AuthorizationResult.fromJson({
        'accounts': [
          {'address': 'dGVzdA=='},
        ],
        'auth_token': 'token123',
      });
      expect(result.accounts, hasLength(1));
      expect(result.accounts.first.address, 'dGVzdA==');
      expect(result.authToken, 'token123');
      expect(result.walletUriBase, isNull);
      expect(result.signInResult, isNull);
    });

    test('fromJson parses sign in result', () {
      final result = AuthorizationResult.fromJson({
        'accounts': [
          {'address': 'dGVzdA=='},
        ],
        'auth_token': 'token123',
        'wallet_uri_base': 'https://wallet.example.com',
        'sign_in_result': {
          'address': 'dGVzdA==',
          'signed_message': 'c2lnbmVk',
          'signature': 'c2ln',
        },
      });
      expect(result.walletUriBase, 'https://wallet.example.com');
      expect(result.signInResult, isNotNull);
      expect(result.signInResult!.address, 'dGVzdA==');
    });
  });

  group('SignInPayload', () {
    test('toJson includes only non-null fields', () {
      const payload = SignInPayload(domain: 'example.com', nonce: 'abc123');
      final json = payload.toJson();
      expect(json, {'domain': 'example.com', 'nonce': 'abc123'});
      expect(json.containsKey('address'), isFalse);
    });
  });

  group('WalletCapabilities', () {
    test('fromJson parses capabilities', () {
      final caps = WalletCapabilities.fromJson({
        'max_transactions_per_request': 10,
        'max_messages_per_request': 5,
        'supported_transaction_versions': ['legacy', 0],
        'features': ['solana:signTransactions'],
      });
      expect(caps.maxTransactionsPerRequest, 10);
      expect(caps.maxMessagesPerRequest, 5);
      expect(caps.supportedTransactionVersions, ['legacy', 0]);
      expect(caps.features, ['solana:signTransactions']);
    });
  });

  group('AssociationParams', () {
    test('LocalAssociationParams is a subtype', () {
      final params = LocalAssociationParams(
        associationPublicKey: Uint8List(65),
        protocol: 'v1',
        port: 50000,
      );
      expect(params, isA<AssociationParams>());
      expect(params.port, 50000);
    });

    test('RemoteAssociationParams is a subtype', () {
      final params = RemoteAssociationParams(
        associationPublicKey: Uint8List(65),
        protocol: 'v1',
        reflectorHost: 'reflect.example.com',
        reflectorId: 12345,
      );
      expect(params, isA<AssociationParams>());
      expect(params.reflectorHost, 'reflect.example.com');
      expect(params.reflectorId, 12345);
    });
  });
}
