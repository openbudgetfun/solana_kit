import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/src/message_partial_signer.dart';
import 'package:solana_kit_signers/src/signable_message.dart';
import 'package:solana_kit_signers/src/transaction_partial_signer.dart';
import 'package:solana_kit_signers/src/types.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Defines a Noop (No-Operation) signer that pretends to partially sign
/// messages and transactions.
///
/// For a given [Address], a Noop Signer can be created to offer an
/// implementation of both the [MessagePartialSigner] and
/// [TransactionPartialSigner] interfaces such that they do not sign
/// anything. Namely, signing a transaction or a message with a
/// [NoopSigner] will return an empty signature dictionary.
class NoopSigner implements MessagePartialSigner, TransactionPartialSigner {
  /// Creates a [NoopSigner] with the given [address].
  const NoopSigner({required this.address});

  @override
  final Address address;

  @override
  Future<List<Map<Address, SignatureBytes>>> signMessages(
    List<SignableMessage> messages, [
    SignerConfig? config,
  ]) async {
    return messages
        .map((_) => Map<Address, SignatureBytes>.unmodifiable({}))
        .toList();
  }

  @override
  Future<List<Map<Address, SignatureBytes>>> signTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    return transactions
        .map((_) => Map<Address, SignatureBytes>.unmodifiable({}))
        .toList();
  }
}

/// Creates a [NoopSigner] from the provided [Address].
///
/// ```dart
/// final signer = createNoopSigner(address('1234..5678'));
/// ```
NoopSigner createNoopSigner(Address addr) {
  return NoopSigner(address: addr);
}
