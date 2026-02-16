import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('singleTransactionPlan', () {
    test('creates SingleTransactionPlan objects', () {
      final message = createMessage();
      final plan = singleTransactionPlan(message);

      expect(plan, isA<SingleTransactionPlan>());
      expect(plan.kind, 'single');
      expect(plan.message, same(message));
    });
  });

  group('sequentialTransactionPlan', () {
    test('creates divisible SequentialTransactionPlan from plans', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = sequentialTransactionPlan([
        singleTransactionPlan(messageA),
        singleTransactionPlan(messageB),
      ]);

      expect(plan, isA<SequentialTransactionPlan>());
      expect(plan.kind, 'sequential');
      expect(plan.divisible, isTrue);
      expect(plan.plans, hasLength(2));
    });

    test(
      'accepts transaction messages directly and wraps them in single plans',
      () {
        final messageA = createMessage();
        final messageB = createMessage();
        final plan = sequentialTransactionPlan([messageA, messageB]);

        expect(plan.plans, hasLength(2));
        expect(plan.plans[0], isA<SingleTransactionPlan>());
        expect(plan.plans[1], isA<SingleTransactionPlan>());
      },
    );

    test('can nest other sequential plans', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final messageC = createMessage();
      final plan = sequentialTransactionPlan([
        messageA,
        sequentialTransactionPlan([messageB, messageC]),
      ]);

      expect(plan.plans, hasLength(2));
      expect(plan.plans[0], isA<SingleTransactionPlan>());
      expect(plan.plans[1], isA<SequentialTransactionPlan>());
    });

    test('creates unmodifiable plans list', () {
      final plan = sequentialTransactionPlan([
        createMessage(),
        createMessage(),
      ]);
      expect(
        () => (plan.plans as List).add(singleTransactionPlan(createMessage())),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('nonDivisibleSequentialTransactionPlan', () {
    test('creates non-divisible SequentialTransactionPlan', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = nonDivisibleSequentialTransactionPlan([
        singleTransactionPlan(messageA),
        singleTransactionPlan(messageB),
      ]);

      expect(plan, isA<SequentialTransactionPlan>());
      expect(plan.kind, 'sequential');
      expect(plan.divisible, isFalse);
      expect(plan.plans, hasLength(2));
    });

    test(
      'accepts transaction messages directly and wraps them in single plans',
      () {
        final messageA = createMessage();
        final messageB = createMessage();
        final plan = nonDivisibleSequentialTransactionPlan([
          messageA,
          messageB,
        ]);

        expect(plan.plans, hasLength(2));
        expect(plan.plans[0], isA<SingleTransactionPlan>());
        expect(plan.plans[1], isA<SingleTransactionPlan>());
      },
    );
  });

  group('parallelTransactionPlan', () {
    test('creates ParallelTransactionPlan from plans', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = parallelTransactionPlan([
        singleTransactionPlan(messageA),
        singleTransactionPlan(messageB),
      ]);

      expect(plan, isA<ParallelTransactionPlan>());
      expect(plan.kind, 'parallel');
      expect(plan.plans, hasLength(2));
    });

    test(
      'accepts transaction messages directly and wraps them in single plans',
      () {
        final messageA = createMessage();
        final messageB = createMessage();
        final plan = parallelTransactionPlan([messageA, messageB]);

        expect(plan.plans, hasLength(2));
        expect(plan.plans[0], isA<SingleTransactionPlan>());
        expect(plan.plans[1], isA<SingleTransactionPlan>());
      },
    );

    test('can nest other parallel plans', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final messageC = createMessage();
      final plan = parallelTransactionPlan([
        messageA,
        parallelTransactionPlan([messageB, messageC]),
      ]);

      expect(plan.plans, hasLength(2));
      expect(plan.plans[0], isA<SingleTransactionPlan>());
      expect(plan.plans[1], isA<ParallelTransactionPlan>());
    });
  });

  group('isSingleTransactionPlan', () {
    test('returns true for SingleTransactionPlan', () {
      expect(
        isSingleTransactionPlan(singleTransactionPlan(createMessage())),
        isTrue,
      );
    });

    test('returns false for other plans', () {
      expect(isSingleTransactionPlan(sequentialTransactionPlan([])), isFalse);
      expect(
        isSingleTransactionPlan(nonDivisibleSequentialTransactionPlan([])),
        isFalse,
      );
      expect(isSingleTransactionPlan(parallelTransactionPlan([])), isFalse);
    });
  });

  group('assertIsSingleTransactionPlan', () {
    test('does nothing for SingleTransactionPlan', () {
      expect(
        () => assertIsSingleTransactionPlan(
          singleTransactionPlan(createMessage()),
        ),
        returnsNormally,
      );
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsSingleTransactionPlan(sequentialTransactionPlan([])),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlan,
          ),
        ),
      );
    });
  });

  group('isSequentialTransactionPlan', () {
    test('returns true for SequentialTransactionPlan (divisible or not)', () {
      expect(
        isSequentialTransactionPlan(sequentialTransactionPlan([])),
        isTrue,
      );
      expect(
        isSequentialTransactionPlan(nonDivisibleSequentialTransactionPlan([])),
        isTrue,
      );
    });

    test('returns false for other plans', () {
      expect(
        isSequentialTransactionPlan(singleTransactionPlan(createMessage())),
        isFalse,
      );
      expect(isSequentialTransactionPlan(parallelTransactionPlan([])), isFalse);
    });
  });

  group('assertIsSequentialTransactionPlan', () {
    test('does nothing for SequentialTransactionPlan', () {
      expect(
        () => assertIsSequentialTransactionPlan(sequentialTransactionPlan([])),
        returnsNormally,
      );
      expect(
        () => assertIsSequentialTransactionPlan(
          nonDivisibleSequentialTransactionPlan([]),
        ),
        returnsNormally,
      );
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsSequentialTransactionPlan(
          singleTransactionPlan(createMessage()),
        ),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('isNonDivisibleSequentialTransactionPlan', () {
    test('returns true for non-divisible SequentialTransactionPlan', () {
      expect(
        isNonDivisibleSequentialTransactionPlan(
          nonDivisibleSequentialTransactionPlan([]),
        ),
        isTrue,
      );
    });

    test('returns false for other plans', () {
      expect(
        isNonDivisibleSequentialTransactionPlan(
          singleTransactionPlan(createMessage()),
        ),
        isFalse,
      );
      expect(
        isNonDivisibleSequentialTransactionPlan(sequentialTransactionPlan([])),
        isFalse,
      );
      expect(
        isNonDivisibleSequentialTransactionPlan(parallelTransactionPlan([])),
        isFalse,
      );
    });
  });

  group('assertIsNonDivisibleSequentialTransactionPlan', () {
    test('does nothing for non-divisible SequentialTransactionPlan', () {
      expect(
        () => assertIsNonDivisibleSequentialTransactionPlan(
          nonDivisibleSequentialTransactionPlan([]),
        ),
        returnsNormally,
      );
    });

    test('throws SolanaError for divisible sequential plan', () {
      expect(
        () => assertIsNonDivisibleSequentialTransactionPlan(
          sequentialTransactionPlan([]),
        ),
        throwsA(isA<SolanaError>()),
      );
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsNonDivisibleSequentialTransactionPlan(
          singleTransactionPlan(createMessage()),
        ),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('isParallelTransactionPlan', () {
    test('returns true for ParallelTransactionPlan', () {
      expect(isParallelTransactionPlan(parallelTransactionPlan([])), isTrue);
    });

    test('returns false for other plans', () {
      expect(
        isParallelTransactionPlan(singleTransactionPlan(createMessage())),
        isFalse,
      );
      expect(isParallelTransactionPlan(sequentialTransactionPlan([])), isFalse);
    });
  });

  group('assertIsParallelTransactionPlan', () {
    test('does nothing for ParallelTransactionPlan', () {
      expect(
        () => assertIsParallelTransactionPlan(parallelTransactionPlan([])),
        returnsNormally,
      );
    });

    test('throws SolanaError for other plans', () {
      expect(
        () => assertIsParallelTransactionPlan(
          singleTransactionPlan(createMessage()),
        ),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('flattenTransactionPlan', () {
    test('returns the single plan when given a SingleTransactionPlan', () {
      final message = createMessage();
      final plan = singleTransactionPlan(message);
      final result = flattenTransactionPlan(plan);
      expect(result, hasLength(1));
      expect(result[0], same(plan));
    });

    test('returns all single plans from a ParallelTransactionPlan', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = parallelTransactionPlan([messageA, messageB]);
      final result = flattenTransactionPlan(plan);
      expect(result, hasLength(2));
      expect(result[0], isA<SingleTransactionPlan>());
      expect(result[1], isA<SingleTransactionPlan>());
    });

    test('returns all single plans from a SequentialTransactionPlan', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = sequentialTransactionPlan([messageA, messageB]);
      final result = flattenTransactionPlan(plan);
      expect(result, hasLength(2));
    });

    test('returns all single plans from a complex nested structure', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final messageC = createMessage();
      final messageD = createMessage();
      final messageE = createMessage();
      final plan = parallelTransactionPlan([
        sequentialTransactionPlan([messageA, messageB]),
        nonDivisibleSequentialTransactionPlan([messageC, messageD]),
        messageE,
      ]);
      final result = flattenTransactionPlan(plan);
      expect(result, hasLength(5));
    });
  });

  group('findTransactionPlan', () {
    test('returns the plan itself when it matches the predicate', () {
      final message = createMessage();
      final plan = singleTransactionPlan(message);
      final result = findTransactionPlan(plan, (p) => p.kind == 'single');
      expect(result, same(plan));
    });

    test('returns null when no plan matches the predicate', () {
      final message = createMessage();
      final plan = singleTransactionPlan(message);
      final result = findTransactionPlan(plan, (p) => p.kind == 'parallel');
      expect(result, isNull);
    });

    test('finds a nested plan in a parallel structure', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final nestedSequential = sequentialTransactionPlan([messageA, messageB]);
      final plan = parallelTransactionPlan([nestedSequential]);
      final result = findTransactionPlan(plan, (p) => p.kind == 'sequential');
      expect(result, same(nestedSequential));
    });

    test('finds a deeply nested plan', () {
      final message = createMessage();
      final deepSingle = singleTransactionPlan(message);
      final plan = parallelTransactionPlan([
        sequentialTransactionPlan([
          parallelTransactionPlan([deepSingle]),
        ]),
      ]);
      final result = findTransactionPlan(plan, (p) => p.kind == 'single');
      expect(result, same(deepSingle));
    });
  });

  group('everyTransactionPlan', () {
    test('returns true when all plans match the predicate', () {
      final plan = sequentialTransactionPlan([
        sequentialTransactionPlan([]),
        sequentialTransactionPlan([]),
      ]);
      final result = everyTransactionPlan(plan, (p) => p.kind == 'sequential');
      expect(result, isTrue);
    });

    test('returns false when at least one plan does not match', () {
      final plan = sequentialTransactionPlan([
        parallelTransactionPlan([]),
        sequentialTransactionPlan([]),
      ]);
      final result = everyTransactionPlan(plan, (p) => p.kind == 'sequential');
      expect(result, isFalse);
    });
  });

  group('transformTransactionPlan', () {
    test('transforms single transaction plans', () {
      final plan = singleTransactionPlan(createMessage());
      final newMessage = createMessage();
      final transformedPlan = transformTransactionPlan(plan, (p) {
        if (p is SingleTransactionPlan) {
          return singleTransactionPlan(newMessage);
        }
        return p;
      });

      expect(transformedPlan, isA<SingleTransactionPlan>());
      expect(
        (transformedPlan as SingleTransactionPlan).message,
        same(newMessage),
      );
    });

    test('transforms sequential transaction plans', () {
      final plan = sequentialTransactionPlan([
        createMessage(),
        createMessage(),
      ]);
      final transformedPlan = transformTransactionPlan(plan, (p) {
        if (p is SequentialTransactionPlan) {
          return SequentialTransactionPlan(
            plans: p.plans.reversed.toList(),
            divisible: p.divisible,
          );
        }
        return p;
      });

      expect(transformedPlan, isA<SequentialTransactionPlan>());
    });

    test('can be used to remove parallelism', () {
      final plan = parallelTransactionPlan([createMessage(), createMessage()]);
      final transformedPlan = transformTransactionPlan(plan, (p) {
        if (p is ParallelTransactionPlan) {
          return sequentialTransactionPlan(p.plans);
        }
        return p;
      });

      expect(transformedPlan, isA<SequentialTransactionPlan>());
    });
  });

  group('isTransactionPlan', () {
    test('returns true for all transaction plan types', () {
      expect(isTransactionPlan(singleTransactionPlan(createMessage())), isTrue);
      expect(isTransactionPlan(sequentialTransactionPlan([])), isTrue);
      expect(
        isTransactionPlan(nonDivisibleSequentialTransactionPlan([])),
        isTrue,
      );
      expect(isTransactionPlan(parallelTransactionPlan([])), isTrue);
    });

    test('returns false for non-transaction-plan values', () {
      expect(isTransactionPlan(null), isFalse);
      expect(isTransactionPlan('string'), isFalse);
      expect(isTransactionPlan(123), isFalse);
      expect(isTransactionPlan(true), isFalse);
    });
  });
}
