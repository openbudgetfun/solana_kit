import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  group('compileOffchainMessageEnvelope()', () {
    test('compiles a v0 message into an envelope', () {
      const message = OffchainMessageV0(
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
      final envelope = compileOffchainMessageEnvelope(message);
      expect(envelope.content.isNotEmpty, isTrue);
      expect(envelope.signatures.length, equals(2));
      expect(envelope.signatures[signerA], isNull);
      expect(envelope.signatures[signerB], isNull);
    });

    test('compiles a v1 message into an envelope', () {
      const message = OffchainMessageV1(
        content: 'Hello\nworld',
        requiredSignatories: [
          OffchainMessageSignatory(address: signerA),
          OffchainMessageSignatory(address: signerB),
        ],
      );
      final envelope = compileOffchainMessageEnvelope(message);
      expect(envelope.content.isNotEmpty, isTrue);
      expect(envelope.signatures.length, equals(2));
      // The address values should match though the Address instances may
      // differ since v1 sorts signatories.
      expect(
        envelope.signatures.keys.any((k) => k.value == signerA.value),
        isTrue,
      );
      expect(
        envelope.signatures.keys.any((k) => k.value == signerB.value),
        isTrue,
      );
      // All signatures should be null.
      for (final sig in envelope.signatures.values) {
        expect(sig, isNull);
      }
    });

    test('content can be decoded back to the original message', () {
      const message = OffchainMessageV0(
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
      final envelope = compileOffchainMessageEnvelope(message);
      final decoded = getOffchainMessageV0Decoder().decode(envelope.content);
      expect(decoded.content.text, equals('Hello world'));
      expect(
        decoded.content.format,
        equals(OffchainMessageContentFormat.restrictedAscii1232BytesMax),
      );
      expect(decoded.applicationDomain.value, equals(applicationDomain.value));
    });
  });
}
