import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:solana_kit_wallet_adapter/src/signer.dart';
import 'package:solana_kit_wallet_adapter/src/state.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// Coordinates wallet discovery, authorization, accounts, and signing.
class WalletController extends ChangeNotifier {
  /// Creates a controller over the supplied registry.
  WalletController(this._registry, {required this.chain});

  final WalletRegistry _registry;

  /// The default chain used for transaction operations.
  final String chain;

  WalletAdapterState _state = WalletAdapterState();
  StreamSubscription<WalletRegistryEvent>? _registrySubscription;
  void Function()? _walletUnsubscribe;
  bool _disposed = false;

  /// Current immutable state.
  WalletAdapterState get state => _state;

  /// Starts wallet discovery.
  Future<void> initialize() async {
    _ensureActive();
    if (_state.connectionStatus != WalletConnectionStatus.initial) return;
    _emit(
      _state.copyWith(connectionStatus: WalletConnectionStatus.discovering),
    );
    await _registry.initialize();
    _registrySubscription = _registry.events.listen(_handleRegistryEvent);
    _emit(
      _state.copyWith(
        connectionStatus: WalletConnectionStatus.disconnected,
        wallets: _registry.wallets,
      ),
    );
  }

  /// Authorizes [wallet] and selects its first returned account.
  Future<void> connect(Wallet wallet, {bool silent = false}) async {
    _ensureActive();
    final feature = wallet.feature<StandardConnectFeature>(
      StandardFeatureId.connect,
    );
    if (feature == null) {
      throw _unsupported(StandardFeatureId.connect, wallet);
    }
    _walletUnsubscribe?.call();
    _walletUnsubscribe = null;
    _emit(
      _state.copyWith(
        connectionStatus: WalletConnectionStatus.connecting,
        selectedWallet: wallet,
        selectedAccount: null,
        error: null,
      ),
    );
    try {
      final output = await feature.connect(
        StandardConnectInput(silent: silent),
      );
      if (output.accounts.isEmpty) {
        throw const WalletStandardException(
          WalletStandardErrorCode.invalidResponse,
          'Wallet connected without authorizing an account',
        );
      }
      final events = wallet.feature<StandardEventsFeature>(
        StandardFeatureId.events,
      );
      _walletUnsubscribe = events?.onChange(
        (change) => _handleWalletChange(wallet, change),
      );
      _emit(
        _state.copyWith(
          connectionStatus: WalletConnectionStatus.connected,
          selectedWallet: wallet,
          selectedAccount: output.accounts.first,
          error: null,
        ),
      );
    } on Object catch (error) {
      _emit(
        _state.copyWith(
          connectionStatus: WalletConnectionStatus.disconnected,
          selectedWallet: null,
          selectedAccount: null,
          error: error,
        ),
      );
      rethrow;
    }
  }

  /// Selects an already authorized [account].
  void selectAccount(WalletAccount account) {
    _ensureActive();
    final wallet = _state.selectedWallet;
    if (wallet == null || !wallet.accounts.contains(account)) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidRequest,
        'Account is not authorized by the selected wallet',
      );
    }
    _emit(_state.copyWith(selectedAccount: account, error: null));
  }

  /// Disconnects the current wallet and clears the selected account.
  Future<void> disconnect() async {
    _ensureActive();
    final wallet = _state.selectedWallet;
    if (wallet == null) return;
    _emit(
      _state.copyWith(connectionStatus: WalletConnectionStatus.disconnecting),
    );
    try {
      await wallet
          .feature<StandardDisconnectFeature>(StandardFeatureId.disconnect)
          ?.disconnect();
    } finally {
      _walletUnsubscribe?.call();
      _walletUnsubscribe = null;
      _emit(
        _state.copyWith(
          connectionStatus: WalletConnectionStatus.disconnected,
          operationStatus: WalletOperationStatus.idle,
          selectedWallet: null,
          selectedAccount: null,
          error: null,
        ),
      );
    }
  }

  /// Performs Sign In With Solana using the connected wallet.
  Future<SolanaSignInOutput> signIn(SolanaSignInInput input) {
    return _operate(
      WalletOperationStatus.signingIn,
      (wallet, account) async {
        final feature = wallet.feature<SolanaSignInFeature>(
          SolanaFeatureId.signIn,
        );
        if (feature == null) throw _unsupported(SolanaFeatureId.signIn, wallet);
        final outputs = await feature.signIn([input]);
        if (outputs.length != 1) {
          throw const WalletStandardException(
            WalletStandardErrorCode.invalidResponse,
            'Wallet returned an unexpected number of sign-in results',
          );
        }
        return outputs.single;
      },
    );
  }

  /// Creates a Solana Kit signer for the connected account.
  WalletAccountSigner createSigner() {
    _ensureActive();
    final wallet = _state.selectedWallet;
    final account = _state.selectedAccount;
    if (wallet == null || account == null) {
      throw const WalletStandardException(
        WalletStandardErrorCode.disconnected,
        'Connect a wallet before creating a signer',
      );
    }
    return WalletAccountSigner(wallet: wallet, account: account, chain: chain);
  }

  /// Clears the last displayed error without changing the connection.
  void clearError() {
    _ensureActive();
    _emit(_state.copyWith(error: null));
  }

  Future<T> _operate<T>(
    WalletOperationStatus operation,
    Future<T> Function(Wallet wallet, WalletAccount account) callback,
  ) async {
    _ensureActive();
    final wallet = _state.selectedWallet;
    final account = _state.selectedAccount;
    if (wallet == null || account == null) {
      throw const WalletStandardException(
        WalletStandardErrorCode.disconnected,
        'Connect a wallet before performing this operation',
      );
    }
    _emit(_state.copyWith(operationStatus: operation, error: null));
    try {
      return await callback(wallet, account);
    } on Object catch (error) {
      _emit(_state.copyWith(error: error));
      rethrow;
    } finally {
      if (!_disposed) {
        _emit(_state.copyWith(operationStatus: WalletOperationStatus.idle));
      }
    }
  }

  void _handleRegistryEvent(WalletRegistryEvent event) {
    final selectedRemoved =
        event is WalletUnregistered &&
        identical(event.wallet, _state.selectedWallet);
    _emit(
      _state.copyWith(
        wallets: _registry.wallets,
        connectionStatus: selectedRemoved
            ? WalletConnectionStatus.disconnected
            : null,
        selectedWallet: selectedRemoved ? null : _state.selectedWallet,
        selectedAccount: selectedRemoved ? null : _state.selectedAccount,
      ),
    );
  }

  void _handleWalletChange(Wallet wallet, StandardWalletChange change) {
    if (!identical(wallet, _state.selectedWallet)) return;
    final accounts = change.accounts ?? wallet.accounts;
    final selected = accounts.where(
      (account) => account.address == _state.selectedAccount?.address,
    );
    final nextAccount = selected.isNotEmpty
        ? selected.first
        : accounts.firstOrNull;
    _emit(
      _state.copyWith(
        connectionStatus: nextAccount == null
            ? WalletConnectionStatus.disconnected
            : WalletConnectionStatus.connected,
        selectedAccount: nextAccount,
      ),
    );
  }

  WalletStandardException _unsupported(String feature, Wallet wallet) {
    return WalletStandardException(
      WalletStandardErrorCode.unsupportedFeature,
      '${wallet.name} does not support $feature',
    );
  }

  void _emit(WalletAdapterState value) {
    _state = value;
    notifyListeners();
  }

  void _ensureActive() {
    if (_disposed) throw StateError('Wallet controller is disposed');
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _walletUnsubscribe?.call();
    unawaited(_registrySubscription?.cancel());
    unawaited(_registry.dispose());
    super.dispose();
  }
}
