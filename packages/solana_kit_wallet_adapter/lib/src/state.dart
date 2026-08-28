import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// Wallet connection lifecycle.
enum WalletConnectionStatus {
  /// The controller has not initialized discovery.
  initial,

  /// Platform wallets are being discovered.
  discovering,

  /// No wallet is connected.
  disconnected,

  /// A wallet is awaiting authorization.
  connecting,

  /// An account is ready for wallet operations.
  connected,

  /// The active wallet is disconnecting.
  disconnecting,
}

/// User-visible wallet operation lifecycle.
enum WalletOperationStatus {
  /// No wallet prompt is outstanding.
  idle,

  /// The wallet is signing a message.
  signingMessage,

  /// The wallet is signing one or more transactions.
  signingTransaction,

  /// The wallet is signing and submitting transactions.
  sendingTransaction,

  /// The wallet is completing Sign In With Solana.
  signingIn,
}

/// Immutable state exposed by `WalletController`.
class WalletAdapterState {
  /// Creates a wallet state snapshot.
  WalletAdapterState({
    this.connectionStatus = WalletConnectionStatus.initial,
    this.operationStatus = WalletOperationStatus.idle,
    List<Wallet> wallets = const [],
    this.selectedWallet,
    this.selectedAccount,
    this.error,
  }) : wallets = List.unmodifiable(wallets);

  /// The current connection lifecycle.
  final WalletConnectionStatus connectionStatus;

  /// The current signing lifecycle.
  final WalletOperationStatus operationStatus;

  /// Discovered wallets.
  final List<Wallet> wallets;

  /// The selected or connected wallet.
  final Wallet? selectedWallet;

  /// The selected authorized account.
  final WalletAccount? selectedAccount;

  /// The most recent operation failure.
  final Object? error;

  /// Whether an account is connected.
  bool get isConnected =>
      connectionStatus == WalletConnectionStatus.connected &&
      selectedWallet != null &&
      selectedAccount != null;

  /// Creates a snapshot with selected fields replaced.
  WalletAdapterState copyWith({
    WalletConnectionStatus? connectionStatus,
    WalletOperationStatus? operationStatus,
    List<Wallet>? wallets,
    Object? selectedWallet = _unchanged,
    Object? selectedAccount = _unchanged,
    Object? error = _unchanged,
  }) {
    return WalletAdapterState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      operationStatus: operationStatus ?? this.operationStatus,
      wallets: wallets ?? this.wallets,
      selectedWallet: identical(selectedWallet, _unchanged)
          ? this.selectedWallet
          : selectedWallet as Wallet?,
      selectedAccount: identical(selectedAccount, _unchanged)
          ? this.selectedAccount
          : selectedAccount as WalletAccount?,
      error: identical(error, _unchanged) ? this.error : error,
    );
  }
}

const _unchanged = Object();
