import 'package:solana_kit_wallet_standard/src/wallet.dart';

/// Input for `standard:connect`.
class StandardConnectInput {
  /// Creates a connect request.
  const StandardConnectInput({this.silent = false});

  /// Whether the wallet should avoid prompting the user.
  final bool silent;
}

/// Output from `standard:connect`.
class StandardConnectOutput {
  /// Creates a connect response.
  StandardConnectOutput(List<WalletAccount> accounts)
    : accounts = List.unmodifiable(accounts);

  /// Accounts authorized by the user.
  final List<WalletAccount> accounts;
}

/// `standard:connect` version 1.0.0.
abstract interface class StandardConnectFeature implements WalletFeature {
  /// Requests authorization to use wallet accounts.
  Future<StandardConnectOutput> connect([StandardConnectInput input]);
}

/// `standard:disconnect` version 1.0.0.
abstract interface class StandardDisconnectFeature implements WalletFeature {
  /// Cleans up the application's active connection.
  Future<void> disconnect();
}

/// Properties changed by a wallet event.
class StandardWalletChange {
  /// Creates a change notification containing only changed properties.
  StandardWalletChange({this.chains, this.features, this.accounts});

  /// New wallet chains, when changed.
  final List<String>? chains;

  /// New wallet features, when changed.
  final Map<String, WalletFeature>? features;

  /// New authorized accounts, when changed.
  final List<WalletAccount>? accounts;
}

/// `standard:events` version 1.0.0.
abstract interface class StandardEventsFeature implements WalletFeature {
  /// Subscribes to wallet property changes and returns an unsubscribe callback.
  void Function() onChange(void Function(StandardWalletChange change) listener);
}
