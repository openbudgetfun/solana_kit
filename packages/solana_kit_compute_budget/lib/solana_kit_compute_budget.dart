/// Compute Budget program client for the Solana Kit Dart SDK.
///
/// Provides instruction builders and codecs for the Compute Budget program,
/// which controls compute unit limits, priority fees, heap size, and loaded
/// accounts data size.
///
/// ## Quick start
///
/// ```dart
/// import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
///
/// // Set compute unit limit
/// final limitIx = getSetComputeUnitLimitInstruction(units: 200000);
///
/// // Set priority fee
/// final priceIx = getSetComputeUnitPriceInstruction(
///   microLamports: BigInt.from(50000),
/// );
/// ```
library;

export 'src/generated/compute_budget.dart';
