import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
const _systemProgram = Address('11111111111111111111111111111111');

BaseAccount _makeBase({bool executable = false, int lamports = 0}) => BaseAccount(
  executable: executable,
  lamports: Lamports(BigInt.from(lamports)),
  programAddress: _systemProgram,
  space: BigInt.zero,
);

Account<Uint8List> _makeAccount({Uint8List? data}) => Account<Uint8List>(
  address: _addr,
  data: data ?? Uint8List.fromList([1, 2, 3]),
  executable: false,
  lamports: Lamports(BigInt.from(1000)),
  programAddress: _systemProgram,
  space: BigInt.from(3),
);

void main() {
  // ---------------------------------------------------------------------------
  // BaseAccount.toString()
  // ---------------------------------------------------------------------------
  group('BaseAccount toString', () {
    test('includes all field names and values', () {
      final base = _makeBase(executable: true, lamports: 42);
      final str = base.toString();
      expect(str, contains('BaseAccount'));
      expect(str, contains('executable'));
      expect(str, contains('true'));
      expect(str, contains('lamports'));
      expect(str, contains('programAddress'));
      expect(str, contains('space'));
    });

    test('identical objects are equal', () {
      final a = _makeBase();
      final b = _makeBase();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('differs when lamports differs', () {
      final a = _makeBase(lamports: 1);
      final b = _makeBase(lamports: 2);
      expect(a, isNot(equals(b)));
    });

    test('differs when space differs', () {
      final a = BaseAccount(
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.from(10),
      );
      final b = BaseAccount(
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.from(20),
      );
      expect(a, isNot(equals(b)));
    });

    test('differs when programAddress differs', () {
      final a = BaseAccount(
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.zero,
      );
      final b = BaseAccount(
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _addr,
        space: BigInt.zero,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // Account.toString() and hashCode
  // ---------------------------------------------------------------------------
  group('Account toString and hashCode', () {
    test('toString includes all field names', () {
      final account = _makeAccount();
      final str = account.toString();
      expect(str, contains('Account'));
      expect(str, contains('address'));
      expect(str, contains('data'));
      expect(str, contains('executable'));
      expect(str, contains('lamports'));
      expect(str, contains('programAddress'));
      expect(str, contains('space'));
    });

    test('hashCode is stable across two equal instances', () {
      final a = _makeAccount(data: Uint8List.fromList([1, 2, 3]));
      final b = _makeAccount(data: Uint8List.fromList([1, 2, 3]));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('hashCode differs for different Uint8List data', () {
      final a = _makeAccount(data: Uint8List.fromList([1, 2, 3]));
      final b = _makeAccount(data: Uint8List.fromList([4, 5, 6]));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    test('hashCode for non-Uint8List data uses regular equality', () {
      final a = Account<Map<String, int>>(
        address: _addr,
        data: const {'key': 1},
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.zero,
      );
      final b = Account<Map<String, int>>(
        address: _addr,
        data: const {'key': 1},
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.zero,
      );
      // Same data → should be equal.
      expect(a, equals(b));
    });

    test('Account with non-Uint8List data is not equal when data differs', () {
      final a = Account<String>(
        address: _addr,
        data: 'hello',
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.zero,
      );
      final b = Account<String>(
        address: _addr,
        data: 'world',
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.zero,
      );
      expect(a, isNot(equals(b)));
    });

    test('Account is not equal when address differs', () {
      final a = Account<Uint8List>(
        address: _addr,
        data: Uint8List.fromList([1]),
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.zero,
      );
      final b = Account<Uint8List>(
        address: _systemProgram,
        data: Uint8List.fromList([1]),
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: _systemProgram,
        space: BigInt.zero,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // ExistingAccount toString and hashCode
  // ---------------------------------------------------------------------------
  group('ExistingAccount toString and hashCode', () {
    test('toString includes ExistingAccount and the inner account info', () {
      final account = _makeAccount();
      final existing = ExistingAccount<Uint8List>(account);
      final str = existing.toString();
      expect(str, contains('ExistingAccount'));
    });

    test('hashCode matches the inner account hashCode', () {
      final account = _makeAccount();
      final existing = ExistingAccount<Uint8List>(account);
      expect(existing.hashCode, equals(account.hashCode));
    });

    test('two ExistingAccounts with the same inner account are equal', () {
      final a = ExistingAccount<Uint8List>(_makeAccount());
      final b = ExistingAccount<Uint8List>(_makeAccount());
      expect(a, equals(b));
    });

    test('two ExistingAccounts with different inner accounts are not equal',
        () {
      final a = ExistingAccount<Uint8List>(
        Account<Uint8List>(
          address: _addr,
          data: Uint8List.fromList([1]),
          executable: false,
          lamports: Lamports(BigInt.from(1)),
          programAddress: _systemProgram,
          space: BigInt.one,
        ),
      );
      final b = ExistingAccount<Uint8List>(
        Account<Uint8List>(
          address: _addr,
          data: Uint8List.fromList([2]),
          executable: false,
          lamports: Lamports(BigInt.from(1)),
          programAddress: _systemProgram,
          space: BigInt.one,
        ),
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // NonExistingAccount toString and hashCode
  // ---------------------------------------------------------------------------
  group('NonExistingAccount toString and hashCode', () {
    test('toString includes NonExistingAccount and the address', () {
      const account = NonExistingAccount<Uint8List>(_addr);
      final str = account.toString();
      expect(str, contains('NonExistingAccount'));
      expect(str, contains(_addr.value));
    });

    test('hashCode matches the address hashCode', () {
      const account = NonExistingAccount<Uint8List>(_addr);
      expect(account.hashCode, equals(_addr.hashCode));
    });

    test('two NonExistingAccounts with the same address are equal', () {
      const a = NonExistingAccount<Uint8List>(_addr);
      const b = NonExistingAccount<Uint8List>(_addr);
      expect(a, equals(b));
    });

    test('two NonExistingAccounts with different addresses are not equal', () {
      const a = NonExistingAccount<Uint8List>(_addr);
      const b = NonExistingAccount<Uint8List>(_systemProgram);
      expect(a, isNot(equals(b)));
    });
  });
}
