import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

void main() {
  group('isKeyPairSigner', () {
    test('returns true for KeyPairSigner', () {
      final signer = generateKeyPairSigner();
      expect(isKeyPairSigner(signer), isTrue);
    });

    test('returns false for non-KeyPairSigner', () {
      expect(isKeyPairSigner('not a signer'), isFalse);
      expect(isKeyPairSigner(null), isFalse);
    });
  });

  group('assertIsKeyPairSigner', () {
    test('succeeds for KeyPairSigner', () {
      final signer = generateKeyPairSigner();
      expect(() => assertIsKeyPairSigner(signer), returnsNormally);
    });

    test('throws for non-KeyPairSigner', () {
      expect(
        () => assertIsKeyPairSigner('not a signer'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerExpectedKeyPairSigner,
          ),
        ),
      );
    });
  });

  group('createSignerFromKeyPair', () {
    test('creates a KeyPairSigner from a given KeyPair', () {
      final keyPair = generateKeyPair();
      final signer = createSignerFromKeyPair(keyPair);

      expect(signer.address, isNotNull);
      expect(signer.keyPair, equals(keyPair));
      expect(isKeyPairSigner(signer), isTrue);
      expect(isMessagePartialSigner(signer), isTrue);
      expect(isTransactionPartialSigner(signer), isTrue);
    });

    test('derives the correct address from the key pair', () {
      final keyPair = generateKeyPair();
      final expectedAddress = getAddressFromPublicKey(keyPair.publicKey);
      final signer = createSignerFromKeyPair(keyPair);

      expect(signer.address, equals(expectedAddress));
    });
  });

  group('generateKeyPairSigner', () {
    test('generates a new KeyPairSigner', () {
      final signer = generateKeyPairSigner();

      expect(signer.address, isNotNull);
      expect(signer.keyPair, isNotNull);
      expect(isKeyPairSigner(signer), isTrue);
    });

    test('generates different signers each time', () {
      final signerA = generateKeyPairSigner();
      final signerB = generateKeyPairSigner();

      expect(signerA.address, isNot(equals(signerB.address)));
    });
  });

  group('KeyPairSigner.signMessages', () {
    test('signs messages using the key pair', () async {
      final signer = generateKeyPairSigner();
      final messages = [
        createSignableMessage(Uint8List.fromList([1, 1, 1])),
        createSignableMessage(Uint8List.fromList([2, 2, 2])),
      ];

      final signatureDictionaries = await signer.signMessages(messages);

      expect(signatureDictionaries, hasLength(2));
      expect(signatureDictionaries[0].containsKey(signer.address), isTrue);
      expect(signatureDictionaries[1].containsKey(signer.address), isTrue);

      // Verify signatures are valid.
      final sig0 = signatureDictionaries[0][signer.address]!;
      final sig1 = signatureDictionaries[1][signer.address]!;
      expect(
        verifySignature(signer.keyPair.publicKey, sig0, messages[0].content),
        isTrue,
      );
      expect(
        verifySignature(signer.keyPair.publicKey, sig1, messages[1].content),
        isTrue,
      );
    });

    test('returns unmodifiable signature dictionaries', () async {
      final signer = generateKeyPairSigner();
      final messages = [createSignableMessage('hello')];

      final signatureDictionaries = await signer.signMessages(messages);

      expect(
        () => signatureDictionaries[0][const Address('test')] = SignatureBytes(
          Uint8List(64),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('createKeyPairSignerFromBytes', () {
    test('creates a signer from 64-byte key pair bytes', () {
      final keyPair = generateKeyPair();
      final bytes = Uint8List(64)
        ..setAll(0, keyPair.privateKey)
        ..setAll(32, keyPair.publicKey);

      final signer = createKeyPairSignerFromBytes(bytes);

      expect(
        signer.address,
        equals(getAddressFromPublicKey(keyPair.publicKey)),
      );
    });
  });

  group('createKeyPairSignerFromPrivateKeyBytes', () {
    test('creates a signer from 32-byte private key bytes', () {
      final keyPair = generateKeyPair();

      final signer = createKeyPairSignerFromPrivateKeyBytes(keyPair.privateKey);

      expect(
        signer.address,
        equals(getAddressFromPublicKey(keyPair.publicKey)),
      );
    });
  });
}
