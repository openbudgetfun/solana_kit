import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

const _mockAddress = Address('FiRHXPUxuo42VfWp3vvPVb5he5zvhvMw6DzNigN7nEpe');
const _programAddress = Address('11111111111111111111111111111111');

/// A minimal mock transaction signer for testing.
class _MockTransactionSigner implements TransactionPartialSigner {
  const _MockTransactionSigner(this.address);

  @override
  final Address address;

  @override
  Future<List<Map<Address, SignatureBytes>>> signTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    return [];
  }
}

void main() {
  const mockPda = (_mockAddress, 255);
  const mockSigner = _MockTransactionSigner(_mockAddress);

  group('getNonNullResolvedInstructionInput', () {
    test('returns the value as-is when it is not null', () {
      expect(getNonNullResolvedInstructionInput('test', 'hello'), 'hello');
      expect(getNonNullResolvedInstructionInput('test', 42), 42);
      expect(
        getNonNullResolvedInstructionInput('test', _mockAddress),
        _mockAddress,
      );
    });

    test('throws when the value is null', () {
      expect(
        () => getNonNullResolvedInstructionInput<String>('myInput', null),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.programClientsResolvedInstructionInputMustBeNonNull,
          ),
        ),
      );
    });
  });

  group('getAddressFromResolvedInstructionAccount', () {
    test('returns the address when given an Address', () {
      expect(
        getAddressFromResolvedInstructionAccount('test', _mockAddress),
        _mockAddress,
      );
    });

    test('extracts the address from a ProgramDerivedAddress', () {
      expect(
        getAddressFromResolvedInstructionAccount('test', mockPda),
        _mockAddress,
      );
    });

    test('extracts the address from a TransactionSigner', () {
      expect(
        getAddressFromResolvedInstructionAccount('test', mockSigner),
        _mockAddress,
      );
    });

    test('throws when the value is null', () {
      expect(
        () => getAddressFromResolvedInstructionAccount('myInput', null),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.programClientsResolvedInstructionInputMustBeNonNull,
          ),
        ),
      );
    });
  });

  group('getResolvedInstructionAccountAsProgramDerivedAddress', () {
    test('returns the PDA when given a ProgramDerivedAddress', () {
      final result = getResolvedInstructionAccountAsProgramDerivedAddress(
        'test',
        mockPda,
      );
      expect(result.$1, _mockAddress);
      expect(result.$2, 255);
    });

    test('throws when the value is not a PDA', () {
      expect(
        () => getResolvedInstructionAccountAsProgramDerivedAddress(
          'myInput',
          _mockAddress,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .programClientsUnexpectedResolvedInstructionInputType,
          ),
        ),
      );
      expect(
        () => getResolvedInstructionAccountAsProgramDerivedAddress(
          'myInput',
          mockSigner,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .programClientsUnexpectedResolvedInstructionInputType,
          ),
        ),
      );
    });

    test('throws when the value is null', () {
      expect(
        () => getResolvedInstructionAccountAsProgramDerivedAddress(
          'myInput',
          null,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .programClientsUnexpectedResolvedInstructionInputType,
          ),
        ),
      );
    });
  });

  group('getResolvedInstructionAccountAsTransactionSigner', () {
    test('returns the signer when given a TransactionSigner', () {
      expect(
        getResolvedInstructionAccountAsTransactionSigner('test', mockSigner),
        mockSigner,
      );
    });

    test('throws when the value is not a TransactionSigner', () {
      expect(
        () => getResolvedInstructionAccountAsTransactionSigner(
          'myInput',
          _mockAddress,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .programClientsUnexpectedResolvedInstructionInputType,
          ),
        ),
      );
      expect(
        () => getResolvedInstructionAccountAsTransactionSigner(
          'myInput',
          mockPda,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .programClientsUnexpectedResolvedInstructionInputType,
          ),
        ),
      );
    });

    test('throws when the value is null', () {
      expect(
        () => getResolvedInstructionAccountAsTransactionSigner('myInput', null),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .programClientsUnexpectedResolvedInstructionInputType,
          ),
        ),
      );
    });
  });

  group('getAccountMetaFactory', () {
    test('creates account meta for an Address with the correct role', () {
      final toAccountMeta = getAccountMetaFactory(
        _mockAddress,
        OptionalAccountStrategy.programId,
      );

      final readonlyMeta = toAccountMeta(
        'test',
        const ResolvedInstructionAccount(
          isWritable: false,
          value: _mockAddress,
        ),
      );
      expect(readonlyMeta, isNotNull);
      expect(readonlyMeta!.address, _mockAddress);
      expect(readonlyMeta.role, AccountRole.readonly);

      final writableMeta = toAccountMeta(
        'test',
        const ResolvedInstructionAccount(isWritable: true, value: _mockAddress),
      );
      expect(writableMeta, isNotNull);
      expect(writableMeta!.address, _mockAddress);
      expect(writableMeta.role, AccountRole.writable);
    });

    test('creates account meta for a TransactionSigner with signer role', () {
      final toAccountMeta = getAccountMetaFactory(
        _mockAddress,
        OptionalAccountStrategy.programId,
      );

      final readonlySignerMeta = toAccountMeta(
        'test',
        const ResolvedInstructionAccount(isWritable: false, value: mockSigner),
      );
      expect(readonlySignerMeta, isNotNull);
      expect(readonlySignerMeta, isA<AccountSignerMeta>());
      expect(readonlySignerMeta!.address, _mockAddress);
      expect(readonlySignerMeta.role, AccountRole.readonlySigner);
      expect((readonlySignerMeta as AccountSignerMeta).signer, mockSigner);

      final writableSignerMeta = toAccountMeta(
        'test',
        const ResolvedInstructionAccount(isWritable: true, value: mockSigner),
      );
      expect(writableSignerMeta, isNotNull);
      expect(writableSignerMeta, isA<AccountSignerMeta>());
      expect(writableSignerMeta!.address, _mockAddress);
      expect(writableSignerMeta.role, AccountRole.writableSigner);
      expect((writableSignerMeta as AccountSignerMeta).signer, mockSigner);
    });

    test('extracts the address from a PDA', () {
      final toAccountMeta = getAccountMetaFactory(
        _mockAddress,
        OptionalAccountStrategy.programId,
      );
      final meta = toAccountMeta(
        'test',
        const ResolvedInstructionAccount(isWritable: false, value: mockPda),
      );
      expect(meta, isNotNull);
      expect(meta!.address, _mockAddress);
      expect(meta.role, AccountRole.readonly);
    });

    test('returns null for null accounts with omitted strategy', () {
      final toAccountMeta = getAccountMetaFactory(
        _mockAddress,
        OptionalAccountStrategy.omitted,
      );
      final meta = toAccountMeta(
        'test',
        const ResolvedInstructionAccount(isWritable: false, value: null),
      );
      expect(meta, isNull);
    });

    test(
      'returns program address for null accounts with programId strategy',
      () {
        final toAccountMeta = getAccountMetaFactory(
          _programAddress,
          OptionalAccountStrategy.programId,
        );
        final meta = toAccountMeta(
          'test',
          const ResolvedInstructionAccount(isWritable: false, value: null),
        );
        expect(meta, isNotNull);
        expect(meta!.address, _programAddress);
        expect(meta.role, AccountRole.readonly);
      },
    );
  });
}
