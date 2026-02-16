import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('BaseAccount', () {
    test('can be created', () {
      final account = BaseAccount(
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.zero,
      );

      expect(account.executable, isFalse);
      expect(account.lamports, Lamports(BigInt.zero));
      expect(
        account.programAddress,
        const Address('11111111111111111111111111111111'),
      );
      expect(account.space, BigInt.zero);
    });

    test('equals another BaseAccount with the same fields', () {
      final a = BaseAccount(
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.zero,
      );
      final b = BaseAccount(
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.zero,
      );

      expect(a, equals(b));
    });

    test('does not equal a BaseAccount with different fields', () {
      final a = BaseAccount(
        executable: false,
        lamports: Lamports(BigInt.zero),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.zero,
      );
      final b = BaseAccount(
        executable: true,
        lamports: Lamports(BigInt.zero),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.zero,
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('Account', () {
    test('can be created with Uint8List data (EncodedAccount)', () {
      final account = Account<Uint8List>(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([1, 2, 3]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );

      expect(
        account.address,
        const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
      );
      expect(account.data, Uint8List.fromList([1, 2, 3]));
      expect(account.executable, isFalse);
      expect(account.lamports, Lamports(BigInt.from(1000000000)));
      expect(
        account.programAddress,
        const Address('11111111111111111111111111111111'),
      );
      expect(account.space, BigInt.from(3));
    });

    test('can be created with custom decoded data', () {
      final account = Account<Map<String, int>>(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: const {'foo': 42},
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(100),
      );

      expect(account.data, {'foo': 42});
    });

    test('equals another Account with the same fields', () {
      final a = Account<Uint8List>(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([1, 2, 3]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );
      final b = Account<Uint8List>(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([1, 2, 3]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );

      expect(a, equals(b));
    });

    test('does not equal an Account with different data', () {
      final a = Account<Uint8List>(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([1, 2, 3]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );
      final b = Account<Uint8List>(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([4, 5, 6]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );

      expect(a, isNot(equals(b)));
    });

    test('EncodedAccount typedef works', () {
      final encoded = EncodedAccount(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([1, 2, 3]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );

      expect(encoded, isA<Account<Uint8List>>());
    });
  });

  group('baseAccountSize', () {
    test('is 128', () {
      expect(baseAccountSize, 128);
    });
  });
}
