import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  late Uint8List sharedSecret;

  setUp(() {
    // Derive a test shared secret via full handshake.
    final associationKeyPair = generateAssociationKeypair();
    final appEcdhKeyPair = generateEcdhKeypair();
    final walletEcdhKeyPair = generateEcdhKeypair();
    final walletPubKeyBytes = exportEcdhPublicKeyBytes(walletEcdhKeyPair);

    final result = parseHelloRsp(
      walletPubKeyBytes,
      associationKeyPair,
      appEcdhKeyPair,
    );
    sharedSecret = result.sharedSecret;
  });

  group('Session properties', () {
    test('parses v1 from integer 1', () {
      final encrypted = encryptMessage(json.encode({'v': 1}), 0, sharedSecret);

      final props = parseSessionProps(encrypted, sharedSecret);
      expect(props.protocolVersion, ProtocolVersion.v1);
    });

    test('parses v1 from string "v1"', () {
      final encrypted = encryptMessage(
        json.encode({'v': 'v1'}),
        0,
        sharedSecret,
      );

      final props = parseSessionProps(encrypted, sharedSecret);
      expect(props.protocolVersion, ProtocolVersion.v1);
    });

    test('parses v1 from string "1"', () {
      final encrypted = encryptMessage(
        json.encode({'v': '1'}),
        0,
        sharedSecret,
      );

      final props = parseSessionProps(encrypted, sharedSecret);
      expect(props.protocolVersion, ProtocolVersion.v1);
    });

    test('parses legacy from string "legacy"', () {
      final encrypted = encryptMessage(
        json.encode({'v': 'legacy'}),
        0,
        sharedSecret,
      );

      final props = parseSessionProps(encrypted, sharedSecret);
      expect(props.protocolVersion, ProtocolVersion.legacy);
    });

    test('defaults to legacy when v field is missing', () {
      final encrypted = encryptMessage(json.encode({}), 0, sharedSecret);

      final props = parseSessionProps(encrypted, sharedSecret);
      expect(props.protocolVersion, ProtocolVersion.legacy);
    });

    test('throws on unknown version', () {
      final encrypted = encryptMessage(
        json.encode({'v': 'v99'}),
        0,
        sharedSecret,
      );

      expect(
        () => parseSessionProps(encrypted, sharedSecret),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.mwaInvalidProtocolVersion,
          ),
        ),
      );
    });
  });

  group('JSON-RPC messages', () {
    test('encrypt and decrypt request round-trip', () {
      final encrypted = encryptJsonRpcRequest(1, 'authorize', {
        'chain': 'solana:mainnet',
      }, sharedSecret);

      final decrypted = decryptMessage(encrypted, sharedSecret);
      final parsed = json.decode(decrypted.plaintext) as Map<String, Object?>;

      expect(parsed['id'], 1);
      expect(parsed['jsonrpc'], '2.0');
      expect(parsed['method'], 'authorize');
      expect(
        (parsed['params']! as Map<String, Object?>)['chain'],
        'solana:mainnet',
      );
    });

    test('decryptJsonRpcResponse returns result', () {
      // Simulate a wallet response.
      final response = {
        'id': 1,
        'jsonrpc': '2.0',
        'result': {'auth_token': 'abc123', 'accounts': <Object?>[]},
      };
      final encrypted = encryptMessage(json.encode(response), 1, sharedSecret);

      final result = decryptJsonRpcResponse(encrypted, sharedSecret);
      expect(result['auth_token'], 'abc123');
    });

    test(
      'decryptJsonRpcResponse throws MwaProtocolError on error response',
      () {
        final errorResponse = {
          'id': 2,
          'jsonrpc': '2.0',
          'error': {
            'code': MwaProtocolErrorCode.authorizationFailed,
            'message': 'User declined',
          },
        };
        final encrypted = encryptMessage(
          json.encode(errorResponse),
          2,
          sharedSecret,
        );

        expect(
          () => decryptJsonRpcResponse(encrypted, sharedSecret),
          throwsA(
            isA<MwaProtocolError>()
                .having((e) => e.code, 'code', -1)
                .having((e) => e.message, 'message', 'User declined')
                .having((e) => e.jsonRpcMessageId, 'id', 2),
          ),
        );
      },
    );

    test('decryptJsonRpcResponse passes error data through', () {
      final errorResponse = {
        'id': 3,
        'jsonrpc': '2.0',
        'error': {
          'code': MwaProtocolErrorCode.attestOriginAndroid,
          'message': 'Attestation required',
          'data': {'attest_origin_uri': 'https://example.com'},
        },
      };
      final encrypted = encryptMessage(
        json.encode(errorResponse),
        3,
        sharedSecret,
      );

      try {
        decryptJsonRpcResponse(encrypted, sharedSecret);
        fail('Should have thrown');
      } on MwaProtocolError catch (e) {
        expect(e.code, MwaProtocolErrorCode.attestOriginAndroid);
        expect(e.data, isNotNull);
      }
    });
  });

  group('Association URIs', () {
    test('buildLocalAssociationUri creates correct format', () {
      final keyPair = generateAssociationKeypair();
      final uri = buildLocalAssociationUri(keyPair.publicKey, 50000);

      expect(uri.scheme, 'solana-wallet');
      expect(uri.path, contains('v1/associate/local'));
      expect(uri.queryParameters['association'], isNotEmpty);
      expect(uri.queryParameters['port'], '50000');
      expect(uri.queryParameters['v'], 'v1');
    });

    test('buildLocalAssociationUri rejects invalid port', () {
      final keyPair = generateAssociationKeypair();
      expect(
        () => buildLocalAssociationUri(keyPair.publicKey, 1234),
        throwsA(isA<SolanaError>()),
      );
    });

    test('buildLocalAssociationUri with custom base URI', () {
      final keyPair = generateAssociationKeypair();
      final uri = buildLocalAssociationUri(
        keyPair.publicKey,
        50000,
        baseUri: 'https://wallet.example.com',
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'wallet.example.com');
    });

    test('buildLocalAssociationUri rejects non-https base URI', () {
      final keyPair = generateAssociationKeypair();
      expect(
        () => buildLocalAssociationUri(
          keyPair.publicKey,
          50000,
          baseUri: 'http://wallet.example.com',
        ),
        throwsA(isA<SolanaError>()),
      );
    });

    test('buildRemoteAssociationUri creates correct format', () {
      final keyPair = generateAssociationKeypair();
      final uri = buildRemoteAssociationUri(
        keyPair.publicKey,
        'reflect.example.com',
        Uint8List.fromList([1, 2, 3]),
      );

      expect(uri.scheme, 'solana-wallet');
      expect(uri.path, contains('v1/associate/remote'));
      expect(uri.queryParameters['association'], isNotEmpty);
      expect(uri.queryParameters['reflector'], 'reflect.example.com');
      expect(uri.queryParameters['id'], isNotEmpty);
      expect(uri.queryParameters['v'], 'v1');
    });

    test('parseAssociationUri parses local URI', () {
      final keyPair = generateAssociationKeypair();
      final uri = buildLocalAssociationUri(keyPair.publicKey, 55000);
      final parsed = parseAssociationUri(uri);

      expect(parsed, isA<LocalAssociationParams>());
      final local = parsed as LocalAssociationParams;
      expect(local.port, 55000);
      expect(local.protocol, 'v1');
      expect(local.associationPublicKey, hasLength(65));
    });

    test('parseAssociationUri round-trips local URI', () {
      final keyPair = generateAssociationKeypair();
      final originalPubKeyBytes = exportPublicKeyBytes(keyPair.publicKey);

      final uri = buildLocalAssociationUri(keyPair.publicKey, 55000);
      final parsed = parseAssociationUri(uri) as LocalAssociationParams;

      expect(parsed.associationPublicKey, originalPubKeyBytes);
      expect(parsed.port, 55000);
    });
  });

  group('Wallet proxy', () {
    test('v1 proxy sends authorize with chain parameter', () async {
      String? capturedMethod;
      Map<String, Object?>? capturedParams;

      final wallet = createMobileWalletProxy((method, params) async {
        capturedMethod = method;
        capturedParams = params;
        return {'accounts': <Object?>[], 'auth_token': 'token'};
      }, const SessionProperties(protocolVersion: ProtocolVersion.v1));

      await wallet.authorize({
        'chain': 'solana:mainnet',
        'identity': {'name': 'Test'},
      });

      expect(capturedMethod, 'authorize');
      expect(capturedParams!['chain'], 'solana:mainnet');
    });

    test('legacy proxy converts chain to cluster', () async {
      Map<String, Object?>? capturedParams;

      final wallet = createMobileWalletProxy((method, params) async {
        capturedParams = params;
        return {'accounts': <Object?>[], 'auth_token': 'token'};
      }, const SessionProperties(protocolVersion: ProtocolVersion.legacy));

      await wallet.authorize({
        'chain': 'solana:mainnet',
        'identity': {'name': 'Test'},
      });

      expect(capturedParams!['cluster'], 'mainnet-beta');
    });

    test('legacy proxy sends reauthorize method', () async {
      String? capturedMethod;

      final wallet = createMobileWalletProxy((method, params) async {
        capturedMethod = method;
        return {'accounts': <Object?>[], 'auth_token': 'token'};
      }, const SessionProperties(protocolVersion: ProtocolVersion.legacy));

      await wallet.reauthorize({
        'auth_token': 'existing_token',
        'identity': {'name': 'Test'},
      });

      expect(capturedMethod, 'reauthorize');
    });

    test('v1 proxy sends authorize for reauthorize with auth_token', () async {
      String? capturedMethod;

      final wallet = createMobileWalletProxy((method, params) async {
        capturedMethod = method;
        return {'accounts': <Object?>[], 'auth_token': 'token'};
      }, const SessionProperties(protocolVersion: ProtocolVersion.v1));

      await wallet.reauthorize({
        'auth_token': 'existing_token',
        'identity': {'name': 'Test'},
      });

      expect(capturedMethod, 'authorize');
    });

    test('v1 getCapabilities adds legacy compatibility fields', () async {
      final wallet = createMobileWalletProxy((method, params) async {
        return {
          'max_transactions_per_request': 10,
          'features': ['solana:signTransactions', 'solana:cloneAuthorization'],
        };
      }, const SessionProperties(protocolVersion: ProtocolVersion.v1));

      final caps = await wallet.getCapabilities();
      expect(caps['supports_sign_and_send_transactions'], isTrue);
      expect(caps['supports_clone_authorization'], isTrue);
    });

    test('legacy getCapabilities converts to features array', () async {
      final wallet = createMobileWalletProxy((method, params) async {
        return {
          'max_transactions_per_request': 10,
          'supports_clone_authorization': true,
        };
      }, const SessionProperties(protocolVersion: ProtocolVersion.legacy));

      final caps = await wallet.getCapabilities();
      final features = (caps['features']! as List<Object?>).cast<String>();
      expect(features, contains('solana:signTransactions'));
      expect(features, contains('solana:cloneAuthorization'));
    });

    test('passthrough methods call correct RPC method', () async {
      String? capturedMethod;

      final wallet = createMobileWalletProxy((method, params) async {
        capturedMethod = method;
        return {};
      }, const SessionProperties(protocolVersion: ProtocolVersion.v1));

      await wallet.signTransactions({'payloads': []});
      expect(capturedMethod, 'sign_transactions');

      await wallet.signMessages({'addresses': [], 'payloads': []});
      expect(capturedMethod, 'sign_messages');

      await wallet.signAndSendTransactions({'payloads': []});
      expect(capturedMethod, 'sign_and_send_transactions');

      await wallet.deauthorize({'auth_token': 'tok'});
      expect(capturedMethod, 'deauthorize');

      await wallet.cloneAuthorization({});
      expect(capturedMethod, 'clone_authorization');
    });
  });

  group('SIWS message', () {
    test('creates message with domain and address', () {
      final message = createSiwsMessage(
        const SignInPayload(
          domain: 'example.com',
          address: '11111111111111111111111111111111',
        ),
      );

      expect(
        message,
        contains('example.com wants you to sign in with your Solana account:'),
      );
      expect(message, contains('11111111111111111111111111111111'));
    });

    test('includes statement when provided', () {
      final message = createSiwsMessage(
        const SignInPayload(
          domain: 'example.com',
          address: '11111111111111111111111111111111',
          statement: 'Sign in to access your account.',
        ),
      );

      expect(message, contains('Sign in to access your account.'));
    });

    test('includes all optional fields', () {
      final message = createSiwsMessage(
        const SignInPayload(
          domain: 'example.com',
          address: '11111111111111111111111111111111',
          uri: 'https://example.com',
          version: '1',
          chainId: 'mainnet',
          nonce: 'abc123',
          issuedAt: '2024-01-01T00:00:00Z',
          expirationTime: '2024-01-02T00:00:00Z',
          notBefore: '2024-01-01T00:00:00Z',
          requestId: 'req-123',
          resources: [
            'https://example.com/resource1',
            'https://example.com/resource2',
          ],
        ),
      );

      expect(message, contains('URI: https://example.com'));
      expect(message, contains('Version: 1'));
      expect(message, contains('Chain ID: mainnet'));
      expect(message, contains('Nonce: abc123'));
      expect(message, contains('Issued At: 2024-01-01T00:00:00Z'));
      expect(message, contains('Expiration Time: 2024-01-02T00:00:00Z'));
      expect(message, contains('Not Before: 2024-01-01T00:00:00Z'));
      expect(message, contains('Request ID: req-123'));
      expect(message, contains('Resources:'));
      expect(message, contains('- https://example.com/resource1'));
      expect(message, contains('- https://example.com/resource2'));
    });
  });
}
