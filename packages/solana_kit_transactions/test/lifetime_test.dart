import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

const _systemProgramAddress = Address('11111111111111111111111111111111');

void main() {
  group('getTransactionLifetimeConstraintFromCompiledTransactionMessage', () {
    final maxU64 = BigInt.parse('18446744073709551615');

    test('returns a blockhash transaction lifetime when there are no '
        'instructions', () async {
      const compiledMessage = CompiledTransactionMessage(
        version: TransactionVersion.v0,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: [
          Address('22222222222222222222222222222222222222222222'),
        ],
        instructions: [],
        lifetimeToken: 'abc',
      );

      final result =
          await getTransactionLifetimeConstraintFromCompiledTransactionMessage(
            compiledMessage,
          );
      expect(result, isA<TransactionBlockhashLifetime>());
      final blockhash = result as TransactionBlockhashLifetime;
      expect(blockhash.blockhash, 'abc');
      expect(blockhash.lastValidBlockHeight, maxU64);
    });

    group('returns a blockhash transaction lifetime when the first instruction '
        'is not an AdvanceNonceAccount instruction', () {
      test('because the program is not the System Program', () async {
        final compiledMessage = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: const MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 0,
          ),
          staticAccounts: const [Address('otherProgramAddress333333333333')],
          instructions: [
            CompiledInstruction(
              programAddressIndex: 0,
              accountIndices: const [1, 2, 3],
              data: Uint8List.fromList([4, 0, 0, 0]),
            ),
          ],
          lifetimeToken: 'abc',
        );

        final result =
            await getTransactionLifetimeConstraintFromCompiledTransactionMessage(
              compiledMessage,
            );
        expect(result, isA<TransactionBlockhashLifetime>());
        final blockhash = result as TransactionBlockhashLifetime;
        expect(blockhash.blockhash, 'abc');
        expect(blockhash.lastValidBlockHeight, maxU64);
      });

      test(
        'because the instruction data is not for AdvanceNonceAccount',
        () async {
          final compiledMessage = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: const MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 0,
            ),
            staticAccounts: const [_systemProgramAddress],
            instructions: [
              CompiledInstruction(
                programAddressIndex: 0,
                accountIndices: const [1, 2, 3],
                data: Uint8List.fromList([1, 0, 0, 0]),
              ),
            ],
            lifetimeToken: 'abc',
          );

          final result =
              await getTransactionLifetimeConstraintFromCompiledTransactionMessage(
                compiledMessage,
              );
          expect(result, isA<TransactionBlockhashLifetime>());
        },
      );

      test('because the instruction does not have exactly 3 accounts', () async {
        final compiledMessage = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: const MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 0,
          ),
          staticAccounts: const [_systemProgramAddress],
          instructions: [
            CompiledInstruction(
              programAddressIndex: 0,
              accountIndices: const [1, 2],
              data: Uint8List.fromList([4, 0, 0, 0]),
            ),
          ],
          lifetimeToken: 'abc',
        );

        final result =
            await getTransactionLifetimeConstraintFromCompiledTransactionMessage(
              compiledMessage,
            );
        expect(result, isA<TransactionBlockhashLifetime>());
      });

      test('because it has no account indices', () async {
        final compiledMessage = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: const MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 0,
          ),
          staticAccounts: const [_systemProgramAddress],
          instructions: [
            CompiledInstruction(
              programAddressIndex: 0,
              data: Uint8List.fromList([4, 0, 0, 0]),
            ),
          ],
          lifetimeToken: 'abc',
        );

        final result =
            await getTransactionLifetimeConstraintFromCompiledTransactionMessage(
              compiledMessage,
            );
        expect(result, isA<TransactionBlockhashLifetime>());
      });
    });

    test('returns a durable nonce transaction lifetime when the first '
        'instruction is an AdvanceNonceAccount instruction', () async {
      final compiledMessage = CompiledTransactionMessage(
        version: TransactionVersion.v0,
        header: const MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [
          Address('11111111111111111111111111111111'),
          Address('nonceAccountAddress33333333333333'),
          Address('recentBlockhashesSysvarAddress333'),
          Address('nonceAuthorityAddress33333333333'),
        ],
        instructions: [
          CompiledInstruction(
            programAddressIndex: 0,
            accountIndices: const [1, 2, 3],
            data: Uint8List.fromList([4, 0, 0, 0]),
          ),
        ],
        lifetimeToken: 'abc',
      );

      final result =
          await getTransactionLifetimeConstraintFromCompiledTransactionMessage(
            compiledMessage,
          );
      expect(result, isA<TransactionDurableNonceLifetime>());
      final nonce = result as TransactionDurableNonceLifetime;
      expect(nonce.nonce, 'abc');
      expect(
        nonce.nonceAccountAddress,
        const Address('nonceAccountAddress33333333333333'),
      );
    });

    test(
      'fatals if the nonce account address is not in static accounts',
      () async {
        final compiledMessage = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: const MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 0,
          ),
          staticAccounts: const [Address('11111111111111111111111111111111')],
          instructions: [
            CompiledInstruction(
              programAddressIndex: 0,
              accountIndices: const [1, 2, 3],
              data: Uint8List.fromList([4, 0, 0, 0]),
            ),
          ],
          lifetimeToken: 'abc',
        );

        expect(
          () async =>
              getTransactionLifetimeConstraintFromCompiledTransactionMessage(
                compiledMessage,
              ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionNonceAccountCannotBeInLookupTable,
            ),
          ),
        );
      },
    );
  });

  group('assertIsTransactionWithBlockhashLifetime', () {
    test('throws for a transaction with no lifetime constraint', () {
      final transaction = Transaction(
        messageBytes: Uint8List(0),
        signatures: const {},
      );
      expect(
        () => assertIsTransactionWithBlockhashLifetime(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionExpectedBlockhashLifetime,
          ),
        ),
      );
    });

    test('throws for a transaction with a durable nonce constraint', () {
      final transaction = TransactionWithLifetime(
        messageBytes: Uint8List(0),
        signatures: const {},
        lifetimeConstraint: const TransactionDurableNonceLifetime(
          nonce: 'abcd',
          nonceAccountAddress: Address(
            '2B7hCrBozp5hPV31mw1qUh5XhXYs9f6p1GsRdHNjF4xS',
          ),
        ),
      );
      expect(
        () => assertIsTransactionWithBlockhashLifetime(transaction),
        throwsA(isA<SolanaError>()),
      );
    });

    test(
      'does not throw for a transaction with a valid blockhash constraint',
      () {
        final transaction = TransactionWithLifetime(
          messageBytes: Uint8List(0),
          signatures: const {},
          lifetimeConstraint: TransactionBlockhashLifetime(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.from(1234),
          ),
        );
        expect(
          () => assertIsTransactionWithBlockhashLifetime(transaction),
          returnsNormally,
        );
      },
    );
  });

  group('assertIsTransactionWithDurableNonceLifetime', () {
    const validAddress = Address(
      '2B7hCrBozp5hPV31mw1qUh5XhXYs9f6p1GsRdHNjF4xS',
    );

    test('throws for a transaction with no lifetime constraint', () {
      final transaction = Transaction(
        messageBytes: Uint8List(0),
        signatures: const {},
      );
      expect(
        () => assertIsTransactionWithDurableNonceLifetime(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionExpectedNonceLifetime,
          ),
        ),
      );
    });

    test('throws for a transaction with a blockhash constraint', () {
      final transaction = TransactionWithLifetime(
        messageBytes: Uint8List(0),
        signatures: const {},
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.from(1234),
        ),
      );
      expect(
        () => assertIsTransactionWithDurableNonceLifetime(transaction),
        throwsA(isA<SolanaError>()),
      );
    });

    test('throws for a transaction with a durable nonce lifetime but an '
        'invalid nonceAccountAddress value', () {
      final transaction = TransactionWithLifetime(
        messageBytes: Uint8List(0),
        signatures: const {},
        lifetimeConstraint: const TransactionDurableNonceLifetime(
          nonce: 'abcd',
          nonceAccountAddress: Address('not a valid address'),
        ),
      );
      expect(
        () => assertIsTransactionWithDurableNonceLifetime(transaction),
        throwsA(isA<SolanaError>()),
      );
    });

    test(
      'does not throw for a transaction with a valid durable nonce lifetime',
      () {
        final transaction = TransactionWithLifetime(
          messageBytes: Uint8List(0),
          signatures: const {},
          lifetimeConstraint: const TransactionDurableNonceLifetime(
            nonce: 'abcd',
            nonceAccountAddress: validAddress,
          ),
        );
        expect(
          () => assertIsTransactionWithDurableNonceLifetime(transaction),
          returnsNormally,
        );
      },
    );
  });
}
