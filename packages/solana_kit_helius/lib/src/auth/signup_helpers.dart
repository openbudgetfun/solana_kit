/// Helper utilities for signup flows, matching upstream v3.0.0.

import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Builds the RPC endpoint URLs for a provisioned API key.
///
/// Returns a [SignupEndpoints] with mainnet and devnet URLs.
SignupEndpoints buildEndpoints(String apiKey) => SignupEndpoints(
      mainnet: 'https://mainnet.helius-rpc.com/?api-key=$apiKey',
      devnet: 'https://devnet.helius-rpc.com/?api-key=$apiKey',
    );
