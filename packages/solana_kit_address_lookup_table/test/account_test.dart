import 'dart:typed_data';

import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:test/test.dart';

const _authority = Address('GsbwXfJraMomNxBcpR3DBFsMki6Djb89kBbHFwNVBgkw');
const _otherAddress = Address('Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB');

/// Helper that compares two `AddressLookupTable` structs field-by-field.
///
/// The generated `@immutable` struct overrides `==` but compares the
/// `addresses: List<Address>` field via Dart's reference equality. Lists
/// produced by a fresh codec decoder are new instances even when they wrap
/// the same addresses, so we compare fields individually in tests.
void expectTablesEqual(
  AddressLookupTable actual,
  AddressLookupTable expected,
) {
  expect(actual.discriminator, equals(expected.discriminator));
  expect(actual.deactivationSlot, equals(expected.deactivationSlot));
  expect(actual.lastExtendedSlot, equals(expected.lastExtendedSlot));
  expect(
    actual.lastExtendedSlotStartIndex,
    equals(expected.lastExtendedSlotStartIndex),
  );
  expect(actual.authority, equals(expected.authority));
  expect(actual.padding, equals(expected.padding));
  expect(actual.addresses, equals(expected.addresses));
}

void main() {
  group('AddressLookupTable account', () {
    test('encodes and decodes back to equal values', () {
      final original = AddressLookupTable(
        discriminator: 1,
        deactivationSlot: BigInt.zero,
        lastExtendedSlot: BigInt.from(42),
        lastExtendedSlotStartIndex: 16,
        authority: _authority,
        padding: 0,
        addresses: const <Address>[_otherAddress],
      );
      final codec = getAddressLookupTableCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(Uint8List.fromList(encoded));

      expectTablesEqual(decoded, original);
    });

    test('accepts a nullable authority in the round-trip', () {
      final original = AddressLookupTable(
        discriminator: 1,
        deactivationSlot: BigInt.from(99),
        lastExtendedSlot: BigInt.zero,
        lastExtendedSlotStartIndex: 0,
        authority: null,
        padding: 0,
        addresses: const <Address>[],
      );
      final codec = getAddressLookupTableCodec();
      final decoded = codec.decode(Uint8List.fromList(codec.encode(original)));
      expectTablesEqual(decoded, original);
      expect(decoded.authority, isNull);
    });

    test('encoder + decoder compose the same as codec', () {
      final original = AddressLookupTable(
        discriminator: 1,
        deactivationSlot: BigInt.zero,
        lastExtendedSlot: BigInt.zero,
        lastExtendedSlotStartIndex: 0,
        authority: _authority,
        padding: 0,
        addresses: const <Address>[_otherAddress, _authority],
      );
      final encoded = getAddressLookupTableEncoder().encode(original);
      final decoded = getAddressLookupTableDecoder().decode(
        Uint8List.fromList(encoded),
      );
      expectTablesEqual(decoded, original);
    });

    test('struct fields and toString are available', () {
      final table = AddressLookupTable(
        discriminator: 1,
        deactivationSlot: BigInt.zero,
        lastExtendedSlot: BigInt.zero,
        lastExtendedSlotStartIndex: 0,
        authority: null,
        padding: 0,
        addresses: const <Address>[],
      );
      expect(table.discriminator, 1);
      expect(table.authority, isNull);
      expect(table.addresses, isEmpty);
      expect(table.toString(), contains('AddressLookupTable('));
    });
  });
}
