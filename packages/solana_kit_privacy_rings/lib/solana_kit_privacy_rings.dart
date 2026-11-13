/// Helius Solana Privacy Rings for Dart.
///
/// Deposit, confidential-transfer, and withdraw instructions are built
/// from the wire format in `helius-labs/privacy-rings`. Confidential
/// notes are decrypted with the X25519 viewing key. The indexer and the
/// remote prover are called over HTTP.
///
/// Poseidon note hashing, owner hashes, nullifier derivation, shielded
/// seed expansion, and the confidential-transfer witness are in this
/// package. A deposit still takes the recipient owner hash and view tag
/// as arguments. A remote prover that is not on loopback is called
/// through an attested session that verifies the AWS Nitro COSE
/// document, or in the clear when the caller sets
/// `allowUnauthenticatedRemoteProver`.
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
export 'package:solana_kit_privacy_rings/src/history.dart';
export 'package:solana_kit_privacy_rings/src/instructions/deposit.dart';
export 'package:solana_kit_privacy_rings/src/instructions/transact.dart';
export 'package:solana_kit_privacy_rings/src/keys/derivation.dart';
export 'package:solana_kit_privacy_rings/src/keys/nullifier.dart';
export 'package:solana_kit_privacy_rings/src/keys/viewing_key.dart';
export 'package:solana_kit_privacy_rings/src/pdas.dart';
export 'package:solana_kit_privacy_rings/src/poseidon/hash.dart';
export 'package:solana_kit_privacy_rings/src/poseidon/poseidon.dart';
export 'package:solana_kit_privacy_rings/src/poseidon/public_input.dart';
export 'package:solana_kit_privacy_rings/src/prover/client.dart';
export 'package:solana_kit_privacy_rings/src/prover/hpke.dart';
export 'package:solana_kit_privacy_rings/src/prover/nitro.dart';
export 'package:solana_kit_privacy_rings/src/prover/p384.dart' show p384Verify;
export 'package:solana_kit_privacy_rings/src/prover/proof.dart';
export 'package:solana_kit_privacy_rings/src/prover/proving_keys.dart';
export 'package:solana_kit_privacy_rings/src/prover/tee_session.dart';
export 'package:solana_kit_privacy_rings/src/prover/witness.dart';
export 'package:solana_kit_privacy_rings/src/redact.dart';
export 'package:solana_kit_privacy_rings/src/rpc/client.dart';
export 'package:solana_kit_privacy_rings/src/rpc/types.dart';
