import 'package:solana_kit_address/solana_kit_address.dart';

// ---------------------------------------------------------------------------
// SPL program addresses
// ---------------------------------------------------------------------------
// Well-known addresses for SPL programs that are not part of the Agave
// runtime but are widely used across the Solana ecosystem.
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

/// The address of the Memo program (v4, on-chain memo).
///
/// Matches the upstream `solana-program/memo` Codama IDL `publicKey` as of
/// `js@v0.14.0`, which pointed the clients at the v4 program.
const memoProgramAddress = Address(
  'Memo4c2pN8afCj432Lb7RMVKi9PbQnnW7ewFFaV3oAH',
);

/// The address of the legacy Memo program (v1).
///
/// The original Memo program (shank/spl-memo v1) was deployed at
/// `Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo`; later versions moved to
/// the v3 and then the v4 `memoProgramAddress` above. Use
/// [memoProgramAddress] when building new memo instructions.
const memoLegacyProgramAddress = Address(
  'Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo',
);

/// The address of the legacy Memo program (v3).
///
/// The v3 program was deployed at `MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr`
/// and was the address this SDK exposed as [memoProgramAddress] before the v4
/// program shipped. It is kept here for reading memos emitted by older
/// transactions; use [memoProgramAddress] when building new memo instructions.
const memoLegacyProgramAddressV3 = Address(
  'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr',
);
