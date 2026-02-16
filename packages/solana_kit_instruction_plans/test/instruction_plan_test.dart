import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('singleInstructionPlan', () {
    test('creates SingleInstructionPlan objects', () {
      final instruction = createInstruction('A');
      final plan = singleInstructionPlan(instruction);

      expect(plan, isA<SingleInstructionPlan>());
      expect(plan.kind, 'single');
      expect(plan.instruction, same(instruction));
    });
  });

  group('sequentialInstructionPlan', () {
    test('creates divisible SequentialInstructionPlan from plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = sequentialInstructionPlan([
        singleInstructionPlan(instructionA),
        singleInstructionPlan(instructionB),
      ]);

      expect(plan, isA<SequentialInstructionPlan>());
      expect(plan.kind, 'sequential');
      expect(plan.divisible, isTrue);
      expect(plan.plans, hasLength(2));
    });

    test('accepts instructions directly and wraps them in single plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = sequentialInstructionPlan([instructionA, instructionB]);

      expect(plan.plans, hasLength(2));
      expect(plan.plans[0], isA<SingleInstructionPlan>());
      expect(plan.plans[1], isA<SingleInstructionPlan>());
      expect(
        (plan.plans[0] as SingleInstructionPlan).instruction,
        same(instructionA),
      );
    });

    test('can nest other sequential plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final instructionC = createInstruction('C');
      final plan = sequentialInstructionPlan([
        instructionA,
        sequentialInstructionPlan([instructionB, instructionC]),
      ]);

      expect(plan.plans, hasLength(2));
      expect(plan.plans[0], isA<SingleInstructionPlan>());
      expect(plan.plans[1], isA<SequentialInstructionPlan>());
    });

    test('creates unmodifiable plans list', () {
      final plan = sequentialInstructionPlan([
        createInstruction('A'),
        createInstruction('B'),
      ]);
      expect(
        () => (plan.plans as List).add(
          singleInstructionPlan(createInstruction('C')),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('nonDivisibleSequentialInstructionPlan', () {
    test('creates non-divisible SequentialInstructionPlan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = nonDivisibleSequentialInstructionPlan([
        singleInstructionPlan(instructionA),
        singleInstructionPlan(instructionB),
      ]);

      expect(plan, isA<SequentialInstructionPlan>());
      expect(plan.kind, 'sequential');
      expect(plan.divisible, isFalse);
      expect(plan.plans, hasLength(2));
    });

    test('accepts instructions directly and wraps them in single plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = nonDivisibleSequentialInstructionPlan([
        instructionA,
        instructionB,
      ]);

      expect(plan.plans, hasLength(2));
      expect(plan.plans[0], isA<SingleInstructionPlan>());
      expect(plan.plans[1], isA<SingleInstructionPlan>());
    });

    test('can nest other non-divisible sequential plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final instructionC = createInstruction('C');
      final plan = nonDivisibleSequentialInstructionPlan([
        instructionA,
        nonDivisibleSequentialInstructionPlan([instructionB, instructionC]),
      ]);

      expect(plan.plans, hasLength(2));
      expect(plan.plans[1], isA<SequentialInstructionPlan>());
      expect((plan.plans[1] as SequentialInstructionPlan).divisible, isFalse);
    });
  });

  group('parallelInstructionPlan', () {
    test('creates ParallelInstructionPlan from plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = parallelInstructionPlan([
        singleInstructionPlan(instructionA),
        singleInstructionPlan(instructionB),
      ]);

      expect(plan, isA<ParallelInstructionPlan>());
      expect(plan.kind, 'parallel');
      expect(plan.plans, hasLength(2));
    });

    test('accepts instructions directly and wraps them in single plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = parallelInstructionPlan([instructionA, instructionB]);

      expect(plan.plans, hasLength(2));
      expect(plan.plans[0], isA<SingleInstructionPlan>());
      expect(plan.plans[1], isA<SingleInstructionPlan>());
    });

    test('can nest other parallel plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final instructionC = createInstruction('C');
      final plan = parallelInstructionPlan([
        instructionA,
        parallelInstructionPlan([instructionB, instructionC]),
      ]);

      expect(plan.plans, hasLength(2));
      expect(plan.plans[0], isA<SingleInstructionPlan>());
      expect(plan.plans[1], isA<ParallelInstructionPlan>());
    });
  });

  group('isSingleInstructionPlan', () {
    test('returns true for SingleInstructionPlan', () {
      expect(
        isSingleInstructionPlan(singleInstructionPlan(createInstruction('A'))),
        isTrue,
      );
    });

    test('returns false for other plans', () {
      expect(isSingleInstructionPlan(sequentialInstructionPlan([])), isFalse);
      expect(
        isSingleInstructionPlan(nonDivisibleSequentialInstructionPlan([])),
        isFalse,
      );
      expect(isSingleInstructionPlan(parallelInstructionPlan([])), isFalse);
    });
  });

  group('assertIsSingleInstructionPlan', () {
    test('does nothing for SingleInstructionPlan', () {
      expect(
        () => assertIsSingleInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        returnsNormally,
      );
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsSingleInstructionPlan(sequentialInstructionPlan([])),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedInstructionPlan,
          ),
        ),
      );
      expect(
        () => assertIsSingleInstructionPlan(parallelInstructionPlan([])),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('isMessagePackerInstructionPlan', () {
    test('returns true for MessagePackerInstructionPlan', () {
      final plan = getMessagePackerInstructionPlanFromInstructions([
        createInstruction('A'),
      ]);
      expect(isMessagePackerInstructionPlan(plan), isTrue);
    });

    test('returns false for other plans', () {
      expect(
        isMessagePackerInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        isFalse,
      );
      expect(
        isMessagePackerInstructionPlan(sequentialInstructionPlan([])),
        isFalse,
      );
      expect(
        isMessagePackerInstructionPlan(parallelInstructionPlan([])),
        isFalse,
      );
    });
  });

  group('assertIsMessagePackerInstructionPlan', () {
    test('does nothing for MessagePackerInstructionPlan', () {
      final plan = getMessagePackerInstructionPlanFromInstructions([
        createInstruction('A'),
      ]);
      expect(() => assertIsMessagePackerInstructionPlan(plan), returnsNormally);
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsMessagePackerInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedInstructionPlan,
          ),
        ),
      );
    });
  });

  group('isSequentialInstructionPlan', () {
    test('returns true for SequentialInstructionPlan (divisible or not)', () {
      expect(
        isSequentialInstructionPlan(sequentialInstructionPlan([])),
        isTrue,
      );
      expect(
        isSequentialInstructionPlan(nonDivisibleSequentialInstructionPlan([])),
        isTrue,
      );
    });

    test('returns false for other plans', () {
      expect(
        isSequentialInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        isFalse,
      );
      expect(isSequentialInstructionPlan(parallelInstructionPlan([])), isFalse);
    });
  });

  group('assertIsSequentialInstructionPlan', () {
    test('does nothing for SequentialInstructionPlan', () {
      expect(
        () => assertIsSequentialInstructionPlan(sequentialInstructionPlan([])),
        returnsNormally,
      );
      expect(
        () => assertIsSequentialInstructionPlan(
          nonDivisibleSequentialInstructionPlan([]),
        ),
        returnsNormally,
      );
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsSequentialInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        throwsA(isA<SolanaError>()),
      );
      expect(
        () => assertIsSequentialInstructionPlan(parallelInstructionPlan([])),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('isNonDivisibleSequentialInstructionPlan', () {
    test('returns true for non-divisible SequentialInstructionPlan', () {
      expect(
        isNonDivisibleSequentialInstructionPlan(
          nonDivisibleSequentialInstructionPlan([]),
        ),
        isTrue,
      );
    });

    test('returns false for other plans', () {
      expect(
        isNonDivisibleSequentialInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        isFalse,
      );
      expect(
        isNonDivisibleSequentialInstructionPlan(sequentialInstructionPlan([])),
        isFalse,
      );
      expect(
        isNonDivisibleSequentialInstructionPlan(parallelInstructionPlan([])),
        isFalse,
      );
    });
  });

  group('assertIsNonDivisibleSequentialInstructionPlan', () {
    test('does nothing for non-divisible SequentialInstructionPlan', () {
      expect(
        () => assertIsNonDivisibleSequentialInstructionPlan(
          nonDivisibleSequentialInstructionPlan([]),
        ),
        returnsNormally,
      );
    });

    test('throws SolanaError for divisible sequential plan', () {
      expect(
        () => assertIsNonDivisibleSequentialInstructionPlan(
          sequentialInstructionPlan([]),
        ),
        throwsA(isA<SolanaError>()),
      );
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsNonDivisibleSequentialInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        throwsA(isA<SolanaError>()),
      );
      expect(
        () => assertIsNonDivisibleSequentialInstructionPlan(
          parallelInstructionPlan([]),
        ),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('isParallelInstructionPlan', () {
    test('returns true for ParallelInstructionPlan', () {
      expect(isParallelInstructionPlan(parallelInstructionPlan([])), isTrue);
    });

    test('returns false for other plans', () {
      expect(
        isParallelInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        isFalse,
      );
      expect(isParallelInstructionPlan(sequentialInstructionPlan([])), isFalse);
      expect(
        isParallelInstructionPlan(nonDivisibleSequentialInstructionPlan([])),
        isFalse,
      );
    });
  });

  group('assertIsParallelInstructionPlan', () {
    test('does nothing for ParallelInstructionPlan', () {
      expect(
        () => assertIsParallelInstructionPlan(parallelInstructionPlan([])),
        returnsNormally,
      );
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsParallelInstructionPlan(
          singleInstructionPlan(createInstruction('A')),
        ),
        throwsA(isA<SolanaError>()),
      );
      expect(
        () => assertIsParallelInstructionPlan(sequentialInstructionPlan([])),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('isInstructionPlan', () {
    test('returns true for all instruction plan types', () {
      expect(
        isInstructionPlan(singleInstructionPlan(createInstruction('A'))),
        isTrue,
      );
      expect(isInstructionPlan(sequentialInstructionPlan([])), isTrue);
      expect(
        isInstructionPlan(nonDivisibleSequentialInstructionPlan([])),
        isTrue,
      );
      expect(isInstructionPlan(parallelInstructionPlan([])), isTrue);
      expect(
        isInstructionPlan(getMessagePackerInstructionPlanFromInstructions([])),
        isTrue,
      );
    });

    test('returns false for non-instruction-plan values', () {
      expect(isInstructionPlan(null), isFalse);
      expect(isInstructionPlan('string'), isFalse);
      expect(isInstructionPlan(123), isFalse);
      expect(isInstructionPlan(true), isFalse);
    });
  });
}
