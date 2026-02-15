import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  const programA = Address(
    'AALQD2dt1k43Acrkp4SvdhZaN4S115Ff2Bi7rHPti3sL',
  );
  const programB = Address(
    'DNAbkMkoMLRXF7wuLCrTzouMyzi25krr3B94yW87VvxU',
  );
  const programC = Address(
    '6Bkt4j67rxzFF6s9DaMRyfitftRrGxe4oYHPRHuFChzi',
  );

  group('Transaction instruction helpers', () {
    late TransactionMessage baseTx;
    late Instruction exampleInstruction;
    late Instruction secondExampleInstruction;

    setUp(() {
      baseTx = const TransactionMessage(
        version: TransactionVersion.v0,
        instructions: [Instruction(programAddress: programA)],
      );
      exampleInstruction = const Instruction(programAddress: programB);
      secondExampleInstruction = const Instruction(programAddress: programC);
    });

    group('appendTransactionMessageInstruction', () {
      test('adds the instruction to the end of the list', () {
        final txWithAdded = appendTransactionMessageInstruction(
          exampleInstruction,
          baseTx,
        );
        expect(txWithAdded.instructions.length, 2);
        expect(txWithAdded.instructions[0].programAddress, programA);
        expect(txWithAdded.instructions[1].programAddress, programB);
      });
    });

    group('appendTransactionMessageInstructions', () {
      test('adds the instructions to the end of the list', () {
        final txWithAdded = appendTransactionMessageInstructions(
          [exampleInstruction, secondExampleInstruction],
          baseTx,
        );
        expect(txWithAdded.instructions.length, 3);
        expect(txWithAdded.instructions[0].programAddress, programA);
        expect(txWithAdded.instructions[1].programAddress, programB);
        expect(txWithAdded.instructions[2].programAddress, programC);
      });
    });

    group('prependTransactionMessageInstruction', () {
      test('adds the instruction to the beginning of the list', () {
        final txWithAdded = prependTransactionMessageInstruction(
          exampleInstruction,
          baseTx,
        );
        expect(txWithAdded.instructions.length, 2);
        expect(txWithAdded.instructions[0].programAddress, programB);
        expect(txWithAdded.instructions[1].programAddress, programA);
      });
    });

    group('prependTransactionMessageInstructions', () {
      test('adds the instructions to the beginning of the list', () {
        final txWithAdded = prependTransactionMessageInstructions(
          [exampleInstruction, secondExampleInstruction],
          baseTx,
        );
        expect(txWithAdded.instructions.length, 3);
        expect(txWithAdded.instructions[0].programAddress, programB);
        expect(txWithAdded.instructions[1].programAddress, programC);
        expect(txWithAdded.instructions[2].programAddress, programA);
      });
    });
  });
}
