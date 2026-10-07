import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart' as addresses;
import 'package:solana_kit_errors/solana_kit_errors.dart';
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
  ///
  /// Throws a [SolanaError] with code
  /// [SolanaErrorCode.signerWalletAccountCannotSignTransaction] when the
  /// account advertises neither transaction feature, mirroring upstream's
  /// `createSignerFromWalletAccount`. Building a signer that can never sign
  /// would only surface later, as a failure at the first call.
  WalletAccountSigner({
    required this.wallet,
    required this.account,
    required this.chain,
  }) : address = addresses.address(account.address) {
    final hasSignTransaction = account.features.contains(
      SolanaFeatureId.signTransaction,
    );
    final hasSignAndSendTransaction = account.features.contains(
      SolanaFeatureId.signAndSendTransaction,
    );
    if (!hasSignTransaction && !hasSignAndSendTransaction) {
      throw SolanaError(
        SolanaErrorCode.signerWalletAccountCannotSignTransaction,
        {
          'address': account.address,
          'supportedFeatures': List<String>.unmodifiable(account.features),
        },
      );
    }
  }

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
            address: _assertVerifiedSignature(
              outputs[index].signature,
              outputs[index].signedMessage,
            ),
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
    return [
      for (var index = 0; index < outputs.length; index++)
        _assertVerifiedSignedTransaction(
          transactions[index],
          decoder.decode(outputs[index].signedTransaction),
        ),
    ];
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
    return [
      for (var index = 0; index < outputs.length; index++)
        _assertVerifiedTransactionSignature(
          transactions[index],
          outputs[index].signature,
        ),
    ];
  }

  /// Verifies a wallet-returned [signature] over [signedBytes] against the
  /// account's public key before it can be treated as authentic.
  ///
  /// A compromised wallet can return any bytes it likes; without this check a
  /// well-formed but forged signature flows into [SignableMessage] and
  /// [Transaction] objects as if the account had actually signed.
  SignatureBytes _assertVerifiedSignature(
    Uint8List signature,
    Uint8List signedBytes,
  ) {
    final signatureBytes = SignatureBytes(Uint8List.fromList(signature));
    if (signature.length != 64 ||
        !verifySignature(account.publicKey, signatureBytes, signedBytes)) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet signature does not verify against the authorized account',
      );
    }
    return signatureBytes;
  }

  /// Verifies the account's signature inside a wallet-returned signed
  /// transaction.
  ///
  /// A [TransactionModifyingSigner] is allowed to modify the transaction it
  /// signs, but the returned signature must be a genuine signature by the
  /// authorized account over the returned message bytes.
  Transaction _assertVerifiedSignedTransaction(
    Transaction submitted,
    Transaction signed,
  ) {
    final signature = signed.signatures[address];
    if (signature == null) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet signed transaction does not include the authorized account',
      );
    }
    _assertVerifiedSignature(signature.value, signed.messageBytes);
    return signed;
  }

  /// Verifies that a wallet-reported submission signature is a genuine
  /// signature of the submitted transaction's message bytes.
  ///
  /// The wallet sends the transaction itself; the signature it reports is
  /// what callers use to track confirmation, so it must correspond to the
  /// transaction that was submitted — verified against the authorized
  /// account first and every declared signer public key second.
  SignatureBytes _assertVerifiedTransactionSignature(
    Transaction submitted,
    Uint8List reportedSignature,
  ) {
    if (reportedSignature.length != 64) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet reported a malformed transaction signature',
      );
    }
    final signatureBytes = SignatureBytes(
      Uint8List.fromList(reportedSignature),
    );
    final isValid =
        verifySignature(
          account.publicKey,
          signatureBytes,
          submitted.messageBytes,
        ) ||
        submitted.signatures.keys.any(
          (signerAddress) => verifySignature(
            addresses.getPublicKeyFromAddress(signerAddress),
            signatureBytes,
            submitted.messageBytes,
          ),
        );
    if (!isValid) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet reported a signature for a different transaction',
      );
    }
    return signatureBytes;
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
