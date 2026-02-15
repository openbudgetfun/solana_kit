import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

Instruction _createMockAdvanceNonceAccountInstruction({
  required Address nonceAccountAddress,
  required Address nonceAuthorityAddress,
}) {
  return Instruction(
    programAddress: const Address('11111111111111111111111111111111'),
    accounts: [
      AccountMeta(
        address: nonceAccountAddress,
        role: AccountRole.writable,
      ),
      const AccountMeta(
        address: Address('SysvarRecentB1ockHashes11111111111111111111'),
        role: AccountRole.readonly,
      ),
      AccountMeta(
        address: nonceAuthorityAddress,
        role: AccountRole.readonlySigner,
      ),
    ],
    data: Uint8List.fromList([4, 0, 0, 0]),
  );
}

void main() {
  const nonceConstraintA = (
    nonce: '123',
    nonceAccountAddress: Address('123'),
    nonceAuthorityAddress: Address('123'),
  );
  const nonceConstraintB = (
    nonce: '456',
    nonceAccountAddress: Address('456'),
    nonceAuthorityAddress: Address('456'),
  );

  group('assertIsTransactionMessageWithDurableNonceLifetime', () {
    late TransactionMessage durableNonceTx;

    setUp(() {
      durableNonceTx = TransactionMessage(
        version: TransactionVersion.v0,
        instructions: [
          _createMockAdvanceNonceAccountInstruction(
            nonceAccountAddress: nonceConstraintA.nonceAccountAddress,
            nonceAuthorityAddress: nonceConstraintA.nonceAuthorityAddress,
          ),
        ],
        lifetimeConstraint: DurableNonceLifetimeConstraint(
          nonce: nonceConstraintA.nonce,
        ),
      );
    });

    test(
      'throws when supplied a transaction with a nonce lifetime constraint '
      'but no instructions',
      () {
        final tx = durableNonceTx.copyWith(instructions: const []);
        expect(
          () => assertIsTransactionMessageWithDurableNonceLifetime(tx),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionExpectedNonceLifetime,
            ),
          ),
        );
      },
    );

    test(
      'throws when supplied a transaction with a nonce lifetime constraint '
      'but an instruction at index 0 for a program other than the system '
      'program',
      () {
        final tx = TransactionMessage(
          version: TransactionVersion.v0,
          instructions: [
            Instruction(
              programAddress: const Address(
                '32JTd9jz5xGuLegzVouXxfzAVTiJYWMLrg6p8RxbV5xc',
              ),
              accounts: durableNonceTx.instructions[0].accounts,
              data: durableNonceTx.instructions[0].data,
            ),
          ],
          lifetimeConstraint: DurableNonceLifetimeConstraint(
            nonce: nonceConstraintA.nonce,
          ),
        );
        expect(
          () => assertIsTransactionMessageWithDurableNonceLifetime(tx),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionExpectedNonceLifetime,
            ),
          ),
        );
      },
    );

    test(
      'throws when supplied a transaction with a system program instruction '
      'at index 0 for something other than the AdvanceNonceAccount '
      'instruction',
      () {
        final tx = TransactionMessage(
          version: TransactionVersion.v0,
          instructions: [
            Instruction(
              programAddress: const Address(
                '11111111111111111111111111111111',
              ),
              accounts: durableNonceTx.instructions[0].accounts,
              data: Uint8List.fromList([2, 0, 0, 0]),
            ),
          ],
          lifetimeConstraint: DurableNonceLifetimeConstraint(
            nonce: nonceConstraintA.nonce,
          ),
        );
        expect(
          () => assertIsTransactionMessageWithDurableNonceLifetime(tx),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionExpectedNonceLifetime,
            ),
          ),
        );
      },
    );

    test(
      'throws when supplied a transaction with a system program instruction '
      'at index 0 with malformed accounts',
      () {
        final tx = TransactionMessage(
          version: TransactionVersion.v0,
          instructions: [
            Instruction(
              programAddress: const Address(
                '11111111111111111111111111111111',
              ),
              accounts: const [],
              data: durableNonceTx.instructions[0].data,
            ),
          ],
          lifetimeConstraint: DurableNonceLifetimeConstraint(
            nonce: nonceConstraintA.nonce,
          ),
        );
        expect(
          () => assertIsTransactionMessageWithDurableNonceLifetime(tx),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionExpectedNonceLifetime,
            ),
          ),
        );
      },
    );

    test(
      'throws when supplied a transaction with an AdvanceNonceAccount '
      'instruction at index 0 but no lifetime constraint',
      () {
        final tx = durableNonceTx.copyWith(clearLifetimeConstraint: true);
        expect(
          () => assertIsTransactionMessageWithDurableNonceLifetime(tx),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionExpectedNonceLifetime,
            ),
          ),
        );
      },
    );

    test(
      'throws when supplied a transaction with an AdvanceNonceAccount '
      'instruction at index 0 but a blockhash lifetime constraint',
      () {
        final tx = durableNonceTx.copyWith(
          lifetimeConstraint: BlockhashLifetimeConstraint(
            blockhash: '123',
            lastValidBlockHeight: BigInt.from(123),
          ),
        );
        expect(
          () => assertIsTransactionMessageWithDurableNonceLifetime(tx),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionExpectedNonceLifetime,
            ),
          ),
        );
      },
    );

    test('does not throw when supplied a durable nonce transaction', () {
      expect(
        () => assertIsTransactionMessageWithDurableNonceLifetime(
          durableNonceTx,
        ),
        returnsNormally,
      );
    });

    test('does not throw when the nonce authority is a writable signer', () {
      final accounts = durableNonceTx.instructions[0].accounts!;
      final updatedInstruction = Instruction(
        programAddress: durableNonceTx.instructions[0].programAddress,
        accounts: [
          accounts[0],
          accounts[1],
          AccountMeta(
            address: accounts[2].address,
            role: AccountRole.writableSigner,
          ),
        ],
        data: durableNonceTx.instructions[0].data,
      );
      final tx = TransactionMessage(
        version: TransactionVersion.v0,
        instructions: [updatedInstruction],
        lifetimeConstraint: DurableNonceLifetimeConstraint(
          nonce: nonceConstraintA.nonce,
        ),
      );
      expect(
        () => assertIsTransactionMessageWithDurableNonceLifetime(tx),
        returnsNormally,
      );
    });
  });

  group('setTransactionMessageLifetimeUsingDurableNonce', () {
    late TransactionMessage baseTx;

    setUp(() {
      baseTx = const TransactionMessage(
        version: TransactionVersion.v0,
        instructions: [
          Instruction(
            programAddress: Address(
              '32JTd9jz5xGuLegzVouXxfzAVTiJYWMLrg6p8RxbV5xc',
            ),
          ),
        ],
      );
    });

    test(
      'sets the lifetime constraint on the transaction to the supplied '
      'durable nonce constraint',
      () {
        final durableNonceTx =
            setTransactionMessageLifetimeUsingDurableNonce(
              DurableNonceConfig(
                nonce: nonceConstraintA.nonce,
                nonceAccountAddress: nonceConstraintA.nonceAccountAddress,
                nonceAuthorityAddress: nonceConstraintA.nonceAuthorityAddress,
              ),
              baseTx,
            );
        expect(
          durableNonceTx.lifetimeConstraint,
          isA<DurableNonceLifetimeConstraint>().having(
            (c) => c.nonce,
            'nonce',
            nonceConstraintA.nonce,
          ),
        );
      },
    );

    test('prepends an AdvanceNonceAccount instruction', () {
      final durableNonceTx =
          setTransactionMessageLifetimeUsingDurableNonce(
            DurableNonceConfig(
              nonce: nonceConstraintA.nonce,
              nonceAccountAddress: nonceConstraintA.nonceAccountAddress,
              nonceAuthorityAddress: nonceConstraintA.nonceAuthorityAddress,
            ),
            baseTx,
          );
      expect(durableNonceTx.instructions.length, 2);
      expect(
        isAdvanceNonceAccountInstruction(durableNonceTx.instructions[0]),
        isTrue,
      );
      expect(
        durableNonceTx.instructions[1].programAddress,
        baseTx.instructions[0].programAddress,
      );
    });

    group(
      'given a transaction with an advance nonce account instruction but '
      'no nonce lifetime constraint',
      () {
        test(
          'does not modify an AdvanceNonceAccount instruction if the existing '
          'one matches the constraint added',
          () {
            final instruction = _createMockAdvanceNonceAccountInstruction(
              nonceAccountAddress: nonceConstraintA.nonceAccountAddress,
              nonceAuthorityAddress: nonceConstraintA.nonceAuthorityAddress,
            );
            final transaction = TransactionMessage(
              version: TransactionVersion.v0,
              instructions: [instruction, baseTx.instructions[0]],
            );
            final durableNonceTx =
                setTransactionMessageLifetimeUsingDurableNonce(
                  DurableNonceConfig(
                    nonce: nonceConstraintA.nonce,
                    nonceAccountAddress: nonceConstraintA.nonceAccountAddress,
                    nonceAuthorityAddress:
                        nonceConstraintA.nonceAuthorityAddress,
                  ),
                  transaction,
                );
            expect(durableNonceTx.instructions.length, 2);
            expect(
              durableNonceTx.instructions[0].accounts![0].address,
              nonceConstraintA.nonceAccountAddress,
            );
            expect(
              durableNonceTx.instructions[0].accounts![2].address,
              nonceConstraintA.nonceAuthorityAddress,
            );
          },
        );

        group(
          'when the existing AdvanceNonceAccount instruction does not match '
          'the constraint added',
          () {
            test('replaces the existing instruction', () {
              final transaction = TransactionMessage(
                version: TransactionVersion.v0,
                instructions: [
                  _createMockAdvanceNonceAccountInstruction(
                    nonceAccountAddress: nonceConstraintB.nonceAccountAddress,
                    nonceAuthorityAddress:
                        nonceConstraintB.nonceAuthorityAddress,
                  ),
                  baseTx.instructions[0],
                ],
              );
              final durableNonceTx =
                  setTransactionMessageLifetimeUsingDurableNonce(
                    DurableNonceConfig(
                      nonce: nonceConstraintA.nonce,
                      nonceAccountAddress:
                          nonceConstraintA.nonceAccountAddress,
                      nonceAuthorityAddress:
                          nonceConstraintA.nonceAuthorityAddress,
                    ),
                    transaction,
                  );
              expect(durableNonceTx.instructions.length, 2);
              expect(
                durableNonceTx.instructions[0].accounts![0].address,
                nonceConstraintA.nonceAccountAddress,
              );
              expect(
                durableNonceTx.instructions[0].accounts![2].address,
                nonceConstraintA.nonceAuthorityAddress,
              );
            });
          },
        );
      },
    );

    group('given a durable nonce transaction', () {
      late TransactionMessage durableNonceTxWithConstraintA;

      setUp(() {
        durableNonceTxWithConstraintA = TransactionMessage(
          version: TransactionVersion.v0,
          instructions: [
            _createMockAdvanceNonceAccountInstruction(
              nonceAccountAddress: nonceConstraintA.nonceAccountAddress,
              nonceAuthorityAddress: nonceConstraintA.nonceAuthorityAddress,
            ),
            const Instruction(
              programAddress: Address(
                '32JTd9jz5xGuLegzVouXxfzAVTiJYWMLrg6p8RxbV5xc',
              ),
            ),
          ],
          lifetimeConstraint: DurableNonceLifetimeConstraint(
            nonce: nonceConstraintA.nonce,
          ),
        );
      });

      test(
        'sets the new durable nonce constraint on the transaction when '
        'it differs from the existing one',
        () {
          final durableNonceTxB =
              setTransactionMessageLifetimeUsingDurableNonce(
                DurableNonceConfig(
                  nonce: nonceConstraintB.nonce,
                  nonceAccountAddress: nonceConstraintB.nonceAccountAddress,
                  nonceAuthorityAddress:
                      nonceConstraintB.nonceAuthorityAddress,
                ),
                durableNonceTxWithConstraintA,
              );
          expect(
            durableNonceTxB.lifetimeConstraint,
            isA<DurableNonceLifetimeConstraint>().having(
              (c) => c.nonce,
              'nonce',
              nonceConstraintB.nonce,
            ),
          );
        },
      );

      test(
        'replaces the advance nonce account instruction when it differs '
        'from the existing one',
        () {
          final durableNonceTxB =
              setTransactionMessageLifetimeUsingDurableNonce(
                DurableNonceConfig(
                  nonce: nonceConstraintB.nonce,
                  nonceAccountAddress: nonceConstraintB.nonceAccountAddress,
                  nonceAuthorityAddress:
                      nonceConstraintB.nonceAuthorityAddress,
                ),
                durableNonceTxWithConstraintA,
              );
          expect(durableNonceTxB.instructions.length, 2);
          expect(
            durableNonceTxB.instructions[0].accounts![0].address,
            nonceConstraintB.nonceAccountAddress,
          );
          expect(
            durableNonceTxB.instructions[0].accounts![2].address,
            nonceConstraintB.nonceAuthorityAddress,
          );
        },
      );

      test(
        'returns the original transaction when trying to set the same '
        'durable nonce constraint again',
        () {
          final txWithSameNonceLifetime =
              setTransactionMessageLifetimeUsingDurableNonce(
                DurableNonceConfig(
                  nonce: nonceConstraintA.nonce,
                  nonceAccountAddress: nonceConstraintA.nonceAccountAddress,
                  nonceAuthorityAddress:
                      nonceConstraintA.nonceAuthorityAddress,
                ),
                durableNonceTxWithConstraintA,
              );
          expect(
            identical(
              durableNonceTxWithConstraintA,
              txWithSameNonceLifetime,
            ),
            isTrue,
          );
        },
      );
    });
  });
}
