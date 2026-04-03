import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

void main() {
  const addr1 = Address('11111111111111111111111111111111');
  const addr2 = Address('22222222222222222222222222222222');
  const addr3 = Address('33333333333333333333333333333333');

  // ---------------------------------------------------------------------------
  // AccountMeta
  // ---------------------------------------------------------------------------
  group('AccountMeta equality', () {
    test('equal when address and role match', () {
      const a = AccountMeta(address: addr1, role: AccountRole.readonly);
      const b = AccountMeta(address: addr1, role: AccountRole.readonly);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when address differs', () {
      const a = AccountMeta(address: addr1, role: AccountRole.readonly);
      const b = AccountMeta(address: addr2, role: AccountRole.readonly);
      expect(a, isNot(equals(b)));
    });

    test('not equal when role differs', () {
      const a = AccountMeta(address: addr1, role: AccountRole.readonly);
      const b = AccountMeta(address: addr1, role: AccountRole.writable);
      expect(a, isNot(equals(b)));
    });

    test('identical instance equals itself', () {
      const a = AccountMeta(address: addr1, role: AccountRole.readonlySigner);
      expect(a, equals(a));
    });

    test('AccountLookupMeta does not equal AccountMeta with same address/role',
        () {
      const meta = AccountMeta(address: addr1, role: AccountRole.readonly);
      const lookup = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 0,
        lookupTableAddress: addr2,
      );
      // AccountMeta.== checks runtimeType, so these must not be equal.
      expect(meta, isNot(equals(lookup)));
    });

    test('toString contains fields', () {
      const a = AccountMeta(address: addr1, role: AccountRole.writable);
      expect(a.toString(), contains('AccountMeta'));
      expect(a.toString(), contains('writable'));
    });
  });

  // ---------------------------------------------------------------------------
  // AccountLookupMeta
  // ---------------------------------------------------------------------------
  group('AccountLookupMeta equality', () {
    test('equal when all fields match', () {
      const a = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 3,
        lookupTableAddress: addr2,
      );
      const b = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 3,
        lookupTableAddress: addr2,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when addressIndex differs', () {
      const a = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 1,
        lookupTableAddress: addr2,
      );
      const b = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 2,
        lookupTableAddress: addr2,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when lookupTableAddress differs', () {
      const a = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 0,
        lookupTableAddress: addr2,
      );
      const b = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 0,
        lookupTableAddress: addr3,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when address differs', () {
      const a = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 0,
        lookupTableAddress: addr2,
      );
      const b = AccountLookupMeta(
        address: addr3,
        role: AccountRole.readonly,
        addressIndex: 0,
        lookupTableAddress: addr2,
      );
      expect(a, isNot(equals(b)));
    });

    test('identical instance equals itself', () {
      const a = AccountLookupMeta(
        address: addr1,
        role: AccountRole.writable,
        addressIndex: 7,
        lookupTableAddress: addr3,
      );
      expect(a, equals(a));
    });

    test('toString contains fields', () {
      const a = AccountLookupMeta(
        address: addr1,
        role: AccountRole.readonly,
        addressIndex: 5,
        lookupTableAddress: addr2,
      );
      expect(a.toString(), contains('AccountLookupMeta'));
      expect(a.toString(), contains('5'));
    });
  });

  // ---------------------------------------------------------------------------
  // Instruction
  // ---------------------------------------------------------------------------
  group('Instruction equality', () {
    test('equal with no accounts and no data', () {
      const a = Instruction(programAddress: addr1);
      const b = Instruction(programAddress: addr1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when programAddress differs', () {
      const a = Instruction(programAddress: addr1);
      const b = Instruction(programAddress: addr2);
      expect(a, isNot(equals(b)));
    });

    test('equal with identical accounts list', () {
      const accounts = [
        AccountMeta(address: addr2, role: AccountRole.readonly),
        AccountMeta(address: addr3, role: AccountRole.writable),
      ];
      const a = Instruction(programAddress: addr1, accounts: accounts);
      const b = Instruction(programAddress: addr1, accounts: accounts);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal with equivalent accounts lists (different list instances)', () {
      const a = Instruction(
        programAddress: addr1,
        accounts: [AccountMeta(address: addr2, role: AccountRole.readonly)],
      );
      const b = Instruction(
        programAddress: addr1,
        accounts: [AccountMeta(address: addr2, role: AccountRole.readonly)],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when accounts differ', () {
      const a = Instruction(
        programAddress: addr1,
        accounts: [AccountMeta(address: addr2, role: AccountRole.readonly)],
      );
      const b = Instruction(
        programAddress: addr1,
        accounts: [AccountMeta(address: addr3, role: AccountRole.readonly)],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when one has accounts and other does not', () {
      const a = Instruction(
        programAddress: addr1,
        accounts: [AccountMeta(address: addr2, role: AccountRole.readonly)],
      );
      const b = Instruction(programAddress: addr1);
      expect(a, isNot(equals(b)));
    });

    test('equal with identical data', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final a = Instruction(programAddress: addr1, data: data);
      final b = Instruction(programAddress: addr1, data: data);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal with equivalent data (different Uint8List instances)', () {
      final a = Instruction(
        programAddress: addr1,
        data: Uint8List.fromList([10, 20, 30]),
      );
      final b = Instruction(
        programAddress: addr1,
        data: Uint8List.fromList([10, 20, 30]),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      final a = Instruction(
        programAddress: addr1,
        data: Uint8List.fromList([1, 2, 3]),
      );
      final b = Instruction(
        programAddress: addr1,
        data: Uint8List.fromList([1, 2, 4]),
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when one has data and other does not', () {
      final a = Instruction(
        programAddress: addr1,
        data: Uint8List.fromList([0]),
      );
      const b = Instruction(programAddress: addr1);
      expect(a, isNot(equals(b)));
    });

    test('equal with empty data lists', () {
      final a = Instruction(programAddress: addr1, data: Uint8List(0));
      final b = Instruction(programAddress: addr1, data: Uint8List(0));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instance equals itself', () {
      final inst = Instruction(
        programAddress: addr1,
        data: Uint8List.fromList([5]),
      );
      expect(inst, equals(inst));
    });

    test('toString contains fields', () {
      const a = Instruction(programAddress: addr1);
      expect(a.toString(), contains('Instruction'));
      expect(a.toString(), contains(addr1.value));
    });
  });
}
