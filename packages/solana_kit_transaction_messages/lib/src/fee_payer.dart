import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Given a base58-encoded address of a system account, this method will return
/// a new transaction message with the fee payer set to the given address.
///
/// Returns the same instance if the fee payer is already set to the same
/// address.
///
/// ```dart
/// final myAddress = Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu');
/// final txPaidByMe = setTransactionMessageFeePayer(myAddress, tx);
/// ```
TransactionMessage setTransactionMessageFeePayer(
  Address feePayer,
  TransactionMessage transactionMessage,
) {
  if (transactionMessage.feePayer == feePayer) {
    return transactionMessage;
  }
  return transactionMessage.copyWith(feePayer: feePayer);
}
