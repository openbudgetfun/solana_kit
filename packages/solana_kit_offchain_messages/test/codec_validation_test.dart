import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:solana_kit_offchain_messages/src/codecs/content_format.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

/// Builds a v1 message from a raw signatory list so malformed orderings and
/// duplicates can be exercised without going through the encoder, which
/// rejects them.
Uint8List _v1Message(List<Uint8List> signatories) {
  return Uint8List.fromList([
    ...signingDomainBytes,
    0x01,
    signatories.length,
    ...signatories.expand((bytes) => bytes),
    0x68,
    0x69,
  ]);
}

Matcher _throwsCode(SolanaErrorCode code) => throwsA(
  isA<SolanaError>().having((error) => error.code, 'code', equals(code)),
);

void main() {
  group('getOffchainMessageContentFormatDecoder()', () {
    test('decodes every recognized format at its boundary', () {
      final decoder = getOffchainMessageContentFormatDecoder();
      expect(
        decoder.decode(Uint8List.fromList([0x00])),
        equals(OffchainMessageContentFormat.restrictedAscii1232BytesMax),
      );
      expect(
        decoder.decode(Uint8List.fromList([0x02])),
        equals(OffchainMessageContentFormat.utf865535BytesMax),
      );
    });

    test('rejects a format value above the highest recognized format', () {
      final decoder = getOffchainMessageContentFormatDecoder();
      expect(
        () => decoder.decode(Uint8List.fromList([0x03])),
        throwsFormatException,
      );
    });
  });

  group('getOffchainMessageSigningDomainDecoder()', () {
    test('accepts the signing domain bytes', () {
      final decoder = getOffchainMessageSigningDomainDecoder();
      expect(decoder.read(Uint8List.fromList(signingDomainBytes), 0).$2, 16);
    });

    test('rejects a mismatched signing domain', () {
      final decoder = getOffchainMessageSigningDomainDecoder();
      expect(
        () => decoder.decode(Uint8List.fromList(List.filled(16, 0x00))),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('offchain message application domain', () {
    test('accepts a domain within the allowed length', () {
      expect(
        offchainMessageApplicationDomain(
          applicationDomain.value,
        ).value,
        equals(applicationDomain.value),
      );
    });

    test('rejects a domain longer than the allowed length', () {
      expect(
        () => offchainMessageApplicationDomain('a' * 33),
        throwsA(isA<SolanaError>()),
      );
    });

    test('encoder rejects an invalid domain', () {
      final encoder = getOffchainMessageApplicationDomainEncoder();
      expect(
        () => encoder.encode(OffchainMessageApplicationDomain('a' * 33)),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('v1 signatory validation on decode', () {
    late Decoder<OffchainMessageV1> decoder;
    setUp(() {
      decoder = getOffchainMessageV1Decoder();
    });

    test('accepts sorted, unique signatories', () {
      final result = decoder.decode(_v1Message([signerABytes, signerBBytes]));
      expect(result.requiredSignatories.length, equals(2));
      expect(result.content, equals('hi'));
    });

    test('rejects signatories that are not sorted', () {
      expect(
        () => decoder.decode(_v1Message([signerBBytes, signerABytes])),
        _throwsCode(SolanaErrorCode.offchainMessageSignatoriesMustBeSorted),
      );
    });

    test('rejects duplicate signatories', () {
      expect(
        () => decoder.decode(_v1Message([signerABytes, signerABytes])),
        _throwsCode(SolanaErrorCode.offchainMessageSignatoriesMustBeUnique),
      );
    });

    test('rejects an empty signatory list', () {
      expect(
        () => decoder.decode(_v1Message(const [])),
        _throwsCode(
          SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
        ),
      );
    });
  });

  group('v1 signatory validation on encode', () {
    late Encoder<OffchainMessageV1> encoder;
    setUp(() {
      encoder = getOffchainMessageV1Encoder();
    });

    test('rejects an empty signatory list', () {
      expect(
        () => encoder.encode(
          const OffchainMessageV1(content: 'hi', requiredSignatories: []),
        ),
        _throwsCode(
          SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
        ),
      );
    });

    test('rejects duplicate signatories', () {
      expect(
        () => encoder.encode(
          const OffchainMessageV1(
            content: 'hi',
            requiredSignatories: [
              OffchainMessageSignatory(address: signerA),
              OffchainMessageSignatory(address: signerA),
            ],
          ),
        ),
        _throwsCode(SolanaErrorCode.offchainMessageSignatoriesMustBeUnique),
      );
    });

    test('sorts signatories when encoding', () {
      final bytes = encoder.encode(
        const OffchainMessageV1(
          content: 'hi',
          requiredSignatories: [
            OffchainMessageSignatory(address: signerB),
            OffchainMessageSignatory(address: signerA),
          ],
        ),
      );
      expect(
        decodeRequiredSignatoryAddresses(bytes).map((a) => a.value).toList(),
        equals([signerA.value, signerB.value]),
      );
    });
  });

  group('codec factories round-trip', () {
    test('getOffchainMessageContentFormatCodec()', () {
      final codec = getOffchainMessageContentFormatCodec();
      for (final format in OffchainMessageContentFormat.values) {
        expect(codec.decode(codec.encode(format)), equals(format));
      }
    });

    test('getOffchainMessageSigningDomainCodec()', () {
      final codec = getOffchainMessageSigningDomainCodec();
      expect(
        codec.encode(null),
        equals(Uint8List.fromList(signingDomainBytes)),
      );
      expect(codec.read(Uint8List.fromList(signingDomainBytes), 0).$2, 16);
    });

    test('getOffchainMessageApplicationDomainCodec()', () {
      final codec = getOffchainMessageApplicationDomainCodec();
      expect(
        codec.decode(codec.encode(applicationDomain)),
        equals(applicationDomain),
      );
    });
  });

  group('isOffchainMessageApplicationDomain()', () {
    test('accepts a base58 string that decodes to 32 bytes', () {
      expect(
        isOffchainMessageApplicationDomain(applicationDomain.value),
        isTrue,
      );
    });

    test('rejects a string of the wrong length', () {
      expect(isOffchainMessageApplicationDomain('a' * 33), isFalse);
    });
  });
}
