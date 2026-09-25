import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart'
    hide v1TransactionSizeLimit;
import 'package:test/test.dart';

const _program = Address('11111111111111111111111111111111');
const _lookupTable = Address('11111111111111111111111111111111');
const _lookupAccount = Address(
  'B1o1kH1uJ6z1N1a1k1o1k1U1a1b1c1d1e1f1g1h1i1j1k1l1m',
);

void main() {
  group('resolvePriorityFee', () {
    test('uses the estimate when no caps are set', () {
      final result = resolvePriorityFee(
        const ResolvePriorityFeeInput(estimate: 1000, units: 200000),
      );
      expect(result.rate, 1000);
      expect(result.lamports, BigInt.from(200));
    });

    test('rounds up lamports so the fee never underpays the rate', () {
      final result = resolvePriorityFee(
        const ResolvePriorityFeeInput(estimate: 3, units: 1000),
      );
      // 3000 microLamports = 0.003 lamports, which rounds up to 1.
      expect(result.rate, 3);
      expect(result.lamports, BigInt.one);
      final whole = resolvePriorityFee(
        const ResolvePriorityFeeInput(estimate: 2000, units: 1000),
      );
      // Exactly 2 lamports.
      expect(whole.lamports, BigInt.from(2));
    });

    test('rateCap clamps the rate', () {
      final result = resolvePriorityFee(
        const ResolvePriorityFeeInput(
          estimate: 10000,
          units: 200000,
          rateCap: 500,
        ),
      );
      expect(result.rate, 500);
      expect(result.lamports, BigInt.from(100));
    });

    test('lamportsCap clamps the rate to keep the total within budget', () {
      // A 200-lamport budget over 200_000 units allows 1000 microLamports
      // per unit; the 10000 estimate is clamped down to it.
      final result = resolvePriorityFee(
        const ResolvePriorityFeeInput(
          estimate: 10000,
          units: 200000,
          lamportsCap: 200,
        ),
      );
      expect(result.rate, 1000);
      expect(result.lamports, BigInt.from(200));
    });

    test('BigInt lamportsCap is respected', () {
      final result = resolvePriorityFee(
        ResolvePriorityFeeInput(
          estimate: 10000,
          units: 200000,
          lamportsCap: BigInt.from(200),
        ),
      );
      expect(result.rate, 1000);
      expect(result.lamports, BigInt.from(200));
    });

    test('rejects a non-numeric lamportsCap', () {
      expect(
        () => resolvePriorityFee(
          const ResolvePriorityFeeInput(
            estimate: 10000,
            units: 200000,
            lamportsCap: 'not-a-number',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('floors fractional rates and clamps negative to zero', () {
      final result = resolvePriorityFee(
        const ResolvePriorityFeeInput(estimate: 1234.9, units: 1000),
      );
      expect(result.rate, 1234);
      final negative = resolvePriorityFee(
        const ResolvePriorityFeeInput(estimate: -10, units: 1000),
      );
      expect(negative.rate, 0);
      expect(negative.lamports, BigInt.zero);
    });
  });

  group('assertNoAddressLookupsOnV1', () {
    test('does not throw for version 0 or legacy messages with lookups', () {
      const ix = Instruction(
        programAddress: _program,
        accounts: [
          AccountLookupMeta(
            address: _lookupAccount,
            addressIndex: 0,
            lookupTableAddress: _lookupTable,
            role: AccountRole.readonly,
          ),
        ],
      );
      expect(
        () => assertNoAddressLookupsOnV1(0, [ix]),
        returnsNormally,
      );
    });

    test(
      'throws for version 1 messages with an account from a lookup table',
      () {
        const ix = Instruction(
          programAddress: _program,
          accounts: [
            AccountLookupMeta(
              address: _lookupAccount,
              addressIndex: 0,
              lookupTableAddress: _lookupTable,
              role: AccountRole.readonly,
            ),
          ],
        );
        expect(
          () => assertNoAddressLookupsOnV1(1, [ix]),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('SIMD-0385'),
            ),
          ),
        );
      },
    );

    test('treats structurally-similar map instructions like upstream', () {
      final lookup = <String, Object?>{
        'address': _lookupAccount.toString(),
        'lookupTableAddress': _lookupTable.toString(),
      };
      final ix = <String, Object?>{
        'programAddress': _program.toString(),
        'accounts': [lookup],
      };
      expect(() => assertNoAddressLookupsOnV1(1, [ix]), throwsStateError);
      // An account that explicitly carries `lookupTableAddress: null` is a
      // static account.
      final staticIx = <String, Object?>{
        'programAddress': _program.toString(),
        'accounts': [
          <String, Object?>{
            'address': _lookupAccount.toString(),
            'lookupTableAddress': null,
          },
        ],
      };
      expect(() => assertNoAddressLookupsOnV1(1, [staticIx]), returnsNormally);
    });
  });

  group('createTxMessage v1 guard', () {
    test('rejects version 1 messages with lookup accounts', () {
      const ix = Instruction(
        programAddress: _program,
        accounts: [
          AccountLookupMeta(
            address: _lookupAccount,
            addressIndex: 0,
            lookupTableAddress: _lookupTable,
            role: AccountRole.readonly,
          ),
        ],
      );
      expect(
        () => createTxMessage(
          CreateTxMessageInput(
            version: 1,
            feePayer: _program.toString(),
            instructions: [ix],
          ),
        ),
        throwsStateError,
      );
    });

    test('v1TransactionSizeLimit matches SIMD-0296', () {
      expect(v1TransactionSizeLimit, 4096);
    });
  });

  test('decodePreconfFrame parses the binary wire format', () {
    final message = const TransactionMessage(version: TransactionVersion.v0)
        .copyWith(
          feePayer: const Address(
            '22222222222222222222222222222222222222222222',
          ),
          lifetimeConstraint: BlockhashLifetimeConstraint(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
        );
    final encoded = getTransactionEncoder().encode(compileTransaction(message));

    // version(1) | slot:u64_le(8) | tx_index:u64_le(8) | status(1) | payload.
    final frame = Uint8List(preconfHeadLength + encoded.length)
      ..[0] = 1
      ..setAll(1, _u64le(42))
      ..setAll(9, _u64le(7))
      ..[17] =
          1 // success
      ..setAll(preconfHeadLength, encoded);

    final notification = decodePreconfFrame(frame);
    expect(notification.version, 1);
    expect(notification.slot, 42);
    expect(notification.transactionIndex, 7);
    expect(notification.status, PreconfStatus.success);
    expect(notification.transactionBytes, encoded);
  });

  test('decodePreconfFrame rejects short frames and unknown versions', () {
    expect(
      () => decodePreconfFrame(Uint8List(18)),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('too short'),
        ),
      ),
    );
    final badVersion = Uint8List(20)
      ..[0] = 99
      ..[18] = 0
      ..[19] = 0;
    expect(
      () => decodePreconfFrame(badVersion),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('unsupported preconf wire version'),
        ),
      ),
    );
  });
}

List<int> _u64le(int value) {
  final bytes = Uint8List(8);
  for (var i = 0; i < 8; i++) {
    bytes[i] = (value >> (8 * i)) & 0xff;
  }
  return bytes;
}
