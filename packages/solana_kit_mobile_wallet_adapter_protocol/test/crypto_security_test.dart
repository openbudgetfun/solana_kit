import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('P-256 public-key validation', () {
    test('rejects an encoded off-curve point with order two', () {
      expect(
        () => ecPublicKeyFromBytes(_orderTwoPointBytes()),
        throwsArgumentError,
      );
    });

    test('rejects the off-curve origin', () {
      final encoded = Uint8List(65)..[0] = 4;

      expect(() => ecPublicKeyFromBytes(encoded), throwsArgumentError);
    });

    test('ECDH rejects a directly constructed off-curve public key', () {
      final publicKey = ECPublicKey(
        p256.curve.createPoint(BigInt.one, BigInt.zero),
        p256,
      );
      final privateKey = ECPrivateKey(BigInt.from(3), p256);

      expect(
        () => ecdhSharedSecret(privateKey, publicKey),
        throwsArgumentError,
      );
    });

    test('ECDH rejects a public key from a different curve', () {
      final otherCurve = ECDomainParameters('secp256k1');

      expect(
        () => ecdhSharedSecret(
          ECPrivateKey(BigInt.from(3), p256),
          ECPublicKey(otherCurve.G, otherCurve),
        ),
        throwsArgumentError,
      );
    });

    test('ECDH rejects a point inconsistent with its declared curve', () {
      final otherCurve = ECDomainParameters('secp256k1');

      expect(
        () => ecdhSharedSecret(
          ECPrivateKey(BigInt.from(3), p256),
          ECPublicKey(otherCurve.G, p256),
        ),
        throwsArgumentError,
      );
    });

    test('ECDH rejects a private key with a different or missing curve', () {
      for (final domain in [ECDomainParameters('secp256k1'), null]) {
        expect(
          () => ecdhSharedSecret(
            ECPrivateKey(BigInt.from(3), domain),
            ECPublicKey(p256.G, p256),
          ),
          throwsArgumentError,
        );
      }
    });

    test('ECDH rejects a public key with a missing curve', () {
      expect(
        () => ecdhSharedSecret(
          ECPrivateKey(BigInt.from(3), p256),
          ECPublicKey(p256.G, null),
        ),
        throwsArgumentError,
      );
    });

    test('ECDH rejects noncanonical negative coordinates', () {
      final modulus = BigInt.parse(
        'ffffffff00000001000000000000000000000000ffffffffffffffffffffffff',
        radix: 16,
      );
      final x = p256.G.x!.toBigInteger()!;
      final y = p256.G.y!.toBigInteger()!;
      final points = [
        p256.curve.createPoint(x - modulus, y),
        p256.curve.createPoint(x, y - modulus),
      ];

      for (final point in points) {
        expect(
          () => ecdhSharedSecret(
            ECPrivateKey(BigInt.from(3), p256),
            ECPublicKey(point, p256),
          ),
          throwsArgumentError,
        );
      }
    });

    test('ECDH rejects the point at infinity', () {
      expect(
        () => ecdhSharedSecret(
          ECPrivateKey(BigInt.from(3), p256),
          ECPublicKey(p256.curve.infinity, p256),
        ),
        throwsArgumentError,
      );
    });

    test('ECDH rejects a missing public point', () {
      expect(
        () => ecdhSharedSecret(
          ECPrivateKey(BigInt.from(3), p256),
          ECPublicKey(null, p256),
        ),
        throwsArgumentError,
      );
    });

    test('rejects a handshake with a degenerate shared secret', () {
      final association = generateAssociationKeypair();
      final privateKey = ECPrivateKey(BigInt.from(3), p256);
      final ephemeral = EcdhKeypair(
        publicKey: ECPublicKey(p256.G * privateKey.d, p256),
        privateKey: privateKey,
      );
      // An order-two point multiplied by any odd scalar retains x = 1.
      // A peer can derive this key without knowing the ephemeral scalar.
      final knownSharedSecret = Uint8List(32)..[31] = 1;
      final predictableKey = hkdfSha256(
        ikm: knownSharedSecret,
        salt: exportPublicKeyBytes(association.publicKey),
        info: Uint8List(0),
        outputLength: 16,
      );

      expect(() {
        final result = parseHelloRsp(
          _orderTwoPointBytes(),
          association,
          ephemeral,
        );
        final message = encryptMessage(
          'private auth token',
          1,
          result.sharedSecret,
        );

        // Before the fix, invalid peer input selects this predictable key.
        expect(
          decryptMessage(message, predictableKey).plaintext,
          'private auth token',
        );
      }, throwsArgumentError);
    });

    test('accepts valid P-256 public keys and derives matching secrets', () {
      final alice = generateEcdhKeypair();
      final bob = generateEcdhKeypair();
      final restored = ecPublicKeyFromBytes(exportEcdhPublicKeyBytes(bob));

      expect(
        ecdhSharedSecret(alice.privateKey, restored),
        ecdhSharedSecret(bob.privateKey, alice.publicKey),
      );
    });
  });
}

Uint8List _orderTwoPointBytes() => Uint8List(65)
  ..[0] = 4
  ..[32] = 1;
