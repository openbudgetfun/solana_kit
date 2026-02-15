import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_functional/solana_kit_functional.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  const programAddress = Address('program');

  group('compressTransactionMessageUsingAddressLookupTables', () {
    test('should replace a read-only account with a lookup table', () {
      const address = Address('address1');
      const lookupTableAddress = Address('lookupTableAddress');

      final transactionMessage =
          createTransactionMessage(version: TransactionVersion.v0).pipe(
            (tx) => appendTransactionMessageInstruction(
              const Instruction(
                programAddress: programAddress,
                accounts: [
                  AccountMeta(address: address, role: AccountRole.readonly),
                ],
              ),
              tx,
            ),
          );

      final lookupTables = <Address, List<Address>>{
        lookupTableAddress: const [address],
      };

      final result = compressTransactionMessageUsingAddressLookupTables(
        transactionMessage,
        lookupTables,
      );

      final account = result.instructions[0].accounts![0];
      expect(account, isA<AccountLookupMeta>());
      final lookupMeta = account as AccountLookupMeta;
      expect(lookupMeta.address, address);
      expect(lookupMeta.addressIndex, 0);
      expect(lookupMeta.lookupTableAddress, lookupTableAddress);
      expect(lookupMeta.role, AccountRole.readonly);
    });

    test('should replace a writable account with a lookup table', () {
      const address = Address('address1');
      const lookupTableAddress = Address('lookupTableAddress');

      final transactionMessage =
          createTransactionMessage(version: TransactionVersion.v0).pipe(
            (tx) => appendTransactionMessageInstruction(
              const Instruction(
                programAddress: programAddress,
                accounts: [
                  AccountMeta(address: address, role: AccountRole.writable),
                ],
              ),
              tx,
            ),
          );

      final lookupTables = <Address, List<Address>>{
        lookupTableAddress: const [address],
      };

      final result = compressTransactionMessageUsingAddressLookupTables(
        transactionMessage,
        lookupTables,
      );

      final account = result.instructions[0].accounts![0];
      expect(account, isA<AccountLookupMeta>());
      final lookupMeta = account as AccountLookupMeta;
      expect(lookupMeta.address, address);
      expect(lookupMeta.addressIndex, 0);
      expect(lookupMeta.lookupTableAddress, lookupTableAddress);
      expect(lookupMeta.role, AccountRole.writable);
    });

    test(
      'should not replace a read-only signer account with a lookup table',
      () {
        const address = Address('address1');
        const lookupTableAddress = Address('lookupTableAddress');

        final transactionMessage =
            createTransactionMessage(version: TransactionVersion.v0).pipe(
              (tx) => appendTransactionMessageInstruction(
                const Instruction(
                  programAddress: programAddress,
                  accounts: [
                    AccountMeta(
                      address: address,
                      role: AccountRole.readonlySigner,
                    ),
                  ],
                ),
                tx,
              ),
            );

        final lookupTables = <Address, List<Address>>{
          lookupTableAddress: const [address],
        };

        final result = compressTransactionMessageUsingAddressLookupTables(
          transactionMessage,
          lookupTables,
        );

        final account = result.instructions[0].accounts![0];
        expect(account, isNot(isA<AccountLookupMeta>()));
        expect(account.address, address);
        expect(account.role, AccountRole.readonlySigner);
      },
    );

    test(
      'should not replace a writable signer account with a lookup table',
      () {
        const address = Address('address1');
        const lookupTableAddress = Address('lookupTableAddress');

        final transactionMessage =
            createTransactionMessage(version: TransactionVersion.v0).pipe(
              (tx) => appendTransactionMessageInstruction(
                const Instruction(
                  programAddress: programAddress,
                  accounts: [
                    AccountMeta(
                      address: address,
                      role: AccountRole.writableSigner,
                    ),
                  ],
                ),
                tx,
              ),
            );

        final lookupTables = <Address, List<Address>>{
          lookupTableAddress: const [address],
        };

        final result = compressTransactionMessageUsingAddressLookupTables(
          transactionMessage,
          lookupTables,
        );

        final account = result.instructions[0].accounts![0];
        expect(account, isNot(isA<AccountLookupMeta>()));
        expect(account.address, address);
        expect(account.role, AccountRole.writableSigner);
      },
    );

    test(
      'should not modify an account that is already from a lookup table',
      () {
        const address = Address('address1');
        const lookupTableAddress = Address('lookupTableAddress');

        const lookupMeta = AccountLookupMeta(
          address: address,
          addressIndex: 0,
          lookupTableAddress: lookupTableAddress,
          role: AccountRole.readonly,
        );

        // AccountLookupMeta extends AccountMeta, so it can be placed
        // directly in the accounts list.
        final transactionMessage =
            createTransactionMessage(version: TransactionVersion.v0).pipe(
              (tx) => appendTransactionMessageInstruction(
                const Instruction(
                  programAddress: programAddress,
                  accounts: [lookupMeta],
                ),
                tx,
              ),
            );

        final lookupTables = <Address, List<Address>>{
          lookupTableAddress: const [address],
        };

        final result = compressTransactionMessageUsingAddressLookupTables(
          transactionMessage,
          lookupTables,
        );

        final account = result.instructions[0].accounts![0];
        expect(account, isA<AccountLookupMeta>());
      },
    );

    test('should replace multiple accounts with different addresses from a '
        'lookup table', () {
      const address1 = Address('address1');
      const address2 = Address('address2');
      const lookupTableAddress = Address('lookupTableAddress');

      final transactionMessage =
          createTransactionMessage(version: TransactionVersion.v0).pipe(
            (tx) => appendTransactionMessageInstruction(
              const Instruction(
                programAddress: programAddress,
                accounts: [
                  AccountMeta(address: address1, role: AccountRole.readonly),
                  AccountMeta(address: address2, role: AccountRole.writable),
                ],
              ),
              tx,
            ),
          );

      final lookupTables = <Address, List<Address>>{
        lookupTableAddress: const [address1, address2],
      };

      final result = compressTransactionMessageUsingAddressLookupTables(
        transactionMessage,
        lookupTables,
      );

      final account0 = result.instructions[0].accounts![0] as AccountLookupMeta;
      expect(account0.address, address1);
      expect(account0.addressIndex, 0);
      expect(account0.lookupTableAddress, lookupTableAddress);
      expect(account0.role, AccountRole.readonly);

      final account1 = result.instructions[0].accounts![1] as AccountLookupMeta;
      expect(account1.address, address2);
      expect(account1.addressIndex, 1);
      expect(account1.lookupTableAddress, lookupTableAddress);
      expect(account1.role, AccountRole.writable);
    });

    test('should replace the same account in multiple instructions from a '
        'lookup table', () {
      const address = Address('address1');
      const lookupTableAddress = Address('lookupTableAddress');

      final transactionMessage =
          createTransactionMessage(version: TransactionVersion.v0)
              .pipe(
                (tx) => appendTransactionMessageInstruction(
                  const Instruction(
                    programAddress: programAddress,
                    accounts: [
                      AccountMeta(address: address, role: AccountRole.readonly),
                    ],
                  ),
                  tx,
                ),
              )
              .pipe(
                (tx) => appendTransactionMessageInstruction(
                  const Instruction(
                    programAddress: programAddress,
                    accounts: [
                      AccountMeta(address: address, role: AccountRole.readonly),
                    ],
                  ),
                  tx,
                ),
              );

      final lookupTables = <Address, List<Address>>{
        lookupTableAddress: const [address],
      };

      final result = compressTransactionMessageUsingAddressLookupTables(
        transactionMessage,
        lookupTables,
      );

      final account0 = result.instructions[0].accounts![0] as AccountLookupMeta;
      expect(account0.address, address);
      expect(account0.addressIndex, 0);
      expect(account0.lookupTableAddress, lookupTableAddress);

      final account1 = result.instructions[1].accounts![0] as AccountLookupMeta;
      expect(account1.address, address);
      expect(account1.addressIndex, 0);
      expect(account1.lookupTableAddress, lookupTableAddress);
    });

    test('should replace multiple accounts with different addresses from '
        'different lookup tables', () {
      const address1 = Address('address1');
      const address2 = Address('address2');
      const lookupTableAddress1 = Address('lookupTableAddress1');
      const lookupTableAddress2 = Address('lookupTableAddress2');

      final transactionMessage =
          createTransactionMessage(version: TransactionVersion.v0).pipe(
            (tx) => appendTransactionMessageInstruction(
              const Instruction(
                programAddress: programAddress,
                accounts: [
                  AccountMeta(address: address1, role: AccountRole.readonly),
                  AccountMeta(address: address2, role: AccountRole.writable),
                ],
              ),
              tx,
            ),
          );

      final lookupTables = <Address, List<Address>>{
        lookupTableAddress1: const [address1],
        lookupTableAddress2: const [address2],
      };

      final result = compressTransactionMessageUsingAddressLookupTables(
        transactionMessage,
        lookupTables,
      );

      final account0 = result.instructions[0].accounts![0] as AccountLookupMeta;
      expect(account0.address, address1);
      expect(account0.addressIndex, 0);
      expect(account0.lookupTableAddress, lookupTableAddress1);

      final account1 = result.instructions[0].accounts![1] as AccountLookupMeta;
      expect(account1.address, address2);
      expect(account1.addressIndex, 0);
      expect(account1.lookupTableAddress, lookupTableAddress2);
    });

    test('should not replace an account that is not in lookup tables', () {
      const address = Address('address1');
      const lookupTableAddress = Address('lookupTableAddress');

      final transactionMessage =
          createTransactionMessage(version: TransactionVersion.v0).pipe(
            (tx) => appendTransactionMessageInstruction(
              const Instruction(
                programAddress: programAddress,
                accounts: [
                  AccountMeta(address: address, role: AccountRole.readonly),
                ],
              ),
              tx,
            ),
          );

      final lookupTables = <Address, List<Address>>{
        lookupTableAddress: const [Address('abc')],
      };

      final result = compressTransactionMessageUsingAddressLookupTables(
        transactionMessage,
        lookupTables,
      );

      final account = result.instructions[0].accounts![0];
      expect(account, isNot(isA<AccountLookupMeta>()));
      expect(account.address, address);
      expect(account.role, AccountRole.readonly);
    });

    test(
      'should replace some accounts if there is a mix of signers and not',
      () {
        const address1 = Address('address1');
        const address2 = Address('address2');
        const lookupTableAddress = Address('lookupTableAddress');

        final transactionMessage =
            createTransactionMessage(version: TransactionVersion.v0)
                .pipe(
                  (tx) => appendTransactionMessageInstruction(
                    const Instruction(
                      programAddress: programAddress,
                      accounts: [
                        AccountMeta(
                          address: address1,
                          role: AccountRole.readonly,
                        ),
                        AccountMeta(
                          address: address2,
                          role: AccountRole.writable,
                        ),
                      ],
                    ),
                    tx,
                  ),
                )
                .pipe(
                  (tx) => appendTransactionMessageInstruction(
                    const Instruction(
                      programAddress: programAddress,
                      accounts: [
                        AccountMeta(
                          address: address1,
                          role: AccountRole.readonly,
                        ),
                        AccountMeta(
                          address: address2,
                          role: AccountRole.readonlySigner,
                        ),
                      ],
                    ),
                    tx,
                  ),
                );

        final lookupTables = <Address, List<Address>>{
          lookupTableAddress: const [address1, address2],
        };

        final result = compressTransactionMessageUsingAddressLookupTables(
          transactionMessage,
          lookupTables,
        );

        // First instruction: both replaced.
        final ix0Account0 = result.instructions[0].accounts![0];
        expect(ix0Account0, isA<AccountLookupMeta>());
        expect(ix0Account0.address, address1);

        final ix0Account1 = result.instructions[0].accounts![1];
        expect(ix0Account1, isA<AccountLookupMeta>());
        expect(ix0Account1.address, address2);

        // Second instruction: address1 replaced, address2 is signer so not.
        final ix1Account0 = result.instructions[1].accounts![0];
        expect(ix1Account0, isA<AccountLookupMeta>());
        expect(ix1Account0.address, address1);

        final ix1Account1 = result.instructions[1].accounts![1];
        expect(ix1Account1, isNot(isA<AccountLookupMeta>()));
        expect(ix1Account1.address, address2);
        expect(ix1Account1.role, AccountRole.readonlySigner);
      },
    );

    test('should return the input transaction message if no accounts are '
        'replaced in any instruction', () {
      const address = Address('address1');
      const lookupTableAddress = Address('lookupTableAddress');

      final transactionMessage =
          createTransactionMessage(version: TransactionVersion.v0).pipe(
            (tx) => appendTransactionMessageInstructions(const [
              Instruction(
                programAddress: programAddress,
                accounts: [
                  AccountMeta(
                    address: address,
                    role: AccountRole.readonlySigner,
                  ),
                ],
              ),
              Instruction(
                programAddress: programAddress,
                accounts: [
                  AccountMeta(
                    address: address,
                    role: AccountRole.readonlySigner,
                  ),
                ],
              ),
            ], tx),
          );

      final lookupTables = <Address, List<Address>>{
        lookupTableAddress: const [address],
      };

      final result = compressTransactionMessageUsingAddressLookupTables(
        transactionMessage,
        lookupTables,
      );

      expect(identical(result, transactionMessage), isTrue);
    });

    test('should not replace a program address that appears as an account '
        'in another instruction', () {
      const programAddressA = Address('programA');
      const programAddressB = Address('programB');
      const lookupTableAddress = Address('lookupTableAddress');

      final transactionMessage = appendTransactionMessageInstructions(const [
        Instruction(programAddress: programAddressA, accounts: <AccountMeta>[]),
        Instruction(
          programAddress: programAddressB,
          accounts: [
            AccountMeta(address: programAddressA, role: AccountRole.readonly),
          ],
        ),
      ], createTransactionMessage(version: TransactionVersion.v0));

      final lookupTables = <Address, List<Address>>{
        lookupTableAddress: const [programAddressA],
      };

      final result = compressTransactionMessageUsingAddressLookupTables(
        transactionMessage,
        lookupTables,
      );

      // programAddressA should NOT be compressed even though it's in the
      // lookup table, because it's used as a program address.
      final account = result.instructions[1].accounts![0];
      expect(account, isNot(isA<AccountLookupMeta>()));
      expect(account.address, programAddressA);
      expect(account.role, AccountRole.readonly);
    });
  });
}
