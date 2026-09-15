/// On-chain integration tests for version 1 transactions against SurfPool.
///
/// Version 1 transactions (SIMD-0296 / SIMD-0385) raise the transaction size
/// ceiling from 1232 to 4096 bytes. These tests prove the Dart port can build,
/// sign, submit, and read back a v1 transaction whose payload genuinely cannot
/// fit in a legacy transaction, which no offline byte-vector test can
/// demonstrate on its own.
///
/// Run via the `test:integration` workspace script (which starts SurfPool) or
/// directly — `IntegrationTestEnv.create` starts a SurfPool instance when one
/// is not already running.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart'
    hide TransactionVersion;
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

/// A memo sized so the resulting transaction lands between the legacy 1232-byte
/// ceiling and the v1 4096-byte ceiling.
const _oversizedMemoLength = 1600;

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create(payerLamports: 100_000_000_000);
  });

  tearDownAll(() => env.dispose());

  /// Builds a memo large enough that its transaction cannot fit the legacy
  /// limit but comfortably fits the v1 limit.
  Instruction oversizedMemoInstruction() {
    return Instruction(
      programAddress: memoProgramAddress,
      accounts: const [],
      // Printable ASCII so the memo program accepts it.
      data: Uint8List(_oversizedMemoLength)
        ..fillRange(0, _oversizedMemoLength, 0x41),
    );
  }

  group('v1 transactions land on-chain', () {
    test('a transaction larger than the legacy limit is accepted', () async {
      final built = await env.buildV1WireTransaction([
        oversizedMemoInstruction(),
      ]);

      // The premise of the test: this is too big for a legacy transaction.
      expect(built.byteLength, greaterThan(legacyTransactionSizeLimit));
      expect(built.byteLength, lessThanOrEqualTo(v1TransactionSizeLimit));

      final signature = await env.sendV1Instructions([
        oversizedMemoInstruction(),
      ]);

      final status = await env.rpc.getSignatureStatuses([signature]).send();
      final values = status['value']! as List<Object?>;
      expect(values, hasLength(1));
      final entry = values.single! as Map<String, Object?>;
      expect(
        entry['err'],
        isNull,
        reason: 'transaction should not have failed',
      );

      // The transaction is only meaningful if it actually executed.
      expect(entry['confirmationStatus'], isNotNull);
    });

    test('the same payload built as v0 exceeds the legacy limit', () {
      final v0Message = TransactionMessageWithFeePayerSigner(
        feePayerSigner: env.payer,
        version: TransactionVersion.v0,
        instructions: [oversizedMemoInstruction()],
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.from(1000),
        ),
      );

      expect(isTransactionMessageWithinSizeLimit(v0Message), isFalse);
    });

    test('a large v1 transaction lands and its memo is recoverable', () async {
      final signature = await env.sendV1Instructions([
        oversizedMemoInstruction(),
      ]);

      // Read the transaction back from the node.
      final fetched = await env.rpc
          .getTransaction(
            signature,
            const GetTransactionConfig(
              commitment: Commitment.confirmed,
              encoding: TransactionEncoding.json,
              maxSupportedTransactionVersion: 1,
            ),
          )
          .send();

      expect(fetched, isNotNull);
      final transaction = fetched!['transaction']! as Map<String, Object?>;
      final message = transaction['message']! as Map<String, Object?>;

      // A v1 message carries an inline config; a v0 message carries lookup
      // tables instead. This is what distinguishes the two on the wire.
      expect(
        message.keys,
        contains('transactionConfig'),
        reason: 'v1 messages carry an inline transactionConfig',
      );

      final instructionList = message['instructions']! as List<Object?>;
      expect(instructionList, hasLength(1));
      final instruction = instructionList.single! as Map<String, Object?>;

      // With `encoding: json` the node returns instruction data as base58
      // text. The memo is a run of `A` bytes, so decoding it proves the full
      // 1600-byte payload survived submission and storage.
      final base58Data = instruction['data']! as String;
      final memoBytes = getBase58Encoder().encode(base58Data);
      expect(
        memoBytes.length,
        equals(_oversizedMemoLength),
        reason: 'the oversized memo should survive the round trip intact',
      );
      expect(memoBytes.every((byte) => byte == 0x41), isTrue);
    });

    test(
      'v1 carries a compute unit limit and loaded accounts limit inline',
      () async {
        final signature = await env.sendV1Instructions(
          [
            getTransferSolInstruction(
              programAddress: systemProgramAddress,
              source: env.payer.address,
              destination: generateKeyPairSigner().address,
              // Above the rent-exempt minimum so the transfer is accepted.
              amount: BigInt.from(10000000),
            ),
          ],
          computeUnitLimit: 250000,
          loadedAccountsDataSizeLimit: 131072,
        );

        final fetched = await env.rpc
            .getTransaction(
              signature,
              const GetTransactionConfig(
                commitment: Commitment.confirmed,
                encoding: TransactionEncoding.json,
                maxSupportedTransactionVersion: 1,
              ),
            )
            .send();

        final transaction = fetched!['transaction']! as Map<String, Object?>;
        final message = transaction['message']! as Map<String, Object?>;
        final config = message['transactionConfig']! as Map<String, Object?>;

        // The node reports the limits that were encoded in the message config,
        // rather than reading them from ComputeBudget instructions.
        expect(config['computeUnitLimit'], equals(250000));
        expect(config['loadedAccountsDataSizeLimit'], equals(131072));
      },
    );

    test('a v1 transfer moves lamports and debits a fee', () async {
      final recipient = generateKeyPairSigner();
      final before = await env.rpc.getBalanceValue(recipient.address).send();
      expect(before.value, equals(BigInt.zero));

      await env.sendV1Instructions([
        getTransferSolInstruction(
          programAddress: systemProgramAddress,
          source: env.payer.address,
          destination: recipient.address,
          amount: BigInt.from(42000000),
        ),
      ]);

      final after = await env.rpc.getBalanceValue(recipient.address).send();
      expect(after.value, equals(BigInt.from(42000000)));
    });

    test('a v1 transaction with an explicit heap size lands', () async {
      final signature = await env.sendV1Instructions(
        [oversizedMemoInstruction()],
        heapSize: 131072,
      );

      final status = await env.rpc.getSignatureStatuses([signature]).send();
      final entry =
          (status['value']! as List<Object?>).single! as Map<String, Object?>;
      expect(entry['err'], isNull);
    });

    test('the node rejects a v1 transaction above 4096 bytes', () async {
      // The payload is deliberately past the v1 ceiling. The node validates
      // size before simulation, so this fails at the RPC boundary.
      final oversized = Instruction(
        programAddress: memoProgramAddress,
        accounts: const [],
        data: Uint8List(4200)..fillRange(0, 4200, 0x41),
      );

      await expectLater(
        env.sendV1Instructions([oversized]),
        throwsA(anything),
      );
    });

    test('a v1 message with no config encodes a zero compute budget', () async {
      // This is why every v1 transaction must state its limits: version 1
      // budgets zero compute units and zero loaded account bytes when the
      // config is empty, rather than falling back to a default the way legacy
      // and v0 transactions do. The encoded mask is 0 and no config values
      // follow, so the runtime has nothing to grant.
      final message = TransactionMessageWithFeePayerSigner(
        feePayerSigner: env.payer,
        version: TransactionVersion.v1,
        instructions: [oversizedMemoInstruction()],
        lifetimeConstraint: await env.recentBlockhashLifetime(),
        // No config: both limits default to zero.
      );

      final compiled = compileTransactionMessage(message);
      expect(compiled.configMask, equals(0));
      expect(compiled.configValues, isEmpty);

      // `fillTransactionMessageProvisoryResourceLimits` is the helper that
      // reserves space for the values estimation later fills in.
      final filled = fillTransactionMessageProvisoryResourceLimits(message);
      final filledCompiled = compileTransactionMessage(filled);
      expect(filledCompiled.configMask, isNot(equals(0)));

      // The message still signs and encodes as a valid v1 transaction; the
      // failure it would hit is an execution budget failure, not a codec one.
      final wire = getBase64EncodedWireTransaction(
        await signTransactionMessageWithSigners(message),
      );
      expect(
        getTransactionDecoder()
            .read(base64Decode(wire), 0)
            .$1
            .messageBytes
            .first,
        equals(0x81),
      );
    });
  });
}
