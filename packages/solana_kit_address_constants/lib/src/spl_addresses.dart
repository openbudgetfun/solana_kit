import 'package:solana_kit_address/solana_kit_address.dart';

// ---------------------------------------------------------------------------
// SPL program addresses
// ---------------------------------------------------------------------------
// Well-known addresses for SPL programs that are not part of the Agave
// runtime but are widely used across the Solana ecosystem.

/// The address of the SPL Token program.
const tokenProgramAddress = Address(
  'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
);

/// The address of the SPL Token-2022 (Token Extensions) program.
const token2022ProgramAddress = Address(
  'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
);

/// The address of the SPL Associated Token Account program.
const associatedTokenProgramAddress = Address(
  'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL',
);

/// The address of the Memo program (v3, on-chain memo).
///
/// Matches the upstream `solana-program/memo` Codama IDL `publicKey`.
const memoProgramAddress = Address(
  'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr',
);

/// The address of the legacy Memo program (v1).
///
/// The original Memo program (shank/spl-memo v1) was deployed at
/// `Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo`; later versions moved to
/// the v3 `memoProgramAddress` above.
const memoLegacyProgramAddress = Address(
  'Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo',
);
