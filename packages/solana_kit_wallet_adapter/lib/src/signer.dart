import 'package:solana_kit_addresses/solana_kit_addresses.dart' as addresses;
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// Adapts a Wallet Standard account to Solana Kit signer interfaces.
class WalletAccountSigner
    implements
        MessageModifyingSigner,
        TransactionModifyingSigner,
        TransactionSendingSigner {
  /// Creates a signer for [account] on [chain].
  WalletAccountSigner({
    required this.wallet,
    required this.account,
    required this.chain,
  }) : address = addresses.address(account.address);

  /// The owning Wallet Standard wallet.
  final Wallet wallet;

  /// The authorized Wallet Standard account.
  final WalletAccount account;

  /// The chain passed to transaction features.
  final String chain;

  @override
  final addresses.Address address;

  @override
  Future<List<SignableMessage>> modifyAndSignMessages(
    List<SignableMessage> messages, [
    SignerConfig? config,
  ]) async {
    final feature = wallet.feature<SolanaSignMessageFeature>(
      SolanaFeatureId.signMessage,
    );
    if (feature == null) throw _unsupported(SolanaFeatureId.signMessage);
    final outputs = await feature.signMessage(
      messages
          .map(
            (message) => SolanaSignMessageInput(
              account: account,
              message: message.content,
            ),
          )
          .toList(),
    );
    _assertOutputLength(messages.length, outputs.length);
    return [
      for (var index = 0; index < outputs.length; index++)
        SignableMessage(
          content: outputs[index].signedMessage,
          signatures: {
            ...messages[index].signatures,
            address: SignatureBytes(outputs[index].signature),
          },
        ),
    ];
  }

  @override
  Future<List<Transaction>> modifyAndSignTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    final feature = wallet.feature<SolanaSignTransactionFeature>(
      SolanaFeatureId.signTransaction,
    );
    if (feature == null) throw _unsupported(SolanaFeatureId.signTransaction);
    final encoder = getTransactionEncoder();
    final outputs = await feature.signTransaction(
      transactions
          .map(
            (transaction) => SolanaSignTransactionInput(
              account: account,
              transaction: encoder.encode(transaction),
              chain: chain,
              options: SolanaSignTransactionOptions(
                minContextSlot: config?.minContextSlot?.toInt(),
              ),
            ),
          )
          .toList(),
    );
    _assertOutputLength(transactions.length, outputs.length);
    final decoder = getTransactionDecoder();
    return outputs
        .map((output) => decoder.decode(output.signedTransaction))
        .toList();
  }

  @override
  Future<List<SignatureBytes>> signAndSendTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    final feature = wallet.feature<SolanaSignAndSendTransactionFeature>(
      SolanaFeatureId.signAndSendTransaction,
    );
    if (feature == null) {
      throw _unsupported(SolanaFeatureId.signAndSendTransaction);
    }
    final encoder = getTransactionEncoder();
    final outputs = await feature.signAndSendTransaction(
      transactions
          .map(
            (transaction) => SolanaSignAndSendTransactionInput(
              account: account,
              transaction: encoder.encode(transaction),
              chain: chain,
              options: SolanaSignAndSendTransactionOptions(
                minContextSlot: config?.minContextSlot?.toInt(),
              ),
            ),
          )
          .toList(),
    );
    _assertOutputLength(transactions.length, outputs.length);
    return outputs.map((output) => SignatureBytes(output.signature)).toList();
  }

  WalletStandardException _unsupported(String feature) {
    return WalletStandardException(
      WalletStandardErrorCode.unsupportedFeature,
      '${wallet.name} does not support $feature',
    );
  }
}

void _assertOutputLength(int inputs, int outputs) {
  if (inputs != outputs) {
    throw const WalletStandardException(
      WalletStandardErrorCode.invalidResponse,
      'Wallet output count does not match the input count',
    );
  }
}
