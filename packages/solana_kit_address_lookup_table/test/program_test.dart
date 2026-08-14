import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:test/test.dart';

void main() {
  group('AddressLookupTable program', () {
    test('exposes the program address constant', () {
      expect(
        addressLookupTableProgramAddress.value,
        equals('AddressLookupTab1e1111111111111111111111111'),
      );
    });

    test('AddressLookupTableInstruction enum lists all known instructions', () {
      final names = <String>{
        for (final e in AddressLookupTableInstruction.values) e.name,
      };
      expect(
        names,
        equals(<String>{
          'createLookupTable',
          'freezeLookupTable',
          'extendLookupTable',
          'deactivateLookupTable',
          'closeLookupTable',
        }),
      );
    });

    test(
      'AddressLookupTableAccount enum lists the AddressLookupTable account',
      () {
        expect(
          AddressLookupTableAccount.values.map((e) => e.name).toList(),
          equals(<String>['addressLookupTable']),
        );
      },
    );
  });
}
