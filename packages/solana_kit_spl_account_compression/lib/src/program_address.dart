/// SPL Account Compression Program address.
///
/// The program ID for the SPL Account Compression program:
/// `cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi`.
///
/// This constant is used as the default program address in instruction builders
/// and PDA derivation. It can be overridden for testing via config classes.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The program address for the SPL Account Compression program.
///
/// This is the canonical address on mainnet, devnet, and testnet.
const splAccountCompressionProgramAddress =
    'cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi';

/// The [Address] representation of the SPL Account Compression program address.
const splAccountCompressionProgramAddressObject = Address(
  splAccountCompressionProgramAddress,
);

/// The program ID for the Noop/Log Wrapper program.
///
/// Used alongside the Account Compression program for proof verification.
const noopProgramAddress = 'noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK';

/// The [Address] representation of the Noop program address.
const noopProgramAddressObject = Address(noopProgramAddress);
