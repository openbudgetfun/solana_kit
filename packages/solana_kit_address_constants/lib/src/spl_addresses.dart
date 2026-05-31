// ignore_for_file: public_member_api_docs

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
  'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25ef7s3c8BnQKu',
);

/// The address of the Memo program (v2, on-chain memo).
const memoProgramAddress = Address(
  'Memo1UhkJ4AsZNBm8hWoQeYfRDfaK9K7a8Kj9vOUdhM7Q',
);

/// The address of the legacy Memo program (v1).
const memoLegacyProgramAddress = Address(
  'MemoSq4gqABb5KBAsS3tQ9UJMKg7hXe3LF7tu4RssKE3',
);
