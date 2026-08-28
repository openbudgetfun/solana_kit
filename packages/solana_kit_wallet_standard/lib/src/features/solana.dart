import 'dart:typed_data';

import 'package:solana_kit_wallet_standard/src/wallet.dart';

/// Transaction versions understood by Solana wallets.
enum SolanaTransactionVersion {
  /// Legacy Solana transactions.
  legacy,

  /// Version-zero transactions.
  version0,
}

/// Commitment levels accepted by signing features.
enum SolanaTransactionCommitment {
  /// The node has processed the transaction.
  processed,

  /// A supermajority of the cluster has voted on the transaction's block.
  confirmed,

  /// The cluster has finalized the transaction's block.
  finalized,
}

/// Common transaction simulation options.
class SolanaSignTransactionOptions {
  /// Creates transaction signing options.
  const SolanaSignTransactionOptions({
    this.preflightCommitment,
    this.minContextSlot,
  });

  /// Commitment used for preflight simulation.
  final SolanaTransactionCommitment? preflightCommitment;

  /// Minimum slot at which the wallet may evaluate the transaction.
  final int? minContextSlot;
}

/// Input for `solana:signTransaction`.
class SolanaSignTransactionInput {
  /// Creates a transaction signing request.
  SolanaSignTransactionInput({
    required this.account,
    required Uint8List transaction,
    this.chain,
    this.options,
  }) : transaction = Uint8List.fromList(transaction);

  /// Account that should sign.
  final WalletAccount account;

  /// Serialized transaction bytes.
  final Uint8List transaction;

  /// Optional target chain.
  final String? chain;

  /// Optional simulation constraints.
  final SolanaSignTransactionOptions? options;
}

/// Output from `solana:signTransaction`.
class SolanaSignTransactionOutput {
  /// Creates a signed transaction result.
  SolanaSignTransactionOutput(Uint8List signedTransaction)
    : signedTransaction = Uint8List.fromList(signedTransaction);

  /// Signed serialized transaction bytes.
  final Uint8List signedTransaction;
}

/// `solana:signTransaction`.
abstract interface class SolanaSignTransactionFeature implements WalletFeature {
  /// Transaction versions supported by this feature.
  List<SolanaTransactionVersion> get supportedTransactionVersions;

  /// Signs every input transaction in order.
  Future<List<SolanaSignTransactionOutput>> signTransaction(
    List<SolanaSignTransactionInput> inputs,
  );
}

/// Options for `solana:signAndSendTransaction`.
class SolanaSignAndSendTransactionOptions extends SolanaSignTransactionOptions {
  /// Creates sign-and-send options.
  const SolanaSignAndSendTransactionOptions({
    super.preflightCommitment,
    super.minContextSlot,
    this.commitment,
    this.skipPreflight,
    this.maxRetries,
  });

  /// Desired confirmation commitment.
  final SolanaTransactionCommitment? commitment;

  /// Whether RPC preflight verification is disabled.
  final bool? skipPreflight;

  /// Maximum RPC retry count.
  final int? maxRetries;
}

/// Input for `solana:signAndSendTransaction`.
class SolanaSignAndSendTransactionInput extends SolanaSignTransactionInput {
  /// Creates a sign-and-send request.
  SolanaSignAndSendTransactionInput({
    required super.account,
    required super.transaction,
    required String chain,
    SolanaSignAndSendTransactionOptions? options,
  }) : super(chain: chain, options: options);

  @override
  SolanaSignAndSendTransactionOptions? get options =>
      super.options as SolanaSignAndSendTransactionOptions?;
}

/// Output from `solana:signAndSendTransaction`.
class SolanaSignAndSendTransactionOutput {
  /// Creates a submitted transaction result.
  SolanaSignAndSendTransactionOutput(Uint8List signature)
    : signature = Uint8List.fromList(signature);

  /// Raw transaction signature bytes.
  final Uint8List signature;
}

/// `solana:signAndSendTransaction`.
abstract interface class SolanaSignAndSendTransactionFeature
    implements WalletFeature {
  /// Transaction versions supported by this feature.
  List<SolanaTransactionVersion> get supportedTransactionVersions;

  /// Signs and sends every transaction in order.
  Future<List<SolanaSignAndSendTransactionOutput>> signAndSendTransaction(
    List<SolanaSignAndSendTransactionInput> inputs,
  );
}

/// Batch submission mode.
enum SolanaSignAndSendAllMode {
  /// Wallet prompts and submissions may proceed concurrently.
  parallel,

  /// Wallet prompts and submissions proceed in input order.
  serial,
}

/// One settled batch output.
sealed class SolanaSignAndSendAllResult {
  const SolanaSignAndSendAllResult();
}

/// A successfully submitted batch item.
class SolanaSignAndSendAllSuccess extends SolanaSignAndSendAllResult {
  /// Creates a successful settled item.
  const SolanaSignAndSendAllSuccess(this.output);

  /// The transaction signature.
  final SolanaSignAndSendTransactionOutput output;
}

/// A failed batch item.
class SolanaSignAndSendAllFailure extends SolanaSignAndSendAllResult {
  /// Creates a failed settled item.
  const SolanaSignAndSendAllFailure(this.error);

  /// The wallet failure.
  final Object error;
}

/// `solana:signAndSendAllTransactions`.
abstract interface class SolanaSignAndSendAllTransactionsFeature
    implements WalletFeature {
  /// Transaction versions supported by this feature.
  List<SolanaTransactionVersion> get supportedTransactionVersions;

  /// Signs and sends a batch, preserving one settled result per input.
  Future<List<SolanaSignAndSendAllResult>> signAndSendAllTransactions(
    List<SolanaSignAndSendTransactionInput> inputs, {
    SolanaSignAndSendAllMode mode = SolanaSignAndSendAllMode.parallel,
  });
}

/// Input for `solana:signMessage`.
class SolanaSignMessageInput {
  /// Creates a message signing request.
  SolanaSignMessageInput({
    required this.account,
    required Uint8List message,
  }) : message = Uint8List.fromList(message);

  /// Account that should sign.
  final WalletAccount account;

  /// Arbitrary message bytes.
  final Uint8List message;
}

/// Output from `solana:signMessage`.
class SolanaSignMessageOutput {
  /// Creates a signed message output.
  SolanaSignMessageOutput({
    required Uint8List signedMessage,
    required Uint8List signature,
    this.signatureType,
  }) : signedMessage = Uint8List.fromList(signedMessage),
       signature = Uint8List.fromList(signature);

  /// Exact bytes signed by the wallet.
  final Uint8List signedMessage;

  /// Signature over [signedMessage].
  final Uint8List signature;

  /// Optional signature algorithm, normally `ed25519`.
  final String? signatureType;
}

/// `solana:signMessage`.
abstract interface class SolanaSignMessageFeature implements WalletFeature {
  /// Signs every input message in order.
  Future<List<SolanaSignMessageOutput>> signMessage(
    List<SolanaSignMessageInput> inputs,
  );
}

/// Sign In With Solana fields.
class SolanaSignInInput {
  /// Creates a sign-in request.
  const SolanaSignInInput({
    this.domain,
    this.address,
    this.statement,
    this.uri,
    this.version,
    this.chainId,
    this.nonce,
    this.issuedAt,
    this.expirationTime,
    this.notBefore,
    this.requestId,
    this.resources,
  });

  /// Domain requesting authentication.
  final String? domain;

  /// Requested address.
  final String? address;

  /// Human-readable purpose.
  final String? statement;

  /// Requesting URI.
  final String? uri;

  /// Message version.
  final String? version;

  /// Chain identifier.
  final String? chainId;

  /// Replay-resistant nonce.
  final String? nonce;

  /// ISO-8601 issue time.
  final String? issuedAt;

  /// ISO-8601 expiry time.
  final String? expirationTime;

  /// ISO-8601 earliest validity time.
  final String? notBefore;

  /// Application request identifier.
  final String? requestId;

  /// Authorized resources.
  final List<String>? resources;
}

/// Output from `solana:signIn`.
class SolanaSignInOutput extends SolanaSignMessageOutput {
  /// Creates a sign-in result.
  SolanaSignInOutput({
    required this.account,
    required super.signedMessage,
    required super.signature,
    super.signatureType,
  });

  /// Account selected by the wallet.
  final WalletAccount account;
}

/// `solana:signIn`.
abstract interface class SolanaSignInFeature implements WalletFeature {
  /// Signs every input in order.
  Future<List<SolanaSignInOutput>> signIn(List<SolanaSignInInput> inputs);
}

/// Input for version-one Solana offchain messages.
class SolanaSignOffchainMessageInput {
  /// Creates an offchain signing request.
  SolanaSignOffchainMessageInput({
    required this.account,
    required this.message,
    required List<Uint8List> requiredSigners,
  }) : requiredSigners = List.unmodifiable(
         requiredSigners.map(Uint8List.fromList),
       );

  /// Account that should sign.
  final WalletAccount account;

  /// UTF-8 message body.
  final String message;

  /// Required 32-byte signer public keys.
  final List<Uint8List> requiredSigners;
}

/// Output from `solana:signOffchainMessage`.
class SolanaSignOffchainMessageOutput {
  /// Creates an offchain signing output.
  SolanaSignOffchainMessageOutput({
    required Uint8List signedOffchainMessage,
    required Uint8List signature,
    this.signatureType,
  }) : signedOffchainMessage = Uint8List.fromList(signedOffchainMessage),
       signature = Uint8List.fromList(signature);

  /// Canonical preamble and message bytes signed by the wallet.
  final Uint8List signedOffchainMessage;

  /// Signature over [signedOffchainMessage].
  final Uint8List signature;

  /// Optional signature algorithm.
  final String? signatureType;
}

/// `solana:signOffchainMessage`.
abstract interface class SolanaSignOffchainMessageFeature
    implements WalletFeature {
  /// Supported offchain message versions.
  List<int> get supportedMessageVersions;

  /// Signs canonical offchain messages.
  Future<List<SolanaSignOffchainMessageOutput>> signOffchainMessage(
    List<SolanaSignOffchainMessageInput> inputs,
  );
}
