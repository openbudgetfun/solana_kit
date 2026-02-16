import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

/// Creates a mock decoder that always returns [mockValue].
Decoder<T> _getMockDecoder<T>(T mockValue) {
  return VariableSizeDecoder<T>(
    read: (bytes, offset) => (mockValue, bytes.length),
  );
}

/// Creates a decoder that always throws.
Decoder<T> _getThrowingDecoder<T>() {
  return VariableSizeDecoder<T>(
    read: (bytes, offset) => throw Exception('decode failed'),
  );
}

void main() {
  group('decodeAccount', () {
    test('decodes the account data of an existing encoded account', () {
      final encodedAccount = EncodedAccount(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([1, 2, 3]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );

      final decoder = _getMockDecoder<Map<String, int>>({'foo': 42});

      final account = decodeAccount(encodedAccount, decoder);

      expect(account.data, {'foo': 42});
      expect(
        account.address,
        const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
      );
      expect(account.executable, isFalse);
      expect(account.lamports, Lamports(BigInt.from(1000000000)));
      expect(
        account.programAddress,
        const Address('11111111111111111111111111111111'),
      );
      expect(account.space, BigInt.from(3));
    });

    test('throws SolanaError when decoder fails', () {
      final encodedAccount = EncodedAccount(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List.fromList([1, 2, 3]),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.from(3),
      );

      final decoder = _getThrowingDecoder<Map<String, int>>();

      expect(
        () => decodeAccount(encodedAccount, decoder),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.accountsFailedToDecodeAccount,
          ),
        ),
      );
    });
  });

  group('decodeMaybeAccount', () {
    test('decodes an existing encoded account', () {
      final maybeAccount = ExistingAccount<Uint8List>(
        EncodedAccount(
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

      final decoder = _getMockDecoder<Map<String, int>>({'foo': 42});
      final result = decodeMaybeAccount(maybeAccount, decoder);

      expect(result.exists, isTrue);
      expect(result, isA<ExistingAccount<Map<String, int>>>());

      final existing = result as ExistingAccount<Map<String, int>>;
      expect(existing.data, {'foo': 42});
    });

    test('returns non-existing accounts as NonExistingAccount', () {
      const maybeAccount = NonExistingAccount<Uint8List>(
        Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
      );

      final decoder = _getMockDecoder<Map<String, int>>({'foo': 42});
      final result = decodeMaybeAccount(maybeAccount, decoder);

      expect(result.exists, isFalse);
      expect(result, isA<NonExistingAccount<Map<String, int>>>());
      expect(
        result.address,
        const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
      );
    });
  });

  group('assertAccountDecoded', () {
    test('throws if the provided account is encoded', () {
      final account = EncodedAccount(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: Uint8List(0),
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.zero,
      );

      expect(
        () => assertAccountDecoded(account),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.accountsExpectedDecodedAccount,
          ),
        ),
      );
    });

    test('does not throw if the provided account is decoded', () {
      final account = Account<Map<String, int>>(
        address: const Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        data: const {'foo': 42},
        executable: false,
        lamports: Lamports(BigInt.from(1000000000)),
        programAddress: const Address('11111111111111111111111111111111'),
        space: BigInt.zero,
      );

      expect(() => assertAccountDecoded(account), returnsNormally);
    });
  });

  group('assertMaybeAccountDecoded', () {
    test('does not throw if the account does not exist', () {
      const account = NonExistingAccount<Map<String, int>>(
        Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
      );

      expect(() => assertMaybeAccountDecoded(account), returnsNormally);
    });

    test('throws if the existing account is encoded', () {
      final account = ExistingAccount<Object>(
        Account<Object>(
          address: const Address(
            'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
          ),
          data: Uint8List(0),
          executable: false,
          lamports: Lamports(BigInt.from(1000000000)),
          programAddress: const Address('11111111111111111111111111111111'),
          space: BigInt.zero,
        ),
      );

      expect(
        () => assertMaybeAccountDecoded(account),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.accountsExpectedDecodedAccount,
          ),
        ),
      );
    });
  });

  group('assertAccountsDecoded', () {
    test('throws if any of the provided accounts are encoded', () {
      final accounts = <Account<Object>>[
        Account<Object>(
          address: const Address(
            'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
          ),
          data: Uint8List(0),
          executable: false,
          lamports: Lamports(BigInt.from(1000000000)),
          programAddress: const Address('11111111111111111111111111111111'),
          space: BigInt.zero,
        ),
        Account<Object>(
          address: const Address('11111111111111111111111111111111'),
          data: Uint8List(0),
          executable: false,
          lamports: Lamports(BigInt.from(1000000000)),
          programAddress: const Address('11111111111111111111111111111111'),
          space: BigInt.zero,
        ),
        Account<Object>(
          address: const Address('22222222222222222222222222222222'),
          data: const {'foo': 42},
          executable: false,
          lamports: Lamports(BigInt.from(1000000000)),
          programAddress: const Address('11111111111111111111111111111111'),
          space: BigInt.zero,
        ),
      ];

      expect(
        () => assertAccountsDecoded(accounts),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.accountsExpectedAllAccountsToBeDecoded,
          ),
        ),
      );
    });

    test('does not throw if all of the provided accounts are decoded', () {
      final accounts = <Account<Map<String, int>>>[
        Account<Map<String, int>>(
          address: const Address(
            'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
          ),
          data: const {'foo': 42},
          executable: false,
          lamports: Lamports(BigInt.from(1000000000)),
          programAddress: const Address('11111111111111111111111111111111'),
          space: BigInt.zero,
        ),
      ];

      expect(() => assertAccountsDecoded(accounts), returnsNormally);
    });
  });

  group('assertMaybeAccountsDecoded', () {
    test('does not throw if all accounts are missing', () {
      const accounts = <MaybeAccount<Map<String, int>>>[
        NonExistingAccount<Map<String, int>>(
          Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G'),
        ),
        NonExistingAccount<Map<String, int>>(
          Address('11111111111111111111111111111111'),
        ),
      ];

      expect(() => assertMaybeAccountsDecoded(accounts), returnsNormally);
    });

    test('throws if an existing account is encoded', () {
      final accounts = <MaybeAccount<Object>>[
        ExistingAccount<Object>(
          Account<Object>(
            address: const Address(
              'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
            ),
            data: Uint8List(0),
            executable: false,
            lamports: Lamports(BigInt.from(1000000000)),
            programAddress: const Address('11111111111111111111111111111111'),
            space: BigInt.zero,
          ),
        ),
      ];

      expect(
        () => assertMaybeAccountsDecoded(accounts),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.accountsExpectedAllAccountsToBeDecoded,
          ),
        ),
      );
    });
  });
}
