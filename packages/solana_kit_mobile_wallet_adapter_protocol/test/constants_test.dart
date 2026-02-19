import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('MWA constants', () {
    test('retry delay schedule has 8 entries', () {
      expect(mwaRetryDelayScheduleMs, hasLength(8));
    });

    test('retry delay schedule starts at 150ms', () {
      expect(mwaRetryDelayScheduleMs.first, 150);
    });

    test('retry delay schedule ends at 1000ms', () {
      expect(mwaRetryDelayScheduleMs.last, 1000);
    });

    test('connection timeout is 30 seconds', () {
      expect(mwaConnectionTimeoutMs, 30000);
    });

    test('port range spans dynamic/private range', () {
      expect(mwaMinAssociationPort, 49152);
      expect(mwaMaxAssociationPort, 65535);
    });

    test('max sequence number is 2^32', () {
      expect(mwaMaxSequenceNumber, 4294967296);
    });

    test('max reflector ID is 2^53 - 1', () {
      expect(mwaMaxReflectorId, 9007199254740991);
    });

    test('public key length is 65 bytes for X9.62 uncompressed', () {
      expect(mwaPublicKeyLengthBytes, 65);
    });

    test('sequence number is 4 bytes', () {
      expect(mwaSequenceNumberBytes, 4);
    });

    test('IV is 12 bytes', () {
      expect(mwaIvBytes, 12);
    });

    test('GCM tag is 128 bits', () {
      expect(mwaGcmTagBits, 128);
    });
  });
}
