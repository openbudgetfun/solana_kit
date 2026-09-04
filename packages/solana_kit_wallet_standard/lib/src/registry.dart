import 'dart:async';

import 'package:solana_kit_wallet_standard/src/wallet.dart';

/// A wallet registry mutation.
sealed class WalletRegistryEvent {
  const WalletRegistryEvent(this.wallet);

  /// The affected wallet.
  final Wallet wallet;
}

/// A wallet became available.
class WalletRegistered extends WalletRegistryEvent {
  /// Creates a registration event.
  const WalletRegistered(super.wallet);
}

/// A wallet became unavailable.
class WalletUnregistered extends WalletRegistryEvent {
  /// Creates an unregistration event.
  const WalletUnregistered(super.wallet);
}

/// A registered wallet changed accounts, chains, or features.
class WalletChanged extends WalletRegistryEvent {
  /// Creates a change event.
  const WalletChanged(super.wallet);
}

/// Discovers and observes Wallet Standard wallets.
abstract interface class WalletRegistry {
  /// The current wallet snapshot.
  List<Wallet> get wallets;

  /// Registry mutations after initialization.
  Stream<WalletRegistryEvent> get events;

  /// Starts discovery.
  Future<void> initialize();

  /// Releases discovery listeners and resources.
  Future<void> dispose();
}

/// Mutable registry base for platform implementations and deterministic tests.
class WalletRegistryController implements WalletRegistry {
  final List<Wallet> _wallets = [];
  final StreamController<WalletRegistryEvent> _events =
      StreamController.broadcast(sync: true);
  bool _disposed = false;

  @override
  List<Wallet> get wallets => List.unmodifiable(_wallets);

  @override
  Stream<WalletRegistryEvent> get events => _events.stream;

  @override
  Future<void> initialize() async {}

  /// Registers [wallet] once and returns an idempotent unregister callback.
  ///
  /// Wallets that share a name with an already-registered wallet are ignored:
  /// extensions can announce themselves more than once through additional
  /// content-script worlds or after a reload, and the picker should show each
  /// wallet a single time. This mirrors wallet-adapter's name-based dedup.
  void Function() register(Wallet wallet) {
    if (_disposed) throw StateError('Wallet registry is disposed');
    if (_wallets.any((existing) => existing.name == wallet.name)) {
      return () {};
    }
    if (_wallets.contains(wallet)) return () {};
    _wallets.add(wallet);
    _events.add(WalletRegistered(wallet));
    var active = true;
    return () {
      if (!active) return;
      active = false;
      unregister(wallet);
    };
  }

  /// Unregisters [wallet] when present.
  void unregister(Wallet wallet) {
    if (_wallets.remove(wallet) && !_disposed) {
      _events.add(WalletUnregistered(wallet));
    }
  }

  /// Reports that a registered wallet changed.
  void changed(Wallet wallet) {
    if (_wallets.contains(wallet) && !_disposed) {
      _events.add(WalletChanged(wallet));
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _wallets.clear();
    await _events.close();
  }
}
