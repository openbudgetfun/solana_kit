/// The Wallet Standard version implemented by this package.
const walletStandardVersion = '1.0.0';

/// Standard feature identifiers.
abstract final class StandardFeatureId {
  /// Authorizes access to wallet accounts.
  static const connect = 'standard:connect';

  /// Cleans up an active connection.
  static const disconnect = 'standard:disconnect';

  /// Reports wallet property changes.
  static const events = 'standard:events';
}

/// Solana Wallet Standard chain identifiers.
abstract final class SolanaChainId {
  /// Solana mainnet-beta.
  static const mainnet = 'solana:mainnet';

  /// Solana devnet.
  static const devnet = 'solana:devnet';

  /// Solana testnet.
  static const testnet = 'solana:testnet';

  /// A local Solana validator.
  static const localnet = 'solana:localnet';

  /// Every canonical Solana Wallet Standard chain.
  static const List<String> values = [mainnet, devnet, testnet, localnet];
}

/// Solana feature identifiers.
abstract final class SolanaFeatureId {
  /// Signs and sends a batch of transactions as one operation.
  static const signAndSendAllTransactions = 'solana:signAndSendAllTransactions';

  /// Signs and sends transactions.
  static const signAndSendTransaction = 'solana:signAndSendTransaction';

  /// Signs in using a domain-bound message.
  static const signIn = 'solana:signIn';

  /// Signs arbitrary message bytes.
  static const signMessage = 'solana:signMessage';

  /// Signs a canonical Solana offchain message.
  static const signOffchainMessage = 'solana:signOffchainMessage';

  /// Signs serialized transactions.
  static const signTransaction = 'solana:signTransaction';
}

/// Whether [value] is a namespaced Wallet Standard identifier.
bool isWalletStandardIdentifier(String value) {
  final separator = value.indexOf(':');
  return separator > 0 && separator < value.length - 1;
}
