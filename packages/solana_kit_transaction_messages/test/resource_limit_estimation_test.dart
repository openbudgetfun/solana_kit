import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('ResourceLimitsEstimate', () {
    test(
      'stores the compute unit limit and optional loaded accounts limit',
      () {
        const estimate = ResourceLimitsEstimate(
          computeUnitLimit: 1000,
          loadedAccountsDataSizeLimit: 2048,
        );

        expect(estimate.computeUnitLimit, 1000);
        expect(estimate.loadedAccountsDataSizeLimit, 2048);
      },
    );

    test('allows a null loaded accounts data size limit', () {
      const estimate = ResourceLimitsEstimate(computeUnitLimit: 1000);

      expect(estimate.computeUnitLimit, 1000);
      expect(estimate.loadedAccountsDataSizeLimit, isNull);
    });
  });

  group('provisoryLoadedAccountsDataSizeLimit', () {
    test('equals zero', () {
      expect(provisoryLoadedAccountsDataSizeLimit, 0);
    });
  });

  group('getTransactionMessageLoadedAccountsDataSizeLimit', () {
    test('returns null for a v1 message with no config', () {
      final message = createTransactionMessage(version: TransactionVersion.v1);

      expect(getTransactionMessageLoadedAccountsDataSizeLimit(message), isNull);
    });

    test('returns null for a v1 message whose config omits the limit', () {
      final message = setTransactionMessageConfig(
        const V1TransactionConfig(computeUnitLimit: 1),
        createTransactionMessage(version: TransactionVersion.v1),
      );

      expect(getTransactionMessageLoadedAccountsDataSizeLimit(message), isNull);
    });

    test('returns the v1 config loaded accounts data size limit', () {
      final message = setTransactionMessageConfig(
        const V1TransactionConfig(loadedAccountsDataSizeLimit: 65536),
        createTransactionMessage(version: TransactionVersion.v1),
      );

      expect(getTransactionMessageLoadedAccountsDataSizeLimit(message), 65536);
    });

    test('returns null for a legacy message with no limit instruction', () {
      final message = createTransactionMessage(
        version: TransactionVersion.legacy,
      );

      expect(getTransactionMessageLoadedAccountsDataSizeLimit(message), isNull);
    });

    test('returns the limit parsed from a legacy message instruction', () {
      final message = setTransactionMessageLoadedAccountsDataSizeLimit(
        4096,
        createTransactionMessage(version: TransactionVersion.legacy),
      );

      expect(getTransactionMessageLoadedAccountsDataSizeLimit(message), 4096);
    });

    test('returns the first matching instruction in a legacy message', () {
      final message =
          createTransactionMessage(
            version: TransactionVersion.v0,
          ).appendInstructions([
            _loadedAccountsDataSizeLimitInstruction(1024),
            _loadedAccountsDataSizeLimitInstruction(2048),
          ]);

      expect(getTransactionMessageLoadedAccountsDataSizeLimit(message), 1024);
    });

    test('ignores non-compute-budget instructions', () {
      final message =
          createTransactionMessage(
            version: TransactionVersion.v0,
          ).appendInstructions([
            Instruction(
              programAddress: const Address(
                '11111111111111111111111111111111',
              ),
              data: _loadedAccountsDataSizeLimitInstruction(123).data,
            ),
          ]);

      expect(getTransactionMessageLoadedAccountsDataSizeLimit(message), isNull);
    });

    test('ignores compute-budget instructions with other discriminators', () {
      final message =
          createTransactionMessage(
            version: TransactionVersion.v0,
          ).appendInstructions([
            Instruction(
              programAddress: computeBudgetProgramAddress,
              data: Uint8List.fromList([3]),
            ),
          ]);

      expect(getTransactionMessageLoadedAccountsDataSizeLimit(message), isNull);
    });
  });

  group('setTransactionMessageLoadedAccountsDataSizeLimit', () {
    group('v1 messages', () {
      test('sets the limit in config when none exists', () {
        final message = createTransactionMessage(
          version: TransactionVersion.v1,
        );
        final updated = setTransactionMessageLoadedAccountsDataSizeLimit(
          65536,
          message,
        );

        expect(updated.config?.loadedAccountsDataSizeLimit, 65536);
        expect(
          getTransactionMessageLoadedAccountsDataSizeLimit(updated),
          65536,
        );
        expect(
          getTransactionMessageLoadedAccountsDataSizeLimit(message),
          isNull,
        );
      });

      test('merges the limit into an existing config', () {
        final message = setTransactionMessageConfig(
          const V1TransactionConfig(computeUnitLimit: 1, heapSize: 32),
          createTransactionMessage(version: TransactionVersion.v1),
        );
        final updated = setTransactionMessageLoadedAccountsDataSizeLimit(
          2048,
          message,
        );

        expect(updated.config?.loadedAccountsDataSizeLimit, 2048);
        expect(updated.config?.computeUnitLimit, 1);
        expect(updated.config?.heapSize, 32);
      });

      test('returns the same message when setting the existing limit', () {
        final message = setTransactionMessageLoadedAccountsDataSizeLimit(
          2048,
          createTransactionMessage(version: TransactionVersion.v1),
        );

        expect(
          setTransactionMessageLoadedAccountsDataSizeLimit(2048, message),
          same(message),
        );
      });

      test('removes the limit and preserves other config fields', () {
        final message = setTransactionMessageConfig(
          const V1TransactionConfig(
            computeUnitLimit: 1,
            loadedAccountsDataSizeLimit: 2048,
            heapSize: 32,
          ),
          createTransactionMessage(version: TransactionVersion.v1),
        );
        final updated = setTransactionMessageLoadedAccountsDataSizeLimit(
          null,
          message,
        );

        expect(updated.config?.loadedAccountsDataSizeLimit, isNull);
        expect(updated.config?.computeUnitLimit, 1);
        expect(updated.config?.heapSize, 32);
      });

      test('clears config when removing its only field', () {
        final message = setTransactionMessageLoadedAccountsDataSizeLimit(
          2048,
          createTransactionMessage(version: TransactionVersion.v1),
        );
        final updated = setTransactionMessageLoadedAccountsDataSizeLimit(
          null,
          message,
        );

        expect(updated.config, isNull);
      });

      test('returns the same message when removing a missing limit', () {
        final message = createTransactionMessage(
          version: TransactionVersion.v1,
        );

        expect(
          setTransactionMessageLoadedAccountsDataSizeLimit(null, message),
          same(message),
        );
      });
    });

    group('legacy and v0 messages', () {
      test('appends a limit instruction when none exists', () {
        final message = createTransactionMessage(
          version: TransactionVersion.legacy,
        );
        final updated = setTransactionMessageLoadedAccountsDataSizeLimit(
          4096,
          message,
        );

        expect(updated.instructions, hasLength(1));
        expect(
          getTransactionMessageLoadedAccountsDataSizeLimit(updated),
          4096,
        );
        expect(
          getTransactionMessageLoadedAccountsDataSizeLimit(message),
          isNull,
        );
      });

      test('returns the same message when setting the existing limit', () {
        final message = setTransactionMessageLoadedAccountsDataSizeLimit(
          4096,
          createTransactionMessage(version: TransactionVersion.legacy),
        );

        expect(
          setTransactionMessageLoadedAccountsDataSizeLimit(4096, message),
          same(message),
        );
      });

      test('replaces an existing limit instruction', () {
        final message =
            createTransactionMessage(
              version: TransactionVersion.v0,
            ).appendInstructions([
              _loadedAccountsDataSizeLimitInstruction(1),
              _loadedAccountsDataSizeLimitInstruction(2),
            ]);
        final updated = setTransactionMessageLoadedAccountsDataSizeLimit(
          3,
          message,
        );

        expect(updated.instructions, hasLength(2));
        expect(
          getTransactionMessageLoadedAccountsDataSizeLimit(updated),
          3,
        );
        expect(_readLoadedAccountsDataSizeLimit(updated.instructions[1]), 2);
      });

      test('removes the first existing limit instruction', () {
        final message =
            createTransactionMessage(
              version: TransactionVersion.v0,
            ).appendInstructions([
              _loadedAccountsDataSizeLimitInstruction(1),
              _loadedAccountsDataSizeLimitInstruction(2),
            ]);
        final updated = setTransactionMessageLoadedAccountsDataSizeLimit(
          null,
          message,
        );

        expect(updated.instructions, hasLength(1));
        expect(
          getTransactionMessageLoadedAccountsDataSizeLimit(updated),
          2,
        );
      });

      test('returns the same message when removing a missing limit', () {
        final message = createTransactionMessage(
          version: TransactionVersion.legacy,
        );

        expect(
          setTransactionMessageLoadedAccountsDataSizeLimit(null, message),
          same(message),
        );
      });
    });
  });

  group('fillTransactionMessageProvisoryResourceLimits', () {
    test('fills both provisory limits on a v1 message', () {
      final message = createTransactionMessage(
        version: TransactionVersion.v1,
      );
      final updated = fillTransactionMessageProvisoryResourceLimits(message);

      expect(
        getTransactionMessageComputeUnitLimit(updated),
        provisoryComputeUnitLimit,
      );
      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(updated),
        provisoryLoadedAccountsDataSizeLimit,
      );
    });

    test('preserves an existing non-provisory compute unit limit on v1', () {
      final message = setTransactionMessageComputeUnitLimit(
        400000,
        createTransactionMessage(version: TransactionVersion.v1),
      );
      final updated = fillTransactionMessageProvisoryResourceLimits(message);

      expect(getTransactionMessageComputeUnitLimit(updated), 400000);
    });

    test('preserves an existing loaded accounts data size limit on v1', () {
      final message = setTransactionMessageLoadedAccountsDataSizeLimit(
        65536,
        createTransactionMessage(version: TransactionVersion.v1),
      );
      final updated = fillTransactionMessageProvisoryResourceLimits(message);

      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(updated),
        65536,
      );
      expect(
        getTransactionMessageComputeUnitLimit(updated),
        provisoryComputeUnitLimit,
      );
    });

    test(
      'only fills the compute unit limit for legacy messages (no loaded '
      'accounts instruction)',
      () {
        final message = createTransactionMessage(
          version: TransactionVersion.legacy,
        );
        final updated = fillTransactionMessageProvisoryResourceLimits(message);

        expect(
          getTransactionMessageComputeUnitLimit(updated),
          provisoryComputeUnitLimit,
        );
        expect(
          getTransactionMessageLoadedAccountsDataSizeLimit(updated),
          isNull,
        );
      },
    );

    test('preserves an existing loaded accounts limit on legacy messages', () {
      final message = setTransactionMessageLoadedAccountsDataSizeLimit(
        4096,
        createTransactionMessage(version: TransactionVersion.legacy),
      );
      final updated = fillTransactionMessageProvisoryResourceLimits(message);

      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(updated),
        4096,
      );
      expect(
        getTransactionMessageComputeUnitLimit(updated),
        provisoryComputeUnitLimit,
      );
    });
  });

  group('estimateResourceLimitsFactory', () {
    test('returns the input function unchanged', () {
      Future<ResourceLimitsEstimate> estimate(TransactionMessage _) async {
        return const ResourceLimitsEstimate(computeUnitLimit: 1);
      }

      expect(estimateResourceLimitsFactory(estimate), same(estimate));
    });
  });

  group('estimateAndSetResourceLimitsFactory', () {
    test('preserves existing non-provisory non-max limits', () async {
      var called = false;
      final message =
          setTransactionMessageComputeUnitLimit(
            400000,
            createTransactionMessage(version: TransactionVersion.v0),
          ).pipe(
            (m) => setTransactionMessageLoadedAccountsDataSizeLimit(4096, m),
          );
      final estimateAndSet = estimateAndSetResourceLimitsFactory((_) async {
        called = true;
        return const ResourceLimitsEstimate(
          computeUnitLimit: 500000,
          loadedAccountsDataSizeLimit: 8192,
        );
      });

      expect(await estimateAndSet(message), same(message));
      expect(called, isFalse);
    });

    test('replaces both provisory limits with the estimate', () async {
      final message = fillTransactionMessageProvisoryResourceLimits(
        createTransactionMessage(version: TransactionVersion.v1),
      );
      final estimateAndSet = estimateAndSetResourceLimitsFactory((_) async {
        return const ResourceLimitsEstimate(
          computeUnitLimit: 500000,
          loadedAccountsDataSizeLimit: 8192,
        );
      });

      final updated = await estimateAndSet(message);

      expect(getTransactionMessageComputeUnitLimit(updated), 500000);
      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(updated),
        8192,
      );
    });

    test('replaces a null compute unit limit with the estimate', () async {
      final message = createTransactionMessage(version: TransactionVersion.v0);
      final estimateAndSet = estimateAndSetResourceLimitsFactory((_) async {
        return const ResourceLimitsEstimate(computeUnitLimit: 500000);
      });

      final updated = await estimateAndSet(message);

      expect(getTransactionMessageComputeUnitLimit(updated), 500000);
      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(updated),
        isNull,
      );
    });

    test('replaces a max compute unit limit with the estimate', () async {
      final message = setTransactionMessageComputeUnitLimit(
        maxComputeUnitLimit,
        createTransactionMessage(version: TransactionVersion.v0),
      );
      final estimateAndSet = estimateAndSetResourceLimitsFactory((_) async {
        return const ResourceLimitsEstimate(computeUnitLimit: 600000);
      });

      final updated = await estimateAndSet(message);

      expect(getTransactionMessageComputeUnitLimit(updated), 600000);
    });

    test(
      'does not set the loaded accounts limit when the estimate omits it',
      () {
        final message = fillTransactionMessageProvisoryResourceLimits(
          createTransactionMessage(version: TransactionVersion.v1),
        );
        final estimateAndSet = estimateAndSetResourceLimitsFactory((_) async {
          return const ResourceLimitsEstimate(computeUnitLimit: 500000);
        });

        final updated = estimateAndSet(message);

        expect(updated, completion(isNotNull));
        updated.then((m) {
          expect(getTransactionMessageComputeUnitLimit(m), 500000);
          expect(
            getTransactionMessageLoadedAccountsDataSizeLimit(m),
            provisoryLoadedAccountsDataSizeLimit,
          );
        });
      },
    );

    test(
      'preserves a non-provisory compute unit limit but replaces a provisory '
      'loaded accounts limit',
      () async {
        final message =
            setTransactionMessageComputeUnitLimit(
              400000,
              createTransactionMessage(version: TransactionVersion.v1),
            ).pipe(
              (m) => setTransactionMessageLoadedAccountsDataSizeLimit(
                provisoryLoadedAccountsDataSizeLimit,
                m,
              ),
            );
        final estimateAndSet = estimateAndSetResourceLimitsFactory((_) async {
          return const ResourceLimitsEstimate(
            computeUnitLimit: 999999,
            loadedAccountsDataSizeLimit: 8192,
          );
        });

        final updated = await estimateAndSet(message);

        expect(getTransactionMessageComputeUnitLimit(updated), 400000);
        expect(
          getTransactionMessageLoadedAccountsDataSizeLimit(updated),
          8192,
        );
      },
    );
  });
}

Instruction _loadedAccountsDataSizeLimitInstruction(int limit) {
  return setTransactionMessageLoadedAccountsDataSizeLimit(
    limit,
    createTransactionMessage(version: TransactionVersion.v0),
  ).instructions.single;
}

int _readLoadedAccountsDataSizeLimit(Instruction instruction) {
  return ByteData.sublistView(instruction.data!).getUint32(1, Endian.little);
}
