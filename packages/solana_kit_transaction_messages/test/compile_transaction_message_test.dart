import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  const feePayer = Address('7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK');
  const programAddress = Address(
    'HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf',
  );

  group('compileTransactionMessage', () {
    test('throws when there is no fee payer', () {
      final tx = createTransactionMessage(version: TransactionVersion.v0);
      expect(
        () => compileTransactionMessage(tx),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionFeePayerMissing,
          ),
        ),
      );
    });

    test('compiles a simple transaction with no instructions', () {
      final tx = createTransactionMessage(
        version: TransactionVersion.v0,
      ).copyWith(feePayer: feePayer);
      final compiled = compileTransactionMessage(tx);

      expect(compiled.version, TransactionVersion.v0);
      expect(compiled.header.numSignerAccounts, 1);
      expect(compiled.header.numReadonlySignerAccounts, 0);
      expect(compiled.header.numReadonlyNonSignerAccounts, 0);
      expect(compiled.staticAccounts, [feePayer]);
      expect(compiled.instructions, isEmpty);
    });

    test('compiles a transaction with a blockhash lifetime', () {
      final tx = createTransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            feePayer: feePayer,
            lifetimeConstraint: BlockhashLifetimeConstraint(
              blockhash: 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
              lastValidBlockHeight: BigInt.from(100),
            ),
          );
      final compiled = compileTransactionMessage(tx);

      expect(
        compiled.lifetimeToken,
        'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
      );
    });

    test('compiles a transaction with a durable nonce lifetime', () {
      final tx = createTransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            feePayer: feePayer,
            lifetimeConstraint: const DurableNonceLifetimeConstraint(
              nonce: '27kqzE1RifbyoFtibDRTjbnfZ894jsNpuR77JJkt3vgH',
            ),
          );
      final compiled = compileTransactionMessage(tx);

      expect(
        compiled.lifetimeToken,
        '27kqzE1RifbyoFtibDRTjbnfZ894jsNpuR77JJkt3vgH',
      );
    });

    test('compiles a transaction with an instruction', () {
      final tx = createTransactionMessage(
        version: TransactionVersion.v0,
      ).copyWith(feePayer: feePayer);
      final txWithInstruction = appendTransactionMessageInstruction(
        Instruction(
          programAddress: programAddress,
          accounts: const [
            AccountMeta(
              address: Address('H4RdPRWYk3pKw2CkNznxQK6J6herjgQke2pzFJW4GC6x'),
              role: AccountRole.writableSigner,
            ),
            AccountMeta(
              address: Address('3LeBzRE9Yna5zi9R8vdT3MiNQYuEp4gJgVyhhwmqfCtd'),
              role: AccountRole.writable,
            ),
          ],
          data: Uint8List.fromList([1, 2, 3]),
        ),
        tx,
      );

      final compiled = compileTransactionMessage(txWithInstruction);

      // Fee payer (writable signer), instruction account (writable signer),
      // instruction account (writable), program (readonly)
      expect(compiled.staticAccounts.length, 4);
      expect(compiled.header.numSignerAccounts, 2);
      expect(compiled.instructions.length, 1);
      expect(compiled.instructions[0].data, Uint8List.fromList([1, 2, 3]));
    });

    test('does not include addressTableLookups for legacy transactions', () {
      final tx = createTransactionMessage(
        version: TransactionVersion.legacy,
      ).copyWith(feePayer: feePayer);
      final compiled = compileTransactionMessage(tx);

      expect(compiled.addressTableLookups, isNull);
    });

    test('includes addressTableLookups for v0 transactions', () {
      final tx = createTransactionMessage(
        version: TransactionVersion.v0,
      ).copyWith(feePayer: feePayer);
      final compiled = compileTransactionMessage(tx);

      expect(compiled.addressTableLookups, isNotNull);
      expect(compiled.addressTableLookups, isEmpty);
    });

    test('compiles v1 config, instruction headers, and payloads', () {
      final tx = createTransactionMessage(version: TransactionVersion.v1)
          .copyWith(
            feePayer: feePayer,
            config: V1TransactionConfig(
              computeUnitLimit: 200000,
              heapSize: 32768,
              loadedAccountsDataSizeLimit: 65536,
              priorityFeeLamports: BigInt.from(5000),
            ),
          );
      final txWithInstruction = appendTransactionMessageInstruction(
        Instruction(
          programAddress: programAddress,
          accounts: const [
            AccountMeta(
              address: Address('H4RdPRWYk3pKw2CkNznxQK6J6herjgQke2pzFJW4GC6x'),
              role: AccountRole.writableSigner,
            ),
          ],
          data: Uint8List.fromList([9, 8, 7]),
        ),
        tx,
      );

      final compiled = compileTransactionMessage(txWithInstruction);

      expect(compiled.version, TransactionVersion.v1);
      expect(compiled.configMask, 31);
      expect(compiled.configValues?.map((value) => (value.kind, value.value)), [
        ('u64', BigInt.from(5000)),
        ('u32', 200000),
        ('u32', 65536),
        ('u32', 32768),
      ]);
      expect(compiled.instructions, isEmpty);
      expect(compiled.addressTableLookups, isNull);
      expect(compiled.numInstructions, 1);
      expect(compiled.numStaticAccounts, compiled.staticAccounts.length);
      expect(compiled.instructionHeaders, hasLength(1));
      expect(compiled.instructionHeaders!.single.numInstructionAccounts, 1);
      expect(compiled.instructionHeaders!.single.numInstructionDataBytes, 3);
      expect(
        compiled.instructionPayloads!.single.instructionData,
        Uint8List.fromList([9, 8, 7]),
      );
    });

    test('compiles all v1 accounts as static accounts', () {
      const lookupAccount = Address('lookupAccount');
      final tx = appendTransactionMessageInstruction(
        const Instruction(
          programAddress: programAddress,
          accounts: [
            AccountLookupMeta(
              address: lookupAccount,
              addressIndex: 0,
              lookupTableAddress: Address('lookupTableAddress'),
              role: AccountRole.readonly,
            ),
          ],
        ),
        createTransactionMessage(
          version: TransactionVersion.v1,
        ).copyWith(feePayer: feePayer),
      );

      final compiled = compileTransactionMessage(tx);

      expect(compiled.staticAccounts, contains(lookupAccount));
      expect(compiled.numStaticAccounts, compiled.staticAccounts.length);
    });

    test('compiles a transaction with readonly signer account', () {
      const readonlySigner = Address('readonlySigner1111111111111111111111');
      final tx = createTransactionMessage(
        version: TransactionVersion.v0,
      ).copyWith(feePayer: feePayer);

      final txWithIx = appendTransactionMessageInstruction(
        const Instruction(
          programAddress: programAddress,
          accounts: [
            AccountMeta(
              address: readonlySigner,
              role: AccountRole.readonlySigner,
            ),
          ],
        ),
        tx,
      );

      final compiled = compileTransactionMessage(txWithIx);

      // Fee payer (writable signer), readonly signer, program (readonly)
      expect(compiled.header.numSignerAccounts, 2);
      expect(compiled.header.numReadonlySignerAccounts, 1);
      expect(compiled.header.numReadonlyNonSignerAccounts, 1);
    });

    test('compiles v0 with lookup table accounts producing writable and '
        'readonly indexes', () {
      const writableLookup = Address('writableLookup');
      const readonlyLookup = Address('readonlyLookup');
      const lookupTableAddr = Address('lookupTableAddress');

      final tx = appendTransactionMessageInstruction(
        const Instruction(
          programAddress: programAddress,
          accounts: [
            AccountLookupMeta(
              address: writableLookup,
              addressIndex: 0,
              lookupTableAddress: lookupTableAddr,
              role: AccountRole.writable,
            ),
            AccountLookupMeta(
              address: readonlyLookup,
              addressIndex: 1,
              lookupTableAddress: lookupTableAddr,
              role: AccountRole.readonly,
            ),
          ],
        ),
        createTransactionMessage(
          version: TransactionVersion.v0,
        ).copyWith(feePayer: feePayer),
      );

      final compiled = compileTransactionMessage(tx);

      expect(compiled.addressTableLookups, isNotNull);
      expect(compiled.addressTableLookups!.length, 1);
      expect(compiled.addressTableLookups![0].writableIndexes, [0]);
      expect(compiled.addressTableLookups![0].readonlyIndexes, [1]);
    });

    test('compiles v0 with multiple lookup tables', () {
      const lookup1 = Address('lookup1Account');
      const lookup2 = Address('lookup2Account');
      const table1 = Address('table1');
      const table2 = Address('table2');

      final tx = appendTransactionMessageInstruction(
        const Instruction(
          programAddress: programAddress,
          accounts: [
            AccountLookupMeta(
              address: lookup1,
              addressIndex: 0,
              lookupTableAddress: table1,
              role: AccountRole.readonly,
            ),
            AccountLookupMeta(
              address: lookup2,
              addressIndex: 0,
              lookupTableAddress: table2,
              role: AccountRole.readonly,
            ),
          ],
        ),
        createTransactionMessage(
          version: TransactionVersion.v0,
        ).copyWith(feePayer: feePayer),
      );

      final compiled = compileTransactionMessage(tx);

      expect(compiled.addressTableLookups, isNotNull);
      expect(compiled.addressTableLookups!.length, 2);
    });
  });
}
