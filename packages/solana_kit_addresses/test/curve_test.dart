import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  final offCurveKeyBytes = [
    Uint8List.fromList([
      0, 121, 240, 130, 166, 28, 199, 78, 165, 226, 171, 237, 100, 187, //
      247, 95, 50, 251, 221, 83, 122, 255, 247, 82, 87, 237, 103, 22,
      201, 227, 114, 153,
    ]),
    Uint8List.fromList([
      194, 222, 197, 61, 68, 225, 252, 198, 155, 150, 247, 44, 45, 10, //
      115, 8, 12, 50, 138, 12, 106, 199, 75, 172, 159, 87, 94, 122,
      251, 246, 136, 75,
    ]),
  ];

  final onCurveKeyBytes = [
    Uint8List.fromList([
      107, 141, 87, 175, 101, 27, 216, 58, 238, 95, 193, 175, 21, 151, //
      207, 102, 28, 107, 157, 178, 69, 77, 203, 89, 199, 77, 162, 19,
      27, 108, 57, 155,
    ]),
    Uint8List.fromList([
      52, 94, 161, 109, 55, 62, 164, 12, 183, 165, 56, 112, 86, 103, //
      19, 109, 196, 33, 93, 42, 143, 6, 221, 172, 173, 21, 130, 96,
      170, 101, 82, 200,
    ]),
  ];

  final onCurveAddresses = [
    address('nick6zJc6HpW3kfBm4xS2dmbuVRyb5F3AnUvj5ymzR5'),
    address('11111111111111111111111111111111'),
    address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
    address('SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf'),
  ];

  final offCurveAddresses = [
    address('CCMCWh4FudPEmY6Q1AVi5o8mQMXkHYkJUmZfzRGdcJ9P'),
    address('2DRxyJDsDccGL6mb8PLMsKQTCU3C7xUq8aprz53VcW4k'),
  ];

  group('compressedPointBytesAreOnCurve', () {
    for (var i = 0; i < offCurveKeyBytes.length; i++) {
      test('returns false when a public key does not lie on the Ed25519 curve '
          '[$i]', () {
        expect(compressedPointBytesAreOnCurve(offCurveKeyBytes[i]), isFalse);
      });
    }

    for (var i = 0; i < onCurveKeyBytes.length; i++) {
      test('returns true when a public key lies on the Ed25519 curve [$i]', () {
        expect(compressedPointBytesAreOnCurve(onCurveKeyBytes[i]), isTrue);
      });
    }

    test('returns false for bytes that are not 32 bytes long', () {
      expect(compressedPointBytesAreOnCurve(Uint8List(31)), isFalse);
      expect(compressedPointBytesAreOnCurve(Uint8List(33)), isFalse);
    });
  });

  group('isOnCurveAddress', () {
    for (final addr in onCurveAddresses) {
      test('returns true for on-curve address ${addr.value}', () {
        expect(isOnCurveAddress(addr), isTrue);
      });
    }

    for (final addr in offCurveAddresses) {
      test('returns false for off-curve address ${addr.value}', () {
        expect(isOnCurveAddress(addr), isFalse);
      });
    }
  });

  group('isOffCurveAddress', () {
    for (final addr in offCurveAddresses) {
      test('returns true for off-curve address ${addr.value}', () {
        expect(isOffCurveAddress(addr), isTrue);
      });
    }

    for (final addr in onCurveAddresses) {
      test('returns false for on-curve address ${addr.value}', () {
        expect(isOffCurveAddress(addr), isFalse);
      });
    }
  });

  group('assertIsOnCurveAddress', () {
    test('does not throw for on-curve addresses', () {
      for (final addr in onCurveAddresses) {
        expect(() => assertIsOnCurveAddress(addr), returnsNormally);
      }
    });

    test('throws for off-curve addresses', () {
      for (final addr in offCurveAddresses) {
        expect(
          () => assertIsOnCurveAddress(addr),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesInvalidEd25519PublicKey,
            ),
          ),
        );
      }
    });
  });

  group('assertIsOffCurveAddress', () {
    test('does not throw for off-curve addresses', () {
      for (final addr in offCurveAddresses) {
        expect(() => assertIsOffCurveAddress(addr), returnsNormally);
      }
    });

    test('throws for on-curve addresses', () {
      for (final addr in onCurveAddresses) {
        expect(
          () => assertIsOffCurveAddress(addr),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesInvalidOffCurveAddress,
            ),
          ),
        );
      }
    });
  });
}
