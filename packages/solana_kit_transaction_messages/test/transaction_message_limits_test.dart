import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('assertTransactionMessageIsWithinLimits', () {
    test('allows a message at the transaction limits', () {
      final message = _messageWithInstructions([
        _instruction(
          0,
          accounts: List.generate(
            maxTransactionSignerAddresses - 1,
            (index) => _account(index, role: AccountRole.readonlySigner),
          ),
        ),
      ]);

      expect(
        () => assertTransactionMessageIsWithinLimits(message),
        returnsNormally,
      );
    });

    test('throws when the message has too many instructions', () {
      final message = _messageWithInstructions(
        List.generate(maxTransactionInstructions + 1, (_) => _instruction(0)),
      );

      expect(
        () => assertTransactionMessageIsWithinLimits(message),
        throwsA(
          _solanaError(
            SolanaErrorCode.transactionTooManyInstructions,
            actualCount: maxTransactionInstructions + 1,
            maxAllowed: maxTransactionInstructions,
          ),
        ),
      );
    });

    test('throws when an instruction has too many account references', () {
      final message = _messageWithInstructions([
        _instruction(
          0,
          accounts: List.generate(
            maxAccountsPerInstruction + 1,
            (_) => _account(0),
          ),
        ),
      ]);

      expect(
        () => assertTransactionMessageIsWithinLimits(message),
        throwsA(
          _solanaError(
            SolanaErrorCode.transactionTooManyAccountsInInstruction,
            instructionIndex: 0,
            actualCount: maxAccountsPerInstruction + 1,
            maxAllowed: maxAccountsPerInstruction,
          ),
        ),
      );
    });

    test('throws when the message has too many signer addresses', () {
      final message = _messageWithInstructions([
        _instruction(
          0,
          accounts: List.generate(
            maxTransactionSignerAddresses,
            (index) => _account(index, role: AccountRole.readonlySigner),
          ),
        ),
      ]);

      expect(
        () => assertTransactionMessageIsWithinLimits(message),
        throwsA(
          _solanaError(
            SolanaErrorCode.transactionTooManySignerAddresses,
            actualCount: maxTransactionSignerAddresses + 1,
            maxAllowed: maxTransactionSignerAddresses,
          ),
        ),
      );
    });

    test('throws when the message has too many account addresses', () {
      final message = _messageWithInstructions([
        _instruction(
          0,
          accounts: List.generate(maxTransactionAccountAddresses - 1, _account),
        ),
      ]);

      expect(
        () => assertTransactionMessageIsWithinLimits(message),
        throwsA(
          _solanaError(
            SolanaErrorCode.transactionTooManyAccountAddresses,
            actualCount: maxTransactionAccountAddresses + 1,
            maxAllowed: maxTransactionAccountAddresses,
          ),
        ),
      );
    });

    test('does not count accounts when the fee payer is missing', () {
      final message = createTransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            instructions: [
              _instruction(
                0,
                accounts: List.generate(
                  maxTransactionAccountAddresses,
                  _account,
                ),
              ),
            ],
          );

      expect(
        () => assertTransactionMessageIsWithinLimits(message),
        returnsNormally,
      );
    });
  });

  group('compileTransactionMessage', () {
    test('enforces transaction message limits before compiling', () {
      final message = _messageWithInstructions(
        List.generate(maxTransactionInstructions + 1, (_) => _instruction(0)),
      );

      expect(
        () => compileTransactionMessage(message),
        throwsA(_solanaError(SolanaErrorCode.transactionTooManyInstructions)),
      );
    });
  });
}

TransactionMessage _messageWithInstructions(List<Instruction> instructions) {
  return createTransactionMessage(
    version: TransactionVersion.v0,
  ).copyWith(feePayer: const Address('fee-payer'), instructions: instructions);
}

Instruction _instruction(int index, {List<AccountMeta>? accounts}) {
  return Instruction(
    programAddress: Address('program-$index'),
    accounts: accounts,
    data: Uint8List(0),
  );
}

AccountMeta _account(int index, {AccountRole role = AccountRole.readonly}) {
  return AccountMeta(address: Address('account-$index'), role: role);
}

Matcher _solanaError(
  SolanaErrorCode code, {
  int? instructionIndex,
  int? actualCount,
  int? maxAllowed,
}) {
  var matcher = isA<SolanaError>().having((error) => error.code, 'code', code);

  if (instructionIndex != null) {
    matcher = matcher.having(
      (error) => error.context['instructionIndex'],
      'instructionIndex',
      instructionIndex,
    );
  }
  if (actualCount != null) {
    matcher = matcher.having(
      (error) => error.context['actualCount'],
      'actualCount',
      actualCount,
    );
  }
  if (maxAllowed != null) {
    matcher = matcher.having(
      (error) => error.context['maxAllowed'],
      'maxAllowed',
      maxAllowed,
    );
  }

  return matcher;
}
