/// Program address for the Squads V4 multisig program.
///
/// The generated code exposes an [Address] version of the program address;
/// this file re-declares the raw string form and the [Address] object form
/// in one place for hand-written helpers.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The program address for the Squads V4 multisig program.
///
/// This is the canonical address on mainnet, devnet, and testnet.
const squadsMultisigProgramAddress =
    'SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf';

/// The [Address] representation of the Squads V4 multisig program address.
const squadsMultisigProgramAddressObject = Address(
  squadsMultisigProgramAddress,
);
