import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  group('getOffchainMessageV0Decoder()', () {
    late Decoder<OffchainMessageV0> decoder;
    setUp(() {
      decoder = getOffchainMessageV0Decoder();
    });

    test('decodes a well-formed ASCII encoded message according to spec', () {
      final encodedMessage = Uint8List.fromList([
        // Signing domain
        ...signingDomainBytes,
        // Version
        0x00,
        // Application domain
        ...applicationDomainBytes,
        // Message format (Restricted ASCII, 1232-byte-max)
        0x00,
        // Signer count
        0x02,
        // Signer addresses
        ...signerABytes,
        ...signerBBytes,
        // Message length (11 characters)
        0x0b, 0x00,
        // Message (Hello world)
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64,
      ]);
      final result = decoder.decode(encodedMessage);
      expect(result.version, equals(0));
      expect(result.applicationDomain.value, equals(applicationDomain.value));
      expect(
        result.content.format,
        equals(OffchainMessageContentFormat.restrictedAscii1232BytesMax),
      );
      expect(result.content.text, equals('Hello world'));
      expect(result.requiredSignatories.length, equals(2));
      expect(
        result.requiredSignatories[0].address.value,
        equals(signerA.value),
      );
      expect(
        result.requiredSignatories[1].address.value,
        equals(signerB.value),
      );
    });

    test('throws when decoding with a malformed signing domain', () {
      final reversedDomain = Uint8List.fromList(
        signingDomainBytes.reversed.toList(),
      );
      final encodedMessage = Uint8List.fromList([
        ...reversedDomain,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x01,
        0x00,
        0x09,
      ]);
      expect(() => decoder.decode(encodedMessage), throwsA(isA<SolanaError>()));
    });

    test('throws when decoding an ASCII message whose content is outside the '
        'restricted set', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x01, 0x00,
        // horizontal tab character
        0x09,
      ]);
      expect(
        () => decoder.decode(encodedMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .offchainMessageRestrictedAsciiBodyCharacterOutOfRange,
          ),
        ),
      );
    });

    test('throws when decoding with a non-zero version', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x01, // version 1, not 0
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b, 0x00,
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64,
      ]);
      expect(
        () => decoder.decode(encodedMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageUnexpectedVersion,
          ),
        ),
      );
    });

    test('throws when decoding with an unsupported version', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0xff, // version 255
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b, 0x00,
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64,
      ]);
      expect(
        () => decoder.decode(encodedMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageVersionNumberNotSupported,
          ),
        ),
      );
    });

    test('throws when message content length is zero', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x00,
        0x00,
      ]);
      expect(
        () => decoder.decode(encodedMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageMessageMustBeNonEmpty,
          ),
        ),
      );
    });

    test('throws when required signers length is zero', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x00, // zero signers
        0x0b, 0x00,
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64,
      ]);
      expect(
        () => decoder.decode(encodedMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
          ),
        ),
      );
    });

    test('throws when message content is too long', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        // Message length (1233)
        0xd1, 0x04,
        // Message (1233 exclamation points)
        ...List<int>.filled(1233, 0x21),
      ]);
      expect(
        () => decoder.decode(encodedMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageMaximumLengthExceeded,
          ),
        ),
      );
    });

    test('throws when message content does not match preamble length', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        0x00,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        // Message length (11 characters specified)
        0x0b, 0x00,
        // Message (12 characters actual)
        ...List<int>.filled(12, 0x21),
      ]);
      expect(
        () => decoder.decode(encodedMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageMessageLengthMismatch,
          ),
        ),
      );
    });

    test('decodes a well-formed 1232-byte-max UTF-8 message', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        // UTF-8, 1232-byte-max
        0x01,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        // 11 bytes
        0x0b, 0x00,
        // \u270c\u1f3ff cool
        0xe2, 0x9c, 0x8c, 0xf0, 0x9f, 0x8f, 0xbf, 0x63, 0x6f, 0x6f, 0x6c,
      ]);
      final result = decoder.decode(encodedMessage);
      expect(
        result.content.format,
        equals(OffchainMessageContentFormat.utf81232BytesMax),
      );
      expect(result.content.text, equals('\u{270c}\u{1f3ff}cool'));
    });

    test('decodes a well-formed 65535-byte-max UTF-8 message', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00,
        ...applicationDomainBytes,
        // UTF-8, 65535-byte-max
        0x02,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x0b, 0x00,
        0xe2, 0x9c, 0x8c, 0xf0, 0x9f, 0x8f, 0xbf, 0x63, 0x6f, 0x6f, 0x6c,
      ]);
      final result = decoder.decode(encodedMessage);
      expect(
        result.content.format,
        equals(OffchainMessageContentFormat.utf865535BytesMax),
      );
      expect(result.content.text, equals('\u{270c}\u{1f3ff}cool'));
    });
  });

  group('getOffchainMessageV0Encoder()', () {
    late Encoder<OffchainMessageV0> encoder;
    setUp(() {
      encoder = getOffchainMessageV0Encoder();
    });

    test('encodes a well-formed ASCII message according to spec', () {
      const offchainMessage = OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: OffchainMessageContent(
          format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
          text: 'Hello world',
        ),
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      final result = encoder.encode(offchainMessage);
      expect(
        result,
        equals(
          Uint8List.fromList([
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
          ]),
        ),
      );
    });

    test('throws when the application domain is not base58', () {
      final offchainMessage = OffchainMessageV0(
        applicationDomain: Address('0' * 32),
        content: const OffchainMessageContent(
          format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
          text: 'Hello world',
        ),
        requiredSignatories: const [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      expect(
        () => encoder.encode(offchainMessage),
        throwsA(isA<SolanaError>()),
      );
    });

    for (final length in [31, 45]) {
      test('throws when application domain is $length characters', () {
        final offchainMessage = OffchainMessageV0(
          applicationDomain: Address('1' * length),
          content: const OffchainMessageContent(
            format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
            text: 'Hello world',
          ),
          requiredSignatories: const [
            OffchainMessageSignatory(address: signerA),
            OffchainMessageSignatory(address: signerB),
          ],
        );
        expect(
          () => encoder.encode(offchainMessage),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .offchainMessageApplicationDomainStringLengthOutOfRange,
            ),
          ),
        );
      });
    }

    test('throws when encoding with no required signers', () {
      const offchainMessage = OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: OffchainMessageContent(
          format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
          text: 'Hello world',
        ),
        requiredSignatories: [],
      );
      expect(
        () => encoder.encode(offchainMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
          ),
        ),
      );
    });

    test('throws when message content is outside the restricted set', () {
      const offchainMessage = OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: OffchainMessageContent(
          format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
          text: '\t',
        ),
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      expect(
        () => encoder.encode(offchainMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .offchainMessageRestrictedAsciiBodyCharacterOutOfRange,
          ),
        ),
      );
    });

    test('throws when message content length is zero', () {
      const offchainMessage = OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: OffchainMessageContent(
          format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
          text: '',
        ),
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      expect(
        () => encoder.encode(offchainMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageMessageMustBeNonEmpty,
          ),
        ),
      );
    });

    test('throws when ASCII message content is too long', () {
      final offchainMessage = OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: OffchainMessageContent(
          format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
          text: '!' * (1232 + 1),
        ),
        requiredSignatories: const [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      expect(
        () => encoder.encode(offchainMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageMaximumLengthExceeded,
          ),
        ),
      );
    });

    test('encodes a well-formed 1232-byte-max UTF-8 message', () {
      const offchainMessage = OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: OffchainMessageContent(
          format: OffchainMessageContentFormat.utf81232BytesMax,
          text: '\u{270c}\u{1f3ff}cool',
        ),
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      final result = encoder.encode(offchainMessage);
      expect(
        result,
        equals(
          Uint8List.fromList([
            ...signingDomainBytes,
            0x00,
            ...applicationDomainBytes,
            0x01,
            0x02,
            ...signerABytes,
            ...signerBBytes,
            0x0b,
            0x00,
            0xe2,
            0x9c,
            0x8c,
            0xf0,
            0x9f,
            0x8f,
            0xbf,
            0x63,
            0x6f,
            0x6f,
            0x6c,
          ]),
        ),
      );
    });

    test('encodes a well-formed 65535-byte-max UTF-8 message', () {
      const offchainMessage = OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: OffchainMessageContent(
          format: OffchainMessageContentFormat.utf865535BytesMax,
          text: '\u{270c}\u{1f3ff}cool',
        ),
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      final result = encoder.encode(offchainMessage);
      expect(
        result,
        equals(
          Uint8List.fromList([
            ...signingDomainBytes,
            0x00,
            ...applicationDomainBytes,
            0x02,
            0x02,
            ...signerABytes,
            ...signerBBytes,
            0x0b,
            0x00,
            0xe2,
            0x9c,
            0x8c,
            0xf0,
            0x9f,
            0x8f,
            0xbf,
            0x63,
            0x6f,
            0x6f,
            0x6c,
          ]),
        ),
      );
    });
  });
}
