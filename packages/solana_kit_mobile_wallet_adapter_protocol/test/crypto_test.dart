import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('Association keypair', () {
    test('generates a P-256 keypair', () {
      final keyPair = generateAssociationKeypair();
      expect(keyPair.publicKey.Q, isNotNull);
      expect(keyPair.privateKey.d, isNotNull);
    });

    test('exports public key as 65-byte X9.62 format', () {
      final keyPair = generateAssociationKeypair();
      final bytes = exportPublicKeyBytes(keyPair.publicKey);
      expect(bytes.length, 65);
      expect(bytes[0], 0x04); // uncompressed point indicator
    });

    test('ecPublicKeyFromBytes round-trips with ecPublicKeyToBytes', () {
      final keyPair = generateAssociationKeypair();
      final bytes = ecPublicKeyToBytes(keyPair.publicKey);
      final restored = ecPublicKeyFromBytes(bytes);
      expect(
        restored.Q!.getEncoded(false),
        keyPair.publicKey.Q!.getEncoded(false),
      );
    });

    test('getAssociationToken returns base64url string', () {
      final keyPair = generateAssociationKeypair();
      final token = getAssociationToken(keyPair.publicKey);
      // Should be base64url without padding
      expect(token, isNot(contains('=')));
      expect(token, isNot(contains('+')));
      expect(token, isNot(contains('/')));
      // Should decode to 65 bytes
      final padded = token.padRight(
        token.length + (4 - token.length % 4) % 4,
        '=',
      );
      final decoded = base64Url.decode(padded);
      expect(decoded.length, 65);
    });
  });

  group('ECDH keypair', () {
    test('generates a P-256 keypair', () {
      final keyPair = generateEcdhKeypair();
      expect(keyPair.publicKey.Q, isNotNull);
      expect(keyPair.privateKey.d, isNotNull);
    });

    test('exports public key as 65-byte X9.62 format', () {
      final keyPair = generateEcdhKeypair();
      final bytes = exportEcdhPublicKeyBytes(keyPair);
      expect(bytes.length, 65);
      expect(bytes[0], 0x04);
    });
  });

  group('HELLO_REQ', () {
    test('creates 129-byte message', () {
      final associationKeyPair = generateAssociationKeypair();
      final ecdhKeyPair = generateEcdhKeypair();

      final helloReq = createHelloReq(ecdhKeyPair, associationKeyPair);

      // 65 bytes ECDH pubkey + 64 bytes ECDSA signature = 129
      expect(helloReq.length, 129);
    });

    test('starts with the ECDH public key', () {
      final associationKeyPair = generateAssociationKeypair();
      final ecdhKeyPair = generateEcdhKeypair();
      final ecdhPubKeyBytes = exportEcdhPublicKeyBytes(ecdhKeyPair);

      final helloReq = createHelloReq(ecdhKeyPair, associationKeyPair);

      // First 65 bytes should be the ECDH public key
      expect(helloReq.sublist(0, 65), ecdhPubKeyBytes);
    });

    test('signature is verifiable', () {
      final associationKeyPair = generateAssociationKeypair();
      final ecdhKeyPair = generateEcdhKeypair();

      final helloReq = createHelloReq(ecdhKeyPair, associationKeyPair);

      final ecdhPubKeyBytes = helloReq.sublist(0, 65);
      final signatureBytes = Uint8List.fromList(helloReq.sublist(65));

      final isValid = ecdsaVerify(
        ecdhPubKeyBytes,
        signatureBytes,
        associationKeyPair.publicKey,
      );

      expect(isValid, isTrue);
    });
  });

  group('HELLO_RSP', () {
    test('derives shared secret from handshake', () {
      // Simulate both sides of the handshake.
      final associationKeyPair = generateAssociationKeypair();
      final appEcdhKeyPair = generateEcdhKeypair();
      final walletEcdhKeyPair = generateEcdhKeypair();

      // Build a fake HELLO_RSP: wallet ECDH public key bytes
      final walletPubKeyBytes = exportEcdhPublicKeyBytes(walletEcdhKeyPair);

      final result = parseHelloRsp(
        walletPubKeyBytes,
        associationKeyPair,
        appEcdhKeyPair,
      );

      expect(result.sharedSecret, hasLength(16)); // 128-bit AES key
      expect(result.encryptedSessionProps, isNull);
    });

    test('extracts encrypted session props when present', () {
      final associationKeyPair = generateAssociationKeypair();
      final appEcdhKeyPair = generateEcdhKeypair();
      final walletEcdhKeyPair = generateEcdhKeypair();

      final walletPubKeyBytes = exportEcdhPublicKeyBytes(walletEcdhKeyPair);

      // Append some extra bytes as "encrypted session props"
      final payload = Uint8List(walletPubKeyBytes.length + 10)
        ..setAll(0, walletPubKeyBytes)
        ..setAll(walletPubKeyBytes.length, List.filled(10, 0xAB));

      final result = parseHelloRsp(payload, associationKeyPair, appEcdhKeyPair);

      expect(result.encryptedSessionProps, isNotNull);
      expect(result.encryptedSessionProps, hasLength(10));
    });

    test('throws on payload too short', () {
      final associationKeyPair = generateAssociationKeypair();
      final ecdhKeyPair = generateEcdhKeypair();

      expect(
        () => parseHelloRsp(
          Uint8List(10), // Too short
          associationKeyPair,
          ecdhKeyPair,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.mwaInvalidHelloResponse,
          ),
        ),
      );
    });

    test('both sides derive the same shared secret', () {
      // Full handshake simulation.
      final associationKeyPair = generateAssociationKeypair();
      final appEcdhKeyPair = generateEcdhKeypair();
      final walletEcdhKeyPair = generateEcdhKeypair();

      // App receives wallet's ECDH public key (HELLO_RSP)
      final walletPubKeyBytes = exportEcdhPublicKeyBytes(walletEcdhKeyPair);
      final appResult = parseHelloRsp(
        walletPubKeyBytes,
        associationKeyPair,
        appEcdhKeyPair,
      );

      // Wallet performs the same derivation with app's ECDH public key
      final associationPubKeyBytes = exportPublicKeyBytes(
        associationKeyPair.publicKey,
      );

      final walletSharedBytes = ecdhSharedSecret(
        walletEcdhKeyPair.privateKey,
        appEcdhKeyPair.publicKey,
      );

      final walletAesKey = hkdfSha256(
        ikm: walletSharedBytes,
        salt: associationPubKeyBytes,
        info: Uint8List(0),
        outputLength: 16,
      );

      // Compare derived keys
      expect(appResult.sharedSecret, walletAesKey);
    });
  });

  group('Encrypted message', () {
    late Uint8List sharedSecret;

    setUp(() {
      // Derive a test shared secret.
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

    test('encrypt and decrypt round-trip', () {
      const plaintext = 'Hello, wallet!';
      const sequenceNumber = 42;

      final encrypted = encryptMessage(plaintext, sequenceNumber, sharedSecret);
      final decrypted = decryptMessage(encrypted, sharedSecret);

      expect(decrypted.plaintext, plaintext);
      expect(decrypted.sequenceNumber, sequenceNumber);
    });

    test('encrypted message has correct wire format length', () {
      const plaintext = 'test';
      final encrypted = encryptMessage(plaintext, 0, sharedSecret);

      // 4 (seq) + 12 (IV) + len(plaintext) + 16 (GCM tag)
      expect(encrypted.length, 4 + 12 + plaintext.length + 16);
    });

    test('sequence number is preserved in wire format', () {
      const sequenceNumber = 12345;
      final encrypted = encryptMessage('test', sequenceNumber, sharedSecret);

      // First 4 bytes are the sequence number (big-endian)
      final seqBytes = ByteData.sublistView(encrypted, 0, 4);
      expect(seqBytes.getUint32(0), sequenceNumber);
    });

    test('different messages produce different ciphertext', () {
      final encrypted1 = encryptMessage('message1', 1, sharedSecret);
      final encrypted2 = encryptMessage('message2', 2, sharedSecret);

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('same message encrypted twice produces different ciphertext', () {
      final encrypted1 = encryptMessage('same', 1, sharedSecret);
      final encrypted2 = encryptMessage('same', 2, sharedSecret);

      // Different due to random IV and different sequence number
      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('tampered ciphertext fails decryption', () {
      final encrypted = encryptMessage('test', 0, sharedSecret);

      // Tamper with the ciphertext (after seq + IV)
      final tampered = Uint8List.fromList(encrypted);
      tampered[20] ^= 0xFF;

      expect(
        () => decryptMessage(tampered, sharedSecret),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.mwaDecryptionFailed,
          ),
        ),
      );
    });

    test('handles empty plaintext', () {
      final encrypted = encryptMessage('', 0, sharedSecret);
      final decrypted = decryptMessage(encrypted, sharedSecret);
      expect(decrypted.plaintext, '');
    });

    test('handles JSON plaintext', () {
      const plaintext =
          '{"method":"authorize","params":{"chain":"solana:mainnet"}}';
      final encrypted = encryptMessage(plaintext, 1, sharedSecret);
      final decrypted = decryptMessage(encrypted, sharedSecret);
      expect(decrypted.plaintext, plaintext);
    });

    test('throws on sequence number overflow', () {
      expect(
        () => encryptMessage('test', 4294967296, sharedSecret),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('JWS', () {
    test('creates valid compact serialization', () {
      final keyPair = generateAssociationKeypair();
      final jws = getJws(keyPair.privateKey, {'test': 'value'});

      final parts = jws.split('.');
      expect(parts, hasLength(3));

      // Decode header
      final headerJson = utf8.decode(base64Url.decode(_addPadding(parts[0])));
      final header = json.decode(headerJson) as Map<String, Object?>;
      expect(header['alg'], 'ES256');

      // Decode payload
      final payloadJson = utf8.decode(base64Url.decode(_addPadding(parts[1])));
      final payload = json.decode(payloadJson) as Map<String, Object?>;
      expect(payload['test'], 'value');

      // Signature should be non-empty base64url
      expect(parts[2], isNotEmpty);
    });

    test('signature is verifiable', () {
      final keyPair = generateAssociationKeypair();
      final jws = getJws(keyPair.privateKey, {'key': 'data'});

      final parts = jws.split('.');
      final message = '${parts[0]}.${parts[1]}';
      final signatureBytes = base64Url.decode(_addPadding(parts[2]));

      final isValid = ecdsaVerify(
        Uint8List.fromList(utf8.encode(message)),
        Uint8List.fromList(signatureBytes),
        keyPair.publicKey,
      );
      expect(isValid, isTrue);
    });
  });

  group('Crypto utilities', () {
    test('randomBytes generates bytes of correct length', () {
      final bytes = randomBytes(32);
      expect(bytes, hasLength(32));
    });

    test('randomBytes generates different bytes each time', () {
      final bytes1 = randomBytes(32);
      final bytes2 = randomBytes(32);
      expect(bytes1, isNot(equals(bytes2)));
    });

    test('ECDSA sign and verify round-trip', () {
      final keyPair = generateP256KeyPair();
      final data = Uint8List.fromList(utf8.encode('test data'));

      final signature = ecdsaSign(data, keyPair.privateKey);
      expect(signature, hasLength(64));

      final isValid = ecdsaVerify(data, signature, keyPair.publicKey);
      expect(isValid, isTrue);
    });

    test('ECDSA verification fails with wrong data', () {
      final keyPair = generateP256KeyPair();
      final data = Uint8List.fromList(utf8.encode('test data'));
      final wrongData = Uint8List.fromList(utf8.encode('wrong data'));

      final signature = ecdsaSign(data, keyPair.privateKey);
      final isValid = ecdsaVerify(wrongData, signature, keyPair.publicKey);
      expect(isValid, isFalse);
    });

    test('ECDSA verification fails with wrong key', () {
      final keyPair1 = generateP256KeyPair();
      final keyPair2 = generateP256KeyPair();
      final data = Uint8List.fromList(utf8.encode('test data'));

      final signature = ecdsaSign(data, keyPair1.privateKey);
      final isValid = ecdsaVerify(data, signature, keyPair2.publicKey);
      expect(isValid, isFalse);
    });

    test('ECDH produces same shared secret from both sides', () {
      final alice = generateP256KeyPair();
      final bob = generateP256KeyPair();

      final aliceSecret = ecdhSharedSecret(alice.privateKey, bob.publicKey);
      final bobSecret = ecdhSharedSecret(bob.privateKey, alice.publicKey);

      expect(aliceSecret, bobSecret);
      expect(aliceSecret, hasLength(32));
    });

    test('HKDF-SHA256 produces deterministic output', () {
      final ikm = Uint8List.fromList(List.filled(32, 0x42));
      final salt = Uint8List.fromList(List.filled(16, 0x01));

      final key1 = hkdfSha256(
        ikm: ikm,
        salt: salt,
        info: Uint8List(0),
        outputLength: 16,
      );
      final key2 = hkdfSha256(
        ikm: ikm,
        salt: salt,
        info: Uint8List(0),
        outputLength: 16,
      );

      expect(key1, key2);
      expect(key1, hasLength(16));
    });

    test('AES-GCM encrypt and decrypt round-trip', () {
      final key = randomBytes(16);
      final nonce = randomBytes(12);
      final aad = Uint8List.fromList([1, 2, 3, 4]);
      final plaintext = Uint8List.fromList(utf8.encode('secret'));

      final ciphertextWithTag = aesGcmEncrypt(
        plaintext: plaintext,
        key: key,
        nonce: nonce,
        aad: aad,
      );

      final decrypted = aesGcmDecrypt(
        ciphertextWithTag: ciphertextWithTag,
        key: key,
        nonce: nonce,
        aad: aad,
      );

      expect(decrypted, plaintext);
    });

    test('AES-GCM fails with tampered ciphertext', () {
      final key = randomBytes(16);
      final nonce = randomBytes(12);
      final aad = Uint8List(0);
      final plaintext = Uint8List.fromList(utf8.encode('secret'));

      final ciphertextWithTag = aesGcmEncrypt(
        plaintext: plaintext,
        key: key,
        nonce: nonce,
        aad: aad,
      );

      // Tamper
      ciphertextWithTag[0] ^= 0xFF;

      expect(
        () => aesGcmDecrypt(
          ciphertextWithTag: ciphertextWithTag,
          key: key,
          nonce: nonce,
          aad: aad,
        ),
        throwsA(anything),
      );
    });
  });
}

String _addPadding(String base64Url) {
  final remainder = base64Url.length % 4;
  if (remainder == 0) return base64Url;
  return base64Url.padRight(base64Url.length + (4 - remainder), '=');
}
