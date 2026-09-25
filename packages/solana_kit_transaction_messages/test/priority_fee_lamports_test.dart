import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  final fee = BigInt.from(10000);

  const feePayerAddress = Address('11111111111111111111111111111111');

  TransactionMessage v1Message({V1TransactionConfig? config}) {
    final message = createTransactionMessage(version: TransactionVersion.v1)
        .pipe((m) => setTransactionMessageFeePayer(feePayerAddress, m));

    if (config == null) return message;
    return setTransactionMessageConfig(config, message);
  }

  group('getTransactionMessagePriorityFeeLamports', () {
    test('returns the fee set in the v1 config', () {
      final message = setTransactionMessageConfig(
        V1TransactionConfig(
          priorityFeeLamports: fee,
          computeUnitLimit: 250000,
        ),
        v1Message(),
      );

      expect(getTransactionMessagePriorityFeeLamports(message), equals(fee));
    });

    test('returns null when no fee is set', () {
      expect(getTransactionMessagePriorityFeeLamports(v1Message()), isNull);
    });

    test('returns null for a v0 message even if a fee is somehow present', () {
      // A v0 message never carries a config, so there is nothing to read. The
      // version check keeps the answer unambiguous rather than relying on the
      // caller to pass the right version.
      final message = createTransactionMessage(version: TransactionVersion.v0);

      expect(getTransactionMessagePriorityFeeLamports(message), isNull);
    });

    test('returns null for a legacy message', () {
      final message = createTransactionMessage(
        version: TransactionVersion.legacy,
      );

      expect(getTransactionMessagePriorityFeeLamports(message), isNull);
    });
  });

  group('setTransactionMessagePriorityFeeLamports', () {
    test('sets the fee on a v1 message', () {
      final updated = setTransactionMessagePriorityFeeLamports(
        fee,
        v1Message(),
      );

      expect(getTransactionMessagePriorityFeeLamports(updated), equals(fee));
    });

    test('preserves other config fields', () {
      final message = setTransactionMessageConfig(
        const V1TransactionConfig(
          computeUnitLimit: 250000,
          loadedAccountsDataSizeLimit: 65536,
          heapSize: 131072,
        ),
        v1Message(),
      );

      final updated = setTransactionMessagePriorityFeeLamports(fee, message);

      expect(getTransactionMessagePriorityFeeLamports(updated), equals(fee));
      expect(getTransactionMessageComputeUnitLimit(updated), equals(250000));
      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(updated),
        equals(65536),
      );
      expect(getTransactionMessageHeapSize(updated), equals(131072));
    });

    test('replaces an existing fee', () {
      final message = setTransactionMessagePriorityFeeLamports(
        fee,
        v1Message(),
      );

      final updated = setTransactionMessagePriorityFeeLamports(
        BigInt.from(25000),
        message,
      );

      expect(
        getTransactionMessagePriorityFeeLamports(updated),
        equals(BigInt.from(25000)),
      );
    });

    test('returns the same instance when the fee already has that value', () {
      final message = setTransactionMessagePriorityFeeLamports(
        fee,
        v1Message(),
      );

      final updated = setTransactionMessagePriorityFeeLamports(fee, message);

      expect(identical(updated, message), isTrue);
    });

    test('removes the fee and preserves other config fields', () {
      final message = setTransactionMessageConfig(
        V1TransactionConfig(computeUnitLimit: 250000, priorityFeeLamports: fee),
        v1Message(),
      );

      final updated = setTransactionMessagePriorityFeeLamports(null, message);

      expect(getTransactionMessagePriorityFeeLamports(updated), isNull);
      expect(getTransactionMessageComputeUnitLimit(updated), equals(250000));
    });

    test('drops the config entirely when removing the only field', () {
      final message = setTransactionMessagePriorityFeeLamports(
        fee,
        v1Message(),
      );

      final updated = setTransactionMessagePriorityFeeLamports(null, message);

      // An empty config is still compiled into the message, so it is dropped
      // rather than left behind.
      expect(updated.config, isNull);
      expect(compileTransactionMessage(updated).configMask, equals(0));
    });

    test('is a no-op when removing a fee that was never set', () {
      final message = v1Message();

      final updated = setTransactionMessagePriorityFeeLamports(null, message);

      expect(identical(updated, message), isTrue);
    });

    test('leaves a v0 message untouched', () {
      final message = createTransactionMessage(
        version: TransactionVersion.v0,
      );

      final updated = setTransactionMessagePriorityFeeLamports(fee, message);

      // The fee is a v1 concept; a legacy or v0 message uses a per-unit price
      // instruction instead.
      expect(updated, same(message));
      expect(getTransactionMessagePriorityFeeLamports(updated), isNull);
    });

    test('leaves a legacy message untouched', () {
      final message = createTransactionMessage(
        version: TransactionVersion.legacy,
      );

      final updated = setTransactionMessagePriorityFeeLamports(fee, message);

      expect(updated, same(message));
    });

    test('the set fee survives a compile round-trip', () {
      var message = v1Message();
      message = setTransactionMessageConfig(
        const V1TransactionConfig(computeUnitLimit: 250000),
        message,
      );
      message = setTransactionMessagePriorityFeeLamports(fee, message);

      final compiled = compileTransactionMessage(message);
      // Bit 0x3 covers the priority fee and bit 0x4 the compute unit limit:
      // the two fields this message set.
      expect(compiled.configMask, equals(0x7));

      final decompiled = decompileTransactionMessage(
        getCompiledTransactionMessageDecoder().decode(
          getCompiledTransactionMessageEncoder().encode(compiled),
        ),
      );

      expect(
        getTransactionMessagePriorityFeeLamports(decompiled),
        equals(fee),
      );
    });
  });
}
