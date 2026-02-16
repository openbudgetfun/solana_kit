import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('getMessagePackerInstructionPlanFromInstructions', () {
    test('creates a MessagePackerInstructionPlan', () {
      final plan = getMessagePackerInstructionPlanFromInstructions([
        createInstruction('A'),
        createInstruction('B'),
      ]);

      expect(plan, isA<MessagePackerInstructionPlan>());
      expect(plan.kind, 'messagePacker');
    });

    test('packs all instructions into a message', () {
      final plan = getMessagePackerInstructionPlanFromInstructions([
        createInstruction('A'),
        createInstruction('B'),
      ]);
      final message = createMessage();

      final messagePacker = plan.getMessagePacker();
      expect(messagePacker.done(), isFalse);

      final packedMessage = messagePacker.packMessageToCapacity(message);
      expect(packedMessage.instructions, hasLength(2));
      expect(messagePacker.done(), isTrue);
    });

    test('throws when packer is already complete', () {
      final plan = getMessagePackerInstructionPlanFromInstructions([
        createInstruction('A'),
      ]);
      final message = createMessage();

      final messagePacker = plan.getMessagePacker();
      messagePacker.packMessageToCapacity(message);
      expect(messagePacker.done(), isTrue);

      expect(
        () => messagePacker.packMessageToCapacity(message),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansMessagePackerAlreadyComplete,
          ),
        ),
      );
    });

    test('creates a new packer each time getMessagePacker is called', () {
      final plan = getMessagePackerInstructionPlanFromInstructions([
        createInstruction('A'),
      ]);
      final message = createMessage();

      final messagePacker1 = plan.getMessagePacker();
      messagePacker1.packMessageToCapacity(message);
      expect(messagePacker1.done(), isTrue);

      // A new packer should start fresh.
      final messagePacker2 = plan.getMessagePacker();
      expect(messagePacker2.done(), isFalse);
    });

    test('handles empty instruction list', () {
      final plan = getMessagePackerInstructionPlanFromInstructions([]);

      final messagePacker = plan.getMessagePacker();
      expect(messagePacker.done(), isTrue);
    });
  });

  group('getLinearMessagePackerInstructionPlan', () {
    test('creates a MessagePackerInstructionPlan', () {
      final plan = getLinearMessagePackerInstructionPlan(
        getInstruction: (offset, length) =>
            createInstruction('$offset-$length'),
        totalLength: 100,
      );

      expect(plan, isA<MessagePackerInstructionPlan>());
      expect(plan.kind, 'messagePacker');
    });

    test('starts with done() returning false', () {
      final plan = getLinearMessagePackerInstructionPlan(
        getInstruction: (offset, length) =>
            createInstruction('$offset-$length'),
        totalLength: 100,
      );

      final messagePacker = plan.getMessagePacker();
      expect(messagePacker.done(), isFalse);
    });

    test('throws when packer is already complete', () {
      final plan = getLinearMessagePackerInstructionPlan(
        getInstruction: (offset, length) =>
            createInstruction('$offset-$length'),
        totalLength: 1,
      );

      final messagePacker = plan.getMessagePacker();
      final message = createMessage();

      // Pack until done.
      while (!messagePacker.done()) {
        messagePacker.packMessageToCapacity(message);
      }

      expect(
        () => messagePacker.packMessageToCapacity(message),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansMessagePackerAlreadyComplete,
          ),
        ),
      );
    });

    test('creates a new packer each time getMessagePacker is called', () {
      final plan = getLinearMessagePackerInstructionPlan(
        getInstruction: (offset, length) =>
            createInstruction('$offset-$length'),
        totalLength: 100,
      );

      final messagePacker1 = plan.getMessagePacker();
      expect(messagePacker1.done(), isFalse);

      // A new packer should start fresh.
      final messagePacker2 = plan.getMessagePacker();
      expect(messagePacker2.done(), isFalse);
    });
  });

  group('getReallocMessagePackerInstructionPlan', () {
    test('creates a MessagePackerInstructionPlan', () {
      final plan = getReallocMessagePackerInstructionPlan(
        getInstruction: (size) => createInstruction('Size: $size'),
        totalSize: 15000,
      );

      expect(plan, isA<MessagePackerInstructionPlan>());
      expect(plan.kind, 'messagePacker');
    });

    test('packs instructions chunked by realloc limit (10240 bytes)', () {
      final sizes = <int>[];
      final plan = getReallocMessagePackerInstructionPlan(
        getInstruction: (size) {
          sizes.add(size);
          return createInstruction('Size: $size');
        },
        totalSize: 15000,
      );

      // The plan generates instructions during creation.
      // 15000 / 10240 = 1 full chunk + 4760 remainder
      expect(plan, isA<MessagePackerInstructionPlan>());
      expect(sizes, hasLength(2));
      expect(sizes[0], 10240);
      expect(sizes[1], 4760);
    });

    test('handles exact multiple of realloc limit', () {
      final sizes = <int>[];
      getReallocMessagePackerInstructionPlan(
        getInstruction: (size) {
          sizes.add(size);
          return createInstruction('Size: $size');
        },
        totalSize: 20480, // 2 * 10240
      );

      expect(sizes, hasLength(2));
      expect(sizes[0], 10240);
      expect(sizes[1], 10240);
    });

    test('handles size smaller than realloc limit', () {
      final sizes = <int>[];
      getReallocMessagePackerInstructionPlan(
        getInstruction: (size) {
          sizes.add(size);
          return createInstruction('Size: $size');
        },
        totalSize: 5000,
      );

      expect(sizes, hasLength(1));
      expect(sizes[0], 5000);
    });

    test('throws when packer is already complete', () {
      final plan = getReallocMessagePackerInstructionPlan(
        getInstruction: (size) => createInstruction('Size: $size'),
        totalSize: 5000,
      );

      final messagePacker = plan.getMessagePacker();
      final message = createMessage();

      // Pack until done.
      while (!messagePacker.done()) {
        messagePacker.packMessageToCapacity(message);
      }

      expect(
        () => messagePacker.packMessageToCapacity(message),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansMessagePackerAlreadyComplete,
          ),
        ),
      );
    });
  });

  group('MessagePacker', () {
    test('can be created with custom done and packMessageToCapacity', () {
      var isDone = false;
      final packer = MessagePacker(
        done: () => isDone,
        packMessageToCapacity: (message) {
          isDone = true;
          return message.copyWith(
            instructions: [
              ...message.instructions,
              createInstruction('custom'),
            ],
          );
        },
      );

      expect(packer.done(), isFalse);
      final result = packer.packMessageToCapacity(createMessage());
      expect(result.instructions, hasLength(1));
      expect(packer.done(), isTrue);
    });
  });
}
