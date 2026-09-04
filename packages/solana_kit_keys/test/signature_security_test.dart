import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('weak-key signature forgery', () {
    // The order-eight torsion subgroup and its non-canonical encodings.
    // These public keys do not require knowledge of an Ed25519 private key.
    final weakPoints = <String>[
      '0000000000000000000000000000000000000000000000000000000000000000',
      '0100000000000000000000000000000000000000000000000000000000000000',
      '26e8958fc2b227b045c3f489f2ef98f0d5dfac05d3c63339b13802886d53fc05',
      'c7176a703d4dd84fba3c0b760d10670f2a2053fa2c39ccc64ec7fd7792ac037a',
      'ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f',
      'edffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f',
      'eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f',
    ];

    for (final point in weakPoints) {
      for (final signBit in [0, 0x80]) {
        test('rejects forged challenges for $point sign $signBit', () {
          final publicKey = _hexBytes(point)..[31] |= signBit;
          // R = identity, S = 0 satisfies the verification equation for an
          // identity public key on every message, and for other weak keys
          // whenever the message hash is divisible by their small order.
          final forgedSignature = SignatureBytes(Uint8List(64)..[0] = 1);

          for (var nonce = 0; nonce < 64; nonce++) {
            final challenge = Uint8List.fromList(
              utf8.encode('Authorize withdrawal: challenge $nonce'),
            );
            expect(
              verifySignature(publicKey, forgedSignature, challenge),
              isFalse,
              reason:
                  'A signature made without a private key must not '
                  'authenticate challenge $nonce',
            );
          }
        });
      }
    }

    test('rejects low-order signature nonce points for normal keys', () {
      for (final point in weakPoints) {
        final forgedSignature = SignatureBytes(
          Uint8List(64)..setAll(0, _hexBytes(point)),
        );
        expect(
          verifySignature(mockPublicKeyBytes, forgedSignature, mockData),
          isFalse,
        );
      }
    });

    test('accepts signatures made by a real key for each challenge', () {
      for (var nonce = 0; nonce < 16; nonce++) {
        final challenge = Uint8List.fromList([nonce]);
        final signature = signBytes(mockPrivateKeyBytes, challenge);
        expect(
          verifySignature(mockPublicKeyBytes, signature, challenge),
          isTrue,
        );
      }
    });

    test('rejects malformed signature lengths before inspecting points', () {
      for (final length in [0, 31, 32, 63, 65]) {
        expect(
          verifySignature(
            mockPublicKeyBytes,
            SignatureBytes(Uint8List(length)),
            mockData,
          ),
          isFalse,
        );
      }
    });
  });
}

Uint8List _hexBytes(String hex) => Uint8List.fromList([
  for (var offset = 0; offset < hex.length; offset += 2)
    int.parse(hex.substring(offset, offset + 2), radix: 16),
]);
