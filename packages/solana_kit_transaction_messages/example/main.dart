// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  final legacy = createTransactionMessage(version: TransactionVersion.legacy);
  final v0 = createTransactionMessage(version: TransactionVersion.v0);

  print('Legacy version: ${legacy.version.name}');
  print('V0 version: ${v0.version.name}');
}
