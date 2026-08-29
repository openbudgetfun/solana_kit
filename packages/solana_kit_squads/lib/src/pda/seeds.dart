/// Shared PDA seed constants for the Squads V4 multisig program.
///
/// These constants are an implementation detail of the PDA derivations in
/// this package and are not exported from the package barrel. They mirror
/// the seed bytes used by the upstream TypeScript SDK
/// (`@sqds/multisig`, `sdk/multisig/src/pda.ts`) and the Rust
/// `squads-client` crate exactly.
library;

import 'dart:convert';
import 'dart:typed_data';

/// UTF-8 bytes of `'multisig'`, the seed prefix used by every Squads PDA.
final Uint8List multisigSeedPrefix = _utf8Bytes('multisig');

/// UTF-8 bytes of `'program_config'`, the seed for the program config PDA.
final Uint8List programConfigSeed = _utf8Bytes('program_config');

/// UTF-8 bytes of `'multisig'`, the seed between the prefix and the create
/// key when deriving a multisig PDA.
final Uint8List multisigSeed = _utf8Bytes('multisig');

/// UTF-8 bytes of `'vault'`, the vault seed.
final Uint8List vaultSeed = _utf8Bytes('vault');

/// UTF-8 bytes of `'transaction'`, the transaction seed, also used when
/// deriving proposal and batch transaction PDAs.
final Uint8List transactionSeed = _utf8Bytes('transaction');

/// UTF-8 bytes of `'proposal'`, the trailing proposal seed.
final Uint8List proposalSeed = _utf8Bytes('proposal');

/// UTF-8 bytes of `'batch_transaction'`, the batch transaction seed.
final Uint8List batchTransactionSeed = _utf8Bytes('batch_transaction');

/// UTF-8 bytes of `'ephemeral_signer'`, the ephemeral signer seed.
final Uint8List ephemeralSignerSeed = _utf8Bytes('ephemeral_signer');

/// UTF-8 bytes of `'spending_limit'`, the spending limit seed.
final Uint8List spendingLimitSeed = _utf8Bytes('spending_limit');

Uint8List _utf8Bytes(String value) => Uint8List.fromList(utf8.encode(value));
