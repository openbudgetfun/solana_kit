import 'dart:typed_data';

import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

void main() {
  group('identifyAddressLookupTableInstruction', () {
    test('identifies CreateLookupTable (disc 0)', () {
      final data = Uint8List.fromList([0, 0, 0, 0, ...List.filled(9, 0)]);
      expect(
        identifyAddressLookupTableInstruction(data),
        equals(AddressLookupTableInstruction.createLookupTable),
      );
    });

    test('identifies FreezeLookupTable (disc 1)', () {
      final data = Uint8List.fromList([1, 0, 0, 0]);
      expect(
        identifyAddressLookupTableInstruction(data),
        equals(AddressLookupTableInstruction.freezeLookupTable),
      );
    });

    test('identifies ExtendLookupTable (disc 2)', () {
      final data = Uint8List.fromList([2, 0, 0, 0, ...List.filled(8, 0)]);
      expect(
        identifyAddressLookupTableInstruction(data),
        equals(AddressLookupTableInstruction.extendLookupTable),
      );
    });

    test('identifies DeactivateLookupTable (disc 3)', () {
      final data = Uint8List.fromList([3, 0, 0, 0]);
      expect(
        identifyAddressLookupTableInstruction(data),
        equals(AddressLookupTableInstruction.deactivateLookupTable),
      );
    });

    test('identifies CloseLookupTable (disc 4)', () {
      final data = Uint8List.fromList([4, 0, 0, 0]);
      expect(
        identifyAddressLookupTableInstruction(data),
        equals(AddressLookupTableInstruction.closeLookupTable),
      );
    });

    test('throws on data too short for u32 discriminator', () {
      expect(
        () => identifyAddressLookupTableInstruction(Uint8List.fromList([0])),
        throwsArgumentError,
      );
    });

    test('throws on empty data', () {
      expect(
        () => identifyAddressLookupTableInstruction(Uint8List(0)),
        throwsArgumentError,
      );
    });

    test('throws on unknown discriminator', () {
      final data = Uint8List.fromList([255, 0, 0, 0]);
      expect(
        () => identifyAddressLookupTableInstruction(data),
        throwsArgumentError,
      );
    });
  });

  group('parseAddressLookupTableInstruction', () {
    test('parses CreateLookupTable instruction', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');
      const payer = Address('Payer11111111111111111111111111111111111111');

      final ix = getCreateLookupTableInstruction(
        address: tableAddr,
        authority: authority,
        payer: payer,
        recentSlot: BigInt.from(999),
        bump: 128,
      );
      final parsed = parseAddressLookupTableInstruction(ix);
      expect(parsed, isA<ParsedCreateLookupTable>());
      final typed = parsed as ParsedCreateLookupTable;
      expect(
        typed.instructionType,
        equals(AddressLookupTableInstruction.createLookupTable),
      );
      expect(typed.data.recentSlot, equals(BigInt.from(999)));
      expect(typed.data.bump, equals(128));
    });

    test('parses FreezeLookupTable instruction', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');

      final ix = getFreezeLookupTableInstruction(
        address: tableAddr,
        authority: authority,
      );
      final parsed = parseAddressLookupTableInstruction(ix);
      expect(parsed, isA<ParsedFreezeLookupTable>());
      final typed = parsed as ParsedFreezeLookupTable;
      expect(
        typed.instructionType,
        equals(AddressLookupTableInstruction.freezeLookupTable),
      );
    });

    test('parses ExtendLookupTable instruction', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');
      const payer = Address('Payer11111111111111111111111111111111111111');
      const addr1 = Address('11111111111111111111111111111111');

      final ix = getExtendLookupTableInstruction(
        address: tableAddr,
        authority: authority,
        payer: payer,
        addresses: [addr1],
      );
      final parsed = parseAddressLookupTableInstruction(ix);
      expect(parsed, isA<ParsedExtendLookupTable>());
      final typed = parsed as ParsedExtendLookupTable;
      expect(
        typed.instructionType,
        equals(AddressLookupTableInstruction.extendLookupTable),
      );
      expect(typed.data.addresses, hasLength(1));
      expect(typed.data.addresses[0], equals(addr1));
    });

    test('parses DeactivateLookupTable instruction', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');

      final ix = getDeactivateLookupTableInstruction(
        address: tableAddr,
        authority: authority,
      );
      final parsed = parseAddressLookupTableInstruction(ix);
      expect(parsed, isA<ParsedDeactivateLookupTable>());
      final typed = parsed as ParsedDeactivateLookupTable;
      expect(
        typed.instructionType,
        equals(AddressLookupTableInstruction.deactivateLookupTable),
      );
    });

    test('parses CloseLookupTable instruction', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');
      const recipient = Address('Recip11111111111111111111111111111111111111');

      final ix = getCloseLookupTableInstruction(
        address: tableAddr,
        authority: authority,
        recipient: recipient,
      );
      final parsed = parseAddressLookupTableInstruction(ix);
      expect(parsed, isA<ParsedCloseLookupTable>());
      final typed = parsed as ParsedCloseLookupTable;
      expect(
        typed.instructionType,
        equals(AddressLookupTableInstruction.closeLookupTable),
      );
    });

    test('throws on instruction with no data', () {
      const ix = Instruction(
        programAddress: addressLookupTableProgramAddress,
        accounts: [],
      );
      expect(
        () => parseAddressLookupTableInstruction(ix),
        throwsArgumentError,
      );
    });

    test('throws on instruction with unknown discriminator', () {
      final ix = Instruction(
        programAddress: addressLookupTableProgramAddress,
        accounts: const [],
        data: Uint8List.fromList([99, 0, 0, 0]),
      );
      expect(
        () => parseAddressLookupTableInstruction(ix),
        throwsArgumentError,
      );
    });
  });

  group('custom program address', () {
    test('CreateLookupTable uses custom address when provided', () {
      const custom = Address('11111111111111111111111111111111');
      final ix = getCreateLookupTableInstruction(
        address: custom,
        authority: custom,
        payer: custom,
        recentSlot: BigInt.one,
        bump: 0,
        programAddress: custom,
      );
      expect(ix.programAddress, equals(custom));
    });

    test('ExtendLookupTable uses custom address when provided', () {
      const custom = Address('11111111111111111111111111111111');
      final ix = getExtendLookupTableInstruction(
        address: custom,
        authority: custom,
        payer: custom,
        addresses: const [],
        programAddress: custom,
      );
      expect(ix.programAddress, equals(custom));
    });
  });
}
