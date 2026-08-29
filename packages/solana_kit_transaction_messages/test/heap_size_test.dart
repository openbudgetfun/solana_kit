import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

const heapSizeA = 32768; // 32 KiB
const heapSizeB = 65536; // 64 KiB

void main() {
  group('setTransactionMessageHeapSize', () {
    group('given a v1 transaction', () {
      test('sets the heap size on the transaction', () {
        final message = setTransactionMessageHeapSize(
          heapSizeA,
          createTransactionMessage(version: TransactionVersion.v1),
        );

        expect(message.config?.heapSize, heapSizeA);
      });

      test('sets the heap size while preserving other config properties', () {
        final message = setTransactionMessageConfig(
          V1TransactionConfig(
            computeUnitLimit: 200000,
            priorityFeeLamports: BigInt.from(5000),
          ),
          createTransactionMessage(version: TransactionVersion.v1),
        );
        final updated = setTransactionMessageHeapSize(heapSizeA, message);

        expect(updated.config?.computeUnitLimit, 200000);
        expect(updated.config?.heapSize, heapSizeA);
        expect(updated.config?.priorityFeeLamports, BigInt.from(5000));
      });

      test('returns the same message when setting the same heap size', () {
        final message = setTransactionMessageHeapSize(
          heapSizeA,
          createTransactionMessage(version: TransactionVersion.v1),
        );

        expect(
          setTransactionMessageHeapSize(heapSizeA, message),
          same(message),
        );
      });

      test('returns a new message when setting a different heap size', () {
        final message = setTransactionMessageHeapSize(
          heapSizeA,
          createTransactionMessage(version: TransactionVersion.v1),
        );
        final updated = setTransactionMessageHeapSize(heapSizeB, message);

        expect(updated, isNot(same(message)));
        expect(updated.config?.heapSize, heapSizeB);
      });

      test('removes the config when clearing its only property', () {
        final message = setTransactionMessageHeapSize(
          heapSizeA,
          createTransactionMessage(version: TransactionVersion.v1),
        );
        final updated = setTransactionMessageHeapSize(null, message);

        expect(updated.config, isNull);
      });

      test('preserves the config when other properties remain', () {
        final message = setTransactionMessageConfig(
          const V1TransactionConfig(computeUnitLimit: 200000),
          createTransactionMessage(version: TransactionVersion.v1),
        );
        final withHeapSize = setTransactionMessageHeapSize(heapSizeA, message);
        final updated = setTransactionMessageHeapSize(null, withHeapSize);

        expect(updated.config?.computeUnitLimit, 200000);
        expect(updated.config?.heapSize, isNull);
      });
    });

    for (final version in [TransactionVersion.legacy, TransactionVersion.v0]) {
      group('given a ${version.name} transaction', () {
        test('appends a RequestHeapFrame instruction', () {
          final message = setTransactionMessageHeapSize(
            heapSizeA,
            createTransactionMessage(version: version),
          );

          expect(message.instructions, hasLength(1));
          expect(
            message.instructions[0].programAddress,
            computeBudgetProgramAddress,
          );
          expect(_readHeapSize(message.instructions[0]), heapSizeA);
        });

        test('appends the instruction after existing instructions', () {
          const existingInstruction = Instruction(
            programAddress: Address('11111111111111111111111111111111'),
          );
          final message = createTransactionMessage(
            version: version,
          ).appendInstructions([existingInstruction]);
          final updated = setTransactionMessageHeapSize(heapSizeA, message);

          expect(updated.instructions, hasLength(2));
          expect(updated.instructions[0], same(existingInstruction));
          expect(
            updated.instructions[1].programAddress,
            computeBudgetProgramAddress,
          );
        });

        test('replaces the existing instruction when setting a new value', () {
          const otherInstruction = Instruction(
            programAddress: Address('11111111111111111111111111111111'),
          );
          final message = createTransactionMessage(version: version)
              .appendInstructions([
                otherInstruction,
                _heapFrameInstruction(heapSizeA),
              ]);
          final updated = setTransactionMessageHeapSize(heapSizeB, message);

          expect(updated.instructions, hasLength(2));
          expect(updated.instructions[0], same(otherInstruction));
          expect(_readHeapSize(updated.instructions[1]), heapSizeB);
        });

        test('returns the same message when setting the same value', () {
          final message = createTransactionMessage(
            version: version,
          ).appendInstructions([_heapFrameInstruction(heapSizeA)]);

          expect(
            setTransactionMessageHeapSize(heapSizeA, message),
            same(message),
          );
        });

        test('returns the same message when no instruction exists', () {
          final message = createTransactionMessage(version: version);

          expect(setTransactionMessageHeapSize(null, message), same(message));
        });

        test('removes the instruction when one exists', () {
          final message = setTransactionMessageHeapSize(
            heapSizeA,
            createTransactionMessage(version: version),
          );
          final updated = setTransactionMessageHeapSize(null, message);

          expect(updated.instructions, isEmpty);
        });

        test('preserves other instructions when removing', () {
          const otherInstruction = Instruction(
            programAddress: Address('11111111111111111111111111111111'),
          );
          final message = createTransactionMessage(version: version)
              .appendInstructions([
                _heapFrameInstruction(heapSizeA),
                otherInstruction,
              ]);
          final updated = setTransactionMessageHeapSize(null, message);

          expect(updated.instructions, hasLength(1));
          expect(updated.instructions[0], same(otherInstruction));
        });
      });

      group('getTransactionMessageHeapSize (${version.name})', () {
        test('returns null without instruction', () {
          final message = createTransactionMessage(version: version);

          expect(getTransactionMessageHeapSize(message), isNull);
        });

        test('returns the value from the instruction', () {
          final message = createTransactionMessage(
            version: version,
          ).appendInstructions([_heapFrameInstruction(heapSizeA)]);

          expect(getTransactionMessageHeapSize(message), heapSizeA);
        });
      });
    }

    group('getTransactionMessageHeapSize (v1)', () {
      test('returns null without config', () {
        final message = createTransactionMessage(
          version: TransactionVersion.v1,
        );

        expect(getTransactionMessageHeapSize(message), isNull);
      });

      test('returns the value from config', () {
        final message = setTransactionMessageConfig(
          const V1TransactionConfig(heapSize: heapSizeA),
          createTransactionMessage(version: TransactionVersion.v1),
        );

        expect(getTransactionMessageHeapSize(message), heapSizeA);
      });
    });
  });

  group('setTransactionMessageHeapSize validation', () {
    const minHeapSize = 32 * 1024;
    const maxHeapSize = 256 * 1024;

    for (final version in [
      TransactionVersion.legacy,
      TransactionVersion.v0,
      TransactionVersion.v1,
    ]) {
      group('given a ${version.name} transaction', () {
        Matcher invalidHeapSizeError(int heapSize) => isA<SolanaError>()
            .having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionInvalidHeapSize,
            )
            .having((e) => e.context['heapSize'], 'heapSize', heapSize)
            .having((e) => e.context['minHeapSize'], 'minHeapSize', minHeapSize)
            .having((e) => e.context['maxHeapSize'], 'maxHeapSize', maxHeapSize)
            .having((e) => e.context['multipleOf'], 'multipleOf', 1024);

        test('throws when the heap size is below the minimum', () {
          const belowMin = minHeapSize - 1024;
          expect(
            () => setTransactionMessageHeapSize(
              belowMin,
              createTransactionMessage(version: version),
            ),
            throwsA(invalidHeapSizeError(belowMin)),
          );
        });

        test('throws when the heap size is above the maximum', () {
          const aboveMax = maxHeapSize + 1024;
          expect(
            () => setTransactionMessageHeapSize(
              aboveMax,
              createTransactionMessage(version: version),
            ),
            throwsA(invalidHeapSizeError(aboveMax)),
          );
        });

        test('throws when the heap size is not a multiple of 1 KiB', () {
          const notMultiple = minHeapSize + 1;
          expect(
            () => setTransactionMessageHeapSize(
              notMultiple,
              createTransactionMessage(version: version),
            ),
            throwsA(invalidHeapSizeError(notMultiple)),
          );
        });

        test('accepts the minimum heap size', () {
          expect(
            () => setTransactionMessageHeapSize(
              minHeapSize,
              createTransactionMessage(version: version),
            ),
            returnsNormally,
          );
        });

        test('accepts the maximum heap size', () {
          expect(
            () => setTransactionMessageHeapSize(
              maxHeapSize,
              createTransactionMessage(version: version),
            ),
            returnsNormally,
          );
        });

        test('does not throw when clearing the heap size', () {
          expect(
            () => setTransactionMessageHeapSize(
              null,
              createTransactionMessage(version: version),
            ),
            returnsNormally,
          );
        });
      });
    }
  });
}

Instruction _heapFrameInstruction(int bytes) {
  final data = Uint8List(5)..first = 1;
  ByteData.sublistView(data).setUint32(1, bytes, Endian.little);
  return Instruction(
    programAddress: computeBudgetProgramAddress,
    accounts: const [],
    data: data,
  );
}

int _readHeapSize(Instruction instruction) {
  return ByteData.sublistView(instruction.data!).getUint32(1, Endian.little);
}
