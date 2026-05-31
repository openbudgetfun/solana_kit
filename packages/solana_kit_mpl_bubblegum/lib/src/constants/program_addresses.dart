/// Well-known Solana program addresses used by mpl-bubblegum.
///
/// These addresses are fixed on all clusters (mainnet, devnet, testnet)
/// and are used by the Bubblegum program and its dependencies.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The SPL Account Compression program address.
///
/// This program manages concurrent Merkle trees used by compressed NFTs.
const splAccountCompressionProgramAddress = Address(
  'cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi',
);

/// The SPL Noop (Log Wrapper) program address.
///
/// This program is used to emit changelogs as CPI instruction data.
const noopProgramAddress = Address(
  'noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK',
);

/// The System program address.
const systemProgramAddress = Address('11111111111111111111111111111111');

/// The SPL Token program address.
const tokenProgramAddress = Address(
  'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
);
