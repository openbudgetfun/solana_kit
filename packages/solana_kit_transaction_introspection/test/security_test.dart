import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_introspection/solana_kit_transaction_introspection.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  final unrecognizedResponse = throwsA(
    isA<SolanaError>().having(
      (error) => error.code,
      'code',
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    ),
  );

  group('loaded address integrity', () {
    final message = CompiledTransactionMessage(
      version: TransactionVersion.v0,
      header: header(1, 0, 1),
      staticAccounts: const [Address(feePayer), Address(systemProgram)],
      instructions: const [
        CompiledInstruction(
          programAddressIndex: 1,
          accountIndices: [2],
        ),
      ],
      addressTableLookups: const [
        AddressTableLookup(
          lookupTableAddress: Address(systemProgram),
          writableIndexes: [0],
          readonlyIndexes: [1],
        ),
      ],
      lifetimeToken: blockhash,
    );

    test(
      'does not reinterpret a readonly address as an omitted writable account',
      () {
        expect(
          () => getInstructionsFromCompiledTransactionMessage(
            message,
            loadedAddresses: const LoadedAddresses(
              readonly: [Address(tokenProgram)],
            ),
          ),
          unrecognizedResponse,
        );
      },
    );

    test(
      'does not reinterpret extra writable addresses as readonly accounts',
      () {
        expect(
          () => walkInstructions(
            compiledMessage: message,
            loadedAddresses: const LoadedAddresses(
              writable: [Address(tokenProgram), Address(systemProgram)],
              readonly: [Address(feePayer)],
            ),
          ),
          unrecognizedResponse,
        );
      },
    );

    test('rejects missing or extra readonly addresses', () {
      for (final readonly in <List<Address>>[
        [],
        [const Address(tokenProgram), const Address(systemProgram)],
      ]) {
        expect(
          () => getAccountMetasFromCompiledTransactionMessage(
            message,
            loadedAddresses: LoadedAddresses(
              writable: const [Address(feePayer)],
              readonly: readonly,
            ),
          ),
          unrecognizedResponse,
        );
      }
    });

    test('requires loaded addresses before resolving lookup accounts', () {
      expect(
        () => getAccountMetasFromCompiledTransactionMessage(message),
        unrecognizedResponse,
      );
    });

    test('rejects injected loaded accounts in a legacy message', () {
      expect(
        () => getAccountMetasFromCompiledTransactionMessage(
          legacyMessage(staticAccounts: const [Address(feePayer)]),
          loadedAddresses: const LoadedAddresses(
            writable: [Address(tokenProgram)],
          ),
        ),
        unrecognizedResponse,
      );
    });

    test('resolves complete lookup metadata with the correct role', () {
      final instructions = getInstructionsFromCompiledTransactionMessage(
        message,
        loadedAddresses: const LoadedAddresses(
          writable: [Address(feePayer)],
          readonly: [Address(tokenProgram)],
        ),
      );
      expect(
        instructions.single.accounts!.single.address,
        const Address(feePayer),
      );
      expect(instructions.single.accounts!.single.role, AccountRole.writable);
    });
  });

  group('inner instruction group integrity', () {
    test(
      'rejects duplicate groups that duplicate the same execution trace',
      () {
        final group = <String, Object?>{
          'index': 0,
          'instructions': [
            {'programIdIndex': 0, 'accounts': <int>[], 'data': '2'},
          ],
        };
        expect(
          () => getInnerInstructionsFromMeta(
            {
              'innerInstructions': [group, group],
            },
            const [
              AccountMeta(
                address: Address(systemProgram),
                role: AccountRole.readonly,
              ),
            ],
          ),
          unrecognizedResponse,
        );
      },
    );

    test('rejects duplicate empty groups', () {
      expect(
        () => getInnerInstructionsFromMeta(
          {
            'innerInstructions': [
              {'index': 0, 'instructions': <Object?>[]},
              {'index': 0, 'instructions': <Object?>[]},
            ],
          },
          const [],
        ),
        unrecognizedResponse,
      );
    });
  });
}
