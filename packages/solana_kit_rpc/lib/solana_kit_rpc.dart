/// Primary RPC client for the Solana Kit Dart SDK.
///
/// This package provides the high-level factory functions for creating Solana
/// RPC clients. It combines transport, API, and transformers into a cohesive
/// RPC client interface.
///
/// Unless you plan to create a custom RPC interface, you can use
/// `createSolanaRpc` to obtain a default implementation of the
/// [Solana JSON RPC API](https://solana.com/docs/rpc/http).
///
/// <!-- {=docsCreateRpcClientSection} -->
///
/// ## Create an RPC client
///
/// Start with a typed RPC client. It gives you method-specific helpers instead of
/// building raw JSON-RPC requests by hand, while still letting you swap transports
/// or request middleware later.
///
/// ```dart
/// import 'package:solana_kit/solana_kit.dart';
///
/// Future<void> main() async {
///   final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
///
///   final slot = await rpc.getSlot().send();
///   final latestBlockhash = await rpc.getLatestBlockhashValue().send();
///
///   print('Current slot: $slot');
///   print('Latest blockhash: ${latestBlockhash.value.blockhash}');
/// }
/// ```
///
/// A call like `rpc.getSlot()` builds a typed request first and only hits the
/// network when you call `.send()`. That separation makes it easier to compose,
/// cache, batch, or decorate RPC interactions.
///
/// Use `solana_kit_rpc_subscriptions` alongside `solana_kit_rpc` when you also
/// need websocket notifications for accounts, signatures, logs, or slots.
///
/// <!-- {/docsCreateRpcClientSection} -->
///
/// <!-- {=typedRpcMethodsSection|replace:"__RPC_IMPORT_PATH__":"package:solana_kit_rpc/solana_kit_rpc.dart"|replace:"__RPC_URL__":"https://api.devnet.solana.com"} -->
///
/// ### Typed RPC methods
///
/// When you already have an `Rpc`, prefer typed convenience helpers over raw
/// method-name strings. They keep parameter builders and response models attached
/// to the method itself, which makes refactors and autocomplete significantly
/// safer.
///
/// ```dart
/// import 'package:solana_kit_rpc/solana_kit_rpc.dart';
///
/// Future<void> main() async {
///   final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
///
///   final slot = await rpc.getSlot().send();
///   final epochInfo = await rpc.getEpochInfo().send();
///   final latestBlockhash = await rpc.getLatestBlockhashValue().send();
///
///   print('Slot: $slot');
///   print('Epoch: ${epochInfo['epoch']}');
///   print('Latest blockhash: ${latestBlockhash.value.blockhash}');
/// }
/// ```
///
/// These helpers forward to canonical request builders in `solana_kit_rpc_api`,
/// return lazy `PendingRpcRequest<T>` values, and make it clear which Solana RPC
/// shape each call expects.
///
/// <!-- {/typedRpcMethodsSection} -->
///
/// <!-- {=preferredDartPathCalloutSection|replace:"__PREFERRED_PATH__":"Start with `createSolanaRpc(...)` plus typed request helpers like `rpc.getSlot()` and `rpc.getLatestBlockhashValue()` before reaching for raw JSON-RPC method names."|replace:"__ESCAPE_HATCH_GUIDANCE__":"Use raw `rpc.request(...)` only when you need an upstream surface that has not yet been wrapped or when you are validating parity behavior."} -->
///
/// > **Preferred Dart path**
/// >
/// > **PREFERRED_PATH**
/// >
/// > **ESCAPE_HATCH_GUIDANCE**
///
/// <!-- {/preferredDartPathCalloutSection} -->
library;

export 'src/rpc.dart';
export 'src/rpc_default_config.dart';
export 'src/rpc_integer_overflow_error.dart';
export 'src/rpc_methods.dart';
export 'src/rpc_request_coalescer.dart';
export 'src/rpc_request_deduplication.dart';
export 'src/rpc_transport.dart';
