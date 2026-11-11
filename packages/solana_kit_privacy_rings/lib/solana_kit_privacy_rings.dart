/// Helius Solana Privacy Rings for Dart.
///
/// Deposit, confidential-transfer, and withdraw instructions are built
/// from the wire format in `helius-labs/privacy-rings`. Confidential
/// notes are decrypted with the X25519 viewing key. The indexer and the
/// remote prover are called over HTTP.
///
/// Poseidon note hashing, `owner_hash`, nullifier derivation, and circuit
/// witness assembly are not in this package. A deposit takes the
/// recipient `owner_hash` and view tag as arguments. A transfer or
/// withdrawal takes a `TransactInstructionData` whose proof comes from
/// `PrivacyProverClient`, which posts a witness the caller built.
library;

export 'package:solana_kit_privacy_rings/src/balance.dart';
export 'package:solana_kit_privacy_rings/src/client.dart';
export 'package:solana_kit_privacy_rings/src/codec/blinding.dart';
export 'package:solana_kit_privacy_rings/src/codec/deposit.dart';
export 'package:solana_kit_privacy_rings/src/codec/output.dart';
export 'package:solana_kit_privacy_rings/src/codec/transact.dart';
export 'package:solana_kit_privacy_rings/src/constants.dart';
export 'package:solana_kit_privacy_rings/src/endpoints.dart';
export 'package:solana_kit_privacy_rings/src/exception.dart';
export 'package:solana_kit_privacy_rings/src/instructions/deposit.dart';
export 'package:solana_kit_privacy_rings/src/instructions/transact.dart';
export 'package:solana_kit_privacy_rings/src/keys/viewing_key.dart';
export 'package:solana_kit_privacy_rings/src/pdas.dart';
export 'package:solana_kit_privacy_rings/src/prover/client.dart';
export 'package:solana_kit_privacy_rings/src/prover/proof.dart';
export 'package:solana_kit_privacy_rings/src/prover/proving_keys.dart';
export 'package:solana_kit_privacy_rings/src/redact.dart';
export 'package:solana_kit_privacy_rings/src/rpc/client.dart';
export 'package:solana_kit_privacy_rings/src/rpc/types.dart';
