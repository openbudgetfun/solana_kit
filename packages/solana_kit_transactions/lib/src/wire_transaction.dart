import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import 'package:solana_kit_transactions/src/codecs/transaction_codec.dart';
import 'package:solana_kit_transactions/src/transaction.dart';

/// Given a signed transaction, this method returns the transaction as a
/// base64-encoded wire transaction string.
String getBase64EncodedWireTransaction(Transaction transaction) {
  final wireTransactionBytes = getTransactionEncoder().encode(transaction);
  return getBase64Decoder().decode(wireTransactionBytes);
}
