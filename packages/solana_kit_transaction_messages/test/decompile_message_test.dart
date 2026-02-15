import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  final u64Max = BigInt.two.pow(64) - BigInt.one;
  const feePayer = Address('7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK');

  group('decompileTransactionMessage', () {
    group('for a transaction with a blockhash lifetime', () {
      const blockhash = 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL';

      test('converts a transaction with no instructions', () {
        const compiledTransaction = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 0,
          ),
          staticAccounts: [feePayer],
          lifetimeToken: blockhash,
          instructions: [],
        );

        final transaction = decompileTransactionMessage(compiledTransaction);

        expect(transaction.version, TransactionVersion.v0);
        expect(transaction.feePayer, feePayer);
        expect(
          transaction.lifetimeConstraint,
          isA<BlockhashLifetimeConstraint>()
              .having((c) => c.blockhash, 'blockhash', blockhash)
              .having(
                (c) => c.lastValidBlockHeight,
                'lastValidBlockHeight',
                u64Max,
              ),
        );
      });

      test('converts a transaction with version legacy', () {
        const compiledTransaction = CompiledTransactionMessage(
          version: TransactionVersion.legacy,
          header: MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 0,
          ),
          staticAccounts: [feePayer],
          lifetimeToken: blockhash,
          instructions: [],
        );

        final transaction = decompileTransactionMessage(compiledTransaction);
        expect(transaction.version, TransactionVersion.legacy);
      });

      test('converts a transaction with one instruction with no accounts '
          'or data', () {
        const programAddress = Address(
          'HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf',
        );

        const compiledTransaction = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 1,
          ),
          staticAccounts: [feePayer, programAddress],
          lifetimeToken: blockhash,
          instructions: [CompiledInstruction(programAddressIndex: 1)],
        );

        final transaction = decompileTransactionMessage(compiledTransaction);

        expect(transaction.instructions.length, 1);
        expect(transaction.instructions[0].programAddress, programAddress);
        expect(transaction.instructions[0].accounts, isNull);
        expect(transaction.instructions[0].data, isNull);
      });

      test(
        'converts a transaction with one instruction with accounts and data',
        () {
          const programAddress = Address(
            'HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf',
          );

          final compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: const MessageHeader(
              numSignerAccounts: 3,
              numReadonlySignerAccounts: 1,
              numReadonlyNonSignerAccounts: 2,
            ),
            staticAccounts: const [
              // writable signers
              feePayer,
              Address('H4RdPRWYk3pKw2CkNznxQK6J6herjgQke2pzFJW4GC6x'),
              // read-only signers
              Address('G35QeFd4jpXWfRkuRKwn8g4vYrmn8DWJ5v88Kkpd8z1V'),
              // writable non-signers
              Address('3LeBzRE9Yna5zi9R8vdT3MiNQYuEp4gJgVyhhwmqfCtd'),
              // read-only non-signers
              Address('8kud9bpNvfemXYdTFjs5cZ8fZinBkx8JAnhVmRwJZk5e'),
              programAddress,
            ],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(
                programAddressIndex: 5,
                accountIndices: const [1, 2, 3, 4],
                data: Uint8List.fromList([0, 1, 2, 3, 4]),
              ),
            ],
          );

          final transaction = decompileTransactionMessage(compiledTransaction);

          expect(transaction.instructions.length, 1);
          final ix = transaction.instructions[0];
          expect(ix.programAddress, programAddress);
          expect(ix.accounts!.length, 4);
          expect(
            ix.accounts![0].address,
            const Address('H4RdPRWYk3pKw2CkNznxQK6J6herjgQke2pzFJW4GC6x'),
          );
          expect(ix.accounts![0].role, AccountRole.writableSigner);
          expect(
            ix.accounts![1].address,
            const Address('G35QeFd4jpXWfRkuRKwn8g4vYrmn8DWJ5v88Kkpd8z1V'),
          );
          expect(ix.accounts![1].role, AccountRole.readonlySigner);
          expect(
            ix.accounts![2].address,
            const Address('3LeBzRE9Yna5zi9R8vdT3MiNQYuEp4gJgVyhhwmqfCtd'),
          );
          expect(ix.accounts![2].role, AccountRole.writable);
          expect(
            ix.accounts![3].address,
            const Address('8kud9bpNvfemXYdTFjs5cZ8fZinBkx8JAnhVmRwJZk5e'),
          );
          expect(ix.accounts![3].role, AccountRole.readonly);
          expect(ix.data, Uint8List.fromList([0, 1, 2, 3, 4]));
        },
      );

      test('converts a transaction with multiple instructions', () {
        const compiledTransaction = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 3,
          ),
          staticAccounts: [
            feePayer,
            Address('3hpECiFPtnyxoWqWqcVyfBUDhPKSZXWDduNXFywo8ncP'),
            Address('Cmqw16pVQvmW1b7Ek1ioQ5Ggf1PaoXi5XxsK9iVSbRKC'),
            Address('GJRYBLa6XpfswT1AN5tpGp8NHtUirwAdTPdSYXsW9L3S'),
          ],
          lifetimeToken: blockhash,
          instructions: [
            CompiledInstruction(programAddressIndex: 1),
            CompiledInstruction(programAddressIndex: 2),
            CompiledInstruction(programAddressIndex: 3),
          ],
        );

        final transaction = decompileTransactionMessage(compiledTransaction);

        expect(transaction.instructions.length, 3);
        expect(
          transaction.instructions[0].programAddress,
          const Address('3hpECiFPtnyxoWqWqcVyfBUDhPKSZXWDduNXFywo8ncP'),
        );
        expect(
          transaction.instructions[1].programAddress,
          const Address('Cmqw16pVQvmW1b7Ek1ioQ5Ggf1PaoXi5XxsK9iVSbRKC'),
        );
        expect(
          transaction.instructions[2].programAddress,
          const Address('GJRYBLa6XpfswT1AN5tpGp8NHtUirwAdTPdSYXsW9L3S'),
        );
      });

      test('converts a transaction with a given lastValidBlockHeight', () {
        const compiledTransaction = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 0,
          ),
          staticAccounts: [feePayer],
          lifetimeToken: blockhash,
          instructions: [],
        );

        final transaction = decompileTransactionMessage(
          compiledTransaction,
          DecompileTransactionMessageConfig(
            lastValidBlockHeight: BigInt.from(100),
          ),
        );

        expect(
          transaction.lifetimeConstraint,
          isA<BlockhashLifetimeConstraint>()
              .having((c) => c.blockhash, 'blockhash', blockhash)
              .having(
                (c) => c.lastValidBlockHeight,
                'lastValidBlockHeight',
                BigInt.from(100),
              ),
        );
      });
    });

    group('for a transaction with a durable nonce lifetime', () {
      const nonce = '27kqzE1RifbyoFtibDRTjbnfZ894jsNpuR77JJkt3vgH';
      const nonceAccountAddress = Address(
        'DhezFECsqmzuDxeuitFChbghTrwKLdsKdVsGArYbFEtm',
      );
      const nonceAuthorityAddress = Address(
        '2KntmCrnaf63tpNb8UMFFjFGGnYYAKQdmW9SbuCiRvhM',
      );
      const systemProgramAddress = Address('11111111111111111111111111111111');
      const recentBlockhashesSysvar = Address(
        'SysvarRecentB1ockHashes11111111111111111111',
      );

      test('converts a transaction with one instruction which is advance nonce '
          '(fee payer is nonce authority)', () {
        final compiledTransaction = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: const MessageHeader(
            numSignerAccounts: 1,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 2,
          ),
          staticAccounts: const [
            nonceAuthorityAddress,
            nonceAccountAddress,
            systemProgramAddress,
            recentBlockhashesSysvar,
          ],
          lifetimeToken: nonce,
          instructions: [
            CompiledInstruction(
              programAddressIndex: 2,
              accountIndices: const [1, 3, 0],
              data: Uint8List.fromList([4, 0, 0, 0]),
            ),
          ],
        );

        final transaction = decompileTransactionMessage(compiledTransaction);

        expect(transaction.instructions.length, 1);
        final ix = transaction.instructions[0];
        expect(ix.programAddress, systemProgramAddress);
        expect(ix.accounts!.length, 3);
        expect(ix.accounts![0].address, nonceAccountAddress);
        expect(ix.accounts![0].role, AccountRole.writable);
        expect(ix.accounts![1].address, recentBlockhashesSysvar);
        expect(ix.accounts![1].role, AccountRole.readonly);
        expect(ix.accounts![2].address, nonceAuthorityAddress);
        expect(ix.accounts![2].role, AccountRole.writableSigner);
        expect(transaction.feePayer, nonceAuthorityAddress);
        expect(
          transaction.lifetimeConstraint,
          isA<DurableNonceLifetimeConstraint>().having(
            (c) => c.nonce,
            'nonce',
            nonce,
          ),
        );
      });

      test('converts a transaction with one instruction which is advance nonce '
          '(fee payer is not nonce authority)', () {
        final compiledTransaction = CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: const MessageHeader(
            numSignerAccounts: 2,
            numReadonlySignerAccounts: 1,
            numReadonlyNonSignerAccounts: 2,
          ),
          staticAccounts: const [
            feePayer,
            nonceAuthorityAddress,
            nonceAccountAddress,
            systemProgramAddress,
            recentBlockhashesSysvar,
          ],
          lifetimeToken: nonce,
          instructions: [
            CompiledInstruction(
              programAddressIndex: 3,
              accountIndices: const [2, 4, 1],
              data: Uint8List.fromList([4, 0, 0, 0]),
            ),
          ],
        );

        final transaction = decompileTransactionMessage(compiledTransaction);

        expect(transaction.instructions.length, 1);
        final ix = transaction.instructions[0];
        expect(ix.programAddress, systemProgramAddress);
        expect(ix.accounts!.length, 3);
        expect(ix.accounts![0].address, nonceAccountAddress);
        expect(ix.accounts![0].role, AccountRole.writable);
        expect(ix.accounts![1].address, recentBlockhashesSysvar);
        expect(ix.accounts![1].role, AccountRole.readonly);
        expect(ix.accounts![2].address, nonceAuthorityAddress);
        expect(ix.accounts![2].role, AccountRole.readonlySigner);
      });

      test(
        'converts a durable nonce transaction with multiple instructions',
        () {
          final compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: const MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 4,
            ),
            staticAccounts: const [
              nonceAuthorityAddress,
              nonceAccountAddress,
              systemProgramAddress,
              recentBlockhashesSysvar,
              Address('3hpECiFPtnyxoWqWqcVyfBUDhPKSZXWDduNXFywo8ncP'),
              Address('Cmqw16pVQvmW1b7Ek1ioQ5Ggf1PaoXi5XxsK9iVSbRKC'),
            ],
            lifetimeToken: nonce,
            instructions: [
              CompiledInstruction(
                programAddressIndex: 2,
                accountIndices: const [1, 3, 0],
                data: Uint8List.fromList([4, 0, 0, 0]),
              ),
              CompiledInstruction(
                programAddressIndex: 4,
                accountIndices: const [0, 1],
                data: Uint8List.fromList([1, 2, 3, 4]),
              ),
              const CompiledInstruction(programAddressIndex: 5),
            ],
          );

          final transaction = decompileTransactionMessage(compiledTransaction);

          expect(transaction.instructions.length, 3);

          // First instruction: advance nonce.
          final ix0 = transaction.instructions[0];
          expect(ix0.programAddress, systemProgramAddress);
          expect(ix0.accounts!.length, 3);
          expect(ix0.accounts![0].address, nonceAccountAddress);
          expect(ix0.accounts![0].role, AccountRole.writable);
          expect(ix0.accounts![2].address, nonceAuthorityAddress);
          expect(ix0.accounts![2].role, AccountRole.writableSigner);

          // Second instruction.
          final ix1 = transaction.instructions[1];
          expect(
            ix1.programAddress,
            const Address('3hpECiFPtnyxoWqWqcVyfBUDhPKSZXWDduNXFywo8ncP'),
          );
          expect(ix1.accounts!.length, 2);
          expect(ix1.accounts![0].address, nonceAuthorityAddress);
          expect(ix1.accounts![0].role, AccountRole.writableSigner);
          expect(ix1.accounts![1].address, nonceAccountAddress);
          expect(ix1.accounts![1].role, AccountRole.writable);
          expect(ix1.data, Uint8List.fromList([1, 2, 3, 4]));

          // Third instruction.
          final ix2 = transaction.instructions[2];
          expect(
            ix2.programAddress,
            const Address('Cmqw16pVQvmW1b7Ek1ioQ5Ggf1PaoXi5XxsK9iVSbRKC'),
          );

          expect(
            transaction.lifetimeConstraint,
            isA<DurableNonceLifetimeConstraint>().having(
              (c) => c.nonce,
              'nonce',
              nonce,
            ),
          );
        },
      );
    });

    group('for a transaction with address lookup tables', () {
      const blockhash = 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL';
      const programAddress = Address(
        'HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf',
      );

      group('for one lookup table', () {
        const lookupTableAddress = Address(
          '9wnrQTq5MKhYfp379pKvpy1PvRyteseQmKv4Bw3uQrUw',
        );

        test('converts an instruction with a single readonly lookup', () {
          const addressInLookup = Address(
            'F1Vc6AGoxXLwGB7QV8f4So3C5d8SXEk3KKGHxKGEJ8qn',
          );
          final lookupTables = <Address, List<Address>>{
            lookupTableAddress: const [addressInLookup],
          };

          const compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: [feePayer, programAddress],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(programAddressIndex: 1, accountIndices: [2]),
            ],
            addressTableLookups: [
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress,
                readonlyIndexes: [0],
                writableIndexes: [],
              ),
            ],
          );

          final transaction = decompileTransactionMessage(
            compiledTransaction,
            DecompileTransactionMessageConfig(
              addressesByLookupTableAddress: lookupTables,
            ),
          );

          expect(transaction.instructions.length, 1);
          final account = transaction.instructions[0].accounts![0];
          expect(account, isA<AccountLookupMeta>());
          final lookup = account as AccountLookupMeta;
          expect(lookup.address, addressInLookup);
          expect(lookup.addressIndex, 0);
          expect(lookup.lookupTableAddress, lookupTableAddress);
          expect(lookup.role, AccountRole.readonly);
        });

        test('converts an instruction with a single writable lookup', () {
          const addressInLookup = Address(
            'F1Vc6AGoxXLwGB7QV8f4So3C5d8SXEk3KKGHxKGEJ8qn',
          );
          final lookupTables = <Address, List<Address>>{
            lookupTableAddress: const [addressInLookup],
          };

          const compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: [feePayer, programAddress],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(programAddressIndex: 1, accountIndices: [2]),
            ],
            addressTableLookups: [
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress,
                readonlyIndexes: [],
                writableIndexes: [0],
              ),
            ],
          );

          final transaction = decompileTransactionMessage(
            compiledTransaction,
            DecompileTransactionMessageConfig(
              addressesByLookupTableAddress: lookupTables,
            ),
          );

          final account = transaction.instructions[0].accounts![0];
          expect(account, isA<AccountLookupMeta>());
          final lookup = account as AccountLookupMeta;
          expect(lookup.address, addressInLookup);
          expect(lookup.addressIndex, 0);
          expect(lookup.lookupTableAddress, lookupTableAddress);
          expect(lookup.role, AccountRole.writable);
        });

        test('converts an instruction with a combination of static and '
            'lookup accounts', () {
          const addressInLookup = Address(
            'F1Vc6AGoxXLwGB7QV8f4So3C5d8SXEk3KKGHxKGEJ8qn',
          );
          const staticAddress = Address(
            'GbRuWcHyNaVuE9rJE4sKpkHYa9k76VJBCCwGtf87ikH3',
          );

          final lookupTables = <Address, List<Address>>{
            lookupTableAddress: const [addressInLookup],
          };

          const compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 2,
            ),
            staticAccounts: [feePayer, staticAddress, programAddress],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(
                programAddressIndex: 2,
                accountIndices: [1, 3],
              ),
            ],
            addressTableLookups: [
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress,
                readonlyIndexes: [0],
                writableIndexes: [],
              ),
            ],
          );

          final transaction = decompileTransactionMessage(
            compiledTransaction,
            DecompileTransactionMessageConfig(
              addressesByLookupTableAddress: lookupTables,
            ),
          );

          expect(transaction.instructions.length, 1);
          final accounts = transaction.instructions[0].accounts!;
          expect(accounts.length, 2);

          // First account is a static account.
          expect(accounts[0], isNot(isA<AccountLookupMeta>()));
          expect(accounts[0].address, staticAddress);
          expect(accounts[0].role, AccountRole.readonly);

          // Second account is a lookup.
          expect(accounts[1], isA<AccountLookupMeta>());
          final lookup = accounts[1] as AccountLookupMeta;
          expect(lookup.address, addressInLookup);
          expect(lookup.addressIndex, 0);
          expect(lookup.lookupTableAddress, lookupTableAddress);
          expect(lookup.role, AccountRole.readonly);
        });

        test('throws if the lookup table is not passed in', () {
          const compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: [feePayer, programAddress],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(programAddressIndex: 1, accountIndices: [2]),
            ],
            addressTableLookups: [
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress,
                readonlyIndexes: [0],
                writableIndexes: [],
              ),
            ],
          );

          expect(
            () => decompileTransactionMessage(compiledTransaction),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .transactionFailedToDecompileAddressLookupTableContentsMissing,
              ),
            ),
          );
        });

        test('throws if a read index is outside the lookup table', () {
          const addressInLookup = Address(
            'F1Vc6AGoxXLwGB7QV8f4So3C5d8SXEk3KKGHxKGEJ8qn',
          );
          final lookupTables = <Address, List<Address>>{
            lookupTableAddress: const [addressInLookup],
          };

          const compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: [feePayer, programAddress],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(programAddressIndex: 1, accountIndices: [2]),
            ],
            addressTableLookups: [
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress,
                readonlyIndexes: [1],
                writableIndexes: [],
              ),
            ],
          );

          expect(
            () => decompileTransactionMessage(
              compiledTransaction,
              DecompileTransactionMessageConfig(
                addressesByLookupTableAddress: lookupTables,
              ),
            ),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .transactionFailedToDecompileAddressLookupTableIndexOutOfRange,
              ),
            ),
          );
        });

        test('throws if a write index is outside the lookup table', () {
          const addressInLookup = Address(
            'F1Vc6AGoxXLwGB7QV8f4So3C5d8SXEk3KKGHxKGEJ8qn',
          );
          final lookupTables = <Address, List<Address>>{
            lookupTableAddress: const [addressInLookup],
          };

          const compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: [feePayer, programAddress],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(programAddressIndex: 1, accountIndices: [2]),
            ],
            addressTableLookups: [
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress,
                readonlyIndexes: [],
                writableIndexes: [1],
              ),
            ],
          );

          expect(
            () => decompileTransactionMessage(
              compiledTransaction,
              DecompileTransactionMessageConfig(
                addressesByLookupTableAddress: lookupTables,
              ),
            ),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .transactionFailedToDecompileAddressLookupTableIndexOutOfRange,
              ),
            ),
          );
        });
      });

      group('for multiple lookup tables', () {
        const lookupTableAddress1 = Address(
          '9wnrQTq5MKhYfp379pKvpy1PvRyteseQmKv4Bw3uQrUw',
        );
        const lookupTableAddress2 = Address(
          'GS7Rphk6CZLoCGbTcbRaPZzD3k4ZK8XiA5BAj89Fi2Eg',
        );

        test('converts an instruction with readonly accounts from two lookup '
            'tables', () {
          const addressInLookup1 = Address(
            'F1Vc6AGoxXLwGB7QV8f4So3C5d8SXEk3KKGHxKGEJ8qn',
          );
          const addressInLookup2 = Address(
            'E7p56hzZZEs9vJ1yjxAFjhUP3fN2UJNk2nWvcY7Hz3ee',
          );
          final lookupTables = <Address, List<Address>>{
            lookupTableAddress1: const [addressInLookup1],
            lookupTableAddress2: const [addressInLookup2],
          };

          const compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: [feePayer, programAddress],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(
                programAddressIndex: 1,
                accountIndices: [2, 3],
              ),
            ],
            addressTableLookups: [
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress1,
                readonlyIndexes: [0],
                writableIndexes: [],
              ),
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress2,
                readonlyIndexes: [0],
                writableIndexes: [],
              ),
            ],
          );

          final transaction = decompileTransactionMessage(
            compiledTransaction,
            DecompileTransactionMessageConfig(
              addressesByLookupTableAddress: lookupTables,
            ),
          );

          final accounts = transaction.instructions[0].accounts!;
          expect(accounts.length, 2);

          final lookup0 = accounts[0] as AccountLookupMeta;
          expect(lookup0.address, addressInLookup1);
          expect(lookup0.lookupTableAddress, lookupTableAddress1);

          final lookup1 = accounts[1] as AccountLookupMeta;
          expect(lookup1.address, addressInLookup2);
          expect(lookup1.lookupTableAddress, lookupTableAddress2);
        });

        test('throws if multiple lookup tables are not passed in', () {
          const compiledTransaction = CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: [feePayer, programAddress],
            lifetimeToken: blockhash,
            instructions: [
              CompiledInstruction(programAddressIndex: 1, accountIndices: [2]),
            ],
            addressTableLookups: [
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress1,
                readonlyIndexes: [0],
                writableIndexes: [],
              ),
              AddressTableLookup(
                lookupTableAddress: lookupTableAddress2,
                readonlyIndexes: [0],
                writableIndexes: [],
              ),
            ],
          );

          expect(
            () => decompileTransactionMessage(compiledTransaction),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .transactionFailedToDecompileAddressLookupTableContentsMissing,
              ),
            ),
          );
        });
      });
    });

    test('throws if no static accounts (fee payer missing)', () {
      const compiledTransaction = CompiledTransactionMessage(
        version: TransactionVersion.v0,
        header: MessageHeader(
          numSignerAccounts: 0,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: [],
        instructions: [],
      );

      expect(
        () => decompileTransactionMessage(compiledTransaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionFailedToDecompileFeePayerMissing,
          ),
        ),
      );
    });
  });
}
