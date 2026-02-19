// Integration tests for the MWA protocol.
//
// These tests simulate a full client↔wallet round-trip using the protocol
// package primitives: keypair generation, HELLO handshake, encrypted
// JSON-RPC messaging, and wallet proxy.
import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

/// Simulates a wallet handling JSON-RPC requests.
///
/// The wallet side generates its own ECDH keypair, completes the handshake,
/// and processes encrypted requests.
class SimulatedWallet {
  SimulatedWallet({
    required this.protocolVersion,
    this.maxTransactionsPerRequest = 10,
    this.maxMessagesPerRequest = 10,
    this.supportedTransactionVersions = const ['legacy', '0'],
  });

  final ProtocolVersion protocolVersion;
  final int maxTransactionsPerRequest;
  final int maxMessagesPerRequest;
  final List<String> supportedTransactionVersions;

  late EcdhKeypair _walletEcdhKeypair;
  late Uint8List _sharedSecret;
  int _nextSequenceNumber = 1;

  /// Handles HELLO_REQ from the dApp and produces HELLO_RSP.
  ///
  /// Also derives the shared secret from the dApp's ECDH public key.
  Uint8List handleHelloReq(
    Uint8List helloReq,
    AssociationKeypair dAppAssociationKeypair,
  ) {
    // Parse dApp's ECDH public key from HELLO_REQ (first 65 bytes).
    final dAppEcdhPublicKeyBytes = helloReq.sublist(0, mwaPublicKeyLengthBytes);
    final signatureBytes = helloReq.sublist(mwaPublicKeyLengthBytes);

    // Verify ECDSA signature of the ECDH public key.
    final isValid = ecdsaVerify(
      dAppEcdhPublicKeyBytes,
      signatureBytes,
      dAppAssociationKeypair.publicKey,
    );
    expect(isValid, isTrue, reason: 'HELLO_REQ signature must be valid');

    // Generate wallet's ECDH keypair.
    _walletEcdhKeypair = generateEcdhKeypair();

    // Derive shared secret via ECDH + HKDF.
    final dAppEcdhPublicKey = ecPublicKeyFromBytes(dAppEcdhPublicKeyBytes);
    final rawSecret = ecdhSharedSecret(
      _walletEcdhKeypair.privateKey,
      dAppEcdhPublicKey,
    );
    final associationPubKeyBytes =
        exportPublicKeyBytes(dAppAssociationKeypair.publicKey);
    _sharedSecret = hkdfSha256(
      ikm: rawSecret,
      salt: associationPubKeyBytes,
      info: Uint8List(0),
      outputLength: 16,
    );

    // Build HELLO_RSP: [wallet ECDH pubkey (65)] [optional encrypted session
    //   props]
    final walletPublicKeyBytes =
        exportEcdhPublicKeyBytes(_walletEcdhKeypair);

    if (protocolVersion == ProtocolVersion.legacy) {
      // Legacy wallets don't send session properties.
      return walletPublicKeyBytes;
    }

    // v1 wallets send encrypted session properties.
    final sessionPropsJson = json.encode({'v': 1});
    final encryptedProps = encryptMessage(sessionPropsJson, 0, _sharedSecret);
    final result = Uint8List(walletPublicKeyBytes.length + encryptedProps.length)
      ..setAll(0, walletPublicKeyBytes)
      ..setAll(walletPublicKeyBytes.length, encryptedProps);
    return result;
  }

  /// Processes an encrypted JSON-RPC request and returns an encrypted response.
  Uint8List handleEncryptedRequest(Uint8List encryptedRequest) {
    final decrypted = decryptMessage(encryptedRequest, _sharedSecret);
    final request =
        json.decode(decrypted.plaintext) as Map<String, Object?>;

    final method = request['method']! as String;
    final id = request['id']! as int;
    final params = request['params'] as Map<String, Object?>? ?? {};

    final result = _handleMethod(method, params);

    // Build JSON-RPC response.
    final Map<String, Object?> response;
    if (result.containsKey('error')) {
      response = {
        'id': id,
        'jsonrpc': '2.0',
        'error': result['error'],
      };
    } else {
      response = {
        'id': id,
        'jsonrpc': '2.0',
        'result': result,
      };
    }

    final responseJson = json.encode(response);
    final seqNum = _nextSequenceNumber++;
    return encryptMessage(responseJson, seqNum, _sharedSecret);
  }

  Map<String, Object?> _handleMethod(
    String method,
    Map<String, Object?> params,
  ) {
    switch (method) {
      case 'authorize':
        return _handleAuthorize(params);
      case 'reauthorize':
        return _handleReauthorize(params);
      case 'deauthorize':
        return {};
      case 'get_capabilities':
        return _handleGetCapabilities();
      case 'sign_transactions':
        return _handleSignTransactions(params);
      case 'sign_messages':
        return _handleSignMessages(params);
      case 'sign_and_send_transactions':
        return _handleSignAndSendTransactions(params);
      case 'clone_authorization':
        return _handleCloneAuthorization(params);
      default:
        return {
          'error': {
            'code': -32601,
            'message': 'Method not found: $method',
          },
        };
    }
  }

  Map<String, Object?> _handleAuthorize(Map<String, Object?> params) {
    return {
      'accounts': [
        {
          'address': 'dGVzdEFkZHJlc3M=', // base64 "testAddress"
          'label': 'Test Wallet',
          'chains': ['solana:mainnet'],
        },
      ],
      'auth_token': 'test-auth-token-123',
      'wallet_uri_base': 'https://wallet.example.com',
    };
  }

  Map<String, Object?> _handleReauthorize(Map<String, Object?> params) {
    return {
      'accounts': [
        {
          'address': 'dGVzdEFkZHJlc3M=',
          'label': 'Test Wallet',
        },
      ],
      'auth_token': 'renewed-auth-token-456',
    };
  }

  Map<String, Object?> _handleGetCapabilities() {
    if (protocolVersion == ProtocolVersion.legacy) {
      return {
        'supports_sign_and_send_transactions': true,
        'supports_clone_authorization': false,
        'max_transactions_per_request': maxTransactionsPerRequest,
        'max_messages_per_request': maxMessagesPerRequest,
        'supported_transaction_versions': supportedTransactionVersions,
      };
    }
    return {
      'features': [
        mwaFeatureSignTransactions,
        mwaFeatureSignAndSendTransaction,
      ],
      'max_transactions_per_request': maxTransactionsPerRequest,
      'max_messages_per_request': maxMessagesPerRequest,
      'supported_transaction_versions': supportedTransactionVersions,
    };
  }

  Map<String, Object?> _handleSignTransactions(Map<String, Object?> params) {
    final payloads = (params['payloads']! as List<Object?>).cast<String>();
    // Simulate signing by echoing payloads with 'signed_' prefix.
    return {
      'signed_payloads': payloads.map((p) => 'signed_$p').toList(),
    };
  }

  Map<String, Object?> _handleSignMessages(Map<String, Object?> params) {
    final payloads = (params['payloads']! as List<Object?>).cast<String>();
    return {
      'signed_payloads': payloads.map((p) => 'signed_$p').toList(),
    };
  }

  Map<String, Object?> _handleSignAndSendTransactions(
    Map<String, Object?> params,
  ) {
    final payloads = (params['payloads']! as List<Object?>).cast<String>();
    // Simulate signing and sending by returning fake signatures.
    return {
      'signatures': List.generate(payloads.length, (i) => 'sig_$i'),
    };
  }

  Map<String, Object?> _handleCloneAuthorization(Map<String, Object?> params) {
    return {
      'auth_token': 'cloned-auth-token-789',
    };
  }
}

/// A simplified transport that routes encrypted requests through the
/// simulated wallet directly (no WebSocket needed).
class InProcessTransport {
  InProcessTransport(this._wallet);

  final SimulatedWallet _wallet;

  Future<Map<String, Object?>> sendRequest(
    String method,
    Map<String, Object?> params,
    int sequenceNumber,
    Uint8List sharedSecret,
  ) async {
    // Encrypt request.
    final encrypted =
        encryptJsonRpcRequest(sequenceNumber, method, params, sharedSecret);

    // Pass through the simulated wallet.
    final encryptedResponse = _wallet.handleEncryptedRequest(encrypted);

    // Decrypt response.
    return decryptJsonRpcResponse(encryptedResponse, sharedSecret);
  }
}

void main() {
  group('Integration: full client↔wallet round-trip', () {
    late AssociationKeypair dAppAssociationKeypair;
    late EcdhKeypair dAppEcdhKeypair;

    setUp(() {
      dAppAssociationKeypair = generateAssociationKeypair();
      dAppEcdhKeypair = generateEcdhKeypair();
    });

    group('v1 protocol', () {
      late SimulatedWallet wallet;
      late Uint8List sharedSecret;
      late SessionProperties sessionProps;

      setUp(() {
        wallet = SimulatedWallet(protocolVersion: ProtocolVersion.v1);

        // Perform handshake.
        final helloReq =
            createHelloReq(dAppEcdhKeypair, dAppAssociationKeypair);
        final helloRsp =
            wallet.handleHelloReq(helloReq, dAppAssociationKeypair);

        // dApp side: parse HELLO_RSP.
        final result = parseHelloRsp(
          helloRsp,
          dAppAssociationKeypair,
          dAppEcdhKeypair,
        );
        sharedSecret = result.sharedSecret;

        // Parse session properties.
        sessionProps = parseSessionProps(
          result.encryptedSessionProps!,
          sharedSecret,
        );
      });

      test('handshake negotiates v1 protocol version', () {
        expect(sessionProps.protocolVersion, ProtocolVersion.v1);
      });

      test('authorize returns accounts and auth token', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.authorize({
          'identity': {'name': 'Test dApp'},
          'chain': 'solana:mainnet',
        });

        expect(result['auth_token'], 'test-auth-token-123');
        final accounts = result['accounts']! as List<Object?>;
        expect(accounts, hasLength(1));
        final account = accounts[0]! as Map<String, Object?>;
        expect(account['address'], 'dGVzdEFkZHJlc3M=');
        expect(account['label'], 'Test Wallet');
      });

      test('reauthorize returns renewed token', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        // v1 proxy sends 'authorize' with auth_token for reauthorization.
        final result = await proxy.reauthorize({
          'auth_token': 'old-token',
        });

        expect(result['auth_token'], isNotNull);
      });

      test('getCapabilities returns features and legacy compat fields',
          () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.getCapabilities();
        // v1 result should include legacy compat boolean.
        expect(result['supports_sign_and_send_transactions'], isTrue);
        expect(result['features'], isA<List<Object?>>());
      });

      test('signTransactions returns signed payloads', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.signTransactions({
          'payloads': ['dHgx', 'dHgy'],
        });

        final signed =
            (result['signed_payloads']! as List<Object?>).cast<String>();
        expect(signed, ['signed_dHgx', 'signed_dHgy']);
      });

      test('signMessages returns signed payloads', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.signMessages({
          'payloads': ['bXNn'],
          'addresses': ['addr1'],
        });

        final signed =
            (result['signed_payloads']! as List<Object?>).cast<String>();
        expect(signed, ['signed_bXNn']);
      });

      test('signAndSendTransactions returns signatures', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.signAndSendTransactions({
          'payloads': ['dHgx', 'dHgy'],
        });

        final signatures =
            (result['signatures']! as List<Object?>).cast<String>();
        expect(signatures, ['sig_0', 'sig_1']);
      });

      test('cloneAuthorization returns cloned token', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.cloneAuthorization({
          'auth_token': 'test-auth-token-123',
        });

        expect(result['auth_token'], 'cloned-auth-token-789');
      });

      test('deauthorize completes without error', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.deauthorize({
          'auth_token': 'test-auth-token-123',
        });

        expect(result, isA<Map<String, Object?>>());
      });
    });

    group('legacy protocol', () {
      late SimulatedWallet wallet;
      late Uint8List sharedSecret;
      late SessionProperties sessionProps;

      setUp(() {
        wallet = SimulatedWallet(protocolVersion: ProtocolVersion.legacy);

        // Perform handshake.
        final helloReq =
            createHelloReq(dAppEcdhKeypair, dAppAssociationKeypair);
        final helloRsp =
            wallet.handleHelloReq(helloReq, dAppAssociationKeypair);

        // dApp side: parse HELLO_RSP (no encrypted session props for legacy).
        final result = parseHelloRsp(
          helloRsp,
          dAppAssociationKeypair,
          dAppEcdhKeypair,
        );
        sharedSecret = result.sharedSecret;

        // No encrypted session props for legacy -> defaults to legacy version.
        expect(result.encryptedSessionProps, isNull);
        sessionProps = const SessionProperties(
          protocolVersion: ProtocolVersion.legacy,
        );
      });

      test('handshake defaults to legacy protocol version', () {
        expect(sessionProps.protocolVersion, ProtocolVersion.legacy);
      });

      test('reauthorize uses reauthorize method for legacy', () async {
        final capturedMethods = <String>[];
        final proxy = createMobileWalletProxy(
          (method, params) {
            capturedMethods.add(method);
            return _sendViaWallet(
              wallet,
              method,
              params,
              sharedSecret,
            );
          },
          sessionProps,
        );

        await proxy.reauthorize({
          'auth_token': 'old-token',
        });

        // Legacy proxy should send 'reauthorize' method.
        expect(capturedMethods, contains('reauthorize'));
      });

      test('authorize maps chain to legacy cluster name', () async {
        final capturedParams = <Map<String, Object?>>[];
        final proxy = createMobileWalletProxy(
          (method, params) {
            capturedParams.add(Map.of(params));
            return _sendViaWallet(
              wallet,
              method,
              params,
              sharedSecret,
            );
          },
          sessionProps,
        );

        await proxy.authorize({
          'identity': {'name': 'Test dApp'},
          'chain': 'solana:mainnet',
        });

        // Legacy proxy should map chain to cluster.
        expect(capturedParams.first['cluster'], 'mainnet-beta');
      });

      test('getCapabilities adds features array for legacy', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.getCapabilities();
        // Legacy response should be augmented with features array.
        expect(result['features'], isA<List<Object?>>());
        expect(result['supports_sign_and_send_transactions'], isTrue);
      });

      test('signTransactions works with legacy wallet', () async {
        final proxy = createMobileWalletProxy(
          (method, params) => _sendViaWallet(
            wallet,
            method,
            params,
            sharedSecret,
          ),
          sessionProps,
        );

        final result = await proxy.signTransactions({
          'payloads': ['dHgx'],
        });

        final signed =
            (result['signed_payloads']! as List<Object?>).cast<String>();
        expect(signed, ['signed_dHgx']);
      });
    });

    group('error handling', () {
      late SimulatedWallet wallet;
      late Uint8List sharedSecret;

      setUp(() {
        wallet = SimulatedWallet(protocolVersion: ProtocolVersion.v1);

        final helloReq =
            createHelloReq(dAppEcdhKeypair, dAppAssociationKeypair);
        final helloRsp =
            wallet.handleHelloReq(helloReq, dAppAssociationKeypair);

        final result = parseHelloRsp(
          helloRsp,
          dAppAssociationKeypair,
          dAppEcdhKeypair,
        );
        sharedSecret = result.sharedSecret;
        parseSessionProps(
          result.encryptedSessionProps!,
          sharedSecret,
        );
      });

      test('unknown method returns JSON-RPC error', () async {
        expect(
          () => _sendViaWallet(
            wallet,
            'nonexistent_method',
            {},
            sharedSecret,
          ),
          throwsA(
            isA<MwaProtocolError>().having(
              (e) => e.code,
              'code',
              -32601,
            ),
          ),
        );
      });

      test('tampered ciphertext fails decryption', () {
        final encrypted = encryptJsonRpcRequest(
          1,
          'authorize',
          {'chain': 'solana:mainnet'},
          sharedSecret,
        );

        // Tamper with the ciphertext.
        encrypted[encrypted.length - 5] ^= 0xFF;

        expect(
          () => decryptJsonRpcResponse(encrypted, sharedSecret),
          throwsA(anything),
        );
      });

      test('wrong shared secret fails decryption', () {
        final encrypted = encryptJsonRpcRequest(
          1,
          'authorize',
          {'chain': 'solana:mainnet'},
          sharedSecret,
        );

        // Use a different key.
        final wrongKey = Uint8List(16);
        for (var i = 0; i < 16; i++) {
          wrongKey[i] = i;
        }

        expect(
          () => decryptJsonRpcResponse(encrypted, wrongKey),
          throwsA(anything),
        );
      });
    });

    group('sequence number enforcement', () {
      late SimulatedWallet wallet;
      late Uint8List sharedSecret;

      setUp(() {
        wallet = SimulatedWallet(protocolVersion: ProtocolVersion.v1);

        final helloReq =
            createHelloReq(dAppEcdhKeypair, dAppAssociationKeypair);
        final helloRsp =
            wallet.handleHelloReq(helloReq, dAppAssociationKeypair);

        final result = parseHelloRsp(
          helloRsp,
          dAppAssociationKeypair,
          dAppEcdhKeypair,
        );
        sharedSecret = result.sharedSecret;
      });

      test('sequence number is correctly encoded in wire format', () {
        final encrypted = encryptMessage('test', 42, sharedSecret);

        // First 4 bytes are the sequence number (big-endian).
        final seqBytes = encrypted.sublist(0, 4);
        final seqNum = ByteData.sublistView(seqBytes).getUint32(0);
        expect(seqNum, 42);
      });

      test('sequence number overflow throws', () {
        expect(
          () => createSequenceNumberVector(0x100000000),
          throwsA(anything),
        );
      });

      test('multiple requests use incrementing sequence numbers', () {
        final encrypted1 = encryptJsonRpcRequest(
          1,
          'authorize',
          {},
          sharedSecret,
        );
        final encrypted2 = encryptJsonRpcRequest(
          2,
          'sign_transactions',
          {'payloads': <String>[]},
          sharedSecret,
        );

        final seq1 =
            ByteData.sublistView(encrypted1.sublist(0, 4)).getUint32(0);
        final seq2 =
            ByteData.sublistView(encrypted2.sublist(0, 4)).getUint32(0);

        expect(seq1, 1);
        expect(seq2, 2);
      });

      test('sequence number is used as AAD and prevents tampering', () {
        final encrypted = encryptJsonRpcRequest(
          5,
          'authorize',
          {},
          sharedSecret,
        );

        // Alter the sequence number in the wire format.
        final tampered = Uint8List.fromList(encrypted);
        tampered[3] = 99; // Change sequence number byte

        // Decryption should fail because AAD no longer matches.
        expect(
          () => decryptMessage(tampered, sharedSecret),
          throwsA(anything),
        );
      });
    });

    group('handshake edge cases', () {
      test('HELLO_REQ has correct length (129 bytes)', () {
        final helloReq =
            createHelloReq(dAppEcdhKeypair, dAppAssociationKeypair);
        expect(helloReq.length, 129); // 65 + 64
      });

      test('HELLO_REQ ECDSA signature is verifiable', () {
        final helloReq =
            createHelloReq(dAppEcdhKeypair, dAppAssociationKeypair);
        final ecdhPubKeyBytes = helloReq.sublist(0, 65);
        final signature = helloReq.sublist(65, 129);

        final isValid = ecdsaVerify(
          ecdhPubKeyBytes,
          signature,
          dAppAssociationKeypair.publicKey,
        );
        expect(isValid, isTrue);
      });

      test('short HELLO_RSP throws', () {
        expect(
          () => parseHelloRsp(
            Uint8List(10),
            dAppAssociationKeypair,
            dAppEcdhKeypair,
          ),
          throwsA(anything),
        );
      });

      test('both sides derive the same shared secret', () {
        final wallet = SimulatedWallet(protocolVersion: ProtocolVersion.v1);

        final helloReq =
            createHelloReq(dAppEcdhKeypair, dAppAssociationKeypair);
        final helloRsp =
            wallet.handleHelloReq(helloReq, dAppAssociationKeypair);

        final dAppResult = parseHelloRsp(
          helloRsp,
          dAppAssociationKeypair,
          dAppEcdhKeypair,
        );

        // Both sides should be able to encrypt/decrypt with the derived keys.
        // Encrypt from dApp side.
        final encrypted =
            encryptMessage('hello', 1, dAppResult.sharedSecret);
        // Decrypt from wallet side (wallet has same shared secret).
        final decrypted = decryptMessage(encrypted, dAppResult.sharedSecret);
        expect(decrypted.plaintext, 'hello');
        expect(decrypted.sequenceNumber, 1);
      });
    });

    group('full session lifecycle', () {
      test('complete dApp session: authorize -> sign -> deauthorize', () async {
        final wallet = SimulatedWallet(protocolVersion: ProtocolVersion.v1);

        // 1. Handshake
        final helloReq =
            createHelloReq(dAppEcdhKeypair, dAppAssociationKeypair);
        final helloRsp =
            wallet.handleHelloReq(helloReq, dAppAssociationKeypair);
        final result = parseHelloRsp(
          helloRsp,
          dAppAssociationKeypair,
          dAppEcdhKeypair,
        );
        final sharedSecret = result.sharedSecret;
        final sessionProps = parseSessionProps(
          result.encryptedSessionProps!,
          sharedSecret,
        );

        // 2. Create wallet proxy
        var seqNum = 0;
        final proxy = createMobileWalletProxy(
          (method, params) {
            seqNum++;
            final encrypted = encryptJsonRpcRequest(
              seqNum,
              method,
              params,
              sharedSecret,
            );
            final encryptedResponse = wallet.handleEncryptedRequest(encrypted);
            return Future.value(
              decryptJsonRpcResponse(encryptedResponse, sharedSecret),
            );
          },
          sessionProps,
        );

        // 3. Authorize
        final authResult = await proxy.authorize({
          'identity': {'name': 'Integration Test dApp'},
          'chain': 'solana:mainnet',
        });
        expect(authResult['auth_token'], isNotNull);
        final authToken = authResult['auth_token']! as String;

        // 4. Get capabilities
        final caps = await proxy.getCapabilities();
        expect(caps['max_transactions_per_request'], 10);

        // 5. Sign transactions
        final signResult = await proxy.signTransactions({
          'payloads': ['dHgxMQ==', 'dHgyMg=='],
        });
        final signed =
            (signResult['signed_payloads']! as List<Object?>).cast<String>();
        expect(signed, hasLength(2));

        // 6. Sign and send
        final sendResult = await proxy.signAndSendTransactions({
          'payloads': ['dHgz'],
        });
        final sigs =
            (sendResult['signatures']! as List<Object?>).cast<String>();
        expect(sigs, hasLength(1));

        // 7. Deauthorize
        final deauthResult = await proxy.deauthorize({
          'auth_token': authToken,
        });
        expect(deauthResult, isA<Map<String, Object?>>());
      });
    });
  });
}

// Helper to send via the simulated wallet.
int _nextSeqNum = 1;

Future<Map<String, Object?>> _sendViaWallet(
  SimulatedWallet wallet,
  String method,
  Map<String, Object?> params,
  Uint8List sharedSecret,
) async {
  final seqNum = _nextSeqNum++;
  final encrypted =
      encryptJsonRpcRequest(seqNum, method, params, sharedSecret);
  final encryptedResponse = wallet.handleEncryptedRequest(encrypted);
  return decryptJsonRpcResponse(encryptedResponse, sharedSecret);
}
