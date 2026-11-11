import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Shielded-pool program.
///
/// Source: Helius docs
/// <https://www.helius.dev/docs/privacy/addresses> and
/// `SHIELDED_POOL_PROGRAM_ID` in
/// `helius-labs/privacy-rings` `program-libs/interface/src/lib.rs`.
const shieldedPoolProgramId = Address(
  'ring1GaLCuJnkUMVkX2JeZLTTX17wKsV4fZmPVzXANW',
);

/// User registry program. Same source as [shieldedPoolProgramId].
const userRegistryProgramId = Address(
  'regy3WAeRXMYuMYxr5iK3Bf9Arr3PcxGxyzAddbiqDQ',
);

/// Permissionless state Merkle tree deployed on mainnet and devnet.
///
/// Source: <https://www.helius.dev/docs/privacy/addresses>.
const stateMerkleTree = Address(
  '777pvSGe5LaBd9nCczvE2FXEauiwtfGJ5XRpjKyniGor',
);

/// Native SOL interface PDA.
///
/// `find_program_address(&[b"sol_interface", &[0]], shielded pool)`.
/// Pinned in `SOL_INTERFACE` in `program-libs/interface/src/lib.rs`.
const solInterfaceAddress = Address(
  'CiNmas621VuyofiDSrEPfTXHKrdZuB6jMKECyNiMpLXE',
);

/// Bump of [solInterfaceAddress]. Pinned as `SOL_INTERFACE_BUMP`.
const solInterfaceBump = 248;

/// Shielded-pool CPI authority PDA.
///
/// Pinned as `SHIELDED_POOL_CPI_AUTHORITY` in
/// `program-libs/interface/src/lib.rs`.
const shieldedPoolCpiAuthority = Address(
  'CaM8DbtJ2mSecgaHYo9xeT7VSKq7AnaqEUm5p7e5LW4a',
);

/// `deposit` instruction tag. `InstructionTag.deposit` in
/// `sdk-libs/ts/src/interface/program.ts`.
const depositInstructionTag = 15;

/// `transact` instruction tag. `InstructionTag.transact` in the same file.
const transactInstructionTag = 16;

/// Distinct assets one deposit batch may settle. `MAX_DEPOSIT_ASSETS`.
const maxDepositAssets = 5;

/// Wire limit on deposit entries (`u8` length prefix).
const maxDepositEntries = 255;

/// Asset id of native SOL. `SOL_ASSET_ID` in
/// `sdk-libs/ts/src/transaction/asset.ts`.
final BigInt solAssetId = BigInt.one;

/// Mint address the protocol uses for native SOL: the all-zero pubkey.
///
/// `SOL_MINT` in `sdk-libs/ts/src/transaction/asset.ts`.
const Address solMint = systemProgramAddress;

/// Confidential output scheme byte. `EncryptedScheme.confidential`.
const confidentialScheme = 3;

/// Ring confidential output scheme byte. `EncryptedScheme.ringConfidential`.
///
/// It uses the same transfer cipher as [confidentialScheme].
const ringConfidentialScheme = 4;

/// Proofless (deposit) output scheme byte. `EncryptedScheme.proofless`.
const prooflessScheme = 0;

/// Encrypted output-data encoding tag.
const encryptedEncoding = 1;

/// Plaintext output-data encoding tag.
const plaintextEncoding = 0;

/// PDA seed `b"sol_interface"`.
const solInterfaceSeed = 'sol_interface';

/// PDA seed `b"spl_asset_vault"` (historical bytes, SPL interface name).
const splInterfaceSeed = 'spl_asset_vault';

/// PDA seed `b"nullifier"`.
const nullifierSeed = 'nullifier';

/// Owners one `getUserRecords` request may name.
///
/// `MAX_USER_RECORD_OWNERS` in
/// `sdk-libs/ts/src/interface/indexer-limits.ts`.
const maxUserRecordOwners = 100;

/// BN254 base-field modulus used to compress Groth16 G1 points.
///
/// `BN254_BASE_MODULUS` in `sdk-libs/ts/src/client/prover/proof.ts`.
final BigInt bn254BaseModulus = BigInt.parse(
  '21888242871839275222246405745257275088696311157297823662689037894645226208583',
);
