import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  group('getOffchainMessageDecoder()', () {
    late Decoder<OffchainMessage> decoder;
    setUp(() {
      decoder = getOffchainMessageDecoder();
    });

    test('decodes a version 0 message', () {
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
      final result = decoder.decode(encodedMessage);
      expect(result, isA<OffchainMessageV0>());
      expect(result.version, equals(0));
      final v0 = result as OffchainMessageV0;
      expect(v0.content.text, equals('Hello world'));
    });

    test('decodes a version 1 message', () {
      final encodedMessage = Uint8List.fromList([
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
      ]);
      final result = decoder.decode(encodedMessage);
      expect(result, isA<OffchainMessageV1>());
      expect(result.version, equals(1));
      final v1 = result as OffchainMessageV1;
      expect(v1.content, equals('Hello\nworld'));
    });

    for (var version = 2; version < 256; version++) {
      test('throws for unsupported version $version', () {
        final encodedMessage = Uint8List.fromList([
          ...signingDomainBytes,
          version,
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
    }
  });

  group('getOffchainMessageEncoder()', () {
    late Encoder<OffchainMessage> encoder;
    setUp(() {
      encoder = getOffchainMessageEncoder();
    });

    test('encodes a version 0 message', () {
      const OffchainMessage offchainMessage = OffchainMessageV0(
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
      expect(result.isNotEmpty, isTrue);
      // Version byte should be 0 after the signing domain.
      expect(result[16], equals(0));
    });

    test('encodes a version 1 message', () {
      const OffchainMessage offchainMessage = OffchainMessageV1(
        content: 'Hello\nworld',
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      final result = encoder.encode(offchainMessage);
      expect(result.isNotEmpty, isTrue);
      // Version byte should be 1 after the signing domain.
      expect(result[16], equals(1));
    });
  });

  group('round-trip', () {
    test('v0 message encodes and decodes correctly', () {
      const originalMessage = OffchainMessageV0(
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
      final codec = getOffchainMessageCodec();
      final encoded = codec.encode(originalMessage);
      final decoded = codec.decode(encoded);
      expect(decoded, isA<OffchainMessageV0>());
      final v0 = decoded as OffchainMessageV0;
      expect(v0.content.text, equals('Hello world'));
      expect(
        v0.content.format,
        equals(OffchainMessageContentFormat.restrictedAscii1232BytesMax),
      );
      expect(v0.applicationDomain.value, equals(applicationDomain.value));
      expect(v0.requiredSignatories.length, equals(2));
    });

    test('v1 message encodes and decodes correctly', () {
      const originalMessage = OffchainMessageV1(
        content: 'Hello\nworld',
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      final codec = getOffchainMessageCodec();
      final encoded = codec.encode(originalMessage);
      final decoded = codec.decode(encoded);
      expect(decoded, isA<OffchainMessageV1>());
      final v1 = decoded as OffchainMessageV1;
      expect(v1.content, equals('Hello\nworld'));
      expect(v1.requiredSignatories.length, equals(2));
    });
  });
}
