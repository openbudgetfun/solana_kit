import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  group('signature completeness', () {
    late OffchainMessageEnvelope unsigned;

    setUp(() {
      unsigned = compileOffchainMessageEnvelope(
        const OffchainMessageV1(
          content: 'Hello world',
          requiredSignatories: [
            OffchainMessageSignatory(address: signerA),
            OffchainMessageSignatory(address: signerB),
          ],
        ),
      );
    });

    test('reports missing signatures from the encoded message', () {
      expect(isFullySignedOffchainMessageEnvelope(unsigned), isFalse);
      expect(
        () => assertIsFullySignedOffchainMessageEnvelope(unsigned),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.offchainMessageSignaturesMissing,
          ),
        ),
      );
    });

    test('accepts present signatures without verifying them', () {
      final envelope = OffchainMessageEnvelope(
        content: unsigned.content,
        signatures: {
          signerA: SignatureBytes(Uint8List(64)),
          signerB: SignatureBytes(Uint8List(64)),
        },
      );
      expect(isFullySignedOffchainMessageEnvelope(envelope), isTrue);
      expect(
        () => assertIsFullySignedOffchainMessageEnvelope(envelope),
        returnsNormally,
      );
    });

    test('an empty signature map is missing every required signer', () {
      final envelope = OffchainMessageEnvelope(
        content: unsigned.content,
        signatures: const {},
      );
      expect(isFullySignedOffchainMessageEnvelope(envelope), isFalse);
      expect(
        () => assertIsFullySignedOffchainMessageEnvelope(envelope),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('partiallySignOffchainMessageEnvelope()', () {
    late KeyPair keyPairA;
    late KeyPair keyPairB;
    late Address addrA;
    late Address addrB;
    late Uint8List encodedMessage;

    setUp(() {
      keyPairA = generateKeyPair();
      keyPairB = generateKeyPair();
      addrA = getAddressFromPublicKey(keyPairA.publicKey);
      addrB = getAddressFromPublicKey(keyPairB.publicKey);

      // Build a v0 encoded message with the two real signer addresses.
      final encoder = getOffchainMessageV0Encoder();
      encodedMessage = encoder.encode(
        OffchainMessageV0(
          applicationDomain: applicationDomain,
          content: const OffchainMessageContent(
            format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
            text: 'Hello world',
          ),
          requiredSignatories: [
            OffchainMessageSignatory(address: addrA),
            OffchainMessageSignatory(address: addrB),
          ],
        ),
      );
    });

    test('signs with the first signer', () {
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: <Address, SignatureBytes?>{addrA: null, addrB: null},
      );
      final result = partiallySignOffchainMessageEnvelope([keyPairA], envelope);
      expect(result.signatures[addrA], isNotNull);
      expect(result.signatures[addrB], isNull);
    });

    test('signs with the second signer', () {
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: <Address, SignatureBytes?>{addrA: null, addrB: null},
      );
      final result = partiallySignOffchainMessageEnvelope([keyPairB], envelope);
      expect(result.signatures[addrA], isNull);
      expect(result.signatures[addrB], isNotNull);
    });

    test('signs with multiple signers', () {
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: <Address, SignatureBytes?>{addrA: null, addrB: null},
      );
      final result = partiallySignOffchainMessageEnvelope([
        keyPairA,
        keyPairB,
      ], envelope);
      expect(result.signatures[addrA], isNotNull);
      expect(result.signatures[addrB], isNotNull);
    });

    test('returns same envelope when signature is unchanged', () {
      final sig = signBytes(keyPairA.privateKey, encodedMessage);
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: <Address, SignatureBytes?>{addrA: sig, addrB: null},
      );
      final result = partiallySignOffchainMessageEnvelope([keyPairA], envelope);
      // Same object should be returned since the signature didn't change.
      expect(identical(result, envelope), isTrue);
    });

    test('throws when key pair is not a required signatory', () {
      final foreignKeyPair = generateKeyPair();
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: <Address, SignatureBytes?>{addrA: null, addrB: null},
      );
      expect(
        () => partiallySignOffchainMessageEnvelope([foreignKeyPair], envelope),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageAddressesCannotSignOffchainMessage,
          ),
        ),
      );
    });
  });

  group('signOffchainMessageEnvelope()', () {
    late KeyPair keyPairA;
    late KeyPair keyPairB;
    late Address addrA;
    late Address addrB;
    late Uint8List encodedMessage;

    setUp(() {
      keyPairA = generateKeyPair();
      keyPairB = generateKeyPair();
      addrA = getAddressFromPublicKey(keyPairA.publicKey);
      addrB = getAddressFromPublicKey(keyPairB.publicKey);

      final encoder = getOffchainMessageV0Encoder();
      encodedMessage = encoder.encode(
        OffchainMessageV0(
          applicationDomain: applicationDomain,
          content: const OffchainMessageContent(
            format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
            text: 'Hello world',
          ),
          requiredSignatories: [
            OffchainMessageSignatory(address: addrA),
            OffchainMessageSignatory(address: addrB),
          ],
        ),
      );
    });

    test('throws when missing a signer', () {
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: <Address, SignatureBytes?>{addrA: null, addrB: null},
      );
      expect(
        () => signOffchainMessageEnvelope([keyPairA], envelope),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageSignaturesMissing,
          ),
        ),
      );
    });

    test('returns a fully signed envelope', () {
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: <Address, SignatureBytes?>{addrA: null, addrB: null},
      );
      final result = signOffchainMessageEnvelope([
        keyPairA,
        keyPairB,
      ], envelope);
      expect(result.signatures[addrA], isNotNull);
      expect(result.signatures[addrB], isNotNull);
      expect(isFullySignedOffchainMessageEnvelope(result), isTrue);
    });
  });

  group('verifyOffchainMessageEnvelope()', () {
    late KeyPair keyPairA;
    late KeyPair keyPairB;
    late Address addrA;
    late Address addrB;

    setUp(() {
      keyPairA = generateKeyPair();
      keyPairB = generateKeyPair();
      addrA = getAddressFromPublicKey(keyPairA.publicKey);
      addrB = getAddressFromPublicKey(keyPairB.publicKey);
    });

    for (final versionCase in ['v0', 'v1']) {
      group('given a $versionCase message', () {
        late Uint8List encodedMessage;

        setUp(() {
          if (versionCase == 'v0') {
            encodedMessage = getOffchainMessageV0Encoder().encode(
              OffchainMessageV0(
                applicationDomain: applicationDomain,
                content: const OffchainMessageContent(
                  format:
                      OffchainMessageContentFormat.restrictedAscii1232BytesMax,
                  text: 'Hello world',
                ),
                requiredSignatories: [
                  OffchainMessageSignatory(address: addrA),
                  OffchainMessageSignatory(address: addrB),
                ],
              ),
            );
          } else {
            encodedMessage = getOffchainMessageV1Encoder().encode(
              OffchainMessageV1(
                content: 'Hello world',
                requiredSignatories: [
                  OffchainMessageSignatory(address: addrA),
                  OffchainMessageSignatory(address: addrB),
                ],
              ),
            );
          }
        });

        test('returns when all signatures are valid', () {
          final sigA = signBytes(keyPairA.privateKey, encodedMessage);
          final sigB = signBytes(keyPairB.privateKey, encodedMessage);
          final envelope = OffchainMessageEnvelope(
            content: encodedMessage,
            signatures: <Address, SignatureBytes?>{addrA: sigA, addrB: sigB},
          );
          expect(
            () => verifyOffchainMessageEnvelope(envelope),
            returnsNormally,
          );
        });

        test('throws when a signature is missing', () {
          final sigA = signBytes(keyPairA.privateKey, encodedMessage);
          final envelope = OffchainMessageEnvelope(
            content: encodedMessage,
            signatures: <Address, SignatureBytes?>{addrA: sigA, addrB: null},
          );
          expect(
            () => verifyOffchainMessageEnvelope(envelope),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.offchainMessageSignatureVerificationFailure,
              ),
            ),
          );
        });

        test('throws when a signature is invalid', () {
          // Sign with keyPairA's private key for addrB's slot.
          final wrongSig = signBytes(keyPairA.privateKey, encodedMessage);
          final sigA = signBytes(keyPairA.privateKey, encodedMessage);
          final envelope = OffchainMessageEnvelope(
            content: encodedMessage,
            signatures: <Address, SignatureBytes?>{
              addrA: sigA,
              addrB: wrongSig, // wrong key
            },
          );
          expect(
            () => verifyOffchainMessageEnvelope(envelope),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.offchainMessageSignatureVerificationFailure,
              ),
            ),
          );
        });
      });
    }
  });
}
