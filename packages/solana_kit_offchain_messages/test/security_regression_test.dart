import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  late KeyPair keyPair;
  late Address address;
  late OffchainMessageEnvelope unsigned;

  setUp(() {
    keyPair = generateKeyPair();
    address = getAddressFromPublicKey(keyPair.publicKey);
    unsigned = compileOffchainMessageEnvelope(
      OffchainMessageV1(
        content: 'Authorize this message',
        requiredSignatories: [OffchainMessageSignatory(address: address)],
      ),
    );
  });

  tearDown(() => keyPair.dispose());

  group('required signature completeness', () {
    test('an omitted signature map entry is not fully signed', () {
      final omitted = OffchainMessageEnvelope(
        content: unsigned.content,
        signatures: const {},
      );
      expect(isFullySignedOffchainMessageEnvelope(omitted), isFalse);
      expect(
        () => assertIsFullySignedOffchainMessageEnvelope(omitted),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.offchainMessageSignaturesMissing,
          ),
        ),
      );
      expect(
        () => signOffchainMessageEnvelope([], omitted),
        throwsA(isA<SolanaError>()),
      );
    });

    test('an unrelated signature does not fulfill the required signer', () {
      final unrelated = OffchainMessageEnvelope(
        content: unsigned.content,
        signatures: {signerA: signBytes(keyPair.privateKey, unsigned.content)},
      );
      expect(isFullySignedOffchainMessageEnvelope(unrelated), isFalse);
      expect(
        () => assertIsFullySignedOffchainMessageEnvelope(unrelated),
        throwsA(isA<SolanaError>()),
      );
    });

    test('signing inserts an omitted required signature entry', () {
      final omitted = OffchainMessageEnvelope(
        content: unsigned.content,
        signatures: const {},
      );
      final signed = signOffchainMessageEnvelope([keyPair], omitted);
      expect(signed.signatures.keys, [address]);
      expect(() => verifyOffchainMessageEnvelope(signed), returnsNormally);
    });

    test('malformed content cannot be considered fully signed', () {
      final malformed = OffchainMessageEnvelope(
        content: Uint8List(0),
        signatures: {address: signBytes(keyPair.privateKey, Uint8List(0))},
      );
      expect(isFullySignedOffchainMessageEnvelope(malformed), isFalse);
      expect(
        () => assertIsFullySignedOffchainMessageEnvelope(malformed),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  test('completeness rejects an invalid v0 format', () {
    final content = getOffchainMessageV0Encoder().encode(
      OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: const OffchainMessageContent(
          format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
          text: 'Authorize this message',
        ),
        requiredSignatories: [OffchainMessageSignatory(address: address)],
      ),
    );
    content[49] = 255;
    final envelope = OffchainMessageEnvelope(
      content: content,
      signatures: {address: signBytes(keyPair.privateKey, content)},
    );
    expect(isFullySignedOffchainMessageEnvelope(envelope), isFalse);
    expect(
      () => assertIsFullySignedOffchainMessageEnvelope(envelope),
      throwsFormatException,
    );
  });

  test('completeness rejects malformed UTF-8', () {
    final content = Uint8List.fromList([...unsigned.content, 0xff]);
    final envelope = OffchainMessageEnvelope(
      content: content,
      signatures: {address: signBytes(keyPair.privateKey, content)},
    );
    expect(isFullySignedOffchainMessageEnvelope(envelope), isFalse);
    expect(
      () => assertIsFullySignedOffchainMessageEnvelope(envelope),
      throwsFormatException,
    );
  });

  group('all envelope entry points validate the complete message', () {
    for (final malformedCase in [
      'duplicate v1 signers',
      'v0 length mismatch',
      'empty v1 content',
    ]) {
      test(
        'rejects $malformedCase despite a valid cryptographic signature',
        () {
          final Uint8List content;
          final int signatureCount;
          final SolanaErrorCode expectedError;
          switch (malformedCase) {
            case 'duplicate v1 signers':
              final addressBytes = getAddressEncoder().encode(address);
              content = Uint8List.fromList([
                ...signingDomainBytes,
                1,
                2,
                ...addressBytes,
                ...addressBytes,
                ...'Authorize this message'.codeUnits,
              ]);
              signatureCount = 2;
              expectedError =
                  SolanaErrorCode.offchainMessageSignatoriesMustBeUnique;
            case 'v0 length mismatch':
              content = getOffchainMessageV0Encoder().encode(
                OffchainMessageV0(
                  applicationDomain: applicationDomain,
                  content: const OffchainMessageContent(
                    format: OffchainMessageContentFormat
                        .restrictedAscii1232BytesMax,
                    text: 'Authorize this message',
                  ),
                  requiredSignatories: [
                    OffchainMessageSignatory(address: address),
                  ],
                ),
              );
              content[83] = 1;
              signatureCount = 1;
              expectedError =
                  SolanaErrorCode.offchainMessageMessageLengthMismatch;
            default:
              content = Uint8List.fromList(unsigned.content.sublist(0, 50));
              signatureCount = 1;
              expectedError =
                  SolanaErrorCode.offchainMessageMessageMustBeNonEmpty;
          }
          final signature = signBytes(keyPair.privateKey, content);
          final envelope = OffchainMessageEnvelope(
            content: content,
            signatures: {address: signature},
          );
          final wireBytes = Uint8List.fromList([
            signatureCount,
            for (var i = 0; i < signatureCount; i++) ...signature.value,
            ...content,
          ]);
          final rejectsMalformed = throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              expectedError,
            ),
          );

          // The signature itself is valid; the structured message is invalid.
          expect(
            verifySignature(keyPair.publicKey, signature, content),
            isTrue,
          );
          expect(
            () => getOffchainMessageDecoder().decode(content),
            rejectsMalformed,
          );
          expect(
            () => verifyOffchainMessageEnvelope(envelope),
            rejectsMalformed,
          );
          expect(
            () => partiallySignOffchainMessageEnvelope([keyPair], envelope),
            rejectsMalformed,
          );
          expect(
            () => getOffchainMessageEnvelopeEncoder().encode(envelope),
            rejectsMalformed,
          );
          expect(
            () => getOffchainMessageEnvelopeDecoder().decode(wireBytes),
            rejectsMalformed,
          );
        },
      );
    }
  });
}
