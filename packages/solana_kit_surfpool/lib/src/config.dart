import 'dart:collection';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Surfpool block production mode.
enum BlockProductionMode {
  /// Blocks advance only when the runtime is manually advanced.
  manual,

  /// Blocks advance on a fixed clock interval.
  clock,

  /// Blocks advance after each transaction.
  transaction;

  /// Value expected by the `surfpool start --block-production-mode` flag.
  String get cliValue => name;
}

/// Configuration used when starting a Surfnet.
///
/// The defaults mirror the upstream Surfpool SDK defaults: offline mode,
/// transaction-mode block production, 1 ms slots, and a random payer funded
/// with 10 SOL (`10_000_000_000` lamports).
@immutable
class SurfnetConfig {
  /// Creates a Surfnet configuration.
  SurfnetConfig({
    this.offline = true,
    this.remoteRpcUrl,
    this.blockProductionMode = BlockProductionMode.transaction,
    this.slotTimeMs = 1,
    this.airdropSol = 10_000_000_000,
    Iterable<Address> airdropAddresses = const [],
    Uint8List? payerSecretKey,
    Iterable<Address> enableFeatures = const [],
    Iterable<Address> disableFeatures = const [],
    this.allFeatures = false,
    this.skipBlockhashCheck = false,
    this.host = '127.0.0.1',
    this.rpcPort,
    this.wsPort,
  }) : _airdropAddresses = List<Address>.unmodifiable(airdropAddresses),
       _payerSecretKey = payerSecretKey == null
           ? null
           : Uint8List.fromList(payerSecretKey),
       _enableFeatures = List<Address>.unmodifiable(enableFeatures),
       _disableFeatures = List<Address>.unmodifiable(disableFeatures) {
    if (slotTimeMs <= 0) {
      throw ArgumentError.value(slotTimeMs, 'slotTimeMs', 'must be positive');
    }
    if (airdropSol < 0) {
      throw ArgumentError.value(
        airdropSol,
        'airdropSol',
        'must be non-negative',
      );
    }
    _validatePort(rpcPort, 'rpcPort');
    _validatePort(wsPort, 'wsPort');
    if (rpcPort != null && rpcPort == wsPort) {
      throw ArgumentError.value(wsPort, 'wsPort', 'must differ from rpcPort');
    }
  }

  /// Whether to run without an upstream RPC endpoint.
  ///
  /// Supplying [remoteRpcUrl] takes precedence and starts a forked Surfnet even
  /// when this value is left at its default `true`.
  final bool offline;

  /// Optional upstream RPC URL used for mainnet-forked tests.
  final Uri? remoteRpcUrl;

  /// How blocks are produced by the local Surfnet.
  final BlockProductionMode blockProductionMode;

  /// Slot duration in milliseconds for clock-mode block production.
  final int slotTimeMs;

  /// Lamports to airdrop to the payer and each configured airdrop address.
  ///
  /// This follows the upstream SDK field name even though the value is lamports,
  /// not whole SOL.
  final int airdropSol;

  /// Alias for [airdropSol] that names the unit explicitly.
  int get airdropLamports => airdropSol;

  /// Additional addresses funded at startup.
  UnmodifiableListView<Address> get airdropAddresses {
    return UnmodifiableListView(_airdropAddresses);
  }

  final List<Address> _airdropAddresses;

  /// Optional 64-byte payer secret key in Solana CLI keypair format.
  Uint8List? get payerSecretKey {
    final payerSecretKey = _payerSecretKey;
    if (payerSecretKey == null) return null;
    return Uint8List.fromList(payerSecretKey);
  }

  final Uint8List? _payerSecretKey;

  /// Feature gates to enable at startup.
  UnmodifiableListView<Address> get enableFeatures {
    return UnmodifiableListView(_enableFeatures);
  }

  final List<Address> _enableFeatures;

  /// Feature gates to disable at startup.
  UnmodifiableListView<Address> get disableFeatures {
    return UnmodifiableListView(_disableFeatures);
  }

  final List<Address> _disableFeatures;

  /// Whether to enable every known SVM feature gate.
  final bool allFeatures;

  /// Whether the runtime should skip transaction blockhash validation.
  final bool skipBlockhashCheck;

  /// Host interface for the CLI-backed Surfnet.
  final String host;

  /// Optional fixed HTTP RPC port.
  final int? rpcPort;

  /// Optional fixed WebSocket RPC port.
  final int? wsPort;
}

void _validatePort(int? port, String name) {
  if (port == null) return;
  if (port <= 0 || port > 65535) {
    throw ArgumentError.value(port, name, 'must be between 1 and 65535');
  }
}
