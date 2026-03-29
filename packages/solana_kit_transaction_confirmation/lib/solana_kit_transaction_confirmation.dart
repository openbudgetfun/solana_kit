/// Confirmation tracking for the Solana Kit Dart SDK.
///
/// This package provides utilities for confirming Solana transactions using
/// multiple strategies such as signature tracking, block-height expiry,
/// durable-nonce invalidation, timeouts, and additive polling helpers.
///
/// This is the Dart port of the TypeScript `@solana/transaction-confirmation`
/// package.
///
/// <!-- {=docsSendAndConfirmSection} -->
///
/// ## Send and confirm a signed transaction
///
/// Once you have a signed `Transaction`, use the additive confirmation helper for
/// an end-to-end “send then wait for confirmation” flow.
///
/// ```dart
/// import 'package:solana_kit/solana_kit.dart';
/// import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
///
/// Future<void> sendAndWait(
///   Rpc rpc,
///   Transaction signedTransaction,
/// ) async {
///   final signature = await sendAndConfirmTransaction(
///     rpc: rpc,
///     transaction: signedTransaction,
///   );
///
///   print('Confirmed signature: ${signature.value}');
/// }
/// ```
///
/// For lower-level control, `solana_kit_transaction_confirmation` also exposes
/// strategy factories for block-height expiry, durable nonce invalidation,
/// signature notifications, and timeout racing.
///
/// <!-- {/docsSendAndConfirmSection} -->
library;

export 'src/commitment_comparator.dart';
export 'src/confirmation_strategy_blockheight.dart';
export 'src/confirmation_strategy_nonce.dart';
export 'src/confirmation_strategy_racer.dart';
export 'src/confirmation_strategy_recent_signature.dart';
export 'src/confirmation_strategy_timeout.dart';
export 'src/rpc_confirmation.dart';
export 'src/signature_status.dart';
export 'src/waiters.dart';
