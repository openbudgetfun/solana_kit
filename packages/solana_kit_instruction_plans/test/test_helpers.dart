import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Valid Solana base58-encoded addresses for testing.
/// These are all the System Program address which is all ones (32 zero bytes).
const _systemProgram = Address('11111111111111111111111111111111');

/// A valid fee payer address for testing.
const _feePayer = Address('E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ');

/// Creates a simple test instruction using the system program address.
///
/// The instruction has no accounts and optional data.
Instruction createInstruction([String? _]) =>
    const Instruction(programAddress: _systemProgram);

/// Creates a simple test instruction with data of a given byte size.
Instruction createInstructionWithData(int dataBytes) =>
    Instruction(programAddress: _systemProgram, data: Uint8List(dataBytes));

/// Creates a test [TransactionMessage] with a fee payer.
TransactionMessage createMessage([String? _]) => const TransactionMessage(
  version: TransactionVersion.v0,
  feePayer: _feePayer,
);

/// Creates a test [Transaction] with a dummy signature.
Transaction createTransaction() => Transaction(
  messageBytes: Uint8List(32),
  signatures: {_feePayer: SignatureBytes(Uint8List(64))},
);
