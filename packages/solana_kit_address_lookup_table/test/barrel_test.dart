import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:test/test.dart';

const _authority = Address('GsbwXfJraMomNxBcpR3DBFsMki6Djb89kBbHFwNVBgkw');
const _payer = Address('11111111111111111111111111111112');
const _tableAddress = Address('AKptnhx5oMn2sX9qZ7wH5d7mN3o2cF8u1nYxBcVx5Bpa');
void main() {
  group('barrel exports', () {
    test('program address is re-exported from solana_kit_address_constants', () {
      // The generated programs file re-exports the canonical program address
      // from `solana_kit_address_constants`, so both the SDK-wide constant and
      // the package-local `addressLookupTableProgramAddress` resolve to the
      // same name. Here we verify the import resolves and has the expected
      // upstream IDL base58 value.
      expect(
        addressLookupTableProgramAddress.value,
        equals('AddressLookupTab1e1111111111111111111111111'),
      );
    });

    test('instruction helpers are callable', () {
      final ix = getCreateLookupTableInstruction(
        programAddress: addressLookupTableProgramAddress,
        address: _tableAddress,
        authority: _authority,
        payer: _payer,
        systemProgram: systemProgramAddress,
        recentSlot: BigInt.from(42),
        bump: 255,
      );

      expect(ix.programAddress, equals(addressLookupTableProgramAddress));
      expect(
        parseCreateLookupTableInstruction(ix).recentSlot,
        equals(BigInt.from(42)),
      );
      expect(
        parseCreateLookupTableInstruction(ix).bump,
        equals(255),
      );
    });

    test('account codec is exported', () {
      final codec = getAddressLookupTableCodec();
      expect(codec, isNotNull);
    });

    test('enums are exported', () {
      expect(AddressLookupTableInstruction.values.length, 5);
      expect(AddressLookupTableAccount.values.length, 1);
    });
  });
}
