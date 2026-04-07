import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The canonical Associated Token Account program address.
const ataProgramAddress = Address(
  'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8bSe',
);

/// Backwards-compatible alias for [ataProgramAddress].
const associatedTokenProgramAddress = ataProgramAddress;

/// Known instructions for the Associated Token Account program.
enum AssociatedTokenInstruction {
  /// Create an associated token account and fail if it already exists.
  createAssociatedToken,

  /// Create an associated token account or no-op if it already exists.
  createAssociatedTokenIdempotent,

  /// Recover lamports from a nested associated token account.
  recoverNestedAssociatedToken,
}
