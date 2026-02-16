/// Confirmation tracking for the Solana Kit Dart SDK.
///
/// This package provides utilities for confirming Solana transactions using
/// multiple strategies:
///
/// - **Signature Confirmation** - Watch for a transaction signature to reach
///   a target commitment level.
/// - **Block Height Exceedence** - Detect when a blockhash-based transaction's
///   lifetime has expired.
/// - **Nonce Invalidation** - Detect when a durable nonce has been advanced
///   (transaction expired).
/// - **Timeout** - Simple timeout-based fallback.
/// - **Strategy Racing** - Race multiple strategies to confirm or reject first.
///
/// This is the Dart port of the TypeScript `@solana/transaction-confirmation`
/// package.
library;

export 'src/commitment_comparator.dart';
export 'src/confirmation_strategy_blockheight.dart';
export 'src/confirmation_strategy_nonce.dart';
export 'src/confirmation_strategy_racer.dart';
export 'src/confirmation_strategy_recent_signature.dart';
export 'src/confirmation_strategy_timeout.dart';
export 'src/signature_status.dart';
export 'src/waiters.dart';
