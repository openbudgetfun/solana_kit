/// Compressed NFT transfer eligibility check.
///
/// Determines whether a compressed NFT can be transferred based on its
/// ownership and delegation state. An asset cannot be transferred if it
/// is frozen or marked as non-transferable.
library;

/// Checks whether a compressed NFT can be transferred.
///
/// An asset is considered non-transferable if:
/// - It is frozen (the `frozen` flag is `true`), or
/// - It is marked as non-transferable (the `nonTransferable` flag is `true`).
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
///
/// void main() {
///   final canTransferResult = canTransfer(
///     frozen: false,
///     nonTransferable: false,
///   );
///   if (!canTransferResult) {
///     print('This compressed NFT cannot be transferred.');
///   }
/// }
/// ```
///
/// ## Parameters
///
/// - [frozen]: Whether the asset is frozen. Frozen assets cannot be
///   transferred.
/// - [nonTransferable]: Whether the asset is marked as non-transferable.
///   This flag is set by the authority to permanently disable transfers.
///
/// ## Returns
///
/// `true` if the asset can be transferred, `false` otherwise.
bool canTransfer({required bool frozen, required bool nonTransferable}) {
  return !frozen && !nonTransferable;
}
