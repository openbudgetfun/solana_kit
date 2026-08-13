import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

const systemProgram = '11111111111111111111111111111111';
const feePayer = 'E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ';
const tokenProgram = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';
const blockhash = '11111111111111111111111111111111';

MessageHeader header(
  int numSigner,
  int numReadonlySigner,
  int numReadonlyNonSigner,
) => MessageHeader(
  numSignerAccounts: numSigner,
  numReadonlySignerAccounts: numReadonlySigner,
  numReadonlyNonSignerAccounts: numReadonlyNonSigner,
);

CompiledTransactionMessage legacyMessage({
  List<Address> staticAccounts = const [],
  List<CompiledInstruction> instructions = const [],
  String lifetimeToken = blockhash,
}) => CompiledTransactionMessage(
  version: TransactionVersion.legacy,
  header: header(1, 0, 0),
  staticAccounts: staticAccounts,
  instructions: instructions,
  lifetimeToken: lifetimeToken,
);

/// Encodes [message] to wire bytes and wraps it in a signed transaction with a
/// single 64-byte zero signature for the first static account.
Uint8List encodeWire(CompiledTransactionMessage message) {
  final messageBytes = getCompiledTransactionMessageEncoder().encode(message);
  final tx = Transaction(
    messageBytes: messageBytes,
    signatures: {
      if (message.staticAccounts.isNotEmpty)
        message.staticAccounts.first: SignatureBytes(Uint8List(64)),
    },
  );
  return getTransactionEncoder().encode(tx);
}

String base58String(Uint8List bytes) => getBase58Decoder().decode(bytes);
String base64String(Uint8List bytes) => getBase64Decoder().decode(bytes);

Uint8List base58Bytes(String s) => getBase58Encoder().encode(s);
