import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:test/test.dart';

void main() {
  group('barrel exports', () {
    test('program address is accessible', () {
      expect(addressLookupTableProgramAddress.value, isNotEmpty);
    });

    test('instruction enum has all variants', () {
      expect(AddressLookupTableInstruction.values, hasLength(5));
    });

    test('instruction builders are callable', () {
      const addr = Address('11111111111111111111111111111111');

      final createIx = getCreateLookupTableInstruction(
        address: addr,
        authority: addr,
        payer: addr,
        recentSlot: BigInt.one,
        bump: 0,
      );
      expect(
        createIx.programAddress,
        equals(addressLookupTableProgramAddress),
      );

      final freezeIx = getFreezeLookupTableInstruction(
        address: addr,
        authority: addr,
      );
      expect(
        freezeIx.programAddress,
        equals(addressLookupTableProgramAddress),
      );

      final extendIx = getExtendLookupTableInstruction(
        address: addr,
        authority: addr,
        payer: addr,
        addresses: const [addr],
      );
      expect(
        extendIx.programAddress,
        equals(addressLookupTableProgramAddress),
      );

      final deactivateIx = getDeactivateLookupTableInstruction(
        address: addr,
        authority: addr,
      );
      expect(
        deactivateIx.programAddress,
        equals(addressLookupTableProgramAddress),
      );

      final closeIx = getCloseLookupTableInstruction(
        address: addr,
        authority: addr,
        recipient: addr,
      );
      expect(
        closeIx.programAddress,
        equals(addressLookupTableProgramAddress),
      );
    });

    test('account data codec is accessible', () {
      final codec = getAddressLookupTableAccountDataCodec();
      expect(codec, isNotNull);
    });
  });
}
