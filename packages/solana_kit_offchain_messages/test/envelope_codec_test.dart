import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  group('getOffchainMessageEnvelopeDecoder()', () {
    late Decoder<OffchainMessageEnvelope> decoder;
    setUp(() {
      decoder = getOffchainMessageEnvelopeDecoder();
    });

    test('decodes a well-formed encoded message envelope', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b,
        0x00,
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x20,
        0x77,
        0x6f,
        0x72,
        0x6c,
        0x64,
      ]);
      final encodedEnvelope = Uint8List.fromList([
        0x02,
        ...Uint8List(64), // all zeros = null signature
        ...List<int>.filled(64, 0x02), // non-zero signature
        ...encodedMessage,
      ]);
      final result = decoder.decode(encodedEnvelope);
      expect(result.content, equals(encodedMessage));
      expect(result.signatures.length, equals(2));
      // First signature should be null (all zeros).
      expect(result.signatures[signerA], isNull);
      // Second signature should be non-null.
      expect(result.signatures[signerB], isNotNull);
      expect(
        result.signatures[signerB]!.value,
        equals(Uint8List.fromList(List<int>.filled(64, 0x02))),
      );
    });

    test('orders the keys in the signatures map by the message order', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        // Signer B first, then Signer A
        ...signerBBytes,
        ...signerABytes,
        0x0b, 0x00,
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64,
      ]);
      final encodedEnvelope = Uint8List.fromList([
        0x02,
        ...List<int>.filled(64, 0x02),
        ...List<int>.filled(64, 0x01),
        ...encodedMessage,
      ]);
      final result = decoder.decode(encodedEnvelope);
      final orderedAddresses = result.signatures.keys.toList();
      expect(orderedAddresses[0].value, equals(signerB.value));
      expect(orderedAddresses[1].value, equals(signerA.value));
    });

    test('throws when the envelope has no signatures', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x00,
        0x0b,
        0x00,
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x20,
        0x77,
        0x6f,
        0x72,
        0x6c,
        0x64,
      ]);
      final encodedEnvelope = Uint8List.fromList([0x00, ...encodedMessage]);
      expect(
        () => decoder.decode(encodedEnvelope),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageNumEnvelopeSignaturesCannotBeZero,
          ),
        ),
      );
    });

    test('throws when signature count mismatches required signers', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b,
        0x00,
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x20,
        0x77,
        0x6f,
        0x72,
        0x6c,
        0x64,
      ]);
      final encodedEnvelope = Uint8List.fromList([
        0x01, // only 1 signature for 2 signers
        ...Uint8List(64),
        ...encodedMessage,
      ]);
      expect(
        () => decoder.decode(encodedEnvelope),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageNumSignaturesMismatch,
          ),
        ),
      );
    });

    for (var version = 2; version < 256; version++) {
      test('throws for unsupported version $version', () {
        final encodedMessage = Uint8List.fromList([
          ...signingDomainBytes,
          version,
        ]);
        final encodedEnvelope = Uint8List.fromList([
          0x01,
          ...Uint8List(64),
          ...encodedMessage,
        ]);
        expect(
          () => decoder.decode(encodedEnvelope),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageVersionNumberNotSupported,
            ),
          ),
        );
      });
    }
  });

  group('getOffchainMessageEnvelopeEncoder()', () {
    late Encoder<OffchainMessageEnvelope> encoder;
    setUp(() {
      encoder = getOffchainMessageEnvelopeEncoder();
    });

    test('encodes a well-formed message envelope', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b,
        0x00,
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x20,
        0x77,
        0x6f,
        0x72,
        0x6c,
        0x64,
      ]);
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: {
          signerA: null,
          signerB: SignatureBytes(
            Uint8List.fromList(List<int>.filled(64, 0x02)),
          ),
        },
      );
      final result = encoder.encode(envelope);
      expect(
        result,
        equals(
          Uint8List.fromList([
            0x02,
            ...Uint8List(64), // null -> 64 zeros
            ...List<int>.filled(64, 0x02),
            ...encodedMessage,
          ]),
        ),
      );
    });

    test('encodes signatures in preamble order regardless of map order', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b,
        0x00,
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x20,
        0x77,
        0x6f,
        0x72,
        0x6c,
        0x64,
      ]);
      // Provide signatures in reverse order (B then A).
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: {
          signerB: SignatureBytes(
            Uint8List.fromList(List<int>.filled(64, 0x02)),
          ),
          signerA: null,
        },
      );
      final result = encoder.encode(envelope);
      // Result should have A's signature first (null -> zeros),
      // then B's signature.
      expect(
        result,
        equals(
          Uint8List.fromList([
            0x02,
            ...Uint8List(64), // signerA is null
            ...List<int>.filled(64, 0x02), // signerB's sig
            ...encodedMessage,
          ]),
        ),
      );
    });

    test('throws when the envelope has no signatures', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b,
        0x00,
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x20,
        0x77,
        0x6f,
        0x72,
        0x6c,
        0x64,
      ]);
      final envelope = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: const {},
      );
      expect(
        () => encoder.encode(envelope),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageNumEnvelopeSignaturesCannotBeZero,
          ),
        ),
      );
    });

    test(
      'throws when signature addresses do not match required signatures',
      () {
        final encodedMessage = Uint8List.fromList([
          ...signingDomainBytes,
          0x00,
          ...applicationDomainBytes,
          0x00,
          0x02,
          ...signerABytes,
          ...signerBBytes,
          0x0b,
          0x00,
          0x48,
          0x65,
          0x6c,
          0x6c,
          0x6f,
          0x20,
          0x77,
          0x6f,
          0x72,
          0x6c,
          0x64,
        ]);
        final envelope = OffchainMessageEnvelope(
          content: encodedMessage,
          signatures: const {signerC: null, signerA: null},
        );
        expect(
          () => encoder.encode(envelope),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageEnvelopeSignersMismatch,
            ),
          ),
        );
      },
    );

    for (var version = 2; version < 256; version++) {
      test('throws for unsupported version $version', () {
        final encodedMessage = Uint8List.fromList([
          ...signingDomainBytes,
          version,
        ]);
        expect(
          () => encoder.encode(
            OffchainMessageEnvelope(
              content: encodedMessage,
              signatures: const {signerA: null},
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.offchainMessageVersionNumberNotSupported,
            ),
          ),
        );
      });
    }
  });

  group('round-trip', () {
    test('envelope encodes and decodes correctly', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b,
        0x00,
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x20,
        0x77,
        0x6f,
        0x72,
        0x6c,
        0x64,
      ]);
      final original = OffchainMessageEnvelope(
        content: encodedMessage,
        signatures: {
          signerA: null,
          signerB: SignatureBytes(
            Uint8List.fromList(List<int>.filled(64, 0x02)),
          ),
        },
      );
      final codec = getOffchainMessageEnvelopeCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded.content, equals(original.content));
      expect(decoded.signatures.length, equals(2));
      expect(decoded.signatures[signerA], isNull);
      expect(decoded.signatures[signerB], isNotNull);
    });
  });
}
