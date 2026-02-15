import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('getSignaturesEncoderWithSizePrefix', () {
    test('throws when encoding an empty signatures map', () {
      final encoder = getSignaturesEncoderWithSizePrefix();
      expect(
        () => encoder.encode(const {}),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionCannotEncodeWithEmptySignatures,
          ),
        ),
      );
    });

    test('encodes a single null signature as 64 zero bytes', () {
      final encoder = getSignaturesEncoderWithSizePrefix();
      final encoded = encoder.encode(const {
        Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): null,
      });
      // 1 byte prefix (count=1) + 64 bytes signature = 65 bytes.
      expect(encoded.length, 65);
      // First byte is the shortU16-encoded count (1).
      expect(encoded[0], 1);
      // The remaining 64 bytes should all be zero.
      for (var i = 1; i < 65; i++) {
        expect(encoded[i], 0, reason: 'byte at index $i should be 0');
      }
    });

    test('encodes a non-null signature correctly', () {
      final sigBytes = SignatureBytes(
        Uint8List.fromList(List<int>.filled(64, 0xff)),
      );
      final encoder = getSignaturesEncoderWithSizePrefix();
      final encoded = encoder.encode({
        const Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): sigBytes,
      });
      expect(encoded.length, 65);
      expect(encoded[0], 1);
      for (var i = 1; i < 65; i++) {
        expect(encoded[i], 0xff);
      }
    });

    test('encodes multiple signatures', () {
      final sigA = SignatureBytes(Uint8List.fromList(List<int>.filled(64, 1)));
      final sigB = SignatureBytes(Uint8List.fromList(List<int>.filled(64, 2)));
      final encoder = getSignaturesEncoderWithSizePrefix();
      final encoded = encoder.encode({
        const Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): sigA,
        const Address('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'): sigB,
      });
      // 1 byte prefix (count=2) + 128 bytes = 129 bytes.
      expect(encoded.length, 129);
      expect(encoded[0], 2);
      // First signature: all 1s.
      for (var i = 1; i < 65; i++) {
        expect(encoded[i], 1);
      }
      // Second signature: all 2s.
      for (var i = 65; i < 129; i++) {
        expect(encoded[i], 2);
      }
    });

    test('encodes mixed null and non-null signatures', () {
      final sigA = SignatureBytes(
        Uint8List.fromList(List<int>.filled(64, 0xab)),
      );
      final encoder = getSignaturesEncoderWithSizePrefix();
      final encoded = encoder.encode({
        const Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): sigA,
        const Address('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'): null,
      });
      expect(encoded.length, 129);
      expect(encoded[0], 2);
      // First signature: all 0xab.
      for (var i = 1; i < 65; i++) {
        expect(encoded[i], 0xab);
      }
      // Second signature: all zeros (null).
      for (var i = 65; i < 129; i++) {
        expect(encoded[i], 0);
      }
    });

    test('getSizeFromValue returns correct size', () {
      final encoder = getSignaturesEncoderWithSizePrefix();
      final size = encoder.getSizeFromValue(const {
        Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): null,
        Address('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'): null,
      });
      // 1 byte prefix (count=2) + 128 bytes = 129 bytes.
      expect(size, 129);
    });
  });
}
