/// Jupiter Exchange client for Solana Kit Dart.
///
/// Provides typed clients for Jupiter's Swap API v2 (quote, assembled
/// transaction, execution, and raw build), Price API v3, and Token API v2,
/// plus helpers for decoding the returned base64 wire transactions with
/// Solana Kit primitives.
///
/// ## Key features
///
/// - **Swap API v2** — request quotes and assembled v0 transactions, submit
///   signed transactions for managed execution, or fetch the raw
///   instruction set for self-landing swaps
/// - **Price API v3** — USD prices for up to fifty mints per request
/// - **Token API v2** — search, tag, category, and recent token metadata
/// - **Transaction decode** — turn base64 order transactions into typed
///   `Transaction` objects for inspection and signing
/// - **Injectable transport** — pass a custom HTTP client via
///   [JupiterConfig] for tests and custom middleware
///
/// The managed order/execute path returns a base64 transaction; sign it with
/// Solana Kit signers and submit it through [JupiterSwapClient.executeOrder].
/// The Trigger API, Limit Orders v1, DCA v1, Referral program on-chain
/// derivation, Lend, Prediction, and Studio surfaces are outside v1 scope.
///
/// Errors.
///
/// <!-- {=docsJupiterSwapSection} -->
///
/// ### Swap through Jupiter's managed order flow
///
/// `/order` returns a quote plus an assembled v0 transaction; sign it with Solana Kit signers and submit it through `/execute`.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_jupiter/solana_kit_jupiter.dart';
///
/// Future<void> main() async {
///   const solAddress = Address('So11111111111111111111111111111111111111112');
///   const usdcAddress = Address(
///     'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
///   );
///
///   final jupiter = createJupiterClient(JupiterConfig(apiKey: 'your-api-key'));
///
///   final order = await jupiter.swap.getOrder(
///     JupiterOrderRequest(
///       inputMint: solAddress,
///       outputMint: usdcAddress,
///       amount: BigInt.from(10000000), // 0.01 SOL
///       slippageBps: 50,
///     ),
///   );
///
///   final transaction = decodeBase64SwapTransaction(order.encodedTransaction!);
///   // Inspect, sign the transaction with solana_kit_signers, then submit it.
///   print(transaction);
/// }
/// ```
///
/// For self-landing swaps, use `jupiter.swap.buildSwap(...)` to fetch the raw instruction set instead of the assembled transaction.
///
/// <!-- {/docsJupiterSwapSection} -->
/// <!-- {=docsJupiterSwapSection -->
///
/// ### Swap through Jupiter's managed order flow
///
/// `/order` returns a quote plus an assembled v0 transaction; sign it with Solana Kit signers and submit it through `/execute`.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_jupiter/solana_kit_jupiter.dart';
///
/// Future<void> main() async {
///   const solAddress = Address('So11111111111111111111111111111111111111112');
///   const usdcAddress = Address(
///     'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
///   );
///
///   final jupiter = createJupiterClient(JupiterConfig(apiKey: 'your-api-key'));
///
///   final order = await jupiter.swap.getOrder(
///     JupiterOrderRequest(
///       inputMint: solAddress,
///       outputMint: usdcAddress,
///       amount: BigInt.from(10000000), // 0.01 SOL
///       slippageBps: 50,
///     ),
///   );
///
///   final transaction = decodeBase64SwapTransaction(order.encodedTransaction!);
///   // Inspect, sign the transaction with solana_kit_signers, then submit it.
///   print(transaction);
/// }
/// ```
///
/// For self-landing swaps, use `jupiter.swap.buildSwap(...)` to fetch the raw instruction set instead of the assembled transaction.
///
/// <!-- {/docsJupiterSwapSection -->

library;
///
// ignore_for_file: comment_references
///
export 'src/internal/rest_client.dart' show JupiterException;

// Client façade.
export 'src/jupiter_client.dart';

// Configuration.
export 'src/jupiter_config.dart';

// Models.
export 'src/models/build.dart';
export 'src/models/order.dart';
export 'src/models/price_and_tokens.dart';

// Sub-clients.
export 'src/price.dart';
export 'src/swap.dart';
export 'src/tokens.dart';
