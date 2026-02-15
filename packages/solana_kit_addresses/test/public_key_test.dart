import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:test/test.dart';

void main() {
  // Corresponds to address 'DcESq8KFcdTdpjWtr2DoGcvu5McM3VJoBetgM1X1vVct'
  final mockPublicKeyBytes = Uint8List.fromList([
    0xbb, 0x52, 0xc6, 0x2d, 0x52, 0x4f, 0x7f, 0xea, //
    0x4f, 0x2c, 0x27, 0x13, 0xd6, 0x20, 0x80, 0xad,
    0x6a, 0x36, 0x9a, 0x0e, 0x36, 0x71, 0x74, 0x32,
    0x8d, 0x1a, 0xf7, 0xee, 0x7e, 0x04, 0x76, 0x19,
  ]);

  group('getAddressFromPublicKey', () {
    test('returns the address corresponding to a given public key', () {
      final addr = getAddressFromPublicKey(mockPublicKeyBytes);
      expect(
        addr.value,
        equals('DcESq8KFcdTdpjWtr2DoGcvu5McM3VJoBetgM1X1vVct'),
      );
    });
  });

  group('getPublicKeyFromAddress', () {
    test('returns the public key bytes for a given address', () {
      final addr = address('DcESq8KFcdTdpjWtr2DoGcvu5McM3VJoBetgM1X1vVct');
      final bytes = getPublicKeyFromAddress(addr);
      expect(bytes, equals(mockPublicKeyBytes));
    });

    test('round-trips with getAddressFromPublicKey', () {
      final addr = getAddressFromPublicKey(mockPublicKeyBytes);
      final bytes = getPublicKeyFromAddress(addr);
      expect(bytes, equals(mockPublicKeyBytes));
    });
  });
}
