import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/kit_mobile_wallet.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

/// A mock [MobileWallet] for testing the Kit wrapper.
class MockMobileWallet implements MobileWallet {
  String? lastMethod;
  Map<String, Object?>? lastParams;
  Map<String, Object?> nextResult = {};

  @override
  Future<Map<String, Object?>> authorize(Map<String, Object?> params) async {
    lastMethod = 'authorize';
    lastParams = params;
    return nextResult;
  }

  @override
  Future<Map<String, Object?>> reauthorize(Map<String, Object?> params) async {
    lastMethod = 'reauthorize';
    lastParams = params;
    return nextResult;
  }

  @override
  Future<Map<String, Object?>> deauthorize(Map<String, Object?> params) async {
    lastMethod = 'deauthorize';
    lastParams = params;
    return nextResult;
  }

  @override
  Future<Map<String, Object?>> getCapabilities() async {
    lastMethod = 'getCapabilities';
    return nextResult;
  }

  @override
  Future<Map<String, Object?>> signTransactions(
    Map<String, Object?> params,
  ) async {
    lastMethod = 'signTransactions';
    lastParams = params;
    return nextResult;
  }

  @override
  Future<Map<String, Object?>> signMessages(
    Map<String, Object?> params,
  ) async {
    lastMethod = 'signMessages';
    lastParams = params;
    return nextResult;
  }

  @override
  Future<Map<String, Object?>> signAndSendTransactions(
    Map<String, Object?> params,
  ) async {
    lastMethod = 'signAndSendTransactions';
    lastParams = params;
    return nextResult;
  }

  @override
  Future<Map<String, Object?>> cloneAuthorization(
    Map<String, Object?> params,
  ) async {
    lastMethod = 'cloneAuthorization';
    lastParams = params;
    return nextResult;
  }
}

void main() {
  group('KitMobileWallet', () {
    late MockMobileWallet mockWallet;
    late KitMobileWallet kitWallet;

    setUp(() {
      mockWallet = MockMobileWallet();
      kitWallet = wrapWithKitApi(mockWallet);
    });

    test('authorize passes identity and chain', () async {
      mockWallet.nextResult = {
        'accounts': [
          {'address': 'dGVzdA=='},
        ],
        'auth_token': 'token123',
      };

      final result = await kitWallet.authorize(
        identity: const AppIdentity(name: 'Test App'),
        chain: 'solana:mainnet',
      );

      expect(mockWallet.lastMethod, 'authorize');
      expect(
        (mockWallet.lastParams!['identity']! as Map)['name'],
        'Test App',
      );
      expect(mockWallet.lastParams!['chain'], 'solana:mainnet');
      expect(result.authToken, 'token123');
      expect(result.accounts, hasLength(1));
    });

    test('reauthorize passes auth token', () async {
      mockWallet.nextResult = {
        'accounts': [
          {'address': 'dGVzdA=='},
        ],
        'auth_token': 'newToken',
      };

      final result = await kitWallet.reauthorize(authToken: 'oldToken');

      expect(mockWallet.lastMethod, 'reauthorize');
      expect(mockWallet.lastParams!['auth_token'], 'oldToken');
      expect(result.authToken, 'newToken');
    });

    test('deauthorize passes auth token', () async {
      mockWallet.nextResult = {};

      await kitWallet.deauthorize(authToken: 'token');

      expect(mockWallet.lastMethod, 'deauthorize');
      expect(mockWallet.lastParams!['auth_token'], 'token');
    });

    test('getCapabilities returns parsed capabilities', () async {
      mockWallet.nextResult = {
        'max_transactions_per_request': 10,
        'max_messages_per_request': 5,
        'features': ['solana:signTransactions'],
      };

      final caps = await kitWallet.getCapabilities();

      expect(caps.maxTransactionsPerRequest, 10);
      expect(caps.maxMessagesPerRequest, 5);
      expect(caps.features, contains('solana:signTransactions'));
    });

    test('signTransactions returns signed payloads', () async {
      mockWallet.nextResult = {
        'signed_payloads': ['c2lnbmVk', 'c2lnbmVkMg=='],
      };

      final result = await kitWallet.signTransactions(
        payloads: ['dHgx', 'dHgy'],
      );

      expect(mockWallet.lastMethod, 'signTransactions');
      expect(result, hasLength(2));
      expect(result[0], 'c2lnbmVk');
    });

    test('signMessages returns signed payloads', () async {
      mockWallet.nextResult = {
        'signed_payloads': ['c2lnbmVk'],
      };

      final result = await kitWallet.signMessages(
        addresses: ['addr1'],
        payloads: ['bXNn'],
      );

      expect(mockWallet.lastMethod, 'signMessages');
      expect(result, hasLength(1));
    });

    test('signAndSendTransactions returns signatures', () async {
      mockWallet.nextResult = {
        'signatures': ['c2ln1', 'c2ln2'],
      };

      final result = await kitWallet.signAndSendTransactions(
        payloads: ['dHgx', 'dHgy'],
        options: const SignAndSendOptions(
          commitment: 'confirmed',
          skipPreflight: true,
        ),
      );

      expect(mockWallet.lastMethod, 'signAndSendTransactions');
      final params = mockWallet.lastParams!;
      final options = params['options']! as Map<String, Object?>;
      expect(options['commitment'], 'confirmed');
      expect(options['skip_preflight'], isTrue);
      expect(result, hasLength(2));
    });

    test('cloneAuthorization returns authorization result', () async {
      mockWallet.nextResult = {
        'accounts': [
          {'address': 'dGVzdA=='},
        ],
        'auth_token': 'clonedToken',
      };

      final result = await kitWallet.cloneAuthorization();

      expect(mockWallet.lastMethod, 'cloneAuthorization');
      expect(result.authToken, 'clonedToken');
    });
  });
}
