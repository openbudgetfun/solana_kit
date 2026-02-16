import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('ExistingAccount', () {
    test('has exists set to true', () {
      final account = ExistingAccount<Uint8List>(
        Account<Uint8List>(
          address: const Address(
            'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
          ),
          data: Uint8List.fromList([1, 2, 3]),
          executable: false,
          lamports: Lamports(BigInt.from(1000000000)),
          programAddress: const Address('11111111111111111111111111111111'),
          space: BigInt.from(3),
        ),
      );

      expect(account.exists, isTrue);
      expect(
        account.address.value,
        'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
      );
      expect(account.data, Uint8List.fromList([1, 2, 3]));
    });

    test('delegates all fields to the inner account', () {
      final inner = Account<Uint8List>(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([1, 2, 3]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );
      final existing = ExistingAccount<Uint8List>(inner);

      expect(existing.executable, inner.executable);
      expect(existing.lamports, inner.lamports);
      expect(existing.programAddress, inner.programAddress);
      expect(existing.space, inner.space);
    });
  });

  group('NonExistingAccount', () {
    test('has exists set to false', () {
      const account = NonExistingAccount<Uint8List>(
        Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
      );

      expect(account.exists, isFalse);
      expect(
        account.address.value,
        'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
      );
    });
  });

  group('assertAccountExists', () {
    test('does not throw for an existing account', () {
      final maybeAccount = ExistingAccount<Uint8List>(
        Account<Uint8List>(
          address: const Address(
            'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
          ),
          data: Uint8List.fromList([1, 2, 3]),
          executable: false,
          lamports: Lamports(BigInt.from(1000000000)),
          programAddress: const Address('11111111111111111111111111111111'),
          space: BigInt.from(3),
        ),
      );

      expect(() => assertAccountExists(maybeAccount), returnsNormally);
    });

    test('throws if the provided MaybeAccount does not exist', () {
      const maybeAccount = NonExistingAccount<Uint8List>(
        Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
      );

      expect(
        () => assertAccountExists(maybeAccount),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.accountsAccountNotFound,
          ),
        ),
      );
    });
  });

  group('assertAccountsExist', () {
    test('does not throw if all accounts exist', () {
      final accounts = [
        ExistingAccount<Uint8List>(
          Account<Uint8List>(
            address: const Address(
              'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
            ),
            data: Uint8List.fromList([1, 2, 3]),
            executable: false,
            lamports: Lamports(BigInt.from(1000000000)),
            programAddress: const Address('11111111111111111111111111111111'),
            space: BigInt.from(3),
          ),
        ),
      ];

      expect(() => assertAccountsExist(accounts), returnsNormally);
    });

    test('throws if any of the provided MaybeAccounts do not exist', () {
      final accounts = <MaybeAccount<Uint8List>>[
        const NonExistingAccount<Uint8List>(
          Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        ),
        const NonExistingAccount<Uint8List>(
          Address('11111111111111111111111111111111'),
        ),
        ExistingAccount<Uint8List>(
          Account<Uint8List>(
            address: const Address(
              'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
            ),
            data: Uint8List.fromList([1, 2, 3]),
            executable: false,
            lamports: Lamports(BigInt.from(1000000000)),
            programAddress: const Address('11111111111111111111111111111111'),
            space: BigInt.from(3),
          ),
        ),
      ];

      expect(
        () => assertAccountsExist(accounts),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.accountsOneOrMoreAccountsNotFound,
          ),
        ),
      );
    });
  });
}
