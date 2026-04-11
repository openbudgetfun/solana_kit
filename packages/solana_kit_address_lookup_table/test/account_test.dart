import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:test/test.dart';

void main() {
  group('AddressLookupTableAccountData', () {
    test('encode/decode round-trips with authority', () {
      const authority = Address('Auth111111111111111111111111111111111111111');
      const addr1 = Address('11111111111111111111111111111111');
      const addr2 = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      final original = AddressLookupTableAccountData(
        deactivationSlot: BigInt.parse('18446744073709551615'), // u64::MAX
        lastExtendedSlot: BigInt.from(42),
        lastExtendedSlotStartIndex: 0,
        authority: authority,
        addresses: const [addr1, addr2],
      );

      final codec = getAddressLookupTableAccountDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(
        decoded.discriminator,
        equals(addressLookupTableAccountDiscriminator),
      );
      expect(decoded.authority, equals(authority));
      expect(decoded.addresses, hasLength(2));
      expect(decoded.addresses[0], equals(addr1));
      expect(decoded.addresses[1], equals(addr2));
    });

    test('encode/decode round-trips without authority (frozen)', () {
      final original = AddressLookupTableAccountData(
        deactivationSlot: BigInt.parse('18446744073709551615'),
        lastExtendedSlot: BigInt.from(100),
        lastExtendedSlotStartIndex: 5,
        addresses: const [],
      );

      final codec = getAddressLookupTableAccountDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.authority, isNull);
      expect(decoded.addresses, isEmpty);
    });

    test('header is 56 bytes without addresses', () {
      final encoder = getAddressLookupTableAccountDataEncoder();
      final bytes = encoder.encode(
        AddressLookupTableAccountData(
          deactivationSlot: BigInt.zero,
          lastExtendedSlot: BigInt.zero,
          lastExtendedSlotStartIndex: 0,
          addresses: const [],
        ),
      );
      // u32(4) + u64(8) + u64(8) + u8(1) + option(33) + padding(2) = 56
      expect(bytes.length, equals(56));
    });

    test('each address adds 32 bytes', () {
      const addr = Address('11111111111111111111111111111111');
      final encoder = getAddressLookupTableAccountDataEncoder();
      final bytesEmpty = encoder.encode(
        AddressLookupTableAccountData(
          deactivationSlot: BigInt.zero,
          lastExtendedSlot: BigInt.zero,
          lastExtendedSlotStartIndex: 0,
          addresses: const [],
        ),
      );
      final bytesOne = encoder.encode(
        AddressLookupTableAccountData(
          deactivationSlot: BigInt.zero,
          lastExtendedSlot: BigInt.zero,
          lastExtendedSlotStartIndex: 0,
          addresses: const [addr],
        ),
      );
      final bytesTwo = encoder.encode(
        AddressLookupTableAccountData(
          deactivationSlot: BigInt.zero,
          lastExtendedSlot: BigInt.zero,
          lastExtendedSlotStartIndex: 0,
          addresses: const [addr, addr],
        ),
      );
      expect(bytesOne.length - bytesEmpty.length, equals(32));
      expect(bytesTwo.length - bytesOne.length, equals(32));
    });

    test('discriminator is 1 at offset 0', () {
      final encoder = getAddressLookupTableAccountDataEncoder();
      final bytes = encoder.encode(
        AddressLookupTableAccountData(
          deactivationSlot: BigInt.zero,
          lastExtendedSlot: BigInt.zero,
          lastExtendedSlotStartIndex: 0,
          addresses: const [],
        ),
      );
      // u32 LE: 1
      expect(bytes[0], equals(1));
      expect(bytes[1], equals(0));
      expect(bytes[2], equals(0));
      expect(bytes[3], equals(0));
    });

    test('value equality', () {
      final a = AddressLookupTableAccountData(
        deactivationSlot: BigInt.from(100),
        lastExtendedSlot: BigInt.from(50),
        lastExtendedSlotStartIndex: 3,
        addresses: const [],
      );
      final b = AddressLookupTableAccountData(
        deactivationSlot: BigInt.from(100),
        lastExtendedSlot: BigInt.from(50),
        lastExtendedSlotStartIndex: 3,
        addresses: const [],
      );
      final c = AddressLookupTableAccountData(
        deactivationSlot: BigInt.from(200),
        lastExtendedSlot: BigInt.from(50),
        lastExtendedSlotStartIndex: 3,
        addresses: const [],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes field values', () {
      final data = AddressLookupTableAccountData(
        deactivationSlot: BigInt.from(42),
        lastExtendedSlot: BigInt.from(10),
        lastExtendedSlotStartIndex: 0,
        addresses: const [],
      );
      final str = data.toString();
      expect(str, contains('deactivationSlot: 42'));
      expect(str, contains('lastExtendedSlot: 10'));
      expect(str, contains('discriminator: 1'));
    });
  });
}
