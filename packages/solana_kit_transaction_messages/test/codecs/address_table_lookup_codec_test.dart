import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  // k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn decodes to [11{32}]
  const lookupTableAddress = Address('k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn');

  group('Address table lookup encoder', () {
    test('serializes an AddressTableLookup according to the spec', () {
      final encoder = getAddressTableLookupEncoder();
      final result = encoder.encode(
        const AddressTableLookup(
          lookupTableAddress: lookupTableAddress,
          writableIndexes: [44],
          readonlyIndexes: [33, 22],
        ),
      );
      expect(
        result,
        equals(
          Uint8List.fromList([
            // Lookup table account address (32 bytes of 11)
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            // Compact array of writable indices
            1, // Compact-u16 length
            44, // Writable index
            // Compact array of read-only indices
            2, // Compact-u16 length
            33, 22, // Read-only indices
          ]),
        ),
      );
    });
  });

  group('Address table lookup decoder', () {
    test('deserializes an AddressTableLookup according to the spec', () {
      final decoder = getAddressTableLookupDecoder();
      final byteArray = Uint8List.fromList([
        // Lookup table account address (32 bytes of 11)
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        // Compact array of writable indices
        1, // Compact-u16 length
        44, // Writable index
        // Compact array of read-only indices
        2, // Compact-u16 length
        33, 22, // Read-only indices
      ]);
      final (lookup, offset) = decoder.read(byteArray, 0);
      expect(lookup.lookupTableAddress, equals(lookupTableAddress));
      expect(lookup.writableIndexes, equals([44]));
      expect(lookup.readonlyIndexes, equals([33, 22]));
      // Expect the entire byte array to have been consumed.
      expect(offset, equals(byteArray.length));
    });
  });

  group('Address table lookup codec', () {
    test('round-trips an AddressTableLookup', () {
      final codec = getAddressTableLookupCodec();
      const lookup = AddressTableLookup(
        lookupTableAddress: lookupTableAddress,
        writableIndexes: [1, 2, 3],
        readonlyIndexes: [4, 5],
      );
      final encoded = codec.encode(lookup);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(lookup));
    });
  });
}
