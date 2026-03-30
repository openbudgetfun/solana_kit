import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Optional configuration for fetching accounts.
class FetchAccountConfig {
  /// Creates a new [FetchAccountConfig].
  const FetchAccountConfig({this.commitment, this.minContextSlot});

  /// Fetch the details of the account as of the highest slot that has reached
  /// this level of commitment.
  final Commitment? commitment;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;
}
