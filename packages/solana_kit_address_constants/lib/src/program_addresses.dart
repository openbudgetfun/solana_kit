// ignore_for_file: public_member_api_docs

import 'package:solana_kit_address/solana_kit_address.dart';

// ---------------------------------------------------------------------------
// Agave / Solana native program addresses
// ---------------------------------------------------------------------------
// Sourced from the solana-sdk-ids crate (https://docs.rs/crate/solana-sdk-ids)
// and the official Solana documentation.

/// The address of the System program.
const systemProgramAddress = Address('11111111111111111111111111111111');

/// The address of the Address Lookup Table program.
const addressLookupTableProgramAddress = Address(
  'AddressLookupTab1e1111111111111111111111111',
);

/// The address of the BPF Loader program (v2).
const bpfLoaderProgramAddress = Address(
  'BPFLoader2111111111111111111111111111111111',
);

/// The address of the deprecated BPF Loader program (v1).
const bpfLoaderDeprecatedProgramAddress = Address(
  'BPFLoader1111111111111111111111111111111111',
);

/// The address of the Upgradeable BPF Loader program.
const bpfLoaderUpgradeableProgramAddress = Address(
  'BPFLoaderUpgradeab1e11111111111111111111111',
);

/// The address of the Compute Budget program.
const computeBudgetProgramAddress = Address(
  'ComputeBudget111111111111111111111111111111',
);

/// The address of the Config program.
const configProgramAddress = Address(
  'Config1111111111111111111111111111111111111',
);

/// The address of the Ed25519 signature verification (precompiled) program.
const ed25519ProgramAddress = Address(
  'Ed25519SigVerify111111111111111111111111111',
);

/// The address of the Feature Gate program.
const featureProgramAddress = Address(
  'Feature111111111111111111111111111111111111',
);

/// The address of the Incinerator account.
///
/// Lamports credited to this address are removed from the total supply
/// (burned) at the end of the current block.
const incineratorAddress = Address(
  '1nc1nerator11111111111111111111111111111111',
);

/// The address of the Loader V4 program.
const loaderV4ProgramAddress = Address(
  'LoaderV411111111111111111111111111111111111',
);

/// The address of the Native Loader program.
const nativeLoaderProgramAddress = Address(
  'NativeLoader1111111111111111111111111111',
);

/// The address of the Secp256k1 signature verification (precompiled) program.
const secp256k1ProgramAddress = Address(
  'KeccakSecp256k11111111111111111111111111111',
);

/// The address of the Secp256r1 signature verification (precompiled) program.
const secp256r1ProgramAddress = Address(
  'Secp256r1SigVerify1111111111111111111111111',
);

/// The address of the Stake program.
const stakeProgramAddress = Address(
  'Stake11111111111111111111111111111111111111',
);

/// The address of the Stake Config program.
const stakeConfigAddress = Address('StakeConfig1111111111111111111111111111');

/// The address of the Vote program.
const voteProgramAddress = Address(
  'Vote111111111111111111111111111111111111111',
);

/// The address of the ZK Token Proof program.
const zkTokenProofProgramAddress = Address(
  'ZkTokenProof1111111111111111111111111111111',
);

/// The address of the ZK ElGamal Proof program.
const zkElgamalProofProgramAddress = Address(
  'ZkE1Gama1Proof11111111111111111111111111111',
);
