// Helper utilities for signup flows.

import 'package:solana_kit_helius/src/auth/developer_api.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Builds the RPC endpoint URLs for a provisioned API key.
///
/// Returns a [SignupEndpoints] with mainnet and devnet URLs.
SignupEndpoints buildEndpoints(String apiKey) => SignupEndpoints(
  mainnet: 'https://mainnet.helius-rpc.com/?api-key=$apiKey',
  devnet: 'https://devnet.helius-rpc.com/?api-key=$apiKey',
);

/// The project's first existing API key and its endpoints, or null for both
/// when the project has no keys. Never creates a key (upstream v4.0.0 #408);
/// callers that need one call [developerCreateApiKey] themselves.
({String? apiKey, SignupEndpoints? endpoints}) existingApiKey(
  DeveloperProjectDetails details,
) {
  final apiKey = details.apiKeys.firstOrNull?.keyId;
  return (
    apiKey: apiKey,
    endpoints: apiKey == null ? null : buildEndpoints(apiKey),
  );
}
