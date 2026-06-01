import 'package:solana_kit_addresses/solana_kit_addresses.dart';

export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show associatedTokenProgramAddress;

/// Backward-compatible alias for [associatedTokenProgramAddress].
///
/// Many codebases reference the ATA program using the shorter [ataProgramAddress]
/// name. This alias preserves that convention.
const Address ataProgramAddress = associatedTokenProgramAddress;

/// Known instructions for the Associated Token Account program.
enum AssociatedTokenInstruction {
  /// Create an associated token account and fail if it already exists.
  createAssociatedToken,

  /// Create an associated token account or no-op if it already exists.
  createAssociatedTokenIdempotent,

  /// Recover lamports from a nested associated token account.
  recoverNestedAssociatedToken,
}
