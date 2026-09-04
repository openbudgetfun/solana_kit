import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

const _payer = Address('7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK');
const _program = Address('11111111111111111111111111111111');
const _account = Address('HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf');
const _table = Address('H4RdPRWYk3pKw2CkNznxQK6J6herjgQke2pzFJW4GC6x');

void main() {
  group('lookup compilation security', () {
    for (final role in [
      AccountRole.readonlySigner,
      AccountRole.writableSigner,
    ]) {
      for (final precedesLookup in [true, false]) {
        test(
          'preserves $role when signer precedes lookup: $precedesLookup',
          () {
            final signer = AccountLookupMeta(
              address: _account,
              role: role,
              lookupTableAddress: _table,
              addressIndex: 0,
            );
            const lookup = AccountLookupMeta(
              address: _account,
              role: AccountRole.readonly,
              lookupTableAddress: _table,
              addressIndex: 0,
            );
            final compiled = compileTransactionMessage(
              TransactionMessage(
                version: TransactionVersion.v0,
                feePayer: _payer,
                instructions: [
                  Instruction(
                    programAddress: _program,
                    accounts: precedesLookup
                        ? [signer, lookup]
                        : [lookup, signer],
                  ),
                ],
              ),
            );

            expect(compiled.header.numSignerAccounts, 2);
            expect(compiled.staticAccounts.take(2), [_payer, _account]);
            expect(compiled.addressTableLookups, isEmpty);
            final preview = decompileTransactionMessage(compiled);
            expect(preview.instructions.single.accounts!.first.role, role);
          },
        );
      }
    }

    for (final version in [TransactionVersion.legacy, TransactionVersion.v1]) {
      test('$version materializes lookup addresses with correct roles', () {
        final message = TransactionMessage(
          version: version,
          feePayer: _payer,
          instructions: const [
            Instruction(
              programAddress: _program,
              accounts: [
                AccountLookupMeta(
                  address: _account,
                  role: AccountRole.writable,
                  lookupTableAddress: _table,
                  addressIndex: 0,
                ),
              ],
            ),
          ],
        );
        final compiled = compileTransactionMessage(message);

        expect(compiled.staticAccounts, [_payer, _account, _program]);
        expect(compiled.header.numReadonlyNonSignerAccounts, 1);
        expect(compiled.addressTableLookups, isNull);
        final preview = decompileTransactionMessage(compiled);
        expect(preview.instructions.single.accounts!.single.address, _account);
        expect(
          preview.instructions.single.accounts!.single.role,
          AccountRole.writable,
        );
      });
    }
  });
}
