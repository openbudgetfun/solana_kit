import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Creates a new empty [TransactionMessage] with the given [version].
///
/// ```dart
/// final message = createTransactionMessage(
///   version: TransactionVersion.v0,
/// );
/// ```
TransactionMessage createTransactionMessage({
  required TransactionVersion version,
}) => TransactionMessage(version: version);
