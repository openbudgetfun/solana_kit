import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  group('getOffchainMessageV1Decoder()', () {
    late Decoder<OffchainMessageV1> decoder;
    setUp(() {
      decoder = getOffchainMessageV1Decoder();
    });

    test('decodes a well-formed message according to spec', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x01,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        // Message (Hello\nworld)
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x0a, 0x77, 0x6f, 0x72, 0x6c, 0x64,
      ]);
      final result = decoder.decode(encodedMessage);
      expect(result.version, equals(1));
      expect(result.content, equals('Hello\nworld'));
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
        0x01,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x09,
      ]);
      expect(() => decoder.decode(encodedMessage), throwsA(isA<SolanaError>()));
    });

    test('throws when decoding with a version other than 1', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x00, // version 0, not 1
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x0a, 0x77, 0x6f, 0x72, 0x6c, 0x64,
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

    test('throws when decoding with duplicate signatories', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x01,
        0x02,
        ...signerABytes,
        ...signerABytes, // duplicate
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x0a, 0x77, 0x6f, 0x72, 0x6c, 0x64,
      ]);
      expect(
        () => decoder.decode(encodedMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageSignatoriesMustBeUnique,
          ),
        ),
      );
    });

    test('throws when decoding with an unsupported version', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0xff,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x0a,
        0x77,
        0x6f,
        0x72,
        0x6c,
        0x64,
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

    test('throws when required signers length is zero', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x01,
        0x00, // zero signers
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x0a, 0x77, 0x6f, 0x72, 0x6c, 0x64,
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

    test('throws when message content length is zero', () {
      final encodedMessage = Uint8List.fromList([
        ...signingDomainBytes,
        0x01,
        0x02,
        ...signerABytes,
        ...signerBBytes,
        // No message content
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
  });

  group('getOffchainMessageV1Encoder()', () {
    late Encoder<OffchainMessageV1> encoder;
    setUp(() {
      encoder = getOffchainMessageV1Encoder();
    });

    test('encodes a well-formed message according to spec', () {
      const offchainMessage = OffchainMessageV1(
        content: 'Hello\nworld',
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
            0x01,
            0x02,
            ...signerABytes,
            ...signerBBytes,
            0x48,
            0x65,
            0x6c,
            0x6c,
            0x6f,
            0x0a,
            0x77,
            0x6f,
            0x72,
            0x6c,
            0x64,
          ]),
        ),
      );
    });

    test('encodes a well-formed UTF-8 message according to spec', () {
      const offchainMessage = OffchainMessageV1(
        content: '\u{270c}\u{1f3ff}cool',
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
            0x01,
            0x02,
            ...signerABytes,
            ...signerBBytes,
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

    test('throws when encoding with no required signers', () {
      const offchainMessage = OffchainMessageV1(
        content: 'Hello\nworld',
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

    test('throws when message content length is zero', () {
      const offchainMessage = OffchainMessageV1(
        content: '',
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

    test('throws when there are duplicate signatories', () {
      const offchainMessage = OffchainMessageV1(
        content: 'Hello\nworld',
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerA),
        ],
      );
      expect(
        () => encoder.encode(offchainMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageSignatoriesMustBeUnique,
          ),
        ),
      );
    });

    test('sorts the signatories in lexicographical order', () {
      const offchainMessage = OffchainMessageV1(
        content: 'Hello\nworld',
        requiredSignatories: [
          // Out of order
          OffchainMessageSignatory(address: signerB),
          OffchainMessageSignatory(address: signerA),
        ],
      );
      final result = encoder.encode(offchainMessage);
      expect(
        result,
        equals(
          Uint8List.fromList([
            ...signingDomainBytes,
            0x01,
            0x02,
            // signerA comes first (sorted)
            ...signerABytes,
            ...signerBBytes,
            0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x0a, 0x77, 0x6f, 0x72, 0x6c, 0x64,
          ]),
        ),
      );
    });
  });
}
