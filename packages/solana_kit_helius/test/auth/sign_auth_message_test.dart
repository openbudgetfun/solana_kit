import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart' as keys;
import 'package:test/test.dart';

void main() {
  group('AuthClient.signAuthMessage', () {
    test('returns the generated auth message and a base58 signature', () async {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final result = await helius.auth.signAuthMessage(
        SignAuthMessageRequest(secretKey: _generateSecretKey()),
      );

      expect(result.message, isA<String>());
      expect(result.signature, isA<String>());
      expect(result.signature, isNotEmpty);
      expect(keys.isSignature(result.signature), isTrue);
    });

    test('message contains the expected verification text', () async {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final result = await helius.auth.signAuthMessage(
        SignAuthMessageRequest(secretKey: _generateSecretKey()),
      );

      final parsed = jsonDecode(result.message!) as Map<String, Object?>;
      expect(
        parsed['message'],
        'Please sign this message to verify ownership of your wallet and connect to Helius.',
      );
      expect(parsed['timestamp'], isA<int>());
    });

    test('produces different signatures for different calls', () async {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final secretKey = _generateSecretKey();

      final a = await helius.auth.signAuthMessage(
        SignAuthMessageRequest(secretKey: secretKey),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final b = await helius.auth.signAuthMessage(
        SignAuthMessageRequest(secretKey: secretKey),
      );

      expect(a.signature, isNot(b.signature));
      expect(a.message, isNot(b.message));
    });

    test(
      'signature verifies against the generated message and public key',
      () async {
        final helius = createHelius(HeliusConfig(apiKey: 'test'));
        final keyPair = keys.generateKeyPair();
        final secretKey = _encodeSecretKey(keyPair);

        final result = await helius.auth.signAuthMessage(
          SignAuthMessageRequest(secretKey: secretKey, timestamp: 1234),
        );
        final signatureBytes = getBase58Encoder().encode(result.signature);
        final verified = keys.verifySignature(
          keyPair.publicKey,
          keys.SignatureBytes(signatureBytes),
          Uint8List.fromList(utf8.encode(result.message!)),
        );

        expect(verified, isTrue);
      },
    );

    test('supports signing a caller-provided compatibility message', () async {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final keyPair = keys.generateKeyPair();
      const message = 'custom-message';

      final result = await helius.auth.signAuthMessage(
        SignAuthMessageRequest(
          message: message,
          secretKey: _encodeSecretKey(keyPair),
        ),
      );
      final signatureBytes = getBase58Encoder().encode(result.signature);

      expect(result.message, message);
      expect(
        keys.verifySignature(
          keyPair.publicKey,
          keys.SignatureBytes(signatureBytes),
          Uint8List.fromList(utf8.encode(message)),
        ),
        isTrue,
      );
    });

    test('can be created from Solana CLI-format secret key bytes', () async {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final keyPair = keys.generateKeyPair();
      final secretKeyBytes = _secretKeyBytes(keyPair);
      const message = 'bytes-message';

      final request = SignAuthMessageRequest.fromSecretKeyBytes(
        secretKeyBytes,
        message: message,
        timestamp: 42,
      );
      expect(base64Decode(request.secretKey), secretKeyBytes);
      expect(request.message, message);
      expect(request.timestamp, 42);

      final result = await helius.auth.signAuthMessage(request);
      final signatureBytes = getBase58Encoder().encode(result.signature);

      expect(
        keys.verifySignature(
          keyPair.publicKey,
          keys.SignatureBytes(signatureBytes),
          Uint8List.fromList(utf8.encode(message)),
        ),
        isTrue,
      );
    });

    test('can be created from a key pair', () async {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final keyPair = keys.generateKeyPair();
      const message = 'keypair-message';

      final request = SignAuthMessageRequest.fromKeyPair(
        keyPair,
        message: message,
        timestamp: 84,
      );
      expect(base64Decode(request.secretKey), _secretKeyBytes(keyPair));
      expect(request.message, message);
      expect(request.timestamp, 84);

      final result = await helius.auth.signAuthMessage(request);
      final signatureBytes = getBase58Encoder().encode(result.signature);

      expect(
        keys.verifySignature(
          keyPair.publicKey,
          keys.SignatureBytes(signatureBytes),
          Uint8List.fromList(utf8.encode(message)),
        ),
        isTrue,
      );
    });
  });
}

String _generateSecretKey() => _encodeSecretKey(keys.generateKeyPair());

String _encodeSecretKey(keys.KeyPair keyPair) {
  return base64Encode(_secretKeyBytes(keyPair));
}

Uint8List _secretKeyBytes(keys.KeyPair keyPair) {
  return Uint8List(64)
    ..setRange(0, 32, keyPair.privateKey)
    ..setRange(32, 64, keyPair.publicKey);
}
