import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// Minimum signer balance required before publishing (about 0.016 SOL).
///
/// Release NFT minting needs roughly 0.015 SOL in rent plus fees; the buffer
/// ensures the CLI fails before uploading the APK.
const minPublicationSignerBalanceLamports = 16000000;

/// The default mainnet RPC URL used for the balance preflight.
const defaultMainnetRpcUrl = 'https://api.mainnet-beta.solana.com';

/// Resolves the RPC URL used for the balance preflight, or null when the
/// check should be skipped.
String? resolveFundingPreflightRpcUrl({
  required bool localDev,
  String? rpcUrl,
}) {
  final explicitRpcUrl = rpcUrl?.trim();
  if (explicitRpcUrl != null && explicitRpcUrl.isNotEmpty) {
    return explicitRpcUrl;
  }
  if (localDev) {
    return null;
  }
  return defaultMainnetRpcUrl;
}

/// A function that fetches the balance (in lamports) of an address.
typedef BalanceFetcher = Future<int> Function(String address, String rpcUrl);

/// Ensures that the publication signer has enough SOL before the workflow
/// starts, returning a warning message when the check could not be performed.
///
/// Throws when the balance is known and insufficient.
Future<String?> ensurePublicationSignerBalance({
  required String publicKey,
  required bool localDev,
  String? rpcUrl,
  BalanceFetcher? fetchBalance,
}) async {
  final resolvedRpcUrl = resolveFundingPreflightRpcUrl(
    localDev: localDev,
    rpcUrl: rpcUrl,
  );
  if (resolvedRpcUrl == null) {
    return null;
  }

  final Address address;
  try {
    address = Address(publicKey);
    assertIsAddress(publicKey);
  } on Object catch (error) {
    throw PublisherCliException(
      'Invalid signer public key for balance preflight: $publicKey. $error',
    );
  }

  final fetcher = fetchBalance ?? defaultBalanceFetcher;
  try {
    final balanceLamports = await fetcher(address.toString(), resolvedRpcUrl);
    if (balanceLamports < minPublicationSignerBalanceLamports) {
      throw PublisherCliException(
        'Signer $publicKey has ${formatSolAmount(balanceLamports)} SOL, '
        'but publishing needs at least '
        '${formatSolAmount(minPublicationSignerBalanceLamports)} SOL '
        'available before it starts.',
      );
    }
    return null;
  } on PublisherCliException {
    rethrow;
  } on Object catch (error) {
    return 'Unable to confirm the signer balance via $resolvedRpcUrl. '
        'Continuing without a SOL preflight check: $error.';
  }
}

/// Fetches a balance using the default Solana RPC transport.
///
/// [rpc] overrides the RPC instance for tests.
Future<int> defaultBalanceFetcher(
  String address,
  String rpcUrl, {
  Rpc? rpc,
}) async {
  final instance =
      rpc ??
      createSolanaRpc(
        url: rpcUrl,
        allowInsecureHttp: !rpcUrl.startsWith('https://'),
      );
  final response = await instance.getBalance(Address(address)).send();
  return parseLamportsValue(response);
}

/// Parses the `value` field of a `getBalance` RPC response into lamports.
int parseLamportsValue(Map<String, Object?> response) {
  final value = response['value'];
  return switch (value) {
    final int lamports => lamports,
    final num lamports => lamports.toInt(),
    final String lamports => BigInt.parse(lamports).toInt(),
    _ => 0,
  };
}

/// Formats a lamports amount as a SOL decimal string.
String formatSolAmount(int lamports) =>
    (lamports / 1000000000).toStringAsFixed(6);
