import 'package:solana_kit_jupiter/src/jupiter_config.dart';
import 'package:solana_kit_jupiter/src/price.dart';
import 'package:solana_kit_jupiter/src/swap.dart';
import 'package:solana_kit_jupiter/src/tokens.dart';

/// The Jupiter Exchange client.
///
/// Exposes the Swap API v2, Price API v3, and Token API v2 under one
/// configuration. Create it with [createJupiterClient].
class JupiterClient {
  /// Creates a Jupiter client from a [config].
  JupiterClient({required this.config})
    : swap = JupiterSwapClient(config: config),
      price = JupiterPriceClient(config: config),
      tokens = JupiterTokenClient(config: config);

  /// The configuration this client was created with.
  final JupiterConfig config;

  /// The Swap API v2 sub-client.
  final JupiterSwapClient swap;

  /// The Price API v3 sub-client.
  final JupiterPriceClient price;

  /// The Token API v2 sub-client.
  final JupiterTokenClient tokens;
}

/// Creates a [JupiterClient] for the given [config].
JupiterClient createJupiterClient(JupiterConfig config) =>
    JupiterClient(config: config);
