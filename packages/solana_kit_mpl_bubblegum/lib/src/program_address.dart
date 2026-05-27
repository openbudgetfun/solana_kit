/// Program addresses for the mpl-bubblegum and related programs.
///
/// The Bubblegum program ID constant and related program addresses used
/// throughout this package.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The program address for the mpl-bubblegum program.
///
/// This is the canonical address on mainnet, devnet, and testnet.
const mplBubblegumProgramAddress =
    'BGUMAp9Gph7G9Jn2tU58R5L2qPG1Mj9HP7G3G7VYV2Ma';

/// The [Address] representation of the mpl-bubblegum program address.
const mplBubblegumProgramAddressObject = const Address(
  mplBubblegumProgramAddress,
);

/// The program address for the SPL Token Metadata program.
///
/// Required for V2 mint instructions that attach metadata to compressed NFTs.
const tokenMetadataProgramAddress =
    'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s';

/// The [Address] representation of the Token Metadata program address.
const tokenMetadataProgramAddressObject = const Address(
  tokenMetadataProgramAddress,
);
