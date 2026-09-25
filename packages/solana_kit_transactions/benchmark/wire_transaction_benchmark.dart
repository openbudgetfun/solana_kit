// Benchmark scripts intentionally print timing summaries.
// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

void main() {
  final transactionMessage = _buildTransactionMessage();
  final compiledTransaction = _buildCompiledTransaction();

  _runBenchmark(
    name: 'compileTransaction()',
    iterations: 10000,
    body: () {
      compileTransaction(transactionMessage);
    },
  );

  _runBenchmark(
    name: 'getBase64EncodedWireTransaction()',
    iterations: 10000,
    body: () {
      getBase64EncodedWireTransaction(compiledTransaction);
    },
  );
}

TransactionMessage _buildTransactionMessage() {
  return createTransactionMessage(version: TransactionVersion.legacy)
      .withFeePayer(_feePayer)
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: _blockhash,
          lastValidBlockHeight: BigInt.from(123456),
        ),
      )
      .appendInstruction(
        Instruction(
          programAddress: _programAddress,
          data: Uint8List.fromList(const [1, 2, 3, 4]),
        ),
      );
}

TransactionWithLifetime _buildCompiledTransaction() {
  final compiledTransaction = compileTransaction(_buildTransactionMessage());
  return TransactionWithLifetime(
    messageBytes: compiledTransaction.messageBytes,
    signatures: {_feePayer: _signatureBytes},
    lifetimeConstraint: compiledTransaction.lifetimeConstraint,
  );
}

const Address _feePayer = Address('11111111111111111111111111111111');
const Address _programAddress = Address(
  'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
);
const String _blockhash = '11111111111111111111111111111111';
final SignatureBytes _signatureBytes = signatureBytes(Uint8List(64));

void _runBenchmark({
  required String name,
  required int iterations,
  required void Function() body,
}) {
  final warmupIterations = iterations ~/ 10;
  for (var i = 0; i < warmupIterations; i++) {
    body();
  }

  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    body();
  }
  stopwatch.stop();

  final microsecondsPerIteration = stopwatch.elapsedMicroseconds / iterations;

  print(
    '$name: ${stopwatch.elapsedMilliseconds} ms total '
    '(${microsecondsPerIteration.toStringAsFixed(3)} µs/op over '
    '$iterations iterations)',
  );
}
