// ignore_for_file: public_member_api_docs

import 'package:solana_kit_address/solana_kit_address.dart';

// ---------------------------------------------------------------------------
// Metaplex program addresses
// ---------------------------------------------------------------------------
// Well-known addresses for Metaplex programs used across the Solana NFT
// ecosystem.

/// The address of the Metaplex Token Metadata program.
const tokenMetadataProgramAddress = Address(
  'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',
);

/// The address of the Metaplex Bubblegum (v1) program.
const mplBubblegumProgramAddress = Address(
  'BGUMAp9Gph7G9Jn2tU58R5L2qPG1Mj9HP7G3G7VYV2Ma',
);

/// The address of the Metaplex Token Auth Rules program.
const mplTokenAuthRulesProgramAddress = Address(
  'auth9SigNpDKz4sJJ1DfCTuZrZNSAgh9sFD3rboVmgg',
);

/// The address of the Metaplex Core program.
const mplCoreProgramAddress = Address(
  'CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d',
);

/// The address of the SPL Account Compression program.
const splAccountCompressionProgramAddress = Address(
  'cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi',
);

/// The address of the Noop (Log Wrapper) program.
///
/// Used alongside the SPL Account Compression program for proof verification.
const noopProgramAddress = Address(
  'noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK',
);
