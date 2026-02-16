import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('findInstructionPlan', () {
    test('returns the plan itself when it matches the predicate', () {
      final instructionA = createInstruction('A');
      final plan = singleInstructionPlan(instructionA);
      final result = findInstructionPlan(plan, (p) => p.kind == 'single');
      expect(result, same(plan));
    });

    test('returns null when no plan matches the predicate', () {
      final instructionA = createInstruction('A');
      final plan = singleInstructionPlan(instructionA);
      final result = findInstructionPlan(plan, (p) => p.kind == 'parallel');
      expect(result, isNull);
    });

    test('finds a nested plan in a parallel structure', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final nestedSequential = sequentialInstructionPlan([
        instructionA,
        instructionB,
      ]);
      final plan = parallelInstructionPlan([nestedSequential]);
      final result = findInstructionPlan(plan, (p) => p.kind == 'sequential');
      expect(result, same(nestedSequential));
    });

    test('finds a nested plan in a sequential structure', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final nestedParallel = parallelInstructionPlan([
        instructionA,
        instructionB,
      ]);
      final plan = sequentialInstructionPlan([nestedParallel]);
      final result = findInstructionPlan(plan, (p) => p.kind == 'parallel');
      expect(result, same(nestedParallel));
    });

    test('returns the first matching plan in top-down order', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final innerSequential = sequentialInstructionPlan([instructionA]);
      final outerSequential = sequentialInstructionPlan([
        innerSequential,
        instructionB,
      ]);
      final result = findInstructionPlan(
        outerSequential,
        (p) => p.kind == 'sequential',
      );
      expect(result, same(outerSequential));
    });

    test('finds a deeply nested plan', () {
      final instructionA = createInstruction('A');
      final deepSingle = singleInstructionPlan(instructionA);
      final plan = parallelInstructionPlan([
        sequentialInstructionPlan([
          parallelInstructionPlan([deepSingle]),
        ]),
      ]);
      final result = findInstructionPlan(plan, (p) => p.kind == 'single');
      expect(result, same(deepSingle));
    });

    test('returns null when searching an empty parallel plan', () {
      final plan = parallelInstructionPlan([]);
      final result = findInstructionPlan(plan, (p) => p.kind == 'single');
      expect(result, isNull);
    });

    test('finds non-divisible sequential plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final nonDivisible = nonDivisibleSequentialInstructionPlan([
        instructionA,
        instructionB,
      ]);
      final plan = parallelInstructionPlan([
        sequentialInstructionPlan([createInstruction('C')]),
        nonDivisible,
      ]);
      final result = findInstructionPlan(
        plan,
        (p) => p is SequentialInstructionPlan && !p.divisible,
      );
      expect(result, same(nonDivisible));
    });

    test('returns null when searching a messagePacker that does not match', () {
      final messagePackerPlan = getMessagePackerInstructionPlanFromInstructions(
        [createInstruction('A')],
      );
      final result = findInstructionPlan(
        messagePackerPlan,
        (p) => p.kind == 'single',
      );
      expect(result, isNull);
    });

    test('finds a messagePacker plan when it matches the predicate', () {
      final messagePackerPlan = getMessagePackerInstructionPlanFromInstructions(
        [createInstruction('A')],
      );
      final plan = parallelInstructionPlan([
        singleInstructionPlan(createInstruction('B')),
        messagePackerPlan,
      ]);
      final result = findInstructionPlan(
        plan,
        (p) => p.kind == 'messagePacker',
      );
      expect(result, same(messagePackerPlan));
    });
  });

  group('everyInstructionPlan', () {
    test('returns true when all plans match the predicate', () {
      final plan = sequentialInstructionPlan([
        sequentialInstructionPlan([]),
        sequentialInstructionPlan([]),
      ]);
      final result = everyInstructionPlan(plan, (p) => p.kind == 'sequential');
      expect(result, isTrue);
    });

    test('returns false when at least one plan does not match', () {
      final plan = sequentialInstructionPlan([
        parallelInstructionPlan([]),
        sequentialInstructionPlan([]),
      ]);
      final result = everyInstructionPlan(plan, (p) => p.kind == 'sequential');
      expect(result, isFalse);
    });

    test('matches single instruction plans', () {
      final plan = singleInstructionPlan(createInstruction('A'));
      final result = everyInstructionPlan(plan, (p) => p.kind == 'single');
      expect(result, isTrue);
    });

    test('matches message packer instruction plans', () {
      final plan = getMessagePackerInstructionPlanFromInstructions([
        createInstruction('A'),
      ]);
      final result = everyInstructionPlan(
        plan,
        (p) => p.kind == 'messagePacker',
      );
      expect(result, isTrue);
    });

    test('fails fast before evaluating children', () {
      var callCount = 0;
      final plan = sequentialInstructionPlan([
        singleInstructionPlan(createInstruction('A')),
        singleInstructionPlan(createInstruction('B')),
      ]);
      final result = everyInstructionPlan(plan, (p) {
        callCount++;
        return false;
      });
      expect(result, isFalse);
      expect(callCount, 1);
    });

    test('fails fast before evaluating siblings', () {
      var callCount = 0;
      final plan = sequentialInstructionPlan([
        singleInstructionPlan(createInstruction('A')),
        singleInstructionPlan(createInstruction('B')),
      ]);
      final result = everyInstructionPlan(plan, (p) {
        callCount++;
        // First call (sequential) returns true, second call (first child)
        // returns false.
        return callCount <= 1;
      });
      expect(result, isFalse);
      // Called for: sequential, first child single (fails)
      expect(callCount, 2);
    });
  });

  group('transformInstructionPlan', () {
    test('transforms single instruction plans', () {
      final plan = singleInstructionPlan(createInstruction('A'));
      final newInstruction = createInstruction('NewA');
      final transformedPlan = transformInstructionPlan(plan, (p) {
        if (p is SingleInstructionPlan) {
          return singleInstructionPlan(newInstruction);
        }
        return p;
      });

      expect(transformedPlan, isA<SingleInstructionPlan>());
      expect(
        (transformedPlan as SingleInstructionPlan).instruction,
        same(newInstruction),
      );
    });

    test('transforms sequential instruction plans', () {
      final plan = sequentialInstructionPlan([
        createInstruction('A'),
        createInstruction('B'),
      ]);
      final transformedPlan = transformInstructionPlan(plan, (p) {
        if (p is SequentialInstructionPlan) {
          return SequentialInstructionPlan(
            plans: p.plans.reversed.toList(),
            divisible: p.divisible,
          );
        }
        return p;
      });

      expect(transformedPlan, isA<SequentialInstructionPlan>());
      final seqPlan = transformedPlan as SequentialInstructionPlan;
      expect(seqPlan.plans, hasLength(2));
    });

    test('transforms parallel instruction plans', () {
      final plan = parallelInstructionPlan([
        createInstruction('A'),
        createInstruction('B'),
      ]);
      final transformedPlan = transformInstructionPlan(plan, (p) {
        if (p is ParallelInstructionPlan) {
          return ParallelInstructionPlan(plans: p.plans.reversed.toList());
        }
        return p;
      });

      expect(transformedPlan, isA<ParallelInstructionPlan>());
    });

    test('transforms using a bottom-up approach', () {
      final plan = sequentialInstructionPlan([
        createInstruction('A'),
        sequentialInstructionPlan([
          createInstruction('B'),
          createInstruction('C'),
        ]),
      ]);

      final seenKinds = <String>[];
      transformInstructionPlan(plan, (p) {
        seenKinds.add(p.kind);
        return p;
      });

      // Bottom-up: inner single A, inner single B, inner single C,
      // inner sequential [B,C], outer sequential
      expect(seenKinds, contains('single'));
      expect(seenKinds, contains('sequential'));
    });

    test('can be used to duplicate instructions', () {
      final plan = sequentialInstructionPlan([
        createInstruction('A'),
        createInstruction('B'),
      ]);
      final transformedPlan = transformInstructionPlan(plan, (p) {
        if (p is SingleInstructionPlan) {
          return sequentialInstructionPlan([p.instruction, p.instruction]);
        }
        return p;
      });

      expect(transformedPlan, isA<SequentialInstructionPlan>());
      final seqPlan = transformedPlan as SequentialInstructionPlan;
      expect(seqPlan.plans, hasLength(2));
      expect(seqPlan.plans[0], isA<SequentialInstructionPlan>());
      expect(seqPlan.plans[1], isA<SequentialInstructionPlan>());
    });

    test('can be used to remove parallelism', () {
      final plan = parallelInstructionPlan([
        createInstruction('A'),
        createInstruction('B'),
      ]);
      final transformedPlan = transformInstructionPlan(plan, (p) {
        if (p is ParallelInstructionPlan) {
          return sequentialInstructionPlan(p.plans);
        }
        return p;
      });

      expect(transformedPlan, isA<SequentialInstructionPlan>());
    });
  });

  group('flattenInstructionPlan', () {
    test('returns the single plan when given a SingleInstructionPlan', () {
      final instructionA = createInstruction('A');
      final plan = singleInstructionPlan(instructionA);
      final result = flattenInstructionPlan(plan);
      expect(result, hasLength(1));
      expect(result[0], same(plan));
    });

    test(
      'returns the message packer plan when given a MessagePackerInstructionPlan',
      () {
        final plan = getMessagePackerInstructionPlanFromInstructions([
          createInstruction('A'),
        ]);
        final result = flattenInstructionPlan(plan);
        expect(result, hasLength(1));
        expect(result[0], same(plan));
      },
    );

    test('returns all leaf plans from a ParallelInstructionPlan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = parallelInstructionPlan([instructionA, instructionB]);
      final result = flattenInstructionPlan(plan);
      expect(result, hasLength(2));
      expect(result[0], isA<SingleInstructionPlan>());
      expect(result[1], isA<SingleInstructionPlan>());
    });

    test('returns all leaf plans from a SequentialInstructionPlan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = sequentialInstructionPlan([instructionA, instructionB]);
      final result = flattenInstructionPlan(plan);
      expect(result, hasLength(2));
    });

    test('returns all leaf plans from a complex nested structure', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final instructionC = createInstruction('C');
      final instructionD = createInstruction('D');
      final instructionE = createInstruction('E');
      final messagePackerPlan = getMessagePackerInstructionPlanFromInstructions(
        [createInstruction('F')],
      );
      final plan = parallelInstructionPlan([
        sequentialInstructionPlan([instructionA, instructionB]),
        nonDivisibleSequentialInstructionPlan([instructionC, instructionD]),
        instructionE,
        messagePackerPlan,
      ]);
      final result = flattenInstructionPlan(plan);
      expect(result, hasLength(6));
      expect(result[0], isA<SingleInstructionPlan>());
      expect(result[1], isA<SingleInstructionPlan>());
      expect(result[2], isA<SingleInstructionPlan>());
      expect(result[3], isA<SingleInstructionPlan>());
      expect(result[4], isA<SingleInstructionPlan>());
      expect(result[5], isA<MessagePackerInstructionPlan>());
    });
  });
}
