/// Well-known Solana program addresses used by mpl-bubblegum.
///
/// These addresses are fixed on all clusters (mainnet, devnet, testnet)
/// and are used by the Bubblegum program and its dependencies.
///
/// The program addresses are re-exported from [solana_kit_addresses] to
/// provide a single source of truth across the workspace.
library;

export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show
        noopProgramAddress,
        splAccountCompressionProgramAddress,
        systemProgramAddress,
        tokenProgramAddress;
